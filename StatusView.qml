import QtQuick 2.0

Column {
    width: 300
    spacing: 5

    visible: gameEngine.state !== "pass"

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
            text: gameEngine.currentTeam.capName
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

    Flow {
        Repeater {
            model: Object.keys(gameEngine.currentTeam.lostParts)
            delegate: PartView {
                rank: modelData
                team: gameEngine.currentTeam.name
                width: 60
                height: width
                showRank: true

                Rectangle {
                    width: 20
                    height: 20
                    radius: width/2
                    visible: gameEngine.currentTeam.lostParts[modelData] > 1
                    color: "#ddd"
                    border.color: "#bbb"
                    anchors {
                        bottom: parent.bottom
                        right: parent.right
                        margins: 5
                    }

                    Text {
                        anchors.centerIn: parent
                        text: gameEngine.currentTeam.lostParts[modelData]
                    }
                }
            }
        }
    }

    Item {
        width: parent.width
        height: 20
    }

    Text {
        font.pointSize: 17
        text: "Parts you have won"
    }

    Flow {
        Repeater {
            model: Object.keys(gameEngine.currentTeam.wonParts)
            delegate: PartView {
                rank: modelData
                team: gameEngine.oppositeTeam.name
                width: 60
                height: width
                showRank: true

                Rectangle {
                    width: 20
                    height: 20
                    radius: width/2
                    visible: gameEngine.currentTeam.wonParts[modelData] > 1
                    color: "#ddd"
                    border.color: "#bbb"
                    anchors {
                        bottom: parent.bottom
                        right: parent.right
                        margins: 5
                    }

                    Text {
                        anchors.centerIn: parent
                        text: gameEngine.currentTeam.wonParts[modelData]
                    }
                }
            }
        }
    }
}

