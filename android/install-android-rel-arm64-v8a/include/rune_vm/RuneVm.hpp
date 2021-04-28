//
// Created by Kirill Delimbetov - github.com/delimbetov - on 14.03.2021
// Copyright (c) HAMMER OF THE GODS INC. - hotg.ai
//

#pragma once

#include <chrono>
#include <cstdint>
#include <optional>
#include <tuple>
#include <vector>
#include <variant>
#include <rune_vm/Capabilities.hpp>
#include <rune_vm/Log.hpp>
#include <rune_vm/VirtualInterface.hpp>

namespace rune_vm {
    using TThreadCount = uint32_t;

    enum class WasmBackend: uint8_t {
        Wasm3
    };

    struct IResult : VirtualInterface<IResult> {
        enum class Type: uint8_t {
            Json,
            Uint32,
            Int32,
            Float,
            String,
            ByteBuffer,
            IResult
        };

        // NOTE: variant contains unowned references to internal data. Please don't use after IResult::Ptr release
        using TVariant = std::variant<uint32_t, int32_t, float, std::string_view, DataView<const uint8_t>, IResult::Ptr>;

        [[nodiscard]] virtual TVariant getAt(const uint32_t idx) const = 0;
        [[nodiscard]] virtual Type typeAt(const uint32_t idx) const = 0;
        [[nodiscard]] virtual uint32_t count() const noexcept = 0;

        [[nodiscard]] virtual std::string asJson() const noexcept = 0;
    };

    struct IRune : VirtualInterface<IRune> {
        [[nodiscard]] virtual capabilities::IContext::Ptr getCapabilitiesContext() const noexcept = 0;
        [[nodiscard]] virtual IResult::Ptr call() = 0;
    };

    struct IRuntime : VirtualInterface<IRuntime> {
        // accepts wasm
        // loads manifest
        // returns callable rune
        //
        // delegates - pass delegates, each providing some subset of capabilities.
        // Subsets should not intersect, if that happens, delegate for capability with multiple delegates is chosen randomly
        //
        // loadRune will not copy DataView with wasm, it's on you to keep memory allocated
        [[nodiscard]] virtual IRune::Ptr loadRune(
            const std::vector<capabilities::IDelegate::Ptr>& delegates,
            const DataView<const uint8_t> data) = 0;
        [[nodiscard]] virtual IRune::Ptr loadRune(
            const std::vector<capabilities::IDelegate::Ptr>& delegates,
            const std::string_view fileName) = 0;

        //
        [[nodiscard]] virtual std::vector<capabilities::Capability>
            getCapabilitiesWithDefaultDelegates() const noexcept = 0;
    };

    struct IEngine : VirtualInterface<IEngine> {
        // contains wasm environment, logging function
        // if optional is not set for either of args, default values are used
        [[nodiscard]] virtual IRuntime::Ptr createRuntime(
            const std::optional<uint32_t> optStackSizeBytes = std::nullopt,
            const std::optional<uint32_t> optMemoryLimit = std::nullopt) = 0;
    };

    [[nodiscard]] IEngine::Ptr createEngine(
        const ILogger::CPtr& logger,
        const WasmBackend backend,
        const TThreadCount inferenceThreadCount);
}
