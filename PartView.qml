import QtQuick 2.0
import QtQuick.Window 2.0
import QtGraphicalEffects 1.0

Item {
    id: partView
    property string team
    property int rank
    property bool showRank: (gameEngine.currentTeam && gameEngine.currentTeam.name === team) || gameEngine.state == "gameOver"
    property color color: "#E6B713"

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
        font.family: "Times New Roman"
        style: Text.Raised
        styleColor: Qt.darker(color)
        color: partView.color

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

    DropShadow {
        anchors.fill: image
        source: image
        color: Qt.darker(partView.color)
        visible: image.source != ""

        horizontalOffset: 0
        verticalOffset: 1
        radius: 0
        samples: 8
    }

    ColorOverlay {
        id: overlay

        anchors.fill: image
        source: image
        color: partView.color
        cached: true
        visible: image.source != ""
    }
}

