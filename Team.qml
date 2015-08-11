import QtQuick 2.0

QtObject {
    property string name
    property GameBoard board
    property var lostParts: {}

    function lostPart(part) {
        if (lostParts[part] !== undefined) {
            lostParts[part]++
        }  else {
            lostParts[part] = 1
        }
    }
}

