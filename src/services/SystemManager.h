#pragma once

#include <QObject>
#include <QStringList>

class SystemManager final : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool wifiEnabled READ wifiEnabled NOTIFY wifiEnabledChanged)
    Q_PROPERTY(QString wifiConnection READ wifiConnection NOTIFY wifiConnectionChanged)
    Q_PROPERTY(QStringList wifiNetworks READ wifiNetworks NOTIFY wifiNetworksChanged)

public:
    explicit SystemManager(QObject *parent = nullptr);

    bool wifiEnabled() const { return m_wifiEnabled; }
    QString wifiConnection() const { return m_wifiConnection; }
    QStringList wifiNetworks() const { return m_wifiNetworks; }

    Q_INVOKABLE void refreshWifi();
    Q_INVOKABLE void toggleWifi();
    Q_INVOKABLE void connectWifi(const QString &ssid);
    Q_INVOKABLE void lock();
    Q_INVOKABLE void logout();
    Q_INVOKABLE void sleep();
    Q_INVOKABLE void shutdown();

signals:
    void wifiEnabledChanged();
    void wifiConnectionChanged();
    void wifiNetworksChanged();

private:
    void setWifiEnabled(bool value);
    void setWifiConnection(const QString &value);
    void setWifiNetworks(const QStringList &value);

    bool m_wifiEnabled = false;
    QString m_wifiConnection;
    QStringList m_wifiNetworks;
};
