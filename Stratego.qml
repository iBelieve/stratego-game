import QtQuick 2.4
import QtQuick.Window 2.0

Window {
    title: "Statego"

    width: blueBoard.width + statusView.width + 30
    height: blueBoard.height + 20

    GameEngine {
        id: gameEngine
    }

    StatusView {
        id: statusView
        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
            margins: 10
        }
    }

    GameBoard {
        id: blueBoard

        anchors {
            left: statusView.right
            verticalCenter: parent.verticalCenter
            margins: 10
        }
    }

    GameBoard {
        id: redBoard

        anchors {
            left: statusView.right
            verticalCenter: parent.verticalCenter
            margins: 10
        }
    }

    OverlayView {
        id: overlayView
        anchors.fill: parent
    }

    Component.onCompleted: {
        gameEngine.createPart("blue", 1, 0, 0)
        gameEngine.createPart("blue", 9, 0, 1)
        gameEngine.createPart("blue", 5, 0, 2)
        gameEngine.createPart("red", -1, 2, 0)
        gameEngine.createPart("red", 0, 2, 1)
    }
}
