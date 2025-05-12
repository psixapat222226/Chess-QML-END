#include "MoveList.h"
#include "PsLegalMoveMaskGen.h"


#pragma once


class LegalMoveGen {
public:
    static MoveList generate(const Position& position, uint8_t side, bool onlyCaptures = false);
private:
    static void pieceMaskToMoves(Pieces pieces, Bitboard mask, uint8_t attackerP, uint8_t attackerType, uint8_t attackerSide, MoveList& moves);
    static void pawnsMaskToMoves(Pieces pieces, Bitboard mask, uint8_t attackerSide, int8_t attackerIndex, bool checkDefender, uint8_t flag, MoveList& moves);

    static bool isLegal(Pieces pieces, Move move);

    static void addEnPassantCaptures(Pieces pieces, uint8_t side, uint8_t enPassant, MoveList& moves);
    static void addCastlingMoves(Pieces pieces, uint8_t side, bool lCastling, bool sCastling, MoveList& moves);
};