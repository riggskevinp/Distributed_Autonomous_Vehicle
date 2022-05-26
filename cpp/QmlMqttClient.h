#ifndef QMLMQTTCLIENT_H
#define QMLMQTTCLIENT_H

#include <QtCore/QMap>
#include <QtMqtt/QMqttClient>
#include <QtMqtt/QMqttSubscription>
#include <QtPositioning>

#include "machine.pb.h"

class QmlMqttClient;

class QmlMqttSubscription : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QMqttTopicFilter topic MEMBER m_topic NOTIFY topicChanged)
public:
    QmlMqttSubscription(QMqttSubscription *s, QmlMqttClient *c);
    ~QmlMqttSubscription();
    Q_INVOKABLE void publishLocation(const QString &topic, const double lat, const double lon);

Q_SIGNALS:
    void topicChanged(QString);
    void messageReceived(const QString &name, const QGeoCoordinate& location, const QString &model);

public slots:
    void handleMessage(const QMqttMessage &qmsg);

private:
    Q_DISABLE_COPY(QmlMqttSubscription)
    QMqttSubscription *sub;
    QmlMqttClient *client;
    QMqttTopicFilter m_topic;
};

class QmlMqttClient : public QMqttClient
{
    Q_OBJECT
public:
    QmlMqttClient(QObject *parent = nullptr);

    Q_INVOKABLE QmlMqttSubscription *subscribe(const QString &topic);

private:
    Q_DISABLE_COPY(QmlMqttClient)
};

#endif // QMLMQTTCLIENT_H
