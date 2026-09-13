#include "BluetoothManager.h"

#include <QDebug>

#include <BluezQt/InitManagerJob>
#include <BluezQt/PendingCall>

BluetoothDeviceModel::BluetoothDeviceModel(QObject *parent)
: QAbstractListModel(parent)
{
}

int BluetoothDeviceModel::rowCount(
    const QModelIndex &parent
) const
{
    if (parent.isValid())
        return 0;

    return m_devices.size();
}

QVariant BluetoothDeviceModel::data(
    const QModelIndex &index,
    int role
) const
{
    if (!index.isValid() ||
        index.row() < 0 ||
        index.row() >= m_devices.size()) {
        return {};
        }

        const auto device = m_devices.at(index.row());

    if (!device)
        return {};

    switch (role) {
        case NameRole:
            return device->name();

        case ConnectedRole:
            return device->isConnected();

        case PairedRole:
            return device->isPaired();

        case AddressRole:
            return device->address();

        default:
            return {};
    }
}

QHash<int, QByteArray>
BluetoothDeviceModel::roleNames() const
{
    return {
        { NameRole, "name" },
        { ConnectedRole, "connected" },
        { PairedRole, "paired" },
        { AddressRole, "address" }
    };
}

void BluetoothDeviceModel::setDevices(
    const QList<BluezQt::DevicePtr> &devices
)
{
    beginResetModel();
    m_devices = devices;
    endResetModel();
}


BluetoothManager::BluetoothManager(QObject *parent)
: QObject(parent)
, m_manager(this)
, m_devices(this)
{
    connect(
        &m_manager,
        &BluezQt::Manager::adapterAdded,
        this,
        &BluetoothManager::adapterAdded
    );

    connect(
        &m_manager,
        &BluezQt::Manager::adapterChanged,
        this,
        &BluetoothManager::adapterChanged
    );

    connect(
        &m_manager,
        &BluezQt::Manager::adapterRemoved,
        this,
        &BluetoothManager::adapterRemoved
    );

    connect(
        &m_manager,
        &BluezQt::Manager::usableAdapterChanged,
        this,
        &BluetoothManager::usableAdapterChanged
    );

    connect(
        &m_manager,
        &BluezQt::Manager::deviceAdded,
        this,
        &BluetoothManager::deviceAdded
    );

    connect(
        &m_manager,
        &BluezQt::Manager::deviceChanged,
        this,
        &BluetoothManager::deviceChanged
    );

    connect(
        &m_manager,
        &BluezQt::Manager::deviceRemoved,
        this,
        &BluetoothManager::deviceRemoved
    );

    m_initJob = m_manager.init();

    connect(
        m_initJob,
        &BluezQt::InitManagerJob::result,
        this,
        &BluetoothManager::initializeFinished
    );

    m_initJob->start();
}

void BluetoothManager::initializeFinished()
{
    m_initJob = nullptr;

    connectAdapter(
        m_manager.usableAdapter()
    );

    refreshDevices();

    emit poweredChanged();
    emit discoveringChanged();
}

BluezQt::AdapterPtr BluetoothManager::adapter() const
{
    /*
     * usableAdapter() specifically returns a powered adapter.
     *
     * If Bluetooth is currently powered off, fall back to the
     * first available adapter so that setPowered(true) can turn
     * it back on.
     */

    const auto usable = m_manager.usableAdapter();

    if (usable)
        return usable;

    const auto adapters = m_manager.adapters();

    if (!adapters.isEmpty())
        return adapters.first();

    return {};
}

bool BluetoothManager::powered() const
{
    const auto a = adapter();

    return a && a->isPowered();
}

bool BluetoothManager::discovering() const
{
    const auto a = adapter();

    return a && a->isDiscovering();
}

QObject *BluetoothManager::devices()
{
    return &m_devices;
}

