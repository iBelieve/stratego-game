import QtQuick 2.0

Item {
    id: part
    x:width * column
    y: width * row
    width: 60; height: width
    z: Drag.active ? 10 : 0

    Behavior on x {
        SmoothedAnimation {}
    }

    Behavior on y {
        SmoothedAnimation {}
    }

    property int row
    property int column

    function reset() {
        move(row, column)
    }

    function move(row, column) {
        part.row = row
        part.column = column

        x = width * column
        y = width * row
    }

    property string team: "blue"
    property int rank

    Drag.active: dragArea.drag.active
    Drag.hotSpot.x: 10
    Drag.hotSpot.y: 10

    property bool canDrag: {
        if (gameEngine.mode == "playing") {
            return rank != 0 && gameEngine.currentTeam && team == gameEngine.currentTeam.name
        } else {
            return true && team == gameEngine.currentTeam.name
        }
    }

    function canDrop(row, column) {
        var dropPart = part.parent.partAt(row, column)

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

    PartView {
        anchors.fill: parent
        rank: part.rank
        team: part.team
    }
}
