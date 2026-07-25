#include <QApplication>
#include <QWidget>
#include <QLabel>
#include <QVBoxLayout>

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    QWidget window;
    window.setWindowTitle("Astryon Home");

    QLabel title("Astryon Home");

    QVBoxLayout layout;
    layout.addWidget(&title);

    window.setLayout(&layout);

    window.resize(800, 450);
    window.show();

    return app.exec();
}
