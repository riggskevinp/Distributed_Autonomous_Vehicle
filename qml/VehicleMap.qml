import QtQuick 2.4
import QtQuick.Window 2.2
import QtPositioning 5.5
import QtLocation 5.6
import "."

Map {
    id: jobSiteMap
    //anchors.centerIn: parent
    anchors.top: parent.top
    anchors.left: parent.left
    width: parent.width
    height: parent.height * 3 / 4
    center: QtPositioning.coordinate(55.75, 7.0)
    //anchors.fill: parent
    focus: true
    gesture.enabled: true
    property var  planes: []
    property bool ready: false

    plugin: Plugin {
        name: "osm" // "mapboxgl", "esri", ...
        PluginParameter {
                    name: "osm.mapping.providersrepository.disabled"
                    value: "true"
                }
        PluginParameter {
            name: "osm.mapping.providersrepository.address"
            value: "http://maps-redirect.qt.io/osm/5.6/"
        }
    }

    Behavior on center {
        CoordinateAnimation {
            duration: 150
            easing.type: Easing.InOutQuad
        }
    }

    Behavior on bearing {
        RotationAnimation {
            direction: RotationAnimation.Shortest
            duration: 150
            easing.type: Easing.Linear
        }
    }

    Timer {
        // At start, center around current objects
        id: patchTimer
        interval: 1000
        repeat: true
        running: jobSiteMap.ready// && app.running
        triggeredOnStart: true
        property int timesRun: 0
        onTriggered: {
            patchTimer.running = timesRun++ < 5;
            jobSiteMap.fitViewportToMapItems();
        }
    }

    Component.onCompleted: {
        jobSiteMap.addPlane("Tony", 0, oslo);
        jobSiteMap.addPlane("Betsy", 0, london);
        jobSiteMap.ready = true;
    }

    function addPlane(name, bearing, coord) {
        var planeComponent = Qt.createComponent("Vehicle.qml");
        if( planeComponent.status !== Component.Ready ){
            if( planeComponent.status === Component.Error )
                console.debug("Error:"+ planeComponent.errorString() );
            return; // or maybe throw
        }
        var plane = planeComponent.createObject(jobSiteMap);

        plane.pilotName = name;
        plane.bearing = bearing || 0;
        plane.coordinate = coord;

        jobSiteMap.planes.push(plane);
        jobSiteMap.addMapItem(plane);
    }

    function updatePlane(msg){
        for(var i = 0; i < jobSiteMap.planes.length; i++){
            if(jobSiteMap.planes[i].name !== msg.name){
                continue;
            }
            var coordinate = QtPositioning.coordinate(msg.lat, msg.lon);
            var bearing = msg.bearing || jobSiteMap.planes[i].coordinate.azimuthTo(coordinate);

            jobSiteMap.planes[i].coordinate = coordinate;
            jobSiteMap.planes[i].bearing = bearing;
            return;
        }
        jobSiteMap.addPlane(msg);
    }
}
