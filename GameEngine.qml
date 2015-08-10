import QtQuick 2.0

QtObject {
    property string mode: "playing" // or "setup"
    property string currentTeam: "blue"

    property var lastPart

    function moveOver(winner) {
        if (currentTeam == "blue") {
            currentTeam = "red"
        } else {
            currentTeam = "blue"
        }

        lastPart = winner
    }
}

