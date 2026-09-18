#pragma once

#include <QObject>
#include <QStringList>

class SystemManager final : public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool wifiEnabled READ wifiEnabled NOTIFY wifiEnabledChanged)
    Q_PROPERTY(QString wifiConnection READ wifiConnection NOTIFY wifiConnectionChanged)
    Q_PROPERTY(QStringList wifiNetworks READ wifiNetworks NOTIFY wifiNetworksChanged)

    Q_PROPERTY(bool ethernetConnected READ ethernetConnected NOTIFY ethernetConnectedChanged)
    Q_PROPERTY(QString ethernetConnection READ ethernetConnection NOTIFY ethernetConnectionChanged)

public:
    explicit SystemManager(QObject *parent = nullptr);

    bool wifiEnabled() const;
    QString wifiConnection() const;
    QStringList wifiNetworks() const;

    bool ethernetConnected() const;
    QString ethernetConnection() const;

    Q_INVOKABLE void refreshWifi();
    Q_INVOKABLE void connectWifi(const QString &ssid);
    Q_INVOKABLE void toggleWifi();

    Q_INVOKABLE void lock();
    Q_INVOKABLE void logout();
    Q_INVOKABLE void sleep();
    Q_INVOKABLE void shutdown();

signals:
    void wifiEnabledChanged();
    void wifiConnectionChanged();
    void wifiNetworksChanged();

    void ethernetConnectedChanged();
    void ethernetConnectionChanged();

private:
    void setWifiEnabled(bool enabled);

    bool m_wifiEnabled = false;
    QString m_wifiConnection;
    QStringList m_wifiNetworks;

    bool m_ethernetConnected = false;
    QString m_ethernetConnection;
};
