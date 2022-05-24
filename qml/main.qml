import QtQuick 2.4
import QtQuick.Window 2.2
import QtPositioning 5.5
import QtLocation 5.6
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.1
import MqttClient 1.0
import "."

Window {
    id: root
    width: 500
    height: 700
    visible: true

    property variant topLeftEurope: QtPositioning.coordinate(60.5, 0.0)
    property variant bottomRightEurope: QtPositioning.coordinate(51.0, 14.0)
    property variant viewOfEurope:
            QtPositioning.rectangle(topLeftEurope, bottomRightEurope)

    property variant berlin: QtPositioning.coordinate(52.5175, 13.384)
    property variant oslo: QtPositioning.coordinate(59.9154, 10.7425)
    property variant london: QtPositioning.coordinate(51.5, 0.1275)

    VehicleMap {
        id: jobSiteMap
        //anchors.centerIn: parent
        anchors.top: parent.top
        anchors.left: parent.left
        width: parent.width
        height: parent.height * 3 / 4
    }

    MqttClientView{
        id: mqttview
        anchors.top: jobSiteMap.bottom
        anchors.left: parent.left
        width: parent.width
        height: parent.height / 4
    }
    /*Rectangle{
        id: mqttview
        parent: root
        visible: true
        anchors.top: jobSiteMap.bottom
        anchors.left: jobSiteMap.left
        width: jobSiteMap.width
        height: root.height / 4
        Loader {
            source:"MqttClientView.qml";
          }
    }
    Rectangle{
        id: mqttview
        visible: true
        anchors.top: jobSiteMap.bottom
        anchors.left: parent.left
        width: parent.width
        height: parent.height / 4
        property var tempSubscription: 0

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
                        mqttview.tempSubscription.destroy()
                        mqttview.tempSubscription = 0
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
                    enabled: mqttview.tempSubscription === 0
                }

                Button {
                    id: subButton
                    text: "Subscribe"
                    visible: mqttview.tempSubscription === 0
                    onClicked: {
                        if (subField.text.length === 0) {
                            console.log("No topic specified to subscribe to.")
                            return
                        }
                        mqttview.tempSubscription = client.subscribe(subField.text)
                        mqttview.tempSubscription.messageReceived.connect(mqttview.addMessage)
                    }
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
    }*/

    Rectangle {
        id: infoBox
        anchors.centerIn: parent
        color: "white"
        border.width: 1
        width: text.width * 1.3
        height: text.height * 1.3
        radius: 5
        Text {
            id: text
            anchors.centerIn: parent
            text: qsTr("Hit the plane to start the flight!")
        }

        Timer {
            interval: 5000; running: true; repeat: false;
            onTriggered: fadeOut.start()
        }

        NumberAnimation {
            id: fadeOut; target: infoBox;
            property: "opacity";
            to: 0.0;
            duration: 200
            easing.type: Easing.InOutQuad
        }
    }
}
