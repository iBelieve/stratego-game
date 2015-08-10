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

        if (defender && defender !== attacker) {
            var outcome = attacker.attack(defender)
            print(outcome)

            if (outcome === "win") {
                defender.visible = false
                attacker.row = row
                attacker.column = column
            } else if (outcome === "loose") {
                attacker.visible = false
                defender.row = attacker.row
                defender.column = attacker.column
            } else if (outcome === "tie") {
                attacker.visible = false
                defender.visible = false
            } else if (outcome === "bomb") {
                attacker.visible = false
            }
        } else {
            attacker.row = row
            attacker.column = column
        }
    }

    Rectangle {
        anchors.fill: parent

        border.color: "gray"
        color: dropArea.containsDrag && dropArea.drag.source.canDrop(row, column) ? "#ddd" : "white"
    }
}
