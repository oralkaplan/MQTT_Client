#ifndef MQTTCLIENT_H
#define MQTTCLIENT_H

#include <QtCore/QMap>
#include <QtMqtt/QMqttClient>
#include <QtMqtt/QMqttSubscription>

class QmlMqttClient;

class QmlMqttSubscription : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QMqttTopicFilter topic MEMBER m_topic NOTIFY topicChanged)

public:
    QmlMqttSubscription(QMqttSubscription *s, QmlMqttClient *c);
    ~QmlMqttSubscription();

Q_SIGNALS:
    void topicChanged(QString);
    void messageReceived(const QString &msg);

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

    Q_INVOKABLE QmlMqttSubscription* subscribe(const QString &topic);
    Q_INVOKABLE void unsubscribe(const QString &topic);
    Q_INVOKABLE QmlMqttSubscription *subscription(const QString &topic);
    Q_INVOKABLE void publishMessage(const QString &topic, const QString &message);
    Q_INVOKABLE void publishObject(const QString &topic, const QJsonObject &object);

private:
    Q_DISABLE_COPY(QmlMqttClient)

    QMap<QString, QmlMqttSubscription*> m_subscriptionMap;
};

#endif // MQTTCLIENT_H
