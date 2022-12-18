import Foundation

guard let moves = readLine() else { print("No input"); exit(-1) }

enum Type : String {
    case air = "."
    case rock = "#"
    case wall = "|"
    case floor = "-"
    case bar = "X"
    case corner = "+"
    case falling = "@"
}

var tower : [[Type]] = [ [.corner, .floor, .floor, .floor, .floor, .floor, .floor, .floor, .corner, .air, .air, .air] ]

let emptyRow : [Type] = [ .wall, .air, .air, .air, .air, .air, .air, .air, .wall, .air, .air, .air ]

for _ in 1...10 {
    tower.append(emptyRow)
}

func printTower() {
    for row in tower.reversed() {
        print(row[0...8].reduce("") { $0 + $1.rawValue } )
    }
}

let horizontalBar : [[Type]] = [ [ .rock, .rock, .rock, .rock ]]
let verticalBar : [[Type]] = [ [.rock],[.rock],[.rock],[.rock]]
let square : [[Type]] = [[.rock,.rock],[.rock,.rock]]
let cross : [[Type]] = [[.air,.rock,.air],[.rock,.rock,.rock],[.air,.rock,.air]]
let lshape : [[Type]] = [[.rock,.rock,.rock],[.air,.air,.rock],[.air, .air, .rock]]

let shapes = [horizontalBar, cross, lshape, verticalBar, square]

struct MoveIterator {
    var iterator = moves.makeIterator()
    var position = 0
    
    mutating func next() -> Character {
        var next = iterator.next()
        if next == nil {
            iterator = moves.makeIterator()
            position = 0
            
            next = iterator.next()
        }
        position += 1
        return next!
    }
}

struct ShapeIterator {
    var shape: Int = shapes.count - 1
    
    mutating func next() -> [[Type]] {
        shape += 1
        if shape == shapes.count {
            shape = 0
        }
        return shapes[shape]
    }
}

// --- 1752 : 1 on 11 for height 2805 ------- 349 349
// --- 3492 : 1 on 11 for height 5559 ------- 389 390

var rocks = 1_000_000_000_000
var printFall = false
var printSteps = false


var col = 3
var row = 0
var removedRows = 0

var moveIterator = MoveIterator()
var shapeIterator = ShapeIterator()

var positionHistories = Set<Int>()
var usedHistories = Set<Combination>()
var maxUsedHistories = 0

struct Combination : Hashable {
    var position: Int
    var section: [[Type]]
}

var skips = (rocks - 13) / 1740
print("We will skip \(skips) blocks of 1740")

for n in 1...(rocks - skips * 1740) {
    var newCol = col
    var newRow = row + 4
    

    let shape = shapeIterator.next()
    if shapeIterator.shape == 1 && row > 1 {

        if moveIterator.position == 11 {
            print("--- \(n) : \(shapeIterator.shape) on \(moveIterator.position) for height \(row+removedRows) -------", positionHistories.count, usedHistories.count)
        }
        
        let section = tower.reversed()
            .trimmingPrefix(while: { $0 == emptyRow })
            .prefix(11)
            .map { $0.map { $0 }}
        
        usedHistories.insert(Combination(position: moveIterator.position, section: section))
        positionHistories.insert(moveIterator.position)

        if usedHistories.count > maxUsedHistories {
            maxUsedHistories = usedHistories.count
        }
    }

    while true {
        var testCol : Int
        
        let move = moveIterator.next()

        
        if  move == ">" {
            testCol = newCol + 1
        } else {
            testCol = newCol - 1
        }
        
        if !collidesAt(shape: shape, row: newRow, col: testCol) {
            newCol = testCol
        }
        
        if !collidesAt(shape: shape, row: newRow-1, col: newCol) {
            newRow -= 1
        } else {
            break
        }
    }

    let fillWith : Type = shape.count == 1 ? .bar : .rock

    for row in zip(shape, (newRow)...) {
        for combination in zip(row.0, (newCol)...) {
            if combination.0 == .rock {
                tower[row.1][combination.1] = fillWith
            }
        }
    }



    if newRow + shape.count - 1 > row {
        row = newRow + shape.count - 1

    }
    if row + 8 > tower.count {
        for _ in (tower.count)...(row+8) {
            tower.append(emptyRow)
        }

    }
    
    if row > 50 {
        tower.removeFirst(10)
        row -= 10
        removedRows += 10
    }
    if printSteps {
        printTower()
    }
    if n & 8191 == 0 {
        print("\(n) Tower height: \(row+removedRows) removed \(removedRows) rows")
    }
}


print("Tower height: \(row+removedRows) removed \(removedRows) rows")
print("Add \(skips) blocks for a total of \(row+removedRows+2754*skips)")


func collidesAt(shape: [[Type]], row: Int, col: Int) -> Bool {
    
    if (printFall) { print("Try \(row),\(col)") }
    
    var collision = false
    for row in zip(shape, (row)...) {
        for combination in zip(row.0, (col)...) {
            if combination.0 == .rock && tower[row.1][combination.1] != .air {
                collision = true
            }
        }
    }
    
    if collision {
        if printFall { print("Collision") }
        return true
    }
    
    if printFall {
        for row in zip(shape, (row)...) {
            for combination in zip(row.0, (col)...) {
                if combination.0 == .rock {
                    tower[row.1][combination.1] = .falling
                }
            }
        }
        printTower()
        for row in zip(shape, (row)...) {
            for combination in zip(row.0, (col)...) {
                if combination.0 == .rock {
                    tower[row.1][combination.1] = .air
                }
            }
        }
    }
    
    return false
}
    
