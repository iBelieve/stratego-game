import QtQuick 2.0

Item {
    property string team: "red"
    property bool playing: true

    property var movingParts: []
    property var rankedParts: []

    property int moveMemory: 10

    function noteEnemyMove(part, row, column) {
        print("Enemy moved", part.rank)
        movingParts.push(part)
        movingParts.splice(moveMemory)
    }

    function noteEnemyRank(part) {
        print("Enemy discovered", part.rank)
        movingParts.push(part)
        movingParts.splice(moveMemory)
    }

    function noteEnemyKilled(part) {
        print("Enemy killed", part.rank)
        var movingIndex = movingParts.indexOf(part)
        var rankIndex = rankedParts.indexOf(part)
        print(movingIndex, rankIndex)

        if (movingIndex > 0)
            movingParts.splice(movingIndex, 1)
        if (rankIndex > 0)
            rankedParts.splice(rankIndex, 1)
    }

    function takeTurn() {
        // Try to move high ranking parts to the flag
        // If any parts are near the flag, attack them it
        // If there are any known high-ranking parts, move higher parts to attack them
        // If there are any known low-ranking parts in the vacinity, engage them
        // If there are any known bombs, attack them
        // If there are any moving parts, engage them
        if (movingParts.length > 0) {
            var routeMap = createRouteMap(movingParts[0])

            for (var i = 9; i >= 0; i--) {
                print(JSON.stringify(routeMap[i]))
            }

//            var bestEnemyPart = bestPartToEngage()
//            print("Best enemy part to attack is", bestEnemyPart.rank)
//            engage(bestEnemyPart)
        }

        // Move forwards
        else {
            moveForwards()
        }
    }

    function engage(part) {
        // To engage an enemy part,
        // Find the nearest and best part to attack with
        var nearestPart = bestTeamPart(part)
        // If a part was found,
        if (nearestPart) {
            // Move that part towards the enemy, attacking if possible
            moveTowards(nearestPart, part)
        }
    }

    function moveForwards() {
        // Find the front-most part with a low rank and no one in front
        var matchingParts = [];
        for (var row = 4; row < 7; row++) {
            for (var column = 0; column < 10; column++) {
                var part = gameEngine.currentBoard.partAt(row, column)
                if (part !== undefined && canMoveForwards(part)) {
                    matchingParts.push(part)
                }
            }
        }

        matchingParts = matchingParts.sort(function(a, b) {
            if (a.row == b.row) {
                return a.column - b.column
            } else {
                return a.row - b.row
            }
        })

        // Move the part forwards
        move(matchingParts[0], -1, 0)
    }

    function bestPartToEngage() {
        // To find the best part to engage,
        // Look through the list of known moving parts,
        var parts = [].concat(movingParts)
        parts.sort(function(a, b) {
            // And find the one with a good part to engage at the closest distance
            var nearestToA = bestTeamPart(a)
            var nearestToB = bestTeamPart(b)

            if (!nearestToA && !nearestToB) {
                return 0
            } else if (!nearestToA) {
                return 1
            } else if (!nearestToB) {
                return -1
            }

            var distA = distBetween(a, nearestToA)
            var distB = distBetween(b, nearestToB)

            return distA - distB
        })

        var bestEnemy = parts[0]

        // Ensure that we have a team part that can engage the enemy part
        if (bestTeamPart(bestEnemy))
            return bestEnemy
        else
            return undefined
    }

    function bestTeamPart(enemyPart) {
        // Cache the route map to the enemy part
        var routeMap = createRouteMap(enemyPart)

        // To find the best team part to engage a specified enemy part,
        // Look through all the team parts, filtering by lower rank if the enemy rank is known
        var parts = teamParts()
        if (rankedParts.indexOf(enemyPart)) {
            parts = filter(parts, function(part) {
                return gameEngine.wouldWin(part, enemyPart)
            })
        }

        // And find the closest part
        parts.sort(function (a, b) {
            var distA = distTo(routeMap, a)
            var distB = distTo(routeMap, b)
            var canMoveA = a.canDrag && distA !== -1
            var canMoveB = b.canDrag && distB !== -1

            if (!canMoveA && !canMoveB) {
                return 0
            } else if (!canMoveA) {
                return 1
            } else if (!canMoveB) {
                return -1
            } else {
                return distA - distB
            }
        })


        var closestPart = parts[0]
        var dist = distTo(routeMap, closestPart)
        var canMove = closestPart.canMove && dist !== -1

        // Ensure we can actually found a part that can be moved
        if (canMove) {
            return closestPart
        } else {
            return undefined
        }
    }

    function teamParts() {
        var parts = gameEngine.currentBoard.children
        return filter(parts, function(part) {
            return part.hasOwnProperty("team") && part.team == "red"
        })
    }

    function filter(array, func) {
        var newArray = []
        for (var i = 0; i < array.length; i++) {
            var item = array[i]
            if (func(item)) {
                newArray.push(item)
            }
        }

        return newArray
    }

    function canMoveForwards(part) {
        if (!part.canDrag)
            return false

        if (part.row > 0) {
            var partInFront = gameEngine.currentBoard.partAt(part.row - 1, part.column)
            return (!partInFront || partInFront.team !== aiPlayer.team) &&
                    !gameEngine.isDisabled(part.row - 1, part.column)
        } else {
            return false
        }
    }

    function moveTowards(part, enemy) {
        print("Moving", part.rank, "to engage", enemy.rank)
        var routeMap = createRouteMap(enemy)
        var moveDiff = bestMove(routeMap, part)
        move(part, moveDiff.rowDiff, moveDiff.columnDiff)
    }

    function createRouteMap(to) {
        var map = emptyMap(10, 10)
        var missingCount = 100
        var previousCount = 100

        gameEngine.disabledSquares.forEach(function(square) {
            map[square.row][square.column] = -1
            missingCount--
        })

        map[to.row][to.column] = 0
        previousCount = missingCount
        missingCount--


        while (missingCount > 0 && missingCount < previousCount) {
            previousCount = missingCount
            for (var row = 0; row < 10; row++) {
                for (var column = 0; column < 10; column++) {
                    if (map[row][column] === -2) {
                        var moveInfo = routeInfo(map, row, column, to)
                        if (moveInfo) {
                            map[row][column] = moveInfo.dist
                            missingCount--
                        }
                    }
                }
            }
        }

        if (missingCount > 0) {
            // Now fill all the remaining unknowns with can't moves
            for (row = 0; row < 10; row++) {
                for (column = 0; column < 10; column++) {
                    if (map[row][column] === -2) {
                        map[row][column] = -1
                    }
                }
            }
        }

        return map
    }

    function bestMove(routeMap, part) {
        return routeInfo(routeMap, part.row, part.column)
    }

    function routeInfo(routeMap, row, column, target) {
        function distIfNoPart(row, column) {
            var part = gameEngine.currentBoard.partAt(row, column)
            if (!part || part == target) {
                return distToPoint(routeMap, row, column)
            } else {
                return -1
            }
        }

        var distLeft = distIfNoPart(row, column - 1)
        var distRight = distIfNoPart(row, column + 1)
        var distUp = distIfNoPart(row + 1, column)
        var distDown = distIfNoPart(row - 1, column)

        var dists = [distLeft, distRight, distUp, distDown]

        var bestDist = -1
        dists.forEach(function(dist) {
            if (dist >= 0 && (bestDist == -1 || dist < bestDist))
                bestDist = dist;
        })

        var sortedDists = JSON.parse(JSON.stringify(dists))
        sortedDists.sort(function(a, b) {
            if (a === b) {
                return 0
            } else if (a < 0) {
                return 1
            } else if (b < 0) {
                return -1
            } else {
                return a - b
            }
        })

        print("Sorted dists", sortedDists)

        if (sortedDists[0] < 0)
            return undefined

        var distIndex = dists.indexOf(sortedDists[0])
        if (distIndex == 0) { // left
            return { dist: bestDist + 1, rowDiff: 0, columnDiff: -1 }
        } else if (distIndex == 1) { // right
            return { dist: bestDist + 1, rowDiff: 0, columnDiff: +1 }
        } else if (distIndex == 2) { // up
            return { dist: bestDist + 1, rowDiff: +1, columnDiff: 0 }
        } else if (distIndex == 3) { // down
            return { dist: bestDist + 1, rowDiff: -1, columnDiff: 0 }
        }
    }

    function distToPoint(routeMap, row, column) {
        if (row < 0 || row >= 10 || column < 0 || column >= 10)
            return -1;

        return routeMap[row][column]
    }

    function emptyMap(rows, columns) {
        var map = []
        var oneRow = []
        for (var i = 0; i < columns; i++){
            oneRow.push(-2)
        }
        for (var j = 0; j < rows; j++) {
            map.push([].concat(oneRow))
        }

        return map
    }

    function move(part, rowDiff, columnDiff) {
        gameEngine.move(part, part.row + rowDiff, part.column + columnDiff)
    }
}
