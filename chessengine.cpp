#include "ChessEngine.h"
#include <QDebug>
#include <QTimer>
#include <QStandardPaths>
#include <QDir>

ChessEngine::ChessEngine(QObject *parent)
    : QObject(parent),
    selectedPiece(QPoint(-1, -1)),
    currentStatus(STATUS::WHITE_TO_MOVE),
    gameMode(GameMode::TwoPlayers),
    m_difficulty(2), // По умолчанию средняя сложность
    hasLastMoveInfo(false)
{
    // Загружаем сохраненные партии при запуске
    loadSavedGames();

    // Стартуем новую партию
    startNewGame();
}

void ChessEngine::startNewGame()
{
    // Инициализация позиции на шахматной доске
    position = Position("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR",
                        Position::NONE, true, true, true, true, 1);
    selectedPiece = QPoint(-1, -1);
    currentStatus = STATUS::WHITE_TO_MOVE;

    // Очищаем историю ходов и последний ход
    moveHistory.clear();
    hasLastMoveInfo = false;

    emit piecesChanged();
    emit statusChanged();
    emit canUndoChanged();
    emit vsComputerEnabled();
    emit lastMoveChanged();
}

void ChessEngine::setGameMode(const QString& mode)
{
    if (mode == "twoPlayers") {
        gameMode = GameMode::TwoPlayers;
    } else if (mode == "vsComputer") {
        gameMode = GameMode::VsComputer;
    }
}

QVariantList ChessEngine::getPieces() const
{
    QVariantList piecesList;
    Pieces pieces = position.getPieces();

    for (int y = 0; y < 8; y++) {
        for (int x = 0; x < 8; x++) {
            int index = y * 8 + x;
            QString pieceName;

            if (BOp::getBit(pieces.getPieceBitboard(SIDE::WHITE, PIECE::PAWN), index))
                pieceName = "whitePawn";
            else if (BOp::getBit(pieces.getPieceBitboard(SIDE::WHITE, PIECE::KNIGHT), index))
                pieceName = "whiteKnight";
            else if (BOp::getBit(pieces.getPieceBitboard(SIDE::WHITE, PIECE::BISHOP), index))
                pieceName = "whiteBishop";
            else if (BOp::getBit(pieces.getPieceBitboard(SIDE::WHITE, PIECE::ROOK), index))
                pieceName = "whiteRook";
            else if (BOp::getBit(pieces.getPieceBitboard(SIDE::WHITE, PIECE::QUEEN), index))
                pieceName = "whiteQueen";
            else if (BOp::getBit(pieces.getPieceBitboard(SIDE::WHITE, PIECE::KING), index))
                pieceName = "whiteKing";
            else if (BOp::getBit(pieces.getPieceBitboard(SIDE::BLACK, PIECE::PAWN), index))
                pieceName = "blackPawn";
            else if (BOp::getBit(pieces.getPieceBitboard(SIDE::BLACK, PIECE::KNIGHT), index))
                pieceName = "blackKnight";
            else if (BOp::getBit(pieces.getPieceBitboard(SIDE::BLACK, PIECE::BISHOP), index))
                pieceName = "blackBishop";
            else if (BOp::getBit(pieces.getPieceBitboard(SIDE::BLACK, PIECE::ROOK), index))
                pieceName = "blackRook";
            else if (BOp::getBit(pieces.getPieceBitboard(SIDE::BLACK, PIECE::QUEEN), index))
                pieceName = "blackQueen";
            else if (BOp::getBit(pieces.getPieceBitboard(SIDE::BLACK, PIECE::KING), index))
                pieceName = "blackKing";
            else
                continue;

            QVariantMap piece;
            piece["x"] = x;
            piece["y"] = y;
            piece["type"] = pieceName;
            piecesList.append(piece);
        }
    }

    return piecesList;
}

QString ChessEngine::getTextureName(int x, int y) const
{
    int index = y * 8 + x;
    Pieces pieces = position.getPieces();

    if (BOp::getBit(pieces.getPieceBitboard(SIDE::WHITE, PIECE::PAWN), index))
        return "whitePawn";
    else if (BOp::getBit(pieces.getPieceBitboard(SIDE::WHITE, PIECE::KNIGHT), index))
        return "whiteKnight";
    else if (BOp::getBit(pieces.getPieceBitboard(SIDE::WHITE, PIECE::BISHOP), index))
        return "whiteBishop";
    else if (BOp::getBit(pieces.getPieceBitboard(SIDE::WHITE, PIECE::ROOK), index))
        return "whiteRook";
    else if (BOp::getBit(pieces.getPieceBitboard(SIDE::WHITE, PIECE::QUEEN), index))
        return "whiteQueen";
    else if (BOp::getBit(pieces.getPieceBitboard(SIDE::WHITE, PIECE::KING), index))
        return "whiteKing";
    else if (BOp::getBit(pieces.getPieceBitboard(SIDE::BLACK, PIECE::PAWN), index))
        return "blackPawn";
    else if (BOp::getBit(pieces.getPieceBitboard(SIDE::BLACK, PIECE::KNIGHT), index))
        return "blackKnight";
    else if (BOp::getBit(pieces.getPieceBitboard(SIDE::BLACK, PIECE::BISHOP), index))
        return "blackBishop";
    else if (BOp::getBit(pieces.getPieceBitboard(SIDE::BLACK, PIECE::ROOK), index))
        return "blackRook";
    else if (BOp::getBit(pieces.getPieceBitboard(SIDE::BLACK, PIECE::QUEEN), index))
        return "blackQueen";
    else if (BOp::getBit(pieces.getPieceBitboard(SIDE::BLACK, PIECE::KING), index))
        return "blackKing";

    return "";
}

