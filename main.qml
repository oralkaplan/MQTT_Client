import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import MqttClient 1.0

Window {
    visible: true
    width: 640
    height: 480
    title: qsTr("Qt Quick MQTT Subscription Example")
    id: root

    MqttClient {
        id: client
        hostname: hostnameField.text
        port: portField.text
    }

    ListModel {
        id: messageModel
    }

    function addMessage(payload)
    {
        messageModel.insert(0, {"payload" : payload})

        if (messageModel.count >= 100)
            messageModel.remove(99)
    }

    GridLayout {
        anchors.fill: parent
        anchors.margins: 10
        columns: 2

        Label {
            text: "Hostname:"
            enabled: client.state === MqttClient.Disconnected
        }

        TextField {
            id: hostnameField
            Layout.fillWidth: true
            text: "test.mosquitto.org"
            placeholderText: "<Enter host running MQTT broker>"
            enabled: client.state === MqttClient.Disconnected
        }

        Label {
            text: "Port:"
            enabled: client.state === MqttClient.Disconnected
        }

        TextField {
            id: portField
            Layout.fillWidth: true
            text: "1883"
            placeholderText: "<Port>"
            inputMethodHints: Qt.ImhDigitsOnly
            enabled: client.state === MqttClient.Disconnected
        }

        Button {
            id: connectButton
            Layout.columnSpan: 2
            Layout.fillWidth: true
            text: client.state === MqttClient.Connected ? "Disconnect" : "Connect"
            onClicked: {
                if (client.state === MqttClient.Connected) {
                    client.disconnectFromHost()
                    messageModel.clear()
                    tempSubscription.destroy()
                    tempSubscription = 0
                } else
                    client.connectToHost()
            }
        }

        RowLayout {
            enabled: client.state === MqttClient.Connected
            Layout.columnSpan: 2
            Layout.fillWidth: true

            Label {
                text: "Topic:"
            }

            TextField {
                id: subField
                placeholderText: "<Subscription topic>"
                Layout.fillWidth: true
            }

            Button {
                id: subButton
                text: "Subscribe"
                onClicked: {
                    if (subField.text.length === 0) {
                        console.log("No topic specified to subscribe to.")
                        return
                    }
                    let subscription = client.subscribe(subField.text)
                    subscription.messageReceived.connect(addMessage)
                    console.log( "Subscribed to " + subscription.topic )
                }
            }

            Button {
                id: unsubButton
                text: "Unsubscribe"
                onClicked: {
                    if (subField.text.length === 0) {
                        console.log("No topic specified to unsubscribe from.")
                        return
                    }
                    let subscription = client.subscription(subField.text)
                    subscription.messageReceived.disconnect(addMessage)
                    console.log( "Unsubscribed from " + subscription.topic )
                    client.unsubscribe(subscription.topic)
                }
            }

            Button {
                text: "Publish"
                onClicked: client.publishMessage( subField.text, payloadField.text )
            }
        }

        RowLayout {
            enabled: client.state === MqttClient.Connected
            Layout.columnSpan: 2
            Layout.fillWidth: true

            TextField {
                id: payloadField
                placeholderText: "<Payload>"
                Layout.fillWidth: true
            }
        }

        ListView {
            id: messageView
            model: messageModel
            height: 300
            width: 200
            Layout.columnSpan: 2
            Layout.fillHeight: true
            Layout.fillWidth: true
            clip: true
            delegate: Rectangle {
                width: messageView.width
                height: 30
                color: index % 2 ? "#DDDDDD" : "#888888"
                radius: 5
                Text {
                    text: payload
                    anchors.centerIn: parent
                }
            }
        }

        Label {
            function stateToString(value) {
                if (value === 0)
                    return "Disconnected"
                else if (value === 1)
                    return "Connecting"
                else if (value === 2)
                    return "Connected"
                else
                    return "Unknown"
            }

            Layout.columnSpan: 2
            Layout.fillWidth: true
            color: "#333333"
            text: "Status:" + stateToString(client.state) + "(" + client.state + ")"
            enabled: client.state === MqttClient.Connected
        }
    }
}
