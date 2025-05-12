#pragma once

#include <QObject>
#include <QHash>
#include <QString>

class ResourceManager : public QObject
{
    Q_OBJECT

public:
    explicit ResourceManager(QObject *parent = nullptr);

    Q_INVOKABLE QString getTexturePath(const QString& name) const;

private:
    QHash<QString, QString> texturePaths;
};
