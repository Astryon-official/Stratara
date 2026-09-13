#pragma once

#include <QObject>

class SettingsLauncher final : public QObject
{
    Q_OBJECT

public:
    explicit SettingsLauncher(QObject *parent = nullptr);

public slots:
    void open();
};
