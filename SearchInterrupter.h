#pragma once


class SearchInterrupter {
public:
    static SearchInterrupter* getPtr();
    SearchInterrupter(const SearchInterrupter& donor) = delete;

    void interrupt();
    void resume();
    [[nodiscard]] bool interrupted() const;
private:
    SearchInterrupter();

    static SearchInterrupter* interrupter;

    bool halt;
};