QVariantList ChessEngine::getLegalMovesForPiece(int x, int y) const
{
    QVariantList moves;
    int from = y * 8 + x;

    // Получаем ходы только для фигур текущего игрока
    Pieces pieces = position.getPieces();
    if ((currentStatus == STATUS::WHITE_TO_MOVE &&
         !BOp::getBit(pieces.getSideBitboard(SIDE::WHITE), from)) ||
        (currentStatus == STATUS::BLACK_TO_MOVE &&
         !BOp::getBit(pieces.getSideBitboard(SIDE::BLACK), from))) {
        return moves;
    }

    uint8_t side = (currentStatus == STATUS::WHITE_TO_MOVE) ? SIDE::WHITE : SIDE::BLACK;
    MoveList legalMoves = LegalMoveGen::generate(position, side);

    for (uint8_t i = 0; i < legalMoves.getSize(); i++) {
        Move move = legalMoves[i];
        if (move.getFrom() == from) {
            int toX = move.getTo() % 8;
            int toY = move.getTo() / 8;
            QVariantMap moveMap;
            moveMap["x"] = toX;
            moveMap["y"] = toY;
            moves.append(moveMap);
        }
    }

    return moves;
}

void ChessEngine::recordMove(int fromX, int fromY, int toX, int toY)
{
    MoveHistoryItem item;
    item.position = position;  // Сохраняем положение до хода
    item.moveFrom = QPoint(fromX, fromY);
    item.moveTo = QPoint(toX, toY);
    moveHistory.push(item);

    // Обновляем информацию о последнем ходе
    setLastMove(fromX, fromY, toX, toY);

    emit canUndoChanged();
    emit vsComputerEnabled();
}

void ChessEngine::setLastMove(int fromX, int fromY, int toX, int toY)
{
    lastMoveFrom = QPoint(fromX, fromY);
    lastMoveTo = QPoint(toX, toY);
    hasLastMoveInfo = true;

    qDebug() << "Last move set: " << fromX << "," << fromY << " to " << toX << "," << toY;

    emit lastMoveChanged();
}

bool ChessEngine::processMove(int fromX, int fromY, int toX, int toY)
{
    if (currentStatus != STATUS::WHITE_TO_MOVE &&
        currentStatus != STATUS::BLACK_TO_MOVE) {
        return false;
    }

    // В режиме игры с компьютером, игрок может ходить только белыми
    if (gameMode == GameMode::VsComputer && currentStatus == STATUS::BLACK_TO_MOVE) {
        return false;
    }

    uint8_t side = (currentStatus == STATUS::WHITE_TO_MOVE) ? SIDE::WHITE : SIDE::BLACK;
    uint8_t from = fromY * 8 + fromX;
    uint8_t to = toY * 8 + toX;

    MoveList moves = LegalMoveGen::generate(position, side);
    int moveIndex = -1;
    bool isPawnPromotion = false;


    bool isWhitePawnPromotion = (side == SIDE::WHITE && toY == 7 &&
                                 BOp::getBit(position.getPieces().getPieceBitboard(SIDE::WHITE, PIECE::PAWN), from));
    bool isBlackPawnPromotion = (side == SIDE::BLACK && toY == 0 &&
                                 BOp::getBit(position.getPieces().getPieceBitboard(SIDE::BLACK, PIECE::PAWN), from));

    if (isWhitePawnPromotion || isBlackPawnPromotion) {
        // Просто проверяем, что такой ход возможен (без учета типа превращения)
        for (uint8_t i = 0; i < moves.getSize(); i++) {
            Move move = moves[i];
            if (move.getFrom() == from && move.getTo() == to &&
                (move.getFlag() == Move::FLAG::PROMOTE_TO_QUEEN ||
                 move.getFlag() == Move::FLAG::PROMOTE_TO_ROOK ||
                 move.getFlag() == Move::FLAG::PROMOTE_TO_BISHOP ||
                 move.getFlag() == Move::FLAG::PROMOTE_TO_KNIGHT)) {
                isPawnPromotion = true;
                // Сохраняем позицию до превращения
                recordMove(fromX, fromY, toX, toY);
                // Мы нашли допустимый ход превращения пешки, но не выполняем его сейчас
                // Вместо этого запрашиваем у пользователя тип фигуры
                emit pawnPromotion(fromX, fromY, toX, toY);
                return true; // Возвращаем true, чтобы показать, что ход будет обработан позже
            }
        }
    }

    // Если это не превращение пешки, продолжаем как обычно
    if (!isPawnPromotion) {
        for (uint8_t i = 0; i < moves.getSize(); i++) {
            Move move = moves[i];
            if (move.getFrom() == from && move.getTo() == to) {
                moveIndex = i;
                break;
            }
        }
    }

    if (moveIndex != -1) {
        Move selectedMove = moves[moveIndex];

        // Записываем ход в историю перед его выполнением
        recordMove(fromX, fromY, toX, toY);

        position.move(selectedMove);
        updateStatus();
        emit piecesChanged();
        emit statusChanged();

        if (currentStatus == STATUS::WHITE_WON ||
            currentStatus == STATUS::BLACK_WON ||
            currentStatus == STATUS::DRAW) {
            QString result;
            if (currentStatus == STATUS::WHITE_WON) {
                result = "Белые победили!";
            } else if (currentStatus == STATUS::BLACK_WON) {
                result = "Чёрные победили!";
            } else {
                result = "Ничья!";
            }
            emit gameEnded(result);
        }
        // Если режим игры с компьютером и сейчас ход черных, компьютер делает ход
        else if (gameMode == GameMode::VsComputer && currentStatus == STATUS::BLACK_TO_MOVE) {
            QTimer::singleShot(500, this, &ChessEngine::makeAIMove);
        }

        return true;
    }

    return false;
}

