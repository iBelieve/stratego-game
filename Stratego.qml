import QtQuick 2.4
import QtQuick.Window 2.0
import "promises.js" as Promises

Window {
    id: stratego
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

        inverted: true

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

    function delay(duration) {
        var promise = new Promises.Promise()

        var timer = timerComponent.createObject(stratego)
        timer.interval = duration
        timer.triggered.connect(function() {
            promise.resolve()
            timer.destroy()
        })
        timer.start()

        return promise
    }

    Component {
        id: timerComponent

        Timer {}
    }
}
