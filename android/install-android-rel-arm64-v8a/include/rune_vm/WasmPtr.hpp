//
// Created by Kirill Delimbetov - github.com/delimbetov - on 29.03.2021
// Copyright (c) HAMMER OF THE GODS INC. - hotg.ai
//

#pragma once

#include <wasm3.h>
#include <m3_core.h>

namespace rune_vm {
    struct WasmPtr {
        u32 m_offset = 0;
        void* m_mem = nullptr;

        WasmPtr():
            m_offset(0),
            m_mem(nullptr)
        {
        }

        WasmPtr(u32 offset,
                void *mem):
            m_offset(offset),
            m_mem(mem)
        {
        }

        inline void* deref() const {
            return deref(m_offset);
        }

        inline void* deref(u32 offset) const {
            if (m_mem == nullptr)
                return nullptr;

            //Based on m3_api_defs' m3ApiOffsetToPtr
            return (void*)((u8*)m_mem + (u32)(offset));
        }
    };
}