bool ChessEngine::promotePawn(int fromX, int fromY, int toX, int toY, const QString& pieceType)
{
    uint8_t side = (currentStatus == STATUS::WHITE_TO_MOVE) ? SIDE::WHITE : SIDE::BLACK;
    uint8_t from = fromY * 8 + fromX;
    uint8_t to = toY * 8 + toX;

    MoveList moves = LegalMoveGen::generate(position, side);
    int moveIndex = -1;

    // Определяем флаг превращения в зависимости от выбранного типа фигуры
    Move::FLAG promotionFlag;
    if (pieceType == "queen") {
        promotionFlag = Move::FLAG::PROMOTE_TO_QUEEN;
    } else if (pieceType == "rook") {
        promotionFlag = Move::FLAG::PROMOTE_TO_ROOK;
    } else if (pieceType == "bishop") {
        promotionFlag = Move::FLAG::PROMOTE_TO_BISHOP;
    } else if (pieceType == "knight") {
        promotionFlag = Move::FLAG::PROMOTE_TO_KNIGHT;
    } else {
        // По умолчанию превращаем в ферзя
        promotionFlag = Move::FLAG::PROMOTE_TO_QUEEN;
    }

    // Находим ход с соответствующим флагом
    for (uint8_t i = 0; i < moves.getSize(); i++) {
        Move move = moves[i];
        if (move.getFrom() == from && move.getTo() == to && move.getFlag() == promotionFlag) {
            moveIndex = i;
            break;
        }
    }

    if (moveIndex != -1) {
        Move selectedMove = moves[moveIndex];

        position.move(selectedMove);
        updateStatus();
        emit piecesChanged();
        emit statusChanged();

        if (currentStatus == STATUS::WHITE_WON ||
            currentStatus == STATUS::BLACK_WON ||
            currentStatus == STATUS::DRAW) {
            QString result;
            if (currentStatus == STATUS::WHITE_WON) {
                result = "Белые победили!";
            } else if (currentStatus == STATUS::BLACK_WON) {
                result = "Чёрные победили!";
            } else {
                result = "Ничья!";
            }
            emit gameEnded(result);
        }
        // Если режим игры с компьютером и сейчас ход черных, компьютер делает ход
        else if (gameMode == GameMode::VsComputer && currentStatus == STATUS::BLACK_TO_MOVE) {
            QTimer::singleShot(500, this, &ChessEngine::makeAIMove);
        }

        return true;
    }

    return false;
}

void ChessEngine::updateStatus()
{
    currentStatus = static_cast<STATUS>(getStatus());
}

QString ChessEngine::status() const
{
    return statusToString();
}

QString ChessEngine::statusToString() const
{
    switch (currentStatus) {
    case STATUS::WHITE_TO_MOVE: return "Ход белых";
    case STATUS::BLACK_TO_MOVE: return "Ход чёрных";
    case STATUS::WHITE_WON: return "Белые выиграли";
    case STATUS::BLACK_WON: return "Чёрные выиграли";
    case STATUS::DRAW: return "Ничья";
    }
    return "Неизвестно";
}

