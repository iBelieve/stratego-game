import QtQuick 2.0
import QtQuick.Window 2.0
import QtGraphicalEffects 1.0

Item {
    property string team
    property int rank
    property bool showRank: gameEngine.currentTeam && gameEngine.currentTeam.name === team

    Rectangle {
        id: rectangle
        anchors.centerIn: parent
        width: parent.width * 2/3
        height: width
        radius: 4
        color: team
    }

    Text {
        anchors.centerIn: parent
        font.pointSize: 17
        color: "white"

        text: {
            if (!showRank) {
                return ""
            } else if (rank == -1) {
                return "S"
            } else if (rank == 0 || rank == -2) {
                return ""
            } else {
                return rank
            }
        }
    }

    Image {
        id: image
        anchors.centerIn: parent
        sourceSize.width: width * Screen.devicePixelRatio
        sourceSize.height: height * Screen.devicePixelRatio
        width: 20
        height: width
        visible: false

        source: {
            if (!showRank) {
                return ""
            } else if (rank == 0) {
                return Qt.resolvedUrl("bomb.svg")
            } else if (rank == -2) {
                return Qt.resolvedUrl("flag.svg")
            } else {
                return ""
            }
        }
    }

    ColorOverlay {
        id: overlay

        anchors.fill: image
        source: image
        color: "white"
        cached: true
        visible: image.source != ""
    }
}

