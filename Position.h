#include <cmath>
#include "RepetitionHistory.h"
#include "Move.h"


#pragma once


class Position {
public:
    Position();
    Position(const std::string& shortFen, uint8_t enPassant, bool wlCastling, bool wsCastling, bool blCastling, bool bsCastling, float moveCtr);

    friend std::ostream& operator <<(std::ostream& ostream, const Position& position);

    void move(Move move);

    [[nodiscard]] Pieces getPieces() const;
    [[nodiscard]] uint8_t getEnPassant() const;
    [[nodiscard]] bool getWLCastling() const;
    [[nodiscard]] bool getWSCastling() const;
    [[nodiscard]] bool getBLCastling() const;
    [[nodiscard]] bool getBSCastling() const;
    [[nodiscard]] bool whiteToMove() const;
    [[nodiscard]] bool blackToMove() const;
    [[nodiscard]] ZobristHash getHash() const;
    [[nodiscard]] bool fiftyMovesRuleDraw() const;
    [[nodiscard]] bool threefoldRepetitionDraw() const;

    static constexpr uint8_t NONE = 255;
private:
    void addPiece(uint8_t square, uint8_t type, uint8_t side);
    void removePiece(uint8_t square, uint8_t type, uint8_t side);
    void changeEnPassant(uint8_t en_passant);

    void removeWLCastling();
    void removeWSCastling();
    void removeBLCastling();
    void removeBSCastling();

    void updateMoveCtr();
    void updateFiftyMovesCtr(bool breakEvent);

    Pieces pieces;
    uint8_t enPassant;

    bool wlCastling;
    bool wsCastling;
    bool blCastling;
    bool bsCastling;

    float moveCtr;
    ZobristHash hash;
    float fiftyMovesCtr;
    RepetitionHistory repetitionHistory;
};