uint8_t ChessEngine::getStatus() const
{
    if (position.fiftyMovesRuleDraw() || position.threefoldRepetitionDraw()) {
        return STATUS::DRAW;
    }

    if (!position.getPieces().getPieceBitboard(SIDE::WHITE, PIECE::PAWN) &&
        !position.getPieces().getPieceBitboard(SIDE::BLACK, PIECE::PAWN) &&
        !position.getPieces().getPieceBitboard(SIDE::WHITE, PIECE::ROOK) &&
        !position.getPieces().getPieceBitboard(SIDE::BLACK, PIECE::ROOK) &&
        !position.getPieces().getPieceBitboard(SIDE::WHITE, PIECE::QUEEN) &&
        !position.getPieces().getPieceBitboard(SIDE::BLACK, PIECE::QUEEN) &&
        BOp::count1(position.getPieces().getPieceBitboard(SIDE::WHITE, PIECE::KNIGHT) |
                    position.getPieces().getPieceBitboard(SIDE::WHITE, PIECE::BISHOP)) < 2 &&
        BOp::count1(position.getPieces().getPieceBitboard(SIDE::BLACK, PIECE::KNIGHT) |
                    position.getPieces().getPieceBitboard(SIDE::BLACK, PIECE::BISHOP)) < 2) {
        return STATUS::DRAW;
    }

    if (position.whiteToMove()) {
        MoveList whiteMoves = LegalMoveGen::generate(position, SIDE::WHITE);
        if (whiteMoves.getSize() == 0) {
            bool whiteInCheck = PsLegalMoveMaskGen::inDanger(
                position.getPieces(),
                BOp::bsf(position.getPieces().getPieceBitboard(SIDE::WHITE, PIECE::KING)),
                SIDE::WHITE
                );
            return whiteInCheck ? STATUS::BLACK_WON : STATUS::DRAW;
        }
        return STATUS::WHITE_TO_MOVE;
    } else {
        MoveList blackMoves = LegalMoveGen::generate(position, SIDE::BLACK);
        if (blackMoves.getSize() == 0) {
            bool blackInCheck = PsLegalMoveMaskGen::inDanger(
                position.getPieces(),
                BOp::bsf(position.getPieces().getPieceBitboard(SIDE::BLACK, PIECE::KING)),
                SIDE::BLACK
                );
            return blackInCheck ? STATUS::WHITE_WON : STATUS::DRAW;
        }
        return STATUS::BLACK_TO_MOVE;
    }
}

bool ChessEngine::undoLastMove()
{
    if (moveHistory.isEmpty()) {
        return false;
    }

    MoveHistoryItem lastMove = moveHistory.pop();
    position = lastMove.position;

    // Обновляем последний ход для визуализации
    if (!moveHistory.isEmpty()) {
        MoveHistoryItem prevMove = moveHistory.top();
        lastMoveFrom = prevMove.moveFrom;
        lastMoveTo = prevMove.moveTo;
        hasLastMoveInfo = true;
    } else {
        hasLastMoveInfo = false;
    }

    updateStatus();
    emit piecesChanged();
    emit canUndoChanged();
    emit vsComputerEnabled();
    emit lastMoveChanged();
    emit statusChanged();

    return true;
}

bool ChessEngine::canUndo() const
{
    return !moveHistory.isEmpty();
}

bool ChessEngine::vsComputer() const
{
    return gameMode == GameMode::VsComputer;
}

QPoint ChessEngine::getLastMoveFrom() const
{
    return lastMoveFrom;
}

QPoint ChessEngine::getLastMoveTo() const
{
    return lastMoveTo;
}

bool ChessEngine::hasLastMove() const
{
    return hasLastMoveInfo;
}

int ChessEngine::difficulty() const
{
    return m_difficulty;
}

void ChessEngine::setDifficulty(int newDifficulty)
{
    if (newDifficulty < 1)
        newDifficulty = 1;
    else if (newDifficulty > 3)
        newDifficulty = 3;

    if (m_difficulty != newDifficulty) {
        m_difficulty = newDifficulty;
        emit difficultyChanged();
    }
}

QString ChessEngine::getDifficultyName() const
{
    switch (m_difficulty) {
    case 1: return "Легкий";
    case 2: return "Средний";
    case 3: return "Сложный";
    default: return "Средний";
    }
}

void ChessEngine::makeAIMove()
{
    if (currentStatus != STATUS::BLACK_TO_MOVE) {
        return;
    }

    int thinkingTime;
    switch (m_difficulty) {
    case 1: // Легкий
        thinkingTime = 500; // 0.5 секунд
        break;
    case 2: // Средний
        thinkingTime = 1000; // 1 секунда
        break;
    case 3: // Сложный
        thinkingTime = 2000; // 2 секунды
        break;
    default:
        thinkingTime = 1000;
    }

    // AI делает ход с учетом сложности
    Move aiMove = AI::getBestMove(position, SIDE::BLACK, thinkingTime);

    int fromX = aiMove.getFrom() % 8;
    int fromY = aiMove.getFrom() / 8;
    int toX = aiMove.getTo() % 8;
    int toY = aiMove.getTo() / 8;

    recordMove(fromX, fromY, toX, toY);

    position.move(aiMove);
    updateStatus();

    emit piecesChanged();
    emit statusChanged();

    // Проверка на конец игры
    if (currentStatus == STATUS::WHITE_WON ||
        currentStatus == STATUS::BLACK_WON ||
        currentStatus == STATUS::DRAW) {
        QString result;
        if (currentStatus == STATUS::WHITE_WON) {
            result = "Белые победили!";
        } else if (currentStatus == STATUS::BLACK_WON) {
            result = "Чёрные победили!";
        } else {
            result = "Ничья!";
        }
        emit gameEnded(result);
    }
}

