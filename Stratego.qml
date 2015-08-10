import QtQuick 2.4
import QtQuick.Window 2.0

Window {
    title: "Statego"

    width: board.width + 20
    height: board.height + 20

    GameEngine {
        id: gameEngine
    }

    GameBoard {
        id: board
        anchors.centerIn: parent

        GamePart {
            rank: 4
        }

        GamePart {
            rank: -1
            team: "red"
            row: 9
        }

        GamePart {
            rank: 0
            team: "red"
            row: 9
            column: 1
        }
    }
}
