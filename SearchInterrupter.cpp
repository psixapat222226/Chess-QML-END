#include "SearchInterrupter.h"


SearchInterrupter* SearchInterrupter::interrupter = nullptr;


SearchInterrupter* SearchInterrupter::getPtr() {
    if (interrupter == nullptr) {
        interrupter = new SearchInterrupter();
    }
    return interrupter;
}
void SearchInterrupter::interrupt() {
    this->halt = true;
}
void SearchInterrupter::resume() {
    this->halt = false;
}
bool SearchInterrupter::interrupted() const {
    return this->halt;
}
SearchInterrupter::SearchInterrupter() {
    this->halt = false;
}