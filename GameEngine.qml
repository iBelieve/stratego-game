import QtQuick 2.0
import "utils.js" as Utils

Item {

    state: "" // or "pass"
    property var stateParams: undefined

    property Team currentTeam: blueTeam
    readonly property Team oppositeTeam: {
        if (currentTeam == blueTeam) {
            return redTeam
        } else {
            return blueTeam
        }
    }

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

    function go(state, params) {
        gameEngine.state = ""
        gameEngine.stateParams = params
        gameEngine.state = state

        if (state == "pass" || state == "battle" || state == "gameOver")
            overlayView.showing = true
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
                currentTeam.wonPart(defender.rank)
                defender.destroy()
                attacker.move(row, column)
                lastWinner = attacker
            } else if (outcome === "loose") {
                currentTeam.lostPart(attacker.rank)
                attacker.destroy()
                lastWinner = defender
                defender.move(attacker.row, attacker.column)
            } else if (outcome === "tie") {
                currentTeam.lostPart(attacker.rank)
                currentTeam.wonPart(defender.rank)
                attacker.destroy()
                defender.destroy()
                lastWinner = undefined
            } else if (outcome === "bomb") {
                currentTeam.lostPart(attacker.rank)
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
                    currentTeam.lostPart(defender.rank)
                    defender.destroy()
                })
            } else if (outcome === "loose") {
                delay(200).then(function() {
                    currentTeam.wonPart(attacker.rank)
                    attacker.destroy()
                })
                delay(200).then(function() {
                    defender.move(attacker.row, attacker.column)
                })
            } else if (outcome === "tie") {
                delay(200).then(function() {
                    currentTeam.wonPart(attacker.rank)
                    attacker.destroy()
                })
                delay(200).then(function() {
                    currentTeam.lostPart(defender.rank)
                    defender.destroy()
                })
            } else if (outcome === "bomb") {
                delay(200).then(function() {
                    currentTeam.wonPart(attacker.rank)
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
        go("battle", {
            "attacker": attacker,
            "defender": defender,
            "outcome": outcome,
            "replay": replay === undefined ? false : replay
        })
    }

    function foundFlag() {
        gameOver(currentTeam, "%1 found the %2 flag!".arg(currentTeam.capName).arg(oppositeTeam.name))
    }

    function passToNext() {
        delay(500).then(function() {
            if (oppositeTeam.noMoreParts) {
                gameOver(currentTeam, oppositeTeam.capName + " has no more moveable parts")
            } else if (currentTeam.noMoreParts) {
                gameOver(oppositeTeam, currentTeam.capName + " has no more moveable parts")
            } else {
                go("pass", {
                    "team": oppositeTeam
                })

                currentTeam = null
            }
        })
    }

    function gameOver(team, message) {
        go("gameOver", {
            "team": team,
            "message": message
        })
    }

    function confirmPass(team) {
        currentTeam = team
        currentBoard = team.board

        delay(500).then(replayMove)
    }

    function createPart(team, rank, row, column) {
        var uid = Utils.generateID()

        if (rank > 0 || rank === -1) {
            if (team === "blue") {
                blueTeam.partCount++
            } else {
                redTeam.partCount++
            }
        }

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

