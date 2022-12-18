import Foundation

guard let moves = readLine() else { print("No input"); exit(-1) }

// let moves = ">>><<><>><<<>><>>><<<>>><<<><<<>><>><<>>"

print(moves.count)

enum Type : String {
    case air = "."
    case rock = "#"
    case wall = "|"
    case floor = "-"
    case corner = "+"
    case falling = "@"
}

var tower : [[Type]] = [ [.corner, .floor, .floor, .floor, .floor, .floor, .floor, .floor, .corner, .air, .air, .air] ]

let emptyRow : [Type] = [ .wall, .air, .air, .air, .air, .air, .air, .air, .wall, .air, .air, .air ]

for _ in 1...7 {
    tower.append(emptyRow)
}

func printTower() {
    for row in tower.reversed() {
        print(row[0...8].reduce("") { $0 + $1.rawValue } )
    }
}
printTower()

let horizontalBar : [[Type]] = [ [ .rock, .rock, .rock, .rock ]]
let verticalBar : [[Type]] = [ [.rock],[.rock],[.rock],[.rock]]
let square : [[Type]] = [[.rock,.rock],[.rock,.rock]]
let cross : [[Type]] = [[.air,.rock,.air],[.rock,.rock,.rock],[.air,.rock,.air]]
let lshape : [[Type]] = [[.rock,.rock,.rock],[.air,.air,.rock],[.air, .air, .rock]]

let shapes = [horizontalBar, cross, lshape, verticalBar, square]

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

var rocks = 10
var printFall = false
var printSteps = false


var col = 3
var row = 0

var moveIterator = moves.makeIterator()
var shapeIterator = ShapeIterator()

for n in 1...rocks {
    print("------ \(n) ----------")
    var newCol = col
    var newRow = row + 4

    let shape = shapeIterator.next()
    
    while true {
        var testCol : Int
        var move : Character
        
        if let nextMove = moveIterator.next() {
            move = nextMove
        } else {
            moveIterator = moves.makeIterator()
            move = moveIterator.next()!
        }
        
        if move == ">" {
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
    
    for row in zip(shape, (newRow)...) {
        for combination in zip(row.0, (newCol)...) {
            if combination.0 == .rock {
                tower[row.1][combination.1] = .rock
            }
        }
    }
    

    
    if newRow + shape.count - 1 > row {
        row = newRow + shape.count - 1
        
    }
//    print(tower.count, row+4+3)
    if row + 8 > tower.count {
        for _ in (tower.count)...(row+8) {
            tower.append(emptyRow)
        }

    }
    if printSteps {
        printTower()
    }
    print("Tower height: \(row)")
}

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
    

//let collide = zip(shape[0], tower[newRow].dropFirst(newCol)).reduce(false) { $0 || ($1.0 == .rock && $1.1 != .air) }
//
//print(collide)






