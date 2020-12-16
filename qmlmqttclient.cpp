#include <QJsonDocument>
#include <QJsonObject>
#include <QDebug>

#include "qmlmqttclient.h"

QmlMqttClient::QmlMqttClient(QObject *parent)
    : QMqttClient(parent)
{
    qDebug() << "Creating client: " << this;
}

QmlMqttSubscription* QmlMqttClient::subscribe(const QString &topic)
{
    qDebug() << "Subscribing to: " << topic;

    auto sub = QMqttClient::subscribe(topic, 0);
    auto result = new QmlMqttSubscription(sub, this);
    m_subscriptionMap.insert( topic, result );
    return result;
}

void QmlMqttClient::unsubscribe(const QString &topic)
{
    qDebug() << "Unsubscribing from: " << topic;

    QMqttClient::unsubscribe(topic);
    m_subscriptionMap.remove(topic);
}

QmlMqttSubscription *QmlMqttClient::subscription(const QString &topic)
{
    qDebug() << "Retrieving: " << topic;

    return m_subscriptionMap.value(topic);
}

void QmlMqttClient::publishMessage(const QString &topic, const QString &message)
{
    qDebug() << "Sending message: " << message;

//    QString header = '(' + QDateTime::currentDateTime().toString() + ')';
//    QString payload = header + ": " + message;

    QString payload = message;

    this->publish( QMqttTopicName( topic ), QByteArray::fromStdString( payload.toStdString() ) );
}

void QmlMqttClient::publishObject(const QString &topic, const QJsonObject &object)
{
    qDebug() << "Sending object: " << object;

    publishMessage( topic, QString( QJsonDocument( object ).toJson( QJsonDocument::Compact )));
}

QmlMqttSubscription::QmlMqttSubscription(QMqttSubscription *s, QmlMqttClient *c)
    : sub(s)
    , client(c)
{

    qDebug() << "Connecting to : " << client;
    qDebug() << "Topic: " << sub;

    connect(sub, &QMqttSubscription::messageReceived, this, &QmlMqttSubscription::handleMessage);
    m_topic = sub->topic();
}

QmlMqttSubscription::~QmlMqttSubscription()
{
}

void QmlMqttSubscription::handleMessage(const QMqttMessage &qmsg)
{
    qDebug() << "Message received: " << qmsg.payload();

    emit messageReceived(qmsg.payload());
}
