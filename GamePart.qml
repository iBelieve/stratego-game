import QtQuick 2.0

Rectangle {
    id: part
    x: 10 + 60 * column
    y: 10 + 60 * row
    width: 40; height: width
    color: team

    radius: 4

    property int row
    property int column

    function reset() {
        move(row, column)
    }

    function move(row, column) {
        part.row = row
        part.column = column

        x = 10 + 60 * column
        y = 10 + 60 * row
    }

    property string team: "blue"
    property int rank

    Drag.active: dragArea.drag.active
    Drag.hotSpot.x: 10
    Drag.hotSpot.y: 10

    property bool canDrag: {
        if (gameEngine.mode == "playing") {
            return rank != 0 && team == gameEngine.currentTeam
        } else {
            return true && team == gameEngine.currentTeam
        }
    }

    function canDrop(row, column) {
        var dropPart = board.partAt(row, column)

        var goodDistance = part.column === column || part.row === row

        if (rank != 9) {
            goodDistance = goodDistance && within(part.column, column, 1) && within(part.row, row, 1)
        }

        if (row === part.row && column === part.column) {
            return true
        } else if (dropPart) {
            return dropPart.team !== part.team && goodDistance
        } else {
            return goodDistance
        }
    }

    function attack(defender) {
        if (defender.rank === 0) {
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

    Text {
        anchors.centerIn: parent
        font.pointSize: 17
        color: "white"

        text: {
            var showRank = gameEngine.currentTeam === team || gameEngine.lastPart == part

            if (!showRank) {
                return ""
            } else if (rank == -1) {
                return "S"
            } else if (rank == 0) {
                return "B"
            } else {
                return rank
            }
        }
    }
}
