import Foundation

var lines : [String] = []
while let line = readLine() {
    lines.append(line)
}

var moves = lines.map { (direction: String($0.first!), steps: Int($0.dropFirst(2))!) }

let rows = 188 // 236
let cols = 232 // 344
print(rows, cols)

let offsetY = 47
let offsetX = 112

var positions : [[Character]] = Array(repeating: Array(repeating: ".", count: cols), count: rows)

func prettyPrint(_ positions: [[Character]], with rope: [(x: Int, y: Int)] = []) {
    let symbols : [Character] = [ "9","8","7","6","5","4","3","2","1","H" ]
    var symbol = symbols.makeIterator()
    
    var field = positions

    field[offsetX][offsetY] = "s"
    for knot in rope.reversed() {
        field[knot.y][knot.x] = symbol.next()!
    }

    for line in field.reversed() {
        print(String(line))
    }
    print()
}

var rope = Array(repeating: (x: offsetX, y: offsetY), count: 10)

var left = 1000
var right = 0
var top = 0
var bottom = 1000

for move in moves {
    for _ in 1...move.steps {
        switch move.direction {
            case "U": 
                    rope[0].y += 1
            case "D":
                    rope[0].y -= 1
            case "L":
                    rope[0].x -= 1
            case "R":
                    rope[0].x += 1
            default: exit(-2)
        }

        for n in 1..<rope.count {

            if rope[n].y == rope[n-1].y && rope[n].x != rope[n-1].x {
                rope[n].x = rope[n-1].x - (rope[n-1].x-rope[n].x).signum()
            } else if rope[n].y != rope[n-1].y && rope[n].x == rope[n-1].x {
                rope[n].y = rope[n-1].y - (rope[n-1].y-rope[n].y).signum()
            } else if abs(rope[n].y - rope[n-1].y) > 1 && abs(rope[n].x - rope[n-1].x) > 1 {
                rope[n].y = rope[n-1].y - (rope[n-1].y-rope[n].y).signum()
                rope[n].x = rope[n-1].x - (rope[n-1].x-rope[n].x).signum()
            } else if abs(rope[n].y - rope[n-1].y) > 1 && rope[n].x != rope[n-1].x {
                rope[n].y = rope[n-1].y - (rope[n-1].y-rope[n].y).signum()
                rope[n].x = rope[n-1].x
            } else if abs(rope[n].x - rope[n-1].x) > 1 && rope[n].y != rope[n-1].y {
                rope[n].x = rope[n-1].x - (rope[n-1].x-rope[n].x).signum()
                rope[n].y = rope[n-1].y
            }

        }

        positions[rope[9].y][rope[9].x] = "#"

        left = min(left, rope[0].x)
        right = max(right, rope[0].x)
        top = max(top, rope[0].y)
        bottom = min(bottom, rope[0].y)
    }
}
print(left,right,top,bottom)
print("Rows: \(top-bottom+1), Cols: \(right-left+1)")
print("offset y: \(-min(top,bottom)), Offset x: \(-min(left,right))")


print(positions.reduce(0) { $0 + $1.reduce(0) { $0 + (($1=="#") ? 1 : 0 )}})
