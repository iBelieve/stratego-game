import QtQuick 2.0

Item {

    state: "" // or "pass" or "battle"
    property var stateParams: undefined


    property string mode: "playing" // or "pass", "battle", "setup"

    property Team currentTeam: blueTeam
    property GameBoard currentBoard: blueTeam.board
    property var lastMove: {
        "part": null,
        "row": 0,
        "column": 0
    }

    function move(attacker, row, column) {
        lastMove = {
            "from": {
                "row": attacker.row,
                "column": attacker.column
            },
            "to": {
                "row": row,
                "column": column
            }
        }

        var defender = currentBoard.partAt(row, column)

        if (defender && defender !== attacker) {
            var outcome = attacker.attack(defender)

            if (outcome === "win") {
                defender.destroy()
                attacker.move(row, column)
            } else if (outcome === "loose") {
                attacker.destroy()
                defender.move(attacker.row, attacker.column)
            } else if (outcome === "tie") {
                attacker.destroy()
                defender.destroy()
            } else if (outcome === "bomb") {
                attacker.destroy()
            }

            showBattle(attacker, defender)
        } else {
            attacker.move(row, column)
            passToNext()
        }
    }

    function replayMove() {
        var row = lastMove.to.row, column = lastMove.to.column
        var attacker = currentBoard.partAt(lastMove.from.row, lastMove.from.column)
        var defender = currentBoard.partAt(row, column)

        attacker.move(row, column)

        if (defender && defender !== attacker) {
            var outcome = attacker.attack(defender)

            if (outcome === "win") {
                delay(200).defender.destroy()
            } else if (outcome === "loose") {
                delay(200).attacker.destroy()
                delay(200).defender.move(attacker.row, attacker.column)
            } else if (outcome === "tie") {
                delay(200).attacker.destroy()
                delay(200).defender.destroy()
            } else if (outcome === "bomb") {
                delay(200).attacker.destroy()
            }

            showBattle(attacker, defender, true)
        } else {
            attacker.move(row, column)
        }
    }

    function showBattle(attacker, defender, replay) {
        overlayView.go("battle", {
            "attacker": attacker,
            "defender": defender,
            "replay": replay === undefined ? false : replay
        })
    }

    function passToNext() {
        delay(500).then(function() {
            if (currentTeam == blueTeam) {
                overlayView.go("pass", {
                    "team": redTeam
                })
            } else {
                overlayView.go("pass", {
                    "team": blueTeam
                })
            }

            currentTeam = null
        })
    }

    function confirmPass(team) {
        currentTeam = team
        currentBoard = team.board

        delay(500).then(replayMove)
    }

    function createPart(team, rank, row, column) {
        var part1 = gamePartComponent.createObject(blueBoard, {
            "team": team,
            "rank": rank
        })
        part1.move(row, column)

        var part2 = gamePartComponent.createObject(redBoard, {
            "team": team,
            "rank": rank
        })
        part2.move(row, column)
    }

    Component {
        id: gamePartComponent

        GamePart {}
    }

    Team {
        id: blueTeam
        name: "blue"
        board: blueBoard
    }

    Team {
        id: redTeam
        name: "red"
        board: redBoard
    }
}

