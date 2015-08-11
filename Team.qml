import QtQuick 2.0

QtObject {
    property string name
    property GameBoard board
    property var lostParts: { return {} }
    property var wonParts: { return {} }

    function lostPart(part) {
        if (lostParts[part] !== undefined) {
            lostParts[part]++
        }  else {
            lostParts[part] = 1
        }

        lostParts = lostParts
    }

    function wonPart(part) {
        if (wonParts[part] !== undefined) {
            wonParts[part]++
        }  else {
            wonParts[part] = 1
        }

        wonParts = wonParts
    }
}

