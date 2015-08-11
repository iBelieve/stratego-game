import QtQuick 2.0

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
            } else if (rank == 0) {
                return "B"
            } else {
                return rank
            }
        }
    }
}

