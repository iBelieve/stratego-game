import QtQuick 2.0

QtObject {
    property string name
    readonly property string capName: {
        return name[0].toUpperCase() + name.substring(1)
    }

    property GameBoard board
    property var lostParts: { return {} }
    property var wonParts: { return {} }
    property int partCount

    property bool noMoreParts: partCount === 0

    function lostPart(part) {
        if (lostParts[part] !== undefined) {
            lostParts[part]++
        }  else {
            lostParts[part] = 1
        }

        lostParts = lostParts

        if (part > 0 || part === -1)
            partCount--
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

