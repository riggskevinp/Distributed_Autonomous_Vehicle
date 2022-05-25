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

    property variant berlin: QtPositioning.coordinate(42.567475, -90.687120)
    property variant oslo: QtPositioning.coordinate(42.567169, -90.688588)
    property variant london: QtPositioning.coordinate(42.568865, -90.687838)

    VehicleMap {
        id: jobSiteMap
        //anchors.centerIn: parent
        anchors.top: parent.top
        anchors.left: parent.left
        width: parent.width
        height: parent.height * 2 / 3
    }

    MqttClientView{
        id: mqttview
        anchors.top: jobSiteMap.bottom
        anchors.left: parent.left
        width: parent.width
        height: parent.height / 4
    }

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
