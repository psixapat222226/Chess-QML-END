#include "Bitboard.h"


#pragma once


namespace SlidersMasks {
    enum DIRECTION {
        NORTH,
        SOUTH,
        WEST,
        EAST,
        NORTH_WEST,
        NORTH_EAST,
        SOUTH_WEST,
        SOUTH_EAST,
    };
    static consteval Bitboard calcMask(uint8_t p, int8_t direction) {
        Bitboard mask = 0;

        int8_t x = p % 8;
        int8_t y = p / 8;

        for (; ;) {
            switch (direction) {
            case SlidersMasks::DIRECTION::NORTH:
                y = y + 1;
                break;
            case SlidersMasks::DIRECTION::SOUTH:
                y = y - 1;
                break;
            case SlidersMasks::DIRECTION::WEST:
                x = x - 1;
                break;
            case SlidersMasks::DIRECTION::EAST:
                x = x + 1;
                break;
            case SlidersMasks::DIRECTION::NORTH_WEST:
                y = y + 1;
                x = x - 1;
                break;
            case SlidersMasks::DIRECTION::NORTH_EAST:
                y = y + 1;
                x = x + 1;
                break;
            case SlidersMasks::DIRECTION::SOUTH_WEST:
                y = y - 1;
                x = x - 1;
                break;
            case SlidersMasks::DIRECTION::SOUTH_EAST:
                y = y - 1;
                x = x + 1;
                break;
            }

            if (x > 7 or x < 0 or y > 7 or y < 0) {
                break;
            }

            mask = BOp::set1(mask, y * 8 + x);
        }

        return mask;
    }
    static consteval std::array<std::array<Bitboard, 8>, 64> calcMasks() {
        std::array<std::array<Bitboard, 8>, 64> masks{};
        for (uint8_t i = 0; i < 64; i = i + 1) {
            for (uint8_t j = 0; j < 8; j = j + 1) {
                masks[i][j] = calcMask(i, j);
            }
        }
        return masks;
    }
    static constexpr std::array<std::array<Bitboard, 8>, 64> MASKS = calcMasks();
};