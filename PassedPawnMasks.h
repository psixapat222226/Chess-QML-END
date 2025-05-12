#include <array>
#include "Bitboard.h"


#pragma once


namespace PassedPawnMasks {
    static consteval std::array<Bitboard, 64> calcWhitePassedPawnMasks() {
        std::array<Bitboard, 64> masks{};

        for (uint8_t x = 0; x < 8; x = x + 1) {
            for (uint8_t y = 0; y < 8; y = y + 1) {

                for (uint8_t y1 = y + 1; y1 < 8; y1 = y1 + 1) {

                    if (x != 0) {
                        masks[y * 8 + x] = BOp::set1(masks[y * 8 + x], y1 * 8 + x - 1);
                    }
                    if (x != 7) {
                        masks[y * 8 + x] = BOp::set1(masks[y * 8 + x], y1 * 8 + x + 1);
                    }
                    masks[y * 8 + x] = BOp::set1(masks[y * 8 + x], y1 * 8 + x);
                }
            }
        }

        return masks;
    }
    static consteval std::array<Bitboard, 64> calcBlackPassedPawnMasks() {
        std::array<Bitboard, 64> masks{};

        for (uint8_t x = 0; x < 8; x = x + 1) {
            for (uint8_t y = 0; y < 8; y = y + 1) {

                for (int8_t y1 = y - 1; y1 >= 0; y1 = y1 - 1) {

                    if (x != 0) {
                        masks[y * 8 + x] = BOp::set1(masks[y * 8 + x], y1 * 8 + x - 1);
                    }
                    if (x != 7) {
                        masks[y * 8 + x] = BOp::set1(masks[y * 8 + x], y1 * 8 + x + 1);
                    }
                    masks[y * 8 + x] = BOp::set1(masks[y * 8 + x], y1 * 8 + x);
                }
            }
        }

        return masks;
    }
    static constexpr std::array<Bitboard, 64> WHITE_PASSED_PAWN_MASKS = calcWhitePassedPawnMasks();
    static constexpr std::array<Bitboard, 64> BLACK_PASSED_PAWN_MASKS = calcBlackPassedPawnMasks();
}