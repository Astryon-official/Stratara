#include "SettingsLauncher.h"

#include <QProcess>

SettingsLauncher::SettingsLauncher(QObject *parent)
: QObject(parent)
{
}

void SettingsLauncher::open()
{
    QProcess::startDetached("noctalia", {"msg", "settings-open"});
}
