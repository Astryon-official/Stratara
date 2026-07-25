#include <QApplication>
#include <QWidget>
#include <QLabel>
#include <QVBoxLayout>

#include "core/AstryonCore.hpp"
#include "ui/AstryonUI.hpp"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    AstryonCore core;
    core.initialize();

    QWidget window;
    window.setWindowTitle("Astryon Home");

    QLabel title("Astryon Home");

    QVBoxLayout layout;
    layout.addWidget(&title);

    window.setLayout(&layout);

    window.resize(800, 450);
    window.show();

    int result = app.exec();

    core.shutdown();

    return result;
}