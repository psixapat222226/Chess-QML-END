#include <chrono>
#include <iomanip>
#include "LegalMoveGen.h"


#pragma once


#define nsecs std::chrono::high_resolution_clock::now().time_since_epoch().count()


class LegalMoveGenTester {
public:
    static void runTests();
private:
    struct Test {
        std::string shortFen;
        uint8_t enPassant;
        bool wlCastling;
        bool wsCastling;
        bool blCastling;
        bool bsCastling;
        uint8_t side;
        std::array<uint64_t, 6> nodes;
    };

    static void runTest(const Test& test);
    static uint64_t getNodesNumber(const Position& position, uint8_t side, uint32_t depth);
};