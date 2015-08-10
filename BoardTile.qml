import QtQuick 2.0

DropArea {
    id: dropArea

    width: 60
    height: width

    property int row
    property int column

    onDropped: {
        print(row, column)
        drag.source.row = row
        drag.source.column = column
    }

    Rectangle {
        anchors.fill: parent

        border.color: "gray"
        color: dropArea.containsDrag && dropArea.drag.source.canDrop(row, column) ? "#ddd" : "white"
    }
}
