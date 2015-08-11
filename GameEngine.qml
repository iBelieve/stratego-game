import QtQuick 2.0
import "utils.js" as Utils

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
    property var lastWinner

    property var initialParts: {
        "-2": 1, // Flag
        "-1": 1, // Spy
        "0": 6, // bombs
        "1": 1,
        "2": 1,
        "3": 2,
        "4": 3,
        "5": 4,
        "6": 4,
        "7": 4,
        "8": 5,
        "9": 8
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
                lastWinner = attacker
            } else if (outcome === "loose") {
                attacker.destroy()
                lastWinner = defender
                defender.move(attacker.row, attacker.column)
            } else if (outcome === "tie") {
                attacker.destroy()
                defender.destroy()
                lastWinner = undefined
            } else if (outcome === "bomb") {
                attacker.destroy()
                lastWinner = defender
            }

            showBattle(attacker, defender, outcome)
        } else {
            lastWinner = undefined
            attacker.move(row, column)
            passToNext()
        }
    }

    function replayMove() {
        var row = lastMove.to.row, column = lastMove.to.column
        var attacker = currentBoard.partAt(lastMove.from.row, lastMove.from.column)
        var defender = currentBoard.partAt(row, column)

        var attackerInfo = attacker ? attacker.info : undefined
        var defenderInfo = defender ? defender.info : undefined

        attacker.move(row, column)

        if (defender && defender !== attacker) {
            var outcome = attacker.attack(defender)

            if (outcome === "win") {
                delay(200).then(function() {
                    defender.destroy()
                })
            } else if (outcome === "loose") {
                delay(200).then(function() {
                    attacker.destroy()
                })
                delay(200).then(function() {
                    defender.move(attacker.row, attacker.column)
                })
            } else if (outcome === "tie") {
                delay(200).then(function() {
                    attacker.destroy()
                })
                delay(200).then(function() {
                    defender.destroy()
                })
            } else if (outcome === "bomb") {
                delay(200).then(function() {
                    attacker.destroy()
                })
            }

            delay(400).then(function() {
                showBattle(attackerInfo, defenderInfo, outcome, true)
            })
        } else {
            attacker.move(row, column)
        }
    }

    function showBattle(attacker, defender, outcome, replay) {
        overlayView.go("battle", {
            "attacker": attacker,
            "defender": defender,
            "outcome": outcome,
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
        var uid = Utils.generateID()

        var part1 = gamePartComponent.createObject(blueBoard, {
            "info": {
                "team": team,
                "rank": rank
            },
            "uid": uid
        })
        part1.move(row, column)

        var part2 = gamePartComponent.createObject(redBoard, {
            "info": {
                "team": team,
                "rank": rank
            },
            "uid": uid
        })
        part2.move(row, column, true)
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

