import QtQuick 2.0

Column {
    width: 300
    spacing: 5

    visible: gameEngine.state === "setup"

    property var parts: { return {} }

    function startSetup() {
        parts = JSON.parse(JSON.stringify(gameEngine.initialParts))
    }

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
            font.family: "Times New Roman"
            text: gameEngine.currentTeam.capName + " setup"
            color: "white"
        }
    }

    Item {
        width: parent.width
        height: 20
    }

    Flow {
        width: parent.width

        Repeater {
            model: Object.keys(parts)
            delegate: PartView {
                rank: modelData
                team: gameEngine.stateParams.team.name
                width: 60
                height: width
                showRank: true

                Rectangle {
                    width: 20
                    height: 20
                    radius: width/2
                    visible: parts[modelData] > 1
                    color: "#ddd"
                    border.color: "#bbb"
                    anchors {
                        bottom: parent.bottom
                        right: parent.right
                        margins: 5
                    }

                    Text {
                        anchors.centerIn: parent
                        text: parts[modelData]
                        font.family: "Times New Roman"
                    }
                }
            }
        }
    }
}

