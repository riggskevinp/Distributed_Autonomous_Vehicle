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
    center: QtPositioning.coordinate(42.567878, -90.688139)
    zoomLevel: 16.0
    //anchors.fill: parent
    focus: true
    gesture.enabled: true
    property var  planes: []
    property bool ready: false
    property bool followSelf: true
    property bool syncBearing: false

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
            duration: 500
            easing.type: Easing.Linear
        }
    }

    Behavior on bearing {
        RotationAnimation {
            direction: RotationAnimation.Shortest
            duration: 500
            easing.type: Easing.Linear
        }
    }

    MouseArea {
        anchors.fill: parent
        onDoubleClicked:{
            if(!jobSiteMap.followSelf){
                jobSiteMap.followSelf = true;
            } else {
                jobSiteMap.followSelf = false;
            }
        }
    }

    gesture.onPinchFinished: {
        // Round piched zoom level to avoid fuzziness.
        if (jobSiteMap.zoomLevel < jobSiteMap.zoomLevelPrev) {
            jobSiteMap.zoomLevel % 1 < 0.75 ?
                jobSiteMap.setZoomLevel(Math.floor(jobSiteMap.zoomLevel)):
                jobSiteMap.setZoomLevel(Math.ceil(jobSiteMap.zoomLevel));
        } else if (jobSiteMap.zoomLevel > jobSiteMap.zoomLevelPrev) {
            jobSiteMap.zoomLevel % 1 > 0.25 ?
                jobSiteMap.setZoomLevel(Math.ceil(jobSiteMap.zoomLevel)):
                jobSiteMap.setZoomLevel(Math.floor(jobSiteMap.zoomLevel));
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
        //jobSiteMap.addPlane("Tony", 0, oslo);
        //jobSiteMap.addPlane("Betsy", 0, london);
        jobSiteMap.ready = true;
    }

    function addPlane(name, bearing, coord, model) {
        var planeComponent = Qt.createComponent("Vehicle.qml");
        if( planeComponent.status !== Component.Ready ){
            if( planeComponent.status === Component.Error )
                console.debug("Error:"+ planeComponent.errorString() );
            return; // or maybe throw
        }
        var plane = planeComponent.createObject(jobSiteMap);

        plane.pilotName = name;
        plane.bearing = (bearing || 0) - jobSiteMap.bearing;
        plane.coordinate = coord;
        plane.vehPlatform = model

        jobSiteMap.planes.push(plane);
        jobSiteMap.addMapItem(plane);
        jobSiteMap.fitViewportToMapItems();
    }

    function updatePlane(machineName, loc, machineModel){
        for(var i = 0; i < jobSiteMap.planes.length; i++){
            if(jobSiteMap.planes[i].pilotName !== machineName){
                continue;
            }
            var coordinate = loc;
            var bearing = loc.bearing || jobSiteMap.planes[i].coordinate.azimuthTo(coordinate);

            if(machineName === "mach0" && jobSiteMap.followSelf === true){
                jobSiteMap.center = coordinate;
                if(jobSiteMap.syncBearing){
                    jobSiteMap.bearing = bearing;
                }
            }

            jobSiteMap.planes[i].coordinate = coordinate;
            jobSiteMap.planes[i].bearing = bearing - jobSiteMap.bearing;


            return;
        }
        jobSiteMap.addPlane(machineName, 0, loc, machineModel);
    }
}