void BluetoothManager::connectAdapter(
    const BluezQt::AdapterPtr &adapterPtr
)
{
    if (!adapterPtr)
        return;

    if (m_connectedAdapter == adapterPtr)
        return;

    if (m_connectedAdapter) {
        disconnect(
            m_connectedAdapter.data(),
                   nullptr,
                   this,
                   nullptr
        );
    }

    m_connectedAdapter = adapterPtr;

    connect(
        m_connectedAdapter.data(),
            &BluezQt::Adapter::poweredChanged,
            this,
            &BluetoothManager::adapterPoweredChanged
    );

    connect(
        m_connectedAdapter.data(),
            &BluezQt::Adapter::discoveringChanged,
            this,
            &BluetoothManager::adapterDiscoveringChanged
    );

    connect(
        m_connectedAdapter.data(),
            &BluezQt::Adapter::deviceAdded,
            this,
            [this](BluezQt::DevicePtr) {
                refreshDevices();
            }
    );

    connect(
        m_connectedAdapter.data(),
            &BluezQt::Adapter::deviceChanged,
            this,
            [this](BluezQt::DevicePtr) {
                refreshDevices();
            }
    );

    connect(
        m_connectedAdapter.data(),
            &BluezQt::Adapter::deviceRemoved,
            this,
            [this](BluezQt::DevicePtr) {
                refreshDevices();
            }
    );

    emit poweredChanged();
    emit discoveringChanged();
}

void BluetoothManager::refreshDevices()
{
    QList<BluezQt::DevicePtr> devices;

    const auto adapters = m_manager.adapters();

    for (const auto &adapterPtr : adapters) {
        if (!adapterPtr)
            continue;

        const auto adapterDevices = adapterPtr->devices();

        for (const auto &device : adapterDevices) {
            if (!device)
                continue;

            bool alreadyPresent = false;

            for (const auto &existing : devices) {
                if (existing &&
                    existing->address() == device->address()) {
                    alreadyPresent = true;
                break;
                    }
            }

            if (!alreadyPresent)
                devices.append(device);
        }
    }

    m_devices.setDevices(devices);
}

void BluetoothManager::adapterAdded(
    BluezQt::AdapterPtr adapterPtr
)
{
    connectAdapter(adapterPtr);
    refreshDevices();

    emit poweredChanged();
    emit discoveringChanged();
}

void BluetoothManager::adapterChanged(
    BluezQt::AdapterPtr adapterPtr
)
{
    if (!adapterPtr)
        return;

    if (adapterPtr == m_connectedAdapter)
        emit poweredChanged();

    refreshDevices();
}

void BluetoothManager::adapterRemoved(
    BluezQt::AdapterPtr adapterPtr
)
{
    if (adapterPtr == m_connectedAdapter) {
        m_connectedAdapter.clear();

        connectAdapter(
            m_manager.usableAdapter()
        );
    }

    refreshDevices();

    emit poweredChanged();
    emit discoveringChanged();
}

void BluetoothManager::usableAdapterChanged(
    BluezQt::AdapterPtr adapterPtr
)
{
    connectAdapter(adapterPtr);
    refreshDevices();

    emit poweredChanged();
    emit discoveringChanged();
}

void BluetoothManager::deviceAdded(
    BluezQt::DevicePtr
)
{
    refreshDevices();
}

void BluetoothManager::deviceChanged(
    BluezQt::DevicePtr
)
{
    refreshDevices();
}

void BluetoothManager::deviceRemoved(
    BluezQt::DevicePtr
)
{
    refreshDevices();
}

void BluetoothManager::adapterPoweredChanged(
    bool
)
{
    refreshDevices();
    emit poweredChanged();
}

void BluetoothManager::adapterDiscoveringChanged(
    bool
)
{
    emit discoveringChanged();
}

void BluetoothManager::togglePowered()
{
    const auto a = adapter();

    if (!a)
        return;

    const bool newState = !a->isPowered();

    qDebug()
    << "Stratara Bluetooth:"
    << (newState ? "powering on" : "powering off");

    a->setPowered(newState);
}

void BluetoothManager::startDiscovery()
{
    const auto a = adapter();

    if (!a || !a->isPowered())
        return;

    if (a->isDiscovering()) {
        a->stopDiscovery();
    } else {
        a->startDiscovery();
    }
}

void BluetoothManager::toggleDeviceConnection(
    const QString &address
)
{
    const auto device = m_manager.deviceForAddress(address);

    if (!device)
        return;

    if (device->isConnected()) {
        device->disconnectFromDevice();
    } else {
        device->connectToDevice();
    }
}
