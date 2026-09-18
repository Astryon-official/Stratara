#include "SystemManager.h"

#include <QProcess>

SystemManager::SystemManager(QObject *parent)
    : QObject(parent)
{
    refreshWifi();
}

bool SystemManager::wifiEnabled() const
{
    return m_wifiEnabled;
}

QString SystemManager::wifiConnection() const
{
    return m_wifiConnection;
}

QStringList SystemManager::wifiNetworks() const
{
    return m_wifiNetworks;
}

bool SystemManager::ethernetConnected() const
{
    return m_ethernetConnected;
}

QString SystemManager::ethernetConnection() const
{
    return m_ethernetConnection;
}

void SystemManager::refreshWifi()
{
    // Wi-Fi enabled/disabled state
    QProcess wifiState;

    wifiState.start(
        "nmcli",
        {
            "-t",
            "-f",
            "WIFI",
            "general"
        }
    );

    if (wifiState.waitForFinished(3000)) {
        const QString state =
            QString::fromUtf8(
                wifiState.readAllStandardOutput()
            ).trimmed();

        const bool enabled = (state == "enabled");

        if (m_wifiEnabled != enabled) {
            m_wifiEnabled = enabled;
            emit wifiEnabledChanged();
        }
    }

    // Current Wi-Fi connection
    QProcess connection;

    connection.start(
        "nmcli",
        {
            "-t",
            "-f",
            "ACTIVE,SSID",
            "device",
            "wifi"
        }
    );

    if (connection.waitForFinished(3000)) {
        const QString output =
            QString::fromUtf8(
                connection.readAllStandardOutput()
            );

        QString currentConnection;

        for (const QString &line :
             output.split('\n', Qt::SkipEmptyParts)) {

            if (line.startsWith("yes:")) {
                currentConnection = line.section(':', 1);
                break;
            }
        }

        if (m_wifiConnection != currentConnection) {
            m_wifiConnection = currentConnection;
            emit wifiConnectionChanged();
        }
    }

    // Available Wi-Fi networks
    QProcess networks;

    networks.start(
        "nmcli",
        {
            "-t",
            "-f",
            "SSID",
            "device",
            "wifi",
            "list",
            "--rescan",
            "no"
        }
    );

    if (networks.waitForFinished(5000)) {
        const QString output =
            QString::fromUtf8(
                networks.readAllStandardOutput()
            );

        QStringList newNetworks;

        for (const QString &line :
             output.split('\n', Qt::SkipEmptyParts)) {

            const QString ssid = line.trimmed();

            if (!ssid.isEmpty() &&
                !newNetworks.contains(ssid)) {
                newNetworks.append(ssid);
            }
        }

        if (m_wifiNetworks != newNetworks) {
            m_wifiNetworks = newNetworks;
            emit wifiNetworksChanged();
        }
    }

    // Ethernet connection
    QProcess ethernet;

    ethernet.start(
        "nmcli",
        {
            "-t",
            "-f",
            "DEVICE,TYPE,STATE,CONNECTION",
            "device"
        }
    );

    if (ethernet.waitForFinished(3000)) {
        const QString output =
            QString::fromUtf8(
                ethernet.readAllStandardOutput()
            );

        bool connected = false;
        QString connectionName;

        for (const QString &line :
             output.split('\n', Qt::SkipEmptyParts)) {

            const QStringList parts =
                line.split(':');

            if (parts.size() >= 4 &&
                parts[1] == "ethernet" &&
                parts[2] == "connected") {

                connected = true;
                connectionName = parts[3];
                break;
            }
        }

        if (m_ethernetConnected != connected) {
            m_ethernetConnected = connected;
            emit ethernetConnectedChanged();
        }

        if (m_ethernetConnection != connectionName) {
            m_ethernetConnection = connectionName;
            emit ethernetConnectionChanged();
        }
    }
}

void SystemManager::connectWifi(const QString &ssid)
{
    if (ssid.isEmpty())
        return;

    QProcess::startDetached(
        "nmcli",
        {
            "device",
            "wifi",
            "connect",
            ssid
        }
    );

    refreshWifi();
}

void SystemManager::toggleWifi()
{
    setWifiEnabled(!m_wifiEnabled);
}

void SystemManager::setWifiEnabled(bool enabled)
{
    QProcess::startDetached(
        "nmcli",
        {
            "radio",
            "wifi",
            enabled ? "on" : "off"
        }
    );

    m_wifiEnabled = enabled;
    emit wifiEnabledChanged();

    if (!enabled) {
        if (!m_wifiConnection.isEmpty()) {
            m_wifiConnection.clear();
            emit wifiConnectionChanged();
        }

        if (!m_wifiNetworks.isEmpty()) {
            m_wifiNetworks.clear();
            emit wifiNetworksChanged();
        }
    } else {
        refreshWifi();
    }
}

void SystemManager::lock()
{
    QProcess::startDetached(
        "loginctl",
        {
            "lock-session"
        }
    );
}

void SystemManager::logout()
{
    QProcess::startDetached(
        "loginctl",
        {
            "terminate-user",
            qEnvironmentVariable("USER")
        }
    );
}

void SystemManager::sleep()
{
    QProcess::startDetached(
        "systemctl",
        {
            "suspend"
        }
    );
}

void SystemManager::shutdown()
{
    QProcess::startDetached(
        "systemctl",
        {
            "poweroff"
        }
    );
}
