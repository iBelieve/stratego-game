import QtQuick 2.0
import QtQuick.Controls 1.2

Rectangle {
    id: overlay
    state: "" // or "pass" or "battle"

    opacity: showing ? 1 : 0
    color: Qt.rgba(0,0,0,0.3)

    property bool showing
    property var stateParams: undefined

    function go(state, params) {
        overlay.state = ""
        overlay.stateParams = params
        overlay.state = state

        showing = true
    }

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
                if (overlay.state === "battle") {
                    return battleView
                } else if (overlay.state === "pass") {
                    return passView
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
                    var outcome = overlayView.stateParams.attacker.attack(stateParams.defender)

                    if (stateParams.replay) {
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
                visible: stateParams.replay
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 5

                PartView {
                    team: overlayView.stateParams.defender.team
                    rank: overlayView.stateParams.defender.rank
                    showRank: true
                    width: 60
                    height: 60
                }

                Text {
                    text: "<--"
                    anchors.verticalCenter: parent.verticalCenter
                }

                PartView {
                    team: overlayView.stateParams.attacker.team
                    rank: overlayView.stateParams.attacker.rank
                    showRank: true
                    width: 60
                    height: 60
                }
            }

            Row {
                visible: !stateParams.replay
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 5

                PartView {
                    team: overlayView.stateParams.attacker.team
                    rank: overlayView.stateParams.attacker.rank
                    showRank: true
                    width: 60
                    height: 60
                }

                Text {
                    text: "-->"
                    anchors.verticalCenter: parent.verticalCenter
                }

                PartView {
                    team: overlayView.stateParams.defender.team
                    rank: overlayView.stateParams.defender.rank
                    showRank: true
                    width: 60
                    height: 60
                }
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Got it!"
                onClicked: {
                    overlayView.showing = false
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
                text: "Please pass to the " + stateParams.team.name + " team"
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Done!"
                onClicked: {
                    overlayView.showing = false
                    gameEngine.confirmPass(stateParams.team)
                }
            }
        }
    }
}

