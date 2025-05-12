#include "MoveList.h"

MoveList::MoveList() {
    this->size = 0;
}
Move& MoveList::operator[](uint8_t index) {
    return this->moves[index];
}
Move MoveList::operator[](uint8_t index) const {
    return this->moves[index];
}
void MoveList::push(Move move) {
    this->moves[this->size] = move;
    this->size = this->size + 1;
}
uint8_t MoveList::getSize() const {
    return this->size;
}
