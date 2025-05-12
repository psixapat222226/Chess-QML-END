#include "ResourceManager.h"

ResourceManager::ResourceManager(QObject *parent) : QObject(parent)
{
    // Инициализация путей к текстурам
    texturePaths["whitePawn"] = "qrc:/resources/images/chessmen/white/pawn.png";
    texturePaths["whiteKnight"] = "qrc:/resources/images/chessmen/white/knight.png";
    texturePaths["whiteBishop"] = "qrc:/resources/images/chessmen/white/bishop.png";
    texturePaths["whiteRook"] = "qrc:/resources/images/chessmen/white/rook.png";
    texturePaths["whiteQueen"] = "qrc:/resources/images/chessmen/white/queen.png";
    texturePaths["whiteKing"] = "qrc:/resources/images/chessmen/white/king.png";
    texturePaths["blackPawn"] = "qrc:/resources/images/chessmen/black/pawn.png";
    texturePaths["blackKnight"] = "qrc:/resources/images/chessmen/black/knight.png";
    texturePaths["blackBishop"] = "qrc:/resources/images/chessmen/black/bishop.png";
    texturePaths["blackRook"] = "qrc:/resources/images/chessmen/black/rook.png";
    texturePaths["blackQueen"] = "qrc:/resources/images/chessmen/black/queen.png";
    texturePaths["blackKing"] = "qrc:/resources/images/chessmen/black/king.png";
}

QString ResourceManager::getTexturePath(const QString& name) const
{
    return texturePaths.value(name, QString());
}
