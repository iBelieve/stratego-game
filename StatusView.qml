import QtQuick 2.0

Column {
    width: 300
    spacing: 5

    Row {
        spacing: 5

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: 20
            height: 20
            radius: 3
            color: gameEngine.currentTeam.name
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            font.pointSize: 19
            text: gameEngine.currentTeam.name
            font.capitalization: Font.Capitalize
        }
    }

    Item {
        width: parent.width
        height: 20
    }

    Text {
        font.pointSize: 17
        text: "Parts you have lost"
    }
}