bool ChessEngine::saveGame(const QString& name)
{
    // Проверка, что имя не пустое
    if (name.trimmed().isEmpty()) {
        return false;
    }

    // Создаем объект с данными о сохраненной игре
    SavedGame game;
    game.name = name;
    game.date = QDateTime::currentDateTime().toString("yyyy-MM-dd hh:mm");
    game.gameMode = vsComputer() ? "vsComputer" : "twoPlayers";
    game.difficulty = difficulty();
    game.status = status();

    // Сохраняем FEN-код позиции
    game.fen = serializePosition(position);

    // Сохраняем историю ходов
    for (const MoveHistoryItem& item : moveHistory) {
        // Проверяем, что координаты валидны
        if (item.moveFrom.x() >= 0 && item.moveFrom.y() >= 0 &&
            item.moveTo.x() >= 0 && item.moveTo.y() >= 0) {
            game.moveFromHistory.append(item.moveFrom);
            game.moveToHistory.append(item.moveTo);
        }
    }

    // Создаем путь к директории сохранений
    QString saveDir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) + "/saves/";
    QDir dir;
    if (!dir.exists(saveDir)) {
        dir.mkpath(saveDir);
    }

    // Генерируем имя файла с временной меткой для уникальности
    QString timestamp = QDateTime::currentDateTime().toString("yyyyMMdd_hhmmss");
    QString filename = saveDir + "game_" + timestamp + ".json";

    // Создаем объект JSON с данными игры
    QJsonObject gameObject;
    gameObject["name"] = game.name;
    gameObject["date"] = game.date;
    gameObject["gameMode"] = game.gameMode;
    gameObject["difficulty"] = game.difficulty;
    gameObject["status"] = game.status;
    gameObject["fen"] = game.fen;
    gameObject["hasLastMove"] = hasLastMove();

    if (hasLastMove()) {
        QJsonObject lastMoveFromObj;
        lastMoveFromObj["x"] = lastMoveFrom.x();
        lastMoveFromObj["y"] = lastMoveFrom.y();
        gameObject["lastMoveFrom"] = lastMoveFromObj;

        QJsonObject lastMoveToObj;
        lastMoveToObj["x"] = lastMoveTo.x();
        lastMoveToObj["y"] = lastMoveTo.y();
        gameObject["lastMoveTo"] = lastMoveToObj;
    }

    // Сохраняем историю ходов
    QJsonArray fromHistoryArray;
    QJsonArray toHistoryArray;
    for (int i = 0; i < game.moveFromHistory.size(); i++) {
        QJsonObject fromObj;
        fromObj["x"] = game.moveFromHistory[i].x();
        fromObj["y"] = game.moveFromHistory[i].y();
        fromHistoryArray.append(fromObj);

        QJsonObject toObj;
        toObj["x"] = game.moveToHistory[i].x();
        toObj["y"] = game.moveToHistory[i].y();
        toHistoryArray.append(toObj);
    }
    gameObject["moveFromHistory"] = fromHistoryArray;
    gameObject["moveToHistory"] = toHistoryArray;

    // Записываем данные в файл
    QJsonDocument doc(gameObject);
    QFile file(filename);
    if (!file.open(QIODevice::WriteOnly)) {
        qWarning() << "Не удалось открыть файл для сохранения:" << filename;
        return false;
    }

    file.write(doc.toJson());
    file.close();

    qDebug() << "Сохранение игры: " << name << " в файл " << filename;
    qDebug() << "Содержимое JSON: " << QString(doc.toJson());

    // Добавляем информацию о сохранении в список
    game.filename = filename;
    savedGames.append(game);

    // Сохраняем список сохраненных игр в настройки
    saveSavedGamesList();

    // Уведомляем UI об изменении списка сохранений
    emit savedGamesChanged();

    return true;
}

bool ChessEngine::saveGameToFile(const SavedGame& game, const QString& filename)
{
    QJsonObject gameObject;
    gameObject["name"] = game.name;
    gameObject["date"] = game.date;
    gameObject["gameMode"] = game.gameMode;
    gameObject["difficulty"] = game.difficulty;
    gameObject["status"] = game.status;
    gameObject["fen"] = game.fen;
    gameObject["whiteTimeLeft"] = game.whiteTimeLeft;
    gameObject["blackTimeLeft"] = game.blackTimeLeft;

    // Сериализуем историю ходов
    QJsonArray moveHistoryArray;
    for (int i = 0; i < game.moveFromHistory.size(); i++) {
        QJsonObject moveFrom;
        moveFrom["x"] = game.moveFromHistory[i].x();
        moveFrom["y"] = game.moveFromHistory[i].y();

        QJsonObject moveTo;
        moveTo["x"] = game.moveToHistory[i].x();
        moveTo["y"] = game.moveToHistory[i].y();

        moveHistoryArray.append(moveFrom);
        moveHistoryArray.append(moveTo);
    }
    gameObject["moveHistory"] = moveHistoryArray;

    QJsonDocument doc(gameObject);
    QFile file(filename);
    if (!file.open(QIODevice::WriteOnly)) {
        qWarning() << "Не удалось открыть файл для сохранения" << filename;
        return false;
    }

    file.write(doc.toJson());
    return true;
}

void ChessEngine::saveSavedGamesList()
{
    QSettings settings;
    settings.beginWriteArray("savedGameFiles");

    QDir saveDir(QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) + "/saves/");
    QFileInfoList files = saveDir.entryInfoList(QStringList() << "game_*.json", QDir::Files);

    for (int i = 0; i < files.size(); i++) {
        settings.setArrayIndex(i);
        settings.setValue("filename", files[i].absoluteFilePath());
    }

    settings.endArray();
}

