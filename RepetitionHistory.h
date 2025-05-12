#include <vector>
#include "ZobristHash.h"


#pragma once


class RepetitionHistory {
public:
    RepetitionHistory();

    void addPosition(ZobristHash hash);
    void clear();
    [[nodiscard]] uint8_t getRepetitionNumber(ZobristHash hash) const;
private:
    std::vector<ZobristHash> hashes;
};
