#pragma once

#include <QAbstractListModel>
#include <QObject>
#include <QHash>
#include <QString>
#include <QVariant>

#include <BluezQt/Adapter>
#include <BluezQt/Device>
#include <BluezQt/Manager>

class BluetoothDeviceModel final : public QAbstractListModel
{
    Q_OBJECT

public:
    enum Roles {
        NameRole = Qt::UserRole + 1,
        ConnectedRole,
        PairedRole,
        AddressRole
    };

    explicit BluetoothDeviceModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;

    QVariant data(
        const QModelIndex &index,
        int role = Qt::DisplayRole
    ) const override;

    QHash<int, QByteArray> roleNames() const override;

    void setDevices(const QList<BluezQt::DevicePtr> &devices);

private:
    QList<BluezQt::DevicePtr> m_devices;
};

class BluetoothManager final : public QObject
{
    Q_OBJECT

    Q_PROPERTY(
        bool powered
        READ powered
        NOTIFY poweredChanged
    )

    Q_PROPERTY(
        bool discovering
        READ discovering
        NOTIFY discoveringChanged
    )

    Q_PROPERTY(
        QObject *devices
        READ devices
        CONSTANT
    )

public:
    explicit BluetoothManager(QObject *parent = nullptr);

    bool powered() const;
    bool discovering() const;
    QObject *devices();

    Q_INVOKABLE void togglePowered();
    Q_INVOKABLE void startDiscovery();
    Q_INVOKABLE void toggleDeviceConnection(
        const QString &address
    );

signals:
    void poweredChanged();
    void discoveringChanged();

private slots:
    void initializeFinished();

    void adapterAdded(
        BluezQt::AdapterPtr adapter
    );

    void adapterChanged(
        BluezQt::AdapterPtr adapter
    );

    void adapterRemoved(
        BluezQt::AdapterPtr adapter
    );

    void usableAdapterChanged(
        BluezQt::AdapterPtr adapter
    );

    void deviceAdded(
        BluezQt::DevicePtr device
    );

    void deviceChanged(
        BluezQt::DevicePtr device
    );

    void deviceRemoved(
        BluezQt::DevicePtr device
    );

    void adapterPoweredChanged(
        bool powered
    );

    void adapterDiscoveringChanged(
        bool discovering
    );

private:
    BluezQt::AdapterPtr adapter() const;

    void connectAdapter(
        const BluezQt::AdapterPtr &adapter
    );

    void refreshDevices();

    BluezQt::Manager m_manager;
    BluetoothDeviceModel m_devices;

    BluezQt::AdapterPtr m_connectedAdapter;
    BluezQt::InitManagerJob *m_initJob = nullptr;
};
