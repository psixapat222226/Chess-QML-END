#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "ChessEngine.h"
#include "ResourceManager.h"
#include <QIcon>

int main(int argc, char *argv[])
{
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    ResourceManager resourceManager;
    ChessEngine chessEngine;
    app.setWindowIcon(QIcon(":/resources/images/logotype3.png"));

    engine.rootContext()->setContextProperty("resourceManager", &resourceManager);
    engine.rootContext()->setContextProperty("chessEngine", &chessEngine);

    // Изменяем путь к QML файлу
    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
                         if (!obj && url == objUrl)
                             QCoreApplication::exit(-1);
                     }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
