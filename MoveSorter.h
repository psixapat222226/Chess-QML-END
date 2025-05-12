#include "MoveList.h"
#include "StaticEvaluator.h"


#pragma once


class MoveSorter {
public:
    static MoveList sort(Pieces pieces, MoveList moves);
private:
    static int32_t evaluateMove(Pieces pieces, Move move);
};