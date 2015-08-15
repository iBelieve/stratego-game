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

    property var disabledSquares: [
        // Left pond
        { row: 4, column: 2 },
        { row: 4, column: 3 },
        { row: 5, column: 2 },
        { row: 5, column: 3 },
        // Left pond
        { row: 4, column: 6 },
        { row: 4, column: 7 },
        { row: 5, column: 6 },
        { row: 5, column: 7 }
    ]

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

    function isDisabled(row, column) {
        for (var i = 0; i < disabledSquares.length; i++) {
            if (disabledSquares[i].row === row && disabledSquares[i].column === column)
                return true
        }

        return false
    }

    function go(state, params) {
        gameEngine.state = ""
        gameEngine.stateParams = params
        gameEngine.state = state

        if (state == "pass" || state == "battle" || state == "gameOver")
            overlayView.showing = true
        else if (state == "setup")
            setupView.startSetup()
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

        function noteRank(part) {
            if (part.team !== aiPlayer.team && aiPlayer.playing)
                aiPlayer.noteEnemyRank(part)
        }

        function noteKill(part) {
            if (part.team !== aiPlayer.team && aiPlayer.playing)
                aiPlayer.noteEnemyKilled(part)
        }

        var isAI = currentTeam.name === aiPlayer.team && aiPlayer.playing

        if (attacker.team !== aiPlayer.team && aiPlayer.playing) {
            aiPlayer.noteEnemyMove(attacker, row, column)
        }

        var defender = currentBoard.partAt(row, column)

        if (defender && defender !== attacker) {
            var outcome = attacker.attack(defender)

            if (outcome === "flag") {
                foundFlag()
                return
            } else if (outcome === "win") {
                currentTeam.wonPart(defender.rank)
                if (aiPlayer.playing) oppositeTeam.lostPart(defender.rank)
                defender.destroy()
                attacker.move(row, column)
                noteRank(attacker)
                noteKill(defender)
                lastWinner = attacker
            } else if (outcome === "loose") {
                currentTeam.lostPart(attacker.rank)
                if (aiPlayer.playing) oppositeTeam.wonPart(attacker.rank)
                defender.move(attacker.row, attacker.column)
                attacker.destroy()
                noteRank(defender)
                noteKill(attacker)
                lastWinner = defender
            } else if (outcome === "tie") {
                currentTeam.lostPart(attacker.rank)
                currentTeam.wonPart(defender.rank)
                if (aiPlayer.playing) {
                    oppositeTeam.wonPart(attacker.rank)
                    oppositeTeam.lostPart(defender.rank)
                }
                attacker.destroy()
                defender.destroy()
                noteKill(attacker)
                noteKill(defender)
                lastWinner = undefined
            } else if (outcome === "bomb") {
                currentTeam.lostPart(attacker.rank)
                if (aiPlayer.playing) oppositeTeam.wonPart(attacker.rank)
                attacker.destroy()
                noteRank(defender)
                noteKill(attacker)
                lastWinner = defender
            }

            showBattle(attacker, defender, outcome, isAI)
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

        var attackerRow = attacker.row, attackerColumn = attacker.column

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
                    defender.move(attackerRow, attackerColumn)
                    attacker.destroy()
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

    function noMoreParts() {
        gameOver(oppositeTeam, currentTeam.capName + " has no more moveable parts")
    }

    function passToNext() {
        delay(500).then(function() {
            if (oppositeTeam.noMoreParts) {
                gameOver(currentTeam, oppositeTeam.capName + " has no more moveable parts")
            } else if (currentTeam.noMoreParts) {
                gameOver(oppositeTeam, currentTeam.capName + " has no more moveable parts")
            } else {
                if (aiPlayer.playing) {
                    confirmPass(oppositeTeam)
                } else {
                    go("pass", {
                        "team": oppositeTeam
                    })

                    currentTeam = null
                }
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

        if (!aiPlayer.playing)
            currentBoard = team.board

        if (currentTeam.name === aiPlayer.team && aiPlayer.playing)
            aiPlayer.takeTurn()
    }

    function setup() {
        go("setup", {"team": blueTeam})
    }

    function randomSetup(team) {
        var parts = JSON.parse(JSON.stringify(initialParts))
        var count = 0
        while (Object.keys(parts).length > 0) {
            var partNames = Object.keys(parts)
            var rank = partNames[0]
            var square = randomSquare(team)
            createPart(team, rank, square.row, square.column)

            parts[rank]--
            if (parts[rank] === 0)
                delete parts[rank]
        }
    }

    function randomSquare(team) {
        while (true) {
            var row = Math.floor(Math.random() * 4)
            var column = Math.floor(Math.random() * 10)

            if (team === "red")
                row = 9 - row

            if (!currentBoard.partAt(row, column))
                return { "row": row, "column": column }
        }
    }

    function createPart(team, rank, row, column) {
        var uid = Utils.generateID()

        if (rank > 0 || rank == -1) {
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

    function wouldWin(attacker, defender) {
        return attacker.attack(defender) === "win"
    }

    function bestPart(a, b) {
        if (a.rank === b.rank) {
            return 0
        } else if (a.rank === -1) {
            return b.rank === 1 ? -1 : 1
        } else if (b.rank === -1) {
            return a.rank === 1 ? -1 : 1
        } else {
            return a.rank - b.rank
        }
    }

    function bestMiddlePart(a, b) {
        var sort = [5, 4, 6, 7, 3, 2, 1, 8, 9]

        if (a.rank === b.rank) {
            return 0
        } else if (a.rank === -1) {
            return 1
        } else if (b.rank === -1) {
            return -1
        } else {
            var sortA = sort.indexOf(a.rank)
            var sortB = sort.indexOf(b.rank)
            return sortA - sortB
        }
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

