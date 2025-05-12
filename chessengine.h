#pragma once

#include <QObject>
#include <QString>
#include <QVariant>
#include <QVector>
#include <QMap>
#include <QPoint>
#include <QTimer>
#include <QStack>
#include <chrono>
#include <QSettings>
#include <QDateTime>
#include <QJsonObject>
#include <QJsonArray>
#include <QJsonDocument>
#include <QStandardPaths>
#include <QDir>
#include <QFile>
#include "Position.h"
#include "AI.h"

#define nsecs std::chrono::high_resolution_clock::now().time_since_epoch().count()

class ChessEngine : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString status READ status NOTIFY statusChanged)
    Q_PROPERTY(int difficulty READ difficulty WRITE setDifficulty NOTIFY difficultyChanged)
    Q_PROPERTY(bool canUndo READ canUndo NOTIFY canUndoChanged)
    Q_PROPERTY(bool vsComputer READ vsComputer NOTIFY vsComputerEnabled)

public:
    explicit ChessEngine(QObject *parent = nullptr);

    Q_INVOKABLE QVariantList getPieces() const;
    Q_INVOKABLE bool processMove(int fromX, int fromY, int toX, int toY);
    Q_INVOKABLE QVariantList getLegalMovesForPiece(int x, int y) const;
    Q_INVOKABLE void startNewGame();
    Q_INVOKABLE void setGameMode(const QString& mode);
    Q_INVOKABLE QString getTextureName(int x, int y) const;
    Q_INVOKABLE void makeAIMove();
    Q_INVOKABLE bool promotePawn(int fromX, int fromY, int toX, int toY, const QString& pieceType);

    // Методы для отмены хода
    Q_INVOKABLE bool undoLastMove();
    bool canUndo() const;
    bool vsComputer() const;

    // Методы для выделения хода компьютера
    Q_INVOKABLE QPoint getLastMoveFrom() const;
    Q_INVOKABLE QPoint getLastMoveTo() const;
    Q_INVOKABLE bool hasLastMove() const;

    // Методы для сохранения/загрузки партий
    Q_INVOKABLE bool saveGame(const QString& name);
    Q_INVOKABLE bool loadGame(int slot);
    Q_INVOKABLE QVariantList getSavedGames() const;
    Q_INVOKABLE bool deleteGame(int slot);

    // Методы для работы со сложностью
    int difficulty() const;
    void setDifficulty(int newDifficulty);
    Q_INVOKABLE QString getDifficultyName() const;
    void cleanSavedGames();
    QString status() const;

signals:
    void piecesChanged();
    void statusChanged();
    void gameEnded(const QString& result);
    void pawnPromotion(int fromX, int fromY, int toX, int toY);
    void difficultyChanged();
    void canUndoChanged();
    void lastMoveChanged();
    void savedGamesChanged();
    void vsComputerEnabled();

private:
    enum STATUS {
        WHITE_TO_MOVE,
        BLACK_TO_MOVE,
        WHITE_WON,
        BLACK_WON,
        DRAW
    };

    enum class GameMode {
        TwoPlayers,
        VsComputer
    };

    struct MoveHistoryItem {
        Position position;
        QPoint moveFrom;
        QPoint moveTo;
    };

    // Структура для сохранения партии
    struct SavedGame {
        QString name;
        QString date;
        QString gameMode;
        int difficulty;
        QString status;
        QString fen;
        int whiteTimeLeft;
        int blackTimeLeft;
        QList<QPoint> moveFromHistory;
        QList<QPoint> moveToHistory;
        QString filename;

        // Добавьте эти поля
        bool hasLastMove;
        QPoint lastMoveFrom;
        QPoint lastMoveTo;
    };

    Position position;
    QPoint selectedPiece;
    STATUS currentStatus;
    GameMode gameMode;
    int m_difficulty; // 1 - легкий, 2 - средний, 3 - сложный

    QStack<MoveHistoryItem> moveHistory;
    QPoint lastMoveFrom;
    QPoint lastMoveTo;
    bool hasLastMoveInfo;

    QVector<SavedGame> savedGames;

    void updateStatus();
    QString statusToString() const;
    uint8_t getStatus() const;
    void recordMove(int fromX, int fromY, int toX, int toY);
    void setLastMove(int fromX, int fromY, int toX, int toY);

    // Методы для сохранения/загрузки
    void loadSavedGames();
    void saveSavedGamesList();
    QString serializePosition(const Position& pos) const;
    Position deserializePosition(const QString& data);
    QString positionToFEN(const Position& pos) const;
    Position positionFromFEN(const QString& fen);
    bool saveGameToFile(const SavedGame& game, const QString& filename);
    SavedGame loadGameFromFile(const QString& filename);
    QString getMoveHistoryJson() const;
    void setMoveHistoryFromJson(const QString& historyJson);
};
