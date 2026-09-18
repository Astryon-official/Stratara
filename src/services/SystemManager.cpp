#include "SystemManager.h"

#include <QProcess>
#include <QRegularExpression>

namespace {
QString runCommand(const QString &program, const QStringList &args)
{
    QProcess process;
    process.start(program, args);

    if (!process.waitForFinished(3000))
        return {};

    return QString::fromUtf8(process.readAllStandardOutput()).trimmed();
}
}

SystemManager::SystemManager(QObject *parent)
    : QObject(parent)
{
    refreshWifi();
}

void SystemManager::setWifiEnabled(bool value)
{
    if (m_wifiEnabled == value)
        return;

    m_wifiEnabled = value;
    emit wifiEnabledChanged();
}

void SystemManager::setWifiConnection(const QString &value)
{
    if (m_wifiConnection == value)
        return;

    m_wifiConnection = value;
    emit wifiConnectionChanged();
}

void SystemManager::setWifiNetworks(const QStringList &value)
{
    if (m_wifiNetworks == value)
        return;

    m_wifiNetworks = value;
    emit wifiNetworksChanged();
}

void SystemManager::refreshWifi()
{
    const QString radio = runCommand("nmcli", {"radio", "wifi"});
    setWifiEnabled(radio.compare("enabled", Qt::CaseInsensitive) == 0);

    const QString active = runCommand(
        "nmcli",
        {"-t", "-f", "ACTIVE,SSID", "dev", "wifi"}
    );

    QString connection;
    for (const QString &line : active.split("
", Qt::SkipEmptyParts)) {
        const QStringList parts = line.split(:);
        if (parts.size() >= 2 && parts.first() == "yes") {
            connection = parts.mid(1).join(:);
            break;
        }
    }
    setWifiConnection(connection);

    const QString list = runCommand(
        "nmcli",
        {"-t", "-f", "SSID", "dev", "wifi", "list"}
    );

    QStringList networks;
    for (const QString &line : list.split("
", Qt::SkipEmptyParts)) {
        const QString ssid = line.trimmed();
        if (!ssid.isEmpty() && !networks.contains(ssid))
            networks.append(ssid);
    }

    setWifiNetworks(networks);
}

void SystemManager::toggleWifi()
{
    runCommand("nmcli", {"radio", "wifi", m_wifiEnabled ? "off" : "on"});
    refreshWifi();
}

void SystemManager::connectWifi(const QString &ssid)
{
    runCommand("nmcli", {"device", "wifi", "connect", ssid});
    refreshWifi();
}

void SystemManager::lock()
{
    QProcess::startDetached("loginctl", {"lock-session"});
}

void SystemManager::logout()
{
    QProcess::startDetached("loginctl", {"terminate-user", QString::number(qgetenv("UID").toUInt())});
}

void SystemManager::sleep()
{
    QProcess::startDetached("systemctl", {"suspend"});
}

void SystemManager::shutdown()
{
    QProcess::startDetached("systemctl", {"poweroff"});
}
