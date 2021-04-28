//
// Created by Kirill Delimbetov on 29.03.2021.
//

#pragma once

#include <memory>

namespace rune_vm {
    template<typename Interface>
    struct VirtualInterface {
        using Ptr = std::shared_ptr<Interface>;
        using CPtr = std::shared_ptr<const Interface>;

        virtual ~VirtualInterface() = default;
    };
}