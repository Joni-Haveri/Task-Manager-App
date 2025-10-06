// Sisällytetään QGuiApplication-luokka, joka hallinnoi sovelluksen elinkaaren ja tapahtumasilmukan.
#include <QGuiApplication>

// Sisällytetään QQmlApplicationEngine, joka lataa ja näyttää QML-käyttöliittymän.
#include <QQmlApplicationEngine>

// Pääohjelma, sovellus käynnistyy täältä. argc ja argv mahdollistavat komentoriviparametrien käytön.
int main(int argc, char *argv[])
{

    // Luodaan QGuiApplication-objekti "app". Tämä hallitsee sovelluksen tapahtumasilmukkaa,
    // resurssien hallintaa ja alustaa GUI-ympäristön.
    QGuiApplication app(argc, argv);


    // Luodaan QQmlApplicationEngine-objekti "engine". Se lataa QML-tiedostot ja liittää ne C++-sovellukseen.
    QQmlApplicationEngine engine;


    // Yhdistetään signaali 'objectCreationFailed' (joka laukeaa, jos QML:n pääobjektia ei pystytä luomaan)
    // slot-funktioon, joka sulkee sovelluksen virhekoodilla -1.
    // Qt::QueuedConnection tarkoittaa, että kutsu tapahtuu turvallisesti tapahtumasilmukassa.
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);


    // Ladataan QML-moduuli nimeltä "TaskManager" ja sen pääobjekti "Main".
    // Tämä vastaa käyttöliittymän käynnistämistä QML:ssä.
    engine.loadFromModule("TaskManager", "Main");


    // Käynnistetään sovelluksen tapahtumasilmukka.
    // Sovellus pysyy tässä silmukassa, kunnes käyttäjä sulkee sen tai tapahtumasilmukka päättyy.
    return app.exec();
}
