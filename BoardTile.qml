import QtQuick 2.0

DropArea {
    id: dropArea

    width: 60
    height: width

    property int row
    property int column

    onDropped: {
        print(row, column)

        var attacker = drag.source
        var defender = board.partAt(row, column)

        if (!attacker.canDrop(row, column)) {
            print("Rejected!")
            drop.accepted = false
            attacker.reset()
            attacker.reset()
            return
        }

        if (defender && defender !== attacker) {
            var outcome = attacker.attack(defender)
            print(outcome)

            if (outcome === "win") {
                defender.visible = false
                attacker.move(row, column)
                gameEngine.moveOver(attacker)
            } else if (outcome === "loose") {
                attacker.visible = false
                defender.move(attacker.row, attacker.column)
                gameEngine.moveOver(defender)
            } else if (outcome === "tie") {
                attacker.visible = false
                defender.visible = false
                gameEngine.moveOver()
            } else if (outcome === "bomb") {
                attacker.visible = false
                gameEngine.moveOver(defender)
            }
        } else {
            attacker.move(row, column)
            gameEngine.moveOver()
        }
    }

    Rectangle {
        anchors.fill: parent

        border.color: "gray"
        color: dropArea.containsDrag && dropArea.drag.source.canDrop(row, column) ? "#ddd" : "white"
    }
}
