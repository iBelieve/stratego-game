import QtQuick 2.0

Rectangle {
    id: board

    visible: gameEngine.currentBoard == board

    width: grid.width + border.width * 2
    height: grid.height + border.width * 2

    border.color: "gray"

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

    Grid {
        id: grid
        columns: 10
        rows: 10

        anchors.centerIn: parent

        Repeater {
            model: grid.rows * grid.columns
            delegate: BoardTile {
                row: Math.floor(index/grid.rows)
                column: index - row * grid.rows
            }
        }
    }
}

