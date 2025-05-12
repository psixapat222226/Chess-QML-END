#include "Position.h"
#include "KnightMasks.h"
#include "KingMasks.h"
#include "SlidersMasks.h"


#pragma once


class PsLegalMoveMaskGen {
public:
    static Bitboard generatePawnsDefaultMask(Pieces pieces, uint8_t side);
    static Bitboard generatePawnsLongMask(Pieces pieces, uint8_t side);
    static Bitboard generatePawnsLeftCapturesMask(Pieces pieces, uint8_t side, bool includeAllAttacks = false);
    static Bitboard generatePawnsRightCapturesMask(Pieces pieces, uint8_t side, bool includeAllAttacks = false);

    static Bitboard generateKnightMask(Pieces pieces, uint8_t p, uint8_t side, bool onlyCaptures = false);
    static Bitboard generateBishopMask(Pieces pieces, uint8_t p, uint8_t side, bool onlyCaptures = false);
    static Bitboard generateRookMask(Pieces pieces, uint8_t p, uint8_t side, bool onlyCaptures = false);
    static Bitboard generateQueenMask(Pieces pieces, uint8_t p, uint8_t side, bool onlyCaptures = false);
    static Bitboard generateKingMask(Pieces pieces, uint8_t p, uint8_t side, bool onlyCaptures = false);

    static bool inDanger(Pieces pieces, uint8_t p, uint8_t side);
private:
    static Bitboard calcRay(Pieces pieces, uint8_t p, uint8_t side, bool onlyCaptures, uint8_t direction, bool bsr);
};
