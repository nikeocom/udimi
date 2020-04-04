#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include "api/apiclient.h"

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);

    ApiClient client;
    // Естественно должно быть где то в конфигах.
    client.setBaseUrl("https://api.quwi.com/v2");

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("client", &client);

    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
        &app, [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
