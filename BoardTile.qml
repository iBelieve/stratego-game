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
            drop.accepted = false
        } else if (!attacker.canDrop(row, column)) {
            drop.accepted = false
        } else {
            drop.accept(Qt.MoveAction)
            gameEngine.move(attacker, row, column)
        }
    }

    Rectangle {
        anchors.fill: parent

        border.color: Qt.rgba(0,0,0,0.25)
        color: dropArea.containsDrag && dropArea.drag.source.canDrop(row, column)
                                                    ? Qt.rgba(0,0,0,0.3) : Qt.rgba(0,0,0,0)
    }
}
