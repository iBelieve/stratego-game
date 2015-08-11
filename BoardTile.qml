import QtQuick 2.0

DropArea {
    id: dropArea

    width: 60
    height: width

    property int row
    property int column

    onDropped: {
        var attacker = drag.source

        if (attacker.row === row && attacker.column === column) {
            attacker.reset()
        } else if (!attacker.canDrop(row, column)) {
            drop.accepted = false
            attacker.reset()
        } else {
            gameEngine.move(attacker, row, column)
        }
    }

    Rectangle {
        anchors.fill: parent

        border.color: "gray"
        color: gameEngine.isDisabled(row, column) ? "#faa"
                                                  : dropArea.containsDrag && dropArea.drag.source.canDrop(row, column)
                                                    ? "#ddd" : "white"
    }
}