void ChessEngine::loadSavedGames()
{
    savedGames.clear();
    qDebug() << "Начинаем загрузку сохранённых партий";

    // Путь к директории сохранений
    QString saveDir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) + "/saves/";
    QDir dir(saveDir);

    qDebug() << "Директория сохранений:" << saveDir;

    if (!dir.exists()) {
        dir.mkpath(".");
        qDebug() << "Директория создана";
        emit savedGamesChanged();
        return; // Если директория только что создана, значит нет сохранённых игр
    }

    // Получаем список файлов сохранений напрямую из директории
    QFileInfoList files = dir.entryInfoList(QStringList() << "game_*.json", QDir::Files);
    qDebug() << "Найдено файлов:" << files.size();

    // Загружаем каждый файл сохранения
    for (const QFileInfo& fileInfo : files) {
        QString filename = fileInfo.absoluteFilePath();
        qDebug() << "Загружаем файл:" << filename;

        QFile file(filename);
        if (!file.open(QIODevice::ReadOnly)) {
            qWarning() << "Не удалось открыть файл:" << filename;
            continue;
        }

        QByteArray data = file.readAll();
        file.close();

        QJsonDocument doc = QJsonDocument::fromJson(data);
        QJsonObject obj = doc.object();

        // Проверка валидности JSON
        if (obj.isEmpty()) {
            qWarning() << "Пустой или невалидный JSON в файле:" << filename;
            continue;
        }

        SavedGame game;
        game.name = obj["name"].toString();
        game.date = obj["date"].toString();
        game.gameMode = obj["gameMode"].toString();
        game.difficulty = obj["difficulty"].toInt(2);
        game.status = obj["status"].toString();
        game.fen = obj["fen"].toString();
        game.filename = filename;

        qDebug() << "Загружена партия:" << game.name << "режим:" << game.gameMode
                 << "сложность:" << game.difficulty << "дата:" << game.date;

        // Загружаем историю ходов
        QJsonArray fromHistoryArray = obj["moveFromHistory"].toArray();
        QJsonArray toHistoryArray = obj["moveToHistory"].toArray();

        for (int i = 0; i < fromHistoryArray.size() && i < toHistoryArray.size(); i++) {
            QJsonObject fromObj = fromHistoryArray[i].toObject();
            QJsonObject toObj = toHistoryArray[i].toObject();

            QPoint from(fromObj["x"].toInt(), fromObj["y"].toInt());
            QPoint to(toObj["x"].toInt(), toObj["y"].toInt());

            game.moveFromHistory.append(from);
            game.moveToHistory.append(to);
        }

        // Проверяем валидность FEN если он есть
        if (!game.fen.isEmpty()) {
            try {
                Position testPos = deserializePosition(game.fen);
                savedGames.append(game);
            }
            catch (const std::exception& e) {
                qWarning() << "Невалидное сохранение:" << filename << e.what();
            }
        } else {
            // Даже если FEN пустой, все равно добавляем игру
            // Это нужно для обратной совместимости
            savedGames.append(game);
        }
    }

    qDebug() << "Загружено сохранений:" << savedGames.size();

    // Уведомляем об изменении списка сохранений
    emit savedGamesChanged();
}

bool ChessEngine::loadGame(int slot)
{
    if (slot < 0 || slot >= savedGames.size()) {
        return false;
    }

    const SavedGame& game = savedGames[slot];

    // Устанавливаем режим игры
    if (game.gameMode == "twoPlayers") {
        gameMode = GameMode::TwoPlayers;
    } else {
        gameMode = GameMode::VsComputer;
    }

    // Устанавливаем сложность
    m_difficulty = game.difficulty;

    // Восстанавливаем позицию
    try {
        position = deserializePosition(game.fen);
    }
    catch (const std::exception& e) {
        qWarning() << "Ошибка при загрузке позиции:" << e.what();
        return false;
    }

    // Очищаем и восстанавливаем историю ходов
    moveHistory.clear();

    for (int i = 0; i < game.moveFromHistory.size(); i++) {
        MoveHistoryItem item;
        item.position = position; // Позиция будет той же, что и загруженная
        item.moveFrom = game.moveFromHistory[i];
        item.moveTo = game.moveToHistory[i];
        moveHistory.push(item);
    }

    // Восстанавливаем информацию о последнем ходе
    if (!game.moveFromHistory.isEmpty()) {
        lastMoveFrom = game.moveFromHistory.last();
        lastMoveTo = game.moveToHistory.last();
        hasLastMoveInfo = true;
    } else {
        hasLastMoveInfo = false;
    }

    updateStatus();

    // Уведомляем UI о изменениях
    emit piecesChanged();
    emit statusChanged();
    emit difficultyChanged();
    emit canUndoChanged();
    emit vsComputerEnabled();
    emit lastMoveChanged();

    return true;
}

