QT += quick
QT += quick multimedia
CONFIG += c++20

SOURCES += \
        AI.cpp \
        LegalMoveGen.cpp \
        LegalMoveGenTester.cpp \
        Move.cpp \
        MoveList.cpp \
        MoveSorter.cpp \
        Pieces.cpp \
        Position.cpp \
        PsLegalMoveMaskGen.cpp \
        RepetitionHistory.cpp \
        SearchInterrupter.cpp \
        StaticEvaluator.cpp \
        TranspositionTable.cpp \
        ZobristHash.cpp \
        chessengine.cpp \
        main.cpp \
        resourcemanager.cpp

resources.files = main.qml 
resources.prefix = /$${TARGET}
RESOURCES += resources \
    qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

DISTFILES += \
    ChessBoard.qml \
    ChessPiece.qml \
    resources/images/chessmen/black/bishop.png \
    resources/images/chessmen/black/king.png \
    resources/images/chessmen/black/knight.png \
    resources/images/chessmen/black/pawn.png \
    resources/images/chessmen/black/queen.png \
    resources/images/chessmen/black/rook.png \
    resources/images/chessmen/white/bishop.png \
    resources/images/chessmen/white/king.png \
    resources/images/chessmen/white/knight.png \
    resources/images/chessmen/white/pawn.png \
    resources/images/chessmen/white/queen.png \
    resources/images/chessmen/white/rook.png \
    resources/images/fon2.png \
    resources/images/logotype.png \
    resources/sounds/capture.ogg \
    resources/sounds/message.ogg \
    resources/sounds/move.ogg

HEADERS += \
    AI.h \
    Bitboard.h \
    KingMasks.h \
    KnightMasks.h \
    LegalMoveGen.h \
    LegalMoveGenTester.h \
    Move.h \
    MoveList.h \
    MoveSorter.h \
    PassedPawnMasks.h \
    Pieces.h \
    Position.h \
    PsLegalMoveMaskGen.h \
    RepetitionHistory.h \
    SearchInterrupter.h \
    SlidersMasks.h \
    StaticEvaluator.h \
    TranspositionTable.h \
    ZobristHash.h \
    ZobristHashConstants.h \
    chessengine.h \
    resourcemanager.h
