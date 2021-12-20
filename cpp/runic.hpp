//
//  runic.hpp
//  runic
//
//  Created by Kartik Thakore on 1/2/21.
//

#pragma once

#include <optional>
#include <vector>
#include <string>
#include <rune_vm/Log.hpp>

namespace runic_common
{
    template <typename T>
    struct Scoper
    {
        Scoper(T &&func)
            : m_func(std::forward<T>(func)), m_releasable(true) {}
        Scoper(Scoper &&scoper)
            : m_func(std::move(scoper.m_func)), m_releasable(true)
        {
            scoper.m_releasable = false;
        }

        ~Scoper()
        {
            if (m_releasable)
                m_func();
        }

    private:
        T m_func;
        bool m_releasable;
    };

    // set logger resets everything. if you don't set it, stdout logger will be used
    bool setLogger(rune_vm::ILogger::Ptr logger) noexcept;

    

    std::optional<std::string> manifest(const uint8_t *app_rune, int app_rune_len, bool newManifest) noexcept;
    std::optional<std::string> callRune(const std::vector<uint8_t *> &input, const std::vector<uint32_t> &input_length) noexcept;
}

std::vector<std::string> getLogs() noexcept;
