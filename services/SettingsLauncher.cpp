#include "SettingsLauncher.h"

#include <QProcess>

SettingsLauncher::SettingsLauncher(QObject *parent)
: QObject(parent)
{
}

void SettingsLauncher::open()
{
    QProcess::startDetached(QStringLiteral("systemsettings"));
}
