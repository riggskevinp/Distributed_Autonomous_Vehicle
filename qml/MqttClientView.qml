import QtQuick 2.8
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import QtPositioning 5.5
import MqttClient 1.0
import "."

Rectangle{
    id: mqttview
    visible: true
    anchors.top: jobSiteMap.bottom
    anchors.left: parent.left
    width: parent.width
    height: parent.height / 3
    property var tempSubscription: 0

    MqttClient {
        id: client
        hostname: hostnameField.text
        port: portField.text
    }

    ListModel {
        id: messageModel
    }

    function addMessage(machineName, location)
    {

        var msg = machineName + location.latitude.toString()
        messageModel.insert(0, {"payload" : msg})

        if (messageModel.count >= 100)
            messageModel.remove(99)
    }

    GridLayout {
        anchors.fill: parent
        anchors.margins: 0
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
                text: "Organization:"
            }

            TextField {
                id: organizationField
                text: "Organization"
                Layout.fillWidth: true
                enabled: mqttview.tempSubscription === 0
            }

            Label {
                text: "Job Site:"
            }

            TextField {
                id: jobSiteField
                text: "JobSite"
                Layout.fillWidth: true
                enabled: mqttview.tempSubscription === 0
            }

            Label {
                text: "Session:"
            }

            TextField {
                id: sessionField
                text: "Session"
                Layout.fillWidth: true
                enabled: mqttview.tempSubscription === 0
            }

            Button {
                id: subButton
                text: "Subscribe"
                visible: mqttview.tempSubscription === 0
                onClicked: {
                    if (organizationField.text.length === 0 && jobSiteField.text.length === 0 && sessionField.text.length === 0) {
                        console.log("No topic specified to subscribe to.")
                        return
                    }
                    var topic = organizationField.text + "/" + jobSiteField.text + "/" + sessionField.text + "/#"
                    mqttview.tempSubscription = client.subscribe(topic)
                    mqttview.tempSubscription.messageReceived.connect(mqttview.addMessage)
                    mqttview.tempSubscription.messageReceived.connect(jobSiteMap.updatePlane)
                }
            }
        }

        RowLayout {
            enabled: client.state === MqttClient.Connected
            Layout.columnSpan: 2
            Layout.fillWidth: true

            Label {
                text: "Machine Name"
            }

            TextField {
                id: machineNameField
                text: "MachineA"
                Layout.fillWidth: true
                enabled: mqttview.tempSubscription !== 0
            }

            Label {
                text: "Latitude:"
            }

            SpinBox {
                id: latitudeField
                property int inputScaleFactor: Math.pow(10, 7)
                from: -90 * inputScaleFactor
                to: 90 * inputScaleFactor
                value: 42.567169  * inputScaleFactor
                property int decimals: 8
                property real realValue: value / inputScaleFactor
                Layout.fillWidth: true
                enabled: mqttview.tempSubscription !== 0

                validator: DoubleValidator {
                      bottom: Math.min(latitudeField.from, latitudeField.to)
                      top:  Math.max(latitudeField.from, latitudeField.to)
                }

                textFromValue: function(value, locale) {
                    return Number(value / inputScaleFactor).toLocaleString(locale, 'f', latitudeField.decimals)
                }

                valueFromText: function(text, locale) {
                    return Number.fromLocaleString(locale, text) * inputScaleFactor
                }
            }

            Label {
                text: "Longitude:"
            }

            SpinBox {
                id: longitudeField
                property int inputScaleFactor: Math.pow(10, 7)
                from: -180 * inputScaleFactor
                to: 180 * inputScaleFactor
                value: -90.688588 * inputScaleFactor
                property int decimals: 8
                property real realValue: value / inputScaleFactor
                Layout.fillWidth: true
                enabled: mqttview.tempSubscription !== 0

                validator: DoubleValidator {
                      bottom: Math.min(longitudeField.from, longitudeField.to)
                      top:  Math.max(longitudeField.from, longitudeField.to)
                }

                textFromValue: function(value, locale) {
                    return Number(value / inputScaleFactor).toLocaleString(locale, 'f', longitudeField.decimals)
                }

                valueFromText: function(text, locale) {
                    return Number.fromLocaleString(locale, text) * inputScaleFactor
                }
            }

            Button {
                id: pubButton
                text: "Publish"
                enabled: mqttview.tempSubscription !== 0
                onClicked: {
                    if (organizationField.text.length === 0 && jobSiteField.text.length === 0 && sessionField.text.length === 0) {
                        console.log("No topic specified to subscribe to.")
                        return
                    }
                    var topic = organizationField.text + "/" + jobSiteField.text + "/" + sessionField.text + "/" + machineNameField.text
                    mqttview.tempSubscription.publishLocation(topic, latitudeField.realValue, longitudeField.realValue)
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
}
