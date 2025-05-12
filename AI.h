#include <chrono>
#include <future>
#include <iomanip>

#include "LegalMoveGen.h"
#include "MoveSorter.h"
#include "TranspositionTable.h"
#include "SearchInterrupter.h"


#pragma once


#define nsecs std::chrono::high_resolution_clock::now().time_since_epoch().count()


class AI {
public:
    static Move getBestMove(const Position& position, uint8_t side, int32_t ms);
private:
    static std::tuple<int32_t, bool, Move> alphaBeta(const Position& position, uint8_t side, int32_t depthLeft);

    static std::tuple<int32_t, bool, Move> alphaBetaMin(const Position& position, int32_t alpha, int32_t beta, int32_t depthLeft, int32_t depthCurrent = 0);
    static std::tuple<int32_t, bool, Move> alphaBetaMax(const Position& position, int32_t alpha, int32_t beta, int32_t depthLeft, int32_t depthCurrent = 0);

    static int32_t alphaBetaMinOnlyCaptures(const Position& position, int32_t alpha, int32_t beta);
    static int32_t alphaBetaMaxOnlyCaptures(const Position& position, int32_t alpha, int32_t beta);

    struct INF {
        static constexpr int32_t NEGATIVE = -1e+9;
        static constexpr int32_t POSITIVE = 1e+9;
    };
};