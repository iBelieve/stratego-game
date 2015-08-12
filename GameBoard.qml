import QtQuick 2.0

Item {
    id: board

    width: boardGrid.width + 75
    height: width

    property bool inverted

    visible: gameEngine.currentBoard == board

    function partAt(row, column) {
        for (var i = 0; i < children.length; i++) {
            var part = children[i]

            if (part.hasOwnProperty("row")) {
                if (part.row === row && part.column === column) {
                    return part
                }
            }
        }
    }

    Image {
        source: Qt.resolvedUrl("game_board.png")
        anchors.fill: parent
    }

    Rectangle {
        id: boardGrid
        anchors.centerIn: parent
        width: grid.width + border.width * 2
        height: grid.height + border.width * 2

        border.color: Qt.rgba(0,0,0,0.25)
        color: "transparent"

        Grid {
            id: grid
            columns: 10
            rows: 10

            anchors.centerIn: parent

            Repeater {
                model: grid.rows * grid.columns
                delegate: BoardTile {
                    property int realRow: Math.floor(index/grid.rows)

                    row: inverted ? realRow : 9 - realRow
                    column: index - realRow * grid.rows
                }
            }
        }
    }
}

