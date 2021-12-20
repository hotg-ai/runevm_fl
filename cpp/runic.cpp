//
//  runic.cpp
//  runic
//
//  Created by Kartik Thakore on 1/2/21.
//

#include <array>
#include <string>
#include <unordered_set>
#include <iostream>
#include <iomanip>
#include <thread>
#include <vector>


#include <fmt/format.h>
#include <nlohmann/json.hpp>
#include <rune_vm/RuneVm.hpp>

#include "runic.hpp"

template <>
struct fmt::formatter<rune_vm::capabilities::Parameter> : fmt::formatter<std::string> {
    template <typename FormatContext>
    auto format(const rune_vm::capabilities::Parameter& param, FormatContext& ctx) {
        return std::visit(
            [&ctx](const auto& parameter) {
                return format_to(ctx.out(), "{}", parameter);
            },
            param.m_data);

    }
};

static std::vector<std::string> logs;

std::vector<std::string> getLogs() noexcept {
    return logs;
}


namespace {
    

    struct StdoutLogger : public rune_vm::ILogger {
        
        
        
        void log(
            const rune_vm::Severity severity,
            const std::string& module,
            const std::string& message) const noexcept final {
                logs.push_back(fmt::format("{}@@{}@@{}\n", rune_vm::severityToString(severity), module, message));
                std::cout << fmt::format(" {}@[{}]: {}\n", rune_vm::severityToString(severity), module, message);
        }
    };

    struct AllInOneDelegate : public rune_vm::capabilities::IDelegate {
        AllInOneDelegate(const rune_vm::ILogger::CPtr& logger)
            : m_log(logger, "AllInOneDelegate")
            , m_supportedCapabilities(g_supportedCapabilities.begin(), g_supportedCapabilities.end())
            , m_currentSource(0){}
        
        void setInput(const std::vector<uint8_t*>& data, const std::vector<uint32_t>& lengths) noexcept {
            if (data.size() != lengths.size()) {
                return;
            }

            m_inputs.clear();
            for(size_t i = 0; i < data.size(); i++) {
                m_inputs.push_back(rune_vm::DataView<const uint8_t>(data[i], lengths[i]));
            }
        }
        
    private:
        static constexpr auto g_supportedCapabilities = std::array{
            rune_vm::capabilities::Capability::Sound,
            rune_vm::capabilities::Capability::Accel,
            rune_vm::capabilities::Capability::Image,
            rune_vm::capabilities::Capability::Raw};
        
        // rune_vm::capabilities::IDelegate
        [[nodiscard]] TCapabilitiesSet getSupportedCapabilities() const noexcept final {
            return m_supportedCapabilities;
        }
        
        [[nodiscard]] bool requestCapability(
                                             const rune_vm::TRuneId runeId,
                                             const rune_vm::capabilities::Capability capability,
            const rune_vm::capabilities::TId newCapabilityId) noexcept final {
            m_log.log(
                rune_vm::Severity::Info,
                fmt::format("requestCapability capability={} id={}", capability, newCapabilityId));
            if(m_supportedCapabilities.count(capability) == 0) {
                m_log.log(
                    rune_vm::Severity::Error,
                    fmt::format("Requesting capability which is not supported={}", capability));
                return false;
            }
            
            m_log.log(
                rune_vm::Severity::Info,
                fmt::format("New capability={} allocated with id={}", capability, newCapabilityId));
            return true;
        }
        
        [[nodiscard]] bool requestCapabilityParamChange(
            const rune_vm::TRuneId runeId,
            const rune_vm::capabilities::TId capabilityId,
            const rune_vm::capabilities::TKey& key,
            const rune_vm::capabilities::Parameter& parameter) noexcept final {
            // TODO: print param
            m_log.log(
                rune_vm::Severity::Info,
                fmt::format(
                    "requestCapabilityParamChange id={} key={}",
                    capabilityId,
                    key));

            if(key == "source") {
                // check if param type is expected
                if(!std::holds_alternative<int32_t>(parameter.m_data))
                    return false;

                const auto& source = std::get<int32_t>(parameter.m_data);

                if(source < 0 || source >= m_inputs.size())
                    return false;

                m_currentSource = source;
                return true;
            }
            return true;
        }
        
