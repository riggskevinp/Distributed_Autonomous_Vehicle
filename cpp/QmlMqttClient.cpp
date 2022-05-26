#include "QmlMqttClient.h"
#include <QDebug>

QmlMqttClient::QmlMqttClient(QObject *parent)
    : QMqttClient(parent)
{
}

QmlMqttSubscription* QmlMqttClient::subscribe(const QString &topic)
{
    auto sub = QMqttClient::subscribe(topic, 0);
    auto result = new QmlMqttSubscription(sub, this);
    return result;
}

QmlMqttSubscription::QmlMqttSubscription(QMqttSubscription *s, QmlMqttClient *c)
    : sub(s)
    , client(c)
{
    connect(sub, &QMqttSubscription::messageReceived, this, &QmlMqttSubscription::handleMessage);
    m_topic = sub->topic();
}

QmlMqttSubscription::~QmlMqttSubscription()
{
}

void QmlMqttSubscription::handleMessage(const QMqttMessage &qmsg)
{
    auto topic = qmsg.topic().levels();
    if(topic.length() >= 4){
        auto machineName = topic.at(3);
        //auto loc = GnssLocation();
        auto vehicleInfo = VehicleInfo();
        vehicleInfo.ParseFromArray(qmsg.payload(), qmsg.payload().size());
        emit messageReceived(machineName, QGeoCoordinate(vehicleInfo.location().latitude(), vehicleInfo.location().longitude()), QString::fromStdString(vehicleInfo.model().model_name()));
    }
}

void QmlMqttSubscription::publishLocation(const QString &topic, const double lat, const double lon){
    GnssLocation payload;
    payload.set_latitude(lat);
    payload.set_longitude(lon);
    auto serialized_payload = QByteArray(payload.SerializeAsString().c_str(), payload.SerializeAsString().size());
    client->publish(topic, serialized_payload);
}
