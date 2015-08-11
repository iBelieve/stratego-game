import QtQuick 2.0

Item {
    id: part
    x: width * column
    y: width * row
    width: 60; height: width
    z: Drag.active ? 10 : 0

    Behavior on x {
        SmoothedAnimation { duration: 400 }
    }

    Behavior on y {
        SmoothedAnimation { duration: 400 }
    }

    property string uid

    property int row
    property int column

    function reset() {
        move(row, column)
    }

    function move(row, column, redTeam) {
        part.row = row
        part.column = column

        x = width * column
        if (gameEngine.currentBoard === redBoard || redTeam == true) {
            y = width * row
        } else {
            y = width * (9 - row)
        }
    }

    property var info: {
        team: "blue"
        rank: 9
    }

    readonly property string team: info.team
    readonly property int rank: info.rank

    Drag.active: dragArea.drag.active
    Drag.hotSpot.x: 10
    Drag.hotSpot.y: 10

    property bool canDrag: {
        if (gameEngine.state === "") {
            return rank != 0 && rank != -2 && gameEngine.currentTeam && team == gameEngine.currentTeam.name
        } else {
            return true && team == gameEngine.currentTeam.name
        }
    }

    function canDrop(row, column) {
        var dropPart = gameEngine.currentBoard.partAt(row, column)

        if (row === part.row && column === part.column) {
            return true
        }

        if (gameEngine.isDisabled(row, column)) {
            return false
        }

        var goodMove = part.column === column || part.row === row

        if (rank != 9 || dropPart) {
            goodMove = goodMove && within(part.column, column, 1) && within(part.row, row, 1)
        } else {
            // For each tile in between the current location and the drop location,
            //   If any spot has a part on it,
            //     Then this is not a good move

            if (part.column === column) {
                if (row < part.row) {
                    for (var i = part.row - 1; i > row; i--) {
                        if (gameEngine.currentBoard.partAt(i, column) || gameEngine.isDisabled(i, column))
                            goodMove = false;
                    }
                } else {
                    for (var i = part.row + 1; i < row; i++) {
                        if (gameEngine.currentBoard.partAt(i, column) || gameEngine.isDisabled(i, column))
                            goodMove = false;
                    }
                }
            } else {
                if (column < part.column) {
                    for (var i = part.column - 1; i > column; i--) {
                        if (gameEngine.currentBoard.partAt(row, i) || gameEngine.isDisabled(row, i))
                            goodMove = false;
                    }
                } else {
                    for (var i = part.column + 1; i < column; i++) {
                        if (gameEngine.currentBoard.partAt(column, i) || gameEngine.isDisabled(row, i))
                            goodMove = false;
                    }
                }
            }
        }

        if (dropPart) {
            return dropPart.team !== part.team && goodMove
        } else {
            return goodMove
        }
    }

    function attack(defender) {
        if (defender.rank === -2) {
            return "flag"
        } else if (defender.rank === 0) {
            return "bomb"
        } else if (defender.rank === 1 && rank === -1) {
            return "win"
        } else if (defender.rank === rank) {
            return "tie"
        } else if (rank === -1) {
            return "loose"
        } else if (defender.rank === -1) {
            return "win"
        } else {
            return defender.rank < rank ? "win" : "loose"
        }
    }

    function within(a, b, count) {
        return b >= a - count && b <= a + count
    }

    MouseArea {
        id: dragArea
        anchors.fill: parent

        drag.target: canDrag ? parent : undefined

        drag.onActiveChanged: {
            if (drag.active) {
                part.Drag.active = true
            } else {
                part.Drag.drop()
            }
        }
    }

    PartView {
        anchors.fill: parent
        rank: part.rank
        team: part.team
        showRank: (gameEngine.currentTeam && gameEngine.currentTeam.name === team) ||
                  (gameEngine.lastWinner !== undefined && part.uid === gameEngine.lastWinner.uid) ||
                  gameEngine.state == "gameOver"
    }
}