        [[nodiscard]] bool requestRuneInputFromCapability(
            const rune_vm::TRuneId runeId,
            const rune_vm::DataView<uint8_t> buffer,
            const rune_vm::capabilities::TId capabilityId) noexcept final {
            m_currentSource = capabilityId -1;
            m_log.log(
                rune_vm::Severity::Debug,
                      fmt::format("requestRuneInputFromCapability id={} buffer bytes length={} {} {} {}", capabilityId, buffer.m_size,m_inputs.size(),m_currentSource, m_inputs[m_currentSource]->m_size));
            if(m_currentSource < 0 ||m_currentSource >= m_inputs.size() || !m_inputs[m_currentSource]) {
                m_log.log(rune_vm::Severity::Error, "No input for rune");
                return false;
            }
            
            if(!buffer.m_data) {
                m_log.log(
                    rune_vm::Severity::Error,
                    fmt::format("Trying to query input for capability id={}, buffer nullptr", capabilityId));
                return false;
            }

            if(buffer.m_size != m_inputs[m_currentSource]->m_size) {
                m_log.log(
                    rune_vm::Severity::Error,
                    fmt::format(
                        "Trying to query input for capability id={}, buffer size invalid: expected={}, actual={}",
                        capabilityId,
                        m_inputs[m_currentSource]->m_size,
                        buffer.m_size));
                return false;
            }

            std::memcpy(buffer.m_data, m_inputs[m_currentSource]->m_data, buffer.m_size);
            m_inputs[m_currentSource].reset();
            
            return true;
        }
        
        // data
        rune_vm::LoggingModule m_log;
        TCapabilitiesSet m_supportedCapabilities;
        size_t m_currentSource;
        std::vector<std::optional<rune_vm::DataView<const uint8_t>>> m_inputs;
    };

    struct RuneVmContext {
        RuneVmContext(rune_vm::ILogger::CPtr logger)
            : m_log(std::move(logger), "runic.cpp")
            , m_engine(
                  rune_vm::createEngine(
                      m_log.logger(),
                      rune_vm::WasmBackend::Wasm3,
                      std::max<rune_vm::TThreadCount>(1, std::thread::hardware_concurrency() - 1)))
            , m_runtime(m_engine->createRuntime()) {
            
        }
        
        const rune_vm::LoggingModule& log() const noexcept {
            return m_log;
        }
        
        const std::shared_ptr<AllInOneDelegate>& delegate() const noexcept {
            return m_delegate;
        }
        
        bool loadRune(const uint8_t* data, const uint32_t length) noexcept {
            try {
                m_rune.reset();
                m_wasmData.clear();
                m_delegate.reset();
                
                // copy wasm, because it contains state and dealing with it is harder than copy
                constexpr auto targetAlignment = 128;
                
                m_wasmData.resize(length + targetAlignment);
                
                auto wasmDataData = (void*)m_wasmData.data();
                auto wasmDataSize = m_wasmData.size();
                const auto alignedData = std::align(targetAlignment, length, wasmDataData, wasmDataSize);
                if(!alignedData || wasmDataSize < length || reinterpret_cast<uint64_t>(alignedData) % targetAlignment != 0)
                    throw std::runtime_error("Failed to align");
                
                std::memcpy(alignedData, data, length);
                m_delegate = std::make_shared<AllInOneDelegate>(m_log.logger());
                // argument check is inside the method - it will throw if anything goes wrong
                m_rune = m_runtime->loadRune({m_delegate}, {reinterpret_cast<uint8_t*>(alignedData), length});
            } catch(const std::exception& e) {
                m_log.log(rune_vm::Severity::Error, fmt::format("Failed to load rune: {}", e.what()));
                return false;
            }
                          
            return true;
        }
        
        // TODO: this is not really the right way to do things. Input should specify what capability it is for instead of being global. And there should be an option to set multiple inputs for multiple caps
        rune_vm::IResult::Ptr callRune(const std::vector<uint8_t*> &data, const std::vector<uint32_t> &length) noexcept {
            if(!m_rune) {
                m_log.log(rune_vm::Severity::Error, "Failed to call rune: it's null");
                return nullptr;
            }
            
            // length might be == 0 for sine rune, so don't check it
            if(data.size() == 0) {
                m_log.log(rune_vm::Severity::Error, "Failed to call rune: input data is invalid");
                return nullptr;
            }
            
            m_delegate->setInput(data, length);
            
            try {
                const auto result = m_rune->call();
                if(!result) {
                    m_log.log(rune_vm::Severity::Error, "Failed to call rune: output is null");
                    return nullptr;
                }
                
                return result;
            } catch(const std::exception& e) {
                m_log.log(rune_vm::Severity::Error, fmt::format("Failed to call rune: {}", e.what()));
                return nullptr;
            }
        }

