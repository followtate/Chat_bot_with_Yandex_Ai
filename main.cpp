#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "ApiClient.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    qmlRegisterType<ApiClient>("AI", 1, 0, "ApiClient"); // Регистрация типа API Client
    QQmlApplicationEngine engine;
    engine.loadFromModule("app_ai", "Main");
    return app.exec();
}

