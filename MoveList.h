#include <array>
#include "Move.h"


#pragma once


class MoveList {
public:
    MoveList();

    Move& operator[](uint8_t index);
    Move operator[](uint8_t index) const;

    void push(Move move);
    [[nodiscard]] uint8_t getSize() const;
private:
    std::array<Move, 220> moves{};
    uint8_t size;
};
