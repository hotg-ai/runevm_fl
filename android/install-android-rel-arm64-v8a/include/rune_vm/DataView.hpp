//
// Created by Kirill Delimbetov - github.com/delimbetov - on 29.03.2021
// Copyright (c) HAMMER OF THE GODS INC. - hotg.ai
//

#pragma once

#include <cstdint>

namespace rune_vm {
    template<typename T, typename TSize = uint32_t>
    struct DataView {
        DataView(T* data, TSize size)
            : m_data(data)
            , m_size(size) {}

        // for tuple instantiation
        DataView()
            : DataView(nullptr, 0) {}

        auto& operator[](const std::size_t idx) const noexcept {
            return m_data[idx];
        }

        auto begin() const noexcept {
            return m_data;
        }

        auto end() const noexcept {
            return m_data + m_size;
        }

        T* m_data;
        TSize m_size;
    };

    template<typename T, typename TSize = uint32_t>
    struct DoubleNestedDataView {
        DoubleNestedDataView(DataView<T, TSize>* data, TSize size)
            : m_data(data)
            , m_size(size) {}

        // for tuple instantiation
        DoubleNestedDataView()
            : DoubleNestedDataView(nullptr, 0) {}

        auto& operator[](const std::size_t idx) const noexcept {
            return m_data[idx];
        }

        auto begin() const noexcept {
            return m_data;
        }

        auto end() const noexcept {
            return m_data + m_size;
        }

        DataView<T, TSize> *m_data;
        TSize m_size;
    };
}