QVariantList ChessEngine::getSavedGames() const
{
    QVariantList result;
    qDebug() << "getSavedGames вызван. Количество сохранений: " << savedGames.size();

    for (int i = 0; i < savedGames.size(); i++) {
        QVariantMap game;
        game["slot"] = i;
        game["name"] = savedGames[i].name;
        game["date"] = savedGames[i].date;
        game["gameMode"] = savedGames[i].gameMode;
        game["difficulty"] = savedGames[i].difficulty;
        game["status"] = savedGames[i].status;

        qDebug() << "Сохранение #" << i << ": name=" << savedGames[i].name
                 << ", gameMode=" << savedGames[i].gameMode
                 << ", difficulty=" << savedGames[i].difficulty
                 << ", date=" << savedGames[i].date;

        result.append(game);
    }

    return result;
}

bool ChessEngine::deleteGame(int slot)
{
    if (slot < 0 || slot >= savedGames.size()) {
        return false;
    }

    // Находим файл, соответствующий этому сохранению
    QString filename = savedGames[slot].filename;
    QFile file(filename);
    if (file.exists()) {
        file.remove();
        qDebug() << "Удален файл сохранения:" << filename;
    }

    // Удаляем сохранение из списка
    savedGames.removeAt(slot);

    // Обновляем список файлов в настройках
    saveSavedGamesList();

    // Уведомляем UI об изменении списка сохранений
    emit savedGamesChanged();

    return true;
}

void ChessEngine::cleanSavedGames()
{
    // Очищаем настройки
    QSettings settings;
    settings.remove("savedGameFiles");

    // Удаляем все файлы сохранений
    QDir saveDir(QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) + "/saves/");
    if (saveDir.exists()) {
        QFileInfoList files = saveDir.entryInfoList(QStringList() << "game_*.json", QDir::Files);
        for (const QFileInfo& fileInfo : files) {
            QFile file(fileInfo.absoluteFilePath());
            file.remove();
        }
    }

    // Очищаем список сохранений
    savedGames.clear();
    emit savedGamesChanged();

    qDebug() << "Кэш сохранений очищен";
}

Position ChessEngine::deserializePosition(const QString& data)
{
    QStringList parts = data.split("|");
    if (parts.size() < 7) {
        throw std::runtime_error("Недостаточно данных для восстановления позиции");
    }

    std::string fenPart = parts[0].trimmed().toStdString();
    uint8_t enPassant = parts[1].toUInt();
    bool wlCastling = parts[2].toInt() != 0;
    bool wsCastling = parts[3].toInt() != 0;
    bool blCastling = parts[4].toInt() != 0;
    bool bsCastling = parts[5].toInt() != 0;
    float moveCtr = parts[6].toInt() != 0 ? 1.0f : 1.5f;

    // Проверка валидности FEN
    int pieceCount = 0;
    int slashCount = 0;

    for (char c : fenPart) {
        if (c == '/') slashCount++;
        else if (isalpha(c)) pieceCount++;
    }

    if (slashCount != 7 || pieceCount < 2) {
        throw std::runtime_error("Неверный формат FEN");
    }

    // Создаем новую позицию
    Position position(fenPart, enPassant, wlCastling, wsCastling, blCastling, bsCastling, moveCtr);

    // Дополнительная валидация
    if (BOp::count1(position.getPieces().getAllBitboard()) < 2) {
        throw std::runtime_error("Недостаточно фигур на доске");
    }

    return position;
}

QString ChessEngine::serializePosition(const Position& pos) const
{
    // Формируем FEN позиции
    QString fenStr = positionToFEN(pos);

    // Добавляем дополнительную информацию
    fenStr += "|" + QString::number(pos.getEnPassant());
    fenStr += "|" + QString::number(pos.getWLCastling() ? 1 : 0);
    fenStr += "|" + QString::number(pos.getWSCastling() ? 1 : 0);
    fenStr += "|" + QString::number(pos.getBLCastling() ? 1 : 0);
    fenStr += "|" + QString::number(pos.getBSCastling() ? 1 : 0);
    fenStr += "|" + QString::number(pos.whiteToMove() ? 1 : 0);

    return fenStr;
}

