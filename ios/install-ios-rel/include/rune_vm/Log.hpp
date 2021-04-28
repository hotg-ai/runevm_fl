//
// Created by Kirill Delimbetov - github.com/delimbetov - on 14.03.2021
// Copyright (c) HAMMER OF THE GODS INC. - hotg.ai
//

#pragma once

#include <memory>
#include <string_view>
#include <string>
#include <rune_vm/VirtualInterface.hpp>

namespace rune_vm {
    enum class Severity: uint8_t {
        Debug,
        Info,
        Warning,
        Error
    };

    constexpr auto severityToString(const Severity severity) {
        switch(severity) {
            case Severity::Debug:
                return "Debug";
            case Severity::Info:
                return "Info";
            case Severity::Warning:
                return "Warning";
            case Severity::Error:
                return "Error";
            default:
                return "Unknown";
        }
    }

    // TODO: Add default loggers
    struct ILogger: VirtualInterface<ILogger> {
        virtual void log(
            const Severity severity,
            const std::string& module,
            const std::string& message) const noexcept = 0;
    };

    class LoggingModule {
    public:
        LoggingModule(const ILogger::CPtr& logger, const std::string& module);

        void log(const Severity severity, const std::string& message) const noexcept;

        const ILogger::CPtr& logger() const noexcept;

    private:
        ILogger::CPtr m_logger;
        std::string m_module;
    };
}
