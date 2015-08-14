import QtQuick 2.0
import QtQuick.Controls 1.2

Rectangle {
    id: overlay

    opacity: showing ? 1 : 0
    color: Qt.rgba(0,0,0,0.3)

    Behavior on opacity {
        NumberAnimation { duration: 200 }
    }

    onOpacityChanged: {
        if (opacity == 0) {
            gameEngine.state = ""
        }
    }

    property bool showing

    Rectangle {
        anchors.centerIn: parent

        color: Qt.rgba(1,1,1,0.9)
        radius: 3
        width: loader.width + 40
        height: loader.height + 40

        Loader {
            id: loader
            anchors.centerIn: parent
            sourceComponent: {
                if (gameEngine.state === "battle") {
                    return battleView
                } else if (gameEngine.state === "pass") {
                    return passView
                } else if (gameEngine.state === "gameOver") {
                    return gameOverView
                } else {
                    return undefined
                }
            }
        }
    }

    Component {
        id: battleView

        Column {
            spacing: 5

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                font.pointSize: 20
                text: {
                    var outcome = gameEngine.stateParams.outcome

                    if (gameEngine.stateParams.replay) {
                        if (outcome === "win") {
                            return "You died :("
                        } else if (outcome === "loose") {
                            return "You killed him!"
                        } else if (outcome === "tie") {
                            return "You both were killed :("
                        } else if (outcome === "bomb") {
                            return "Boom! No more attacker!"
                        }
                    } else {
                        if (outcome === "win") {
                            return "You killed him!"
                        } else if (outcome === "loose") {
                            return "You died :("
                        } else if (outcome === "tie") {
                            return "You killed each other :("
                        } else if (outcome === "bomb") {
                            return "Boom! No more you :("
                        }
                    }
                }
            }

            Row {
                visible: gameEngine.stateParams.replay
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 5

                PartView {
                    team: gameEngine.stateParams.defender.team
                    rank: gameEngine.stateParams.defender.rank
                    showRank: true
                    width: 60
                    height: 60
                }

                Text {
                    text: "<--"
                    anchors.verticalCenter: parent.verticalCenter
                }

                PartView {
                    team: gameEngine.stateParams.attacker.team
                    rank: gameEngine.stateParams.attacker.rank
                    showRank: true
                    width: 60
                    height: 60
                }
            }

            Row {
                visible: !gameEngine.stateParams.replay
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 5

                PartView {
                    team: gameEngine.stateParams.attacker.team
                    rank: gameEngine.stateParams.attacker.rank
                    showRank: true
                    width: 60
                    height: 60
                }

                Text {
                    text: "-->"
                    anchors.verticalCenter: parent.verticalCenter
                }

                PartView {
                    team: gameEngine.stateParams.defender.team
                    rank: gameEngine.stateParams.defender.rank
                    showRank: true
                    width: 60
                    height: 60
                }
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Got it!"
                onClicked: {
                    var isAI = gameEngine.currentTeam.name === aiPlayer.team && aiPlayer.playing

                    overlayView.showing = false
                    if (!gameEngine.stateParams.replay || isAI)
                        gameEngine.passToNext()
                }
            }
        }
    }

    Component {
        id: passView

        Column {
            spacing: 5

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                font.pointSize: 20
                text: "Please pass to the " + gameEngine.stateParams.team.name + " team"
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Done!"
                onClicked: {
                    overlayView.showing = false
                    gameEngine.confirmPass(gameEngine.stateParams.team)
                }
            }
        }
    }

    Component {
        id: gameOverView

        Column {
            spacing: 5

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                font.pointSize: 20
                text: gameEngine.stateParams.team.capName + " won!"
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                font.pointSize: 15
                text: gameEngine.stateParams.message
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Quit!"
                onClicked: {
                    Qt.quit()
                }
            }
        }
    }
}