QString ChessEngine::positionToFEN(const Position& pos) const
{
    std::ostringstream fenStream;

    const Pieces& pieces = pos.getPieces();

    for (int rank = 7; rank >= 0; rank--) {
        int emptyCount = 0;

        for (int file = 0; file < 8; file++) {
            int index = rank * 8 + file;

            if (BOp::getBit(pieces.getPieceBitboard(SIDE::WHITE, PIECE::PAWN), index))
            { if (emptyCount > 0) { fenStream << emptyCount; emptyCount = 0; } fenStream << "P"; }
            else if (BOp::getBit(pieces.getPieceBitboard(SIDE::WHITE, PIECE::KNIGHT), index))
            { if (emptyCount > 0) { fenStream << emptyCount; emptyCount = 0; } fenStream << "N"; }
            else if (BOp::getBit(pieces.getPieceBitboard(SIDE::WHITE, PIECE::BISHOP), index))
            { if (emptyCount > 0) { fenStream << emptyCount; emptyCount = 0; } fenStream << "B"; }
            else if (BOp::getBit(pieces.getPieceBitboard(SIDE::WHITE, PIECE::ROOK), index))
            { if (emptyCount > 0) { fenStream << emptyCount; emptyCount = 0; } fenStream << "R"; }
            else if (BOp::getBit(pieces.getPieceBitboard(SIDE::WHITE, PIECE::QUEEN), index))
            { if (emptyCount > 0) { fenStream << emptyCount; emptyCount = 0; } fenStream << "Q"; }
            else if (BOp::getBit(pieces.getPieceBitboard(SIDE::WHITE, PIECE::KING), index))
            { if (emptyCount > 0) { fenStream << emptyCount; emptyCount = 0; } fenStream << "K"; }
            else if (BOp::getBit(pieces.getPieceBitboard(SIDE::BLACK, PIECE::PAWN), index))
            { if (emptyCount > 0) { fenStream << emptyCount; emptyCount = 0; } fenStream << "p"; }
            else if (BOp::getBit(pieces.getPieceBitboard(SIDE::BLACK, PIECE::KNIGHT), index))
            { if (emptyCount > 0) { fenStream << emptyCount; emptyCount = 0; } fenStream << "n"; }
            else if (BOp::getBit(pieces.getPieceBitboard(SIDE::BLACK, PIECE::BISHOP), index))
            { if (emptyCount > 0) { fenStream << emptyCount; emptyCount = 0; } fenStream << "b"; }
            else if (BOp::getBit(pieces.getPieceBitboard(SIDE::BLACK, PIECE::ROOK), index))
            { if (emptyCount > 0) { fenStream << emptyCount; emptyCount = 0; } fenStream << "r"; }
            else if (BOp::getBit(pieces.getPieceBitboard(SIDE::BLACK, PIECE::QUEEN), index))
            { if (emptyCount > 0) { fenStream << emptyCount; emptyCount = 0; } fenStream << "q"; }
            else if (BOp::getBit(pieces.getPieceBitboard(SIDE::BLACK, PIECE::KING), index))
            { if (emptyCount > 0) { fenStream << emptyCount; emptyCount = 0; } fenStream << "k"; }
            else
                emptyCount++;
        }

        if (emptyCount > 0)
            fenStream << emptyCount;

        if (rank > 0)
            fenStream << "/";
    }

    return QString::fromStdString(fenStream.str());
}

ChessEngine::SavedGame ChessEngine::loadGameFromFile(const QString& filename)
{
    SavedGame game;

    QFile file(filename);
    if (!file.open(QIODevice::ReadOnly)) {
        qWarning() << "Не удалось открыть файл" << filename;
        return game;
    }

    QByteArray data = file.readAll();
    QJsonDocument doc = QJsonDocument::fromJson(data);
    QJsonObject obj = doc.object();

    game.name = obj["name"].toString();
    game.date = obj["date"].toString();
    game.gameMode = obj["gameMode"].toString();
    game.difficulty = obj["difficulty"].toInt();
    game.status = obj["status"].toString();
    game.fen = obj["fen"].toString();
    game.whiteTimeLeft = obj["whiteTimeLeft"].toInt(0);
    game.blackTimeLeft = obj["blackTimeLeft"].toInt(0);

    // Загружаем историю ходов
    QJsonArray moveHistory = obj["moveHistory"].toArray();
    for (int j = 0; j < moveHistory.size(); j += 2) {
        if (j + 1 >= moveHistory.size()) break;

        QJsonObject fromObj = moveHistory[j].toObject();
        QJsonObject toObj = moveHistory[j+1].toObject();

        QPoint from(fromObj["x"].toInt(), fromObj["y"].toInt());
        QPoint to(toObj["x"].toInt(), toObj["y"].toInt());

        game.moveFromHistory.append(from);
        game.moveToHistory.append(to);
    }

    return game;
}

QString ChessEngine::getMoveHistoryJson() const
{
    QJsonArray historyArray;
    for (const MoveHistoryItem& item : moveHistory) {
        QJsonObject fromObj;
        fromObj["x"] = item.moveFrom.x();
        fromObj["y"] = item.moveFrom.y();

        QJsonObject toObj;
        toObj["x"] = item.moveTo.x();
        toObj["y"] = item.moveTo.y();

        historyArray.append(fromObj);
        historyArray.append(toObj);
    }

    QJsonDocument doc(historyArray);
    return QString(doc.toJson());
}

void ChessEngine::setMoveHistoryFromJson(const QString& historyJson)
{
    moveHistory.clear();

    QJsonDocument doc = QJsonDocument::fromJson(historyJson.toUtf8());
    QJsonArray historyArray = doc.array();

    for (int i = 0; i < historyArray.size(); i += 2) {
        QJsonObject fromObj = historyArray[i].toObject();
        QJsonObject toObj = historyArray[i+1].toObject();

        MoveHistoryItem item;
        item.position = position; // Используем текущую позицию, т.к. полных предыдущих нет
        item.moveFrom = QPoint(fromObj["x"].toInt(), fromObj["y"].toInt());
        item.moveTo = QPoint(toObj["x"].toInt(), toObj["y"].toInt());

        moveHistory.push(item);
    }

    if (!moveHistory.isEmpty()) {
        MoveHistoryItem lastItem = moveHistory.top();
        lastMoveFrom = lastItem.moveFrom;
        lastMoveTo = lastItem.moveTo;
        hasLastMoveInfo = true;
    } else {
        hasLastMoveInfo = false;
    }

    emit canUndoChanged();
    emit vsComputerEnabled();
    emit lastMoveChanged();
}