        rune_vm::capabilities::IContext::TCapabilityIdToDataMap getCapabilityIdToDataMap() const {
            return m_rune->getCapabilitiesContext()->getCapabilityIdToDataMap();
        }
        
    private:
        rune_vm::LoggingModule m_log;
        std::shared_ptr<AllInOneDelegate> m_delegate;
        std::vector<uint8_t> m_wasmData;
        rune_vm::IRune::Ptr m_rune;
        rune_vm::IEngine::Ptr m_engine;
        rune_vm::IRuntime::Ptr m_runtime;
    };

    // TODO: to refactor implement object ownership passing between flutter and cpp
    static auto g_context = RuneVmContext(std::make_shared<StdoutLogger>());

    // this is done to not fight with strange internal state errors
    bool resetContext(rune_vm::ILogger::CPtr logger) noexcept {
        g_context.log().log(rune_vm::Severity::Info, "Resetting rune_vm context");
        if(!logger) {
            g_context.log().log(rune_vm::Severity::Error, "resetContext: null logger was passed");
            return false;
        }
        
        try {
            auto context = RuneVmContext(std::move(logger));
            
            // this is noexcept so can't fail - g_context is always valid (unless it fails on dlload)
            std::swap(g_context, context);
        }  catch(const std::exception& e) {
            g_context.log().log(rune_vm::Severity::Error, fmt::format("Failed to reset context: {}", e.what()));
            return false;
        }
        
        return true;
    }
}

namespace runic_common {



bool setLogger(rune_vm::ILogger::Ptr logger) noexcept {
    return resetContext(std::move(logger));
}

std::optional<std::string> manifest(const uint8_t* app_rune, int app_rune_len, bool) noexcept {
    g_context.log().log(rune_vm::Severity::Info, fmt::format("manifest called: rune len={}", app_rune_len));
    
    // reset context to avoid wasm3 internal state errors
    if(!resetContext(g_context.log().logger())) {
        g_context.log().log(rune_vm::Severity::Info, "manifest: failed to reset context");
        return std::nullopt;
    }
    
    // create rune
    if(!g_context.loadRune(app_rune, app_rune_len)) {
        g_context.log().log(rune_vm::Severity::Error, "Failed to load rune");
        return std::nullopt;
    }
    try {
        const auto& capabilitiesDataMap = g_context.getCapabilityIdToDataMap();

        // prepare json capabilities description
        auto json = nlohmann::json::array();

        std::transform(
            capabilitiesDataMap.begin(),
            capabilitiesDataMap.end(),
            std::back_inserter(json),
            [](const auto& pair) {
                const auto& [id, data] = pair;
                auto paramsJson = nlohmann::json::array();

                std::transform(
                    data.m_parameters.begin(),
                    data.m_parameters.end(),
                    std::back_inserter(paramsJson),
                    [](const auto& pair) {
                        const auto& [key, parameter] = pair;

                        return nlohmann::json({
                            {"key", key},
                            {"value", fmt::format("{}", parameter)}
                        });
                    });

                // + 1 because that translates enum to rune_interop value
                return nlohmann::json({
                    {"capability", static_cast<uint32_t>(data.m_capability) + 1},
                    {"parameters", std::move(paramsJson)}});
            });

        const auto jsonStr = json.dump();
        g_context.log().log(rune_vm::Severity::Info, fmt::format("manifest() output={}", jsonStr));

        return jsonStr;
    } catch(const std::exception& e) {
        g_context.log().log(rune_vm::Severity::Error, fmt::format("Failed to prepare json: {}", e.what()));
        // if we failed to construct manifest json there's no point in keeping context alive
        resetContext(g_context.log().logger());
        return std::nullopt;
    }
}

std::optional<std::string> callRune(const std::vector<uint8_t *>& input, const std::vector<uint32_t>& input_length) noexcept {

    g_context.log().log(rune_vm::Severity::Info, fmt::format("callRune called: inputs={}", input_length.size()));
    
    const auto result = g_context.callRune(input, input_length);
    if(!result) {
        g_context.log().log(rune_vm::Severity::Error, "Failed to call rune");
        return std::nullopt;
    }
    
    return result->asJson();
}

}
