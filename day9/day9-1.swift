import Foundation

var lines : [String] = []
while let line = readLine() {
    lines.append(line)
}

var moves = lines.map { (direction: String($0.first!), steps: Int($0.dropFirst(2))!) }

let rows = 236
let cols = 344
print(rows, cols)

var positions : [[Character]] = Array(repeating: Array(repeating: ".", count: cols), count: rows)

func prettyPrint(_ positions: [[Character]], head: (x: Int, y: Int)? = nil, tail: (x: Int, y:Int)? = nil) {
    var field = positions
    field[0][0] = "s"
    if let h = head { field[h.y][h.x] = "H" }
    if let t = tail { field[t.y][t.x] = "T" }

    for line in field.reversed() {
        print(String(line))
    }
    print()
}

let offsetX = 112
let offsetY = 48
var head = (x: offsetX, y: offsetY)
var tail = (x: offsetX, y: offsetY)

var left = 0
var right = 0
var top = 0
var bottom = 0

for move in moves {
    for _ in 1...move.steps {
        switch move.direction {
            case "U": 
                    head.y += 1
            case "D":
                    head.y -= 1
            case "L":
                    head.x -= 1
            case "R":
                    head.x += 1
            default: exit(-2)
        }
    
        if tail.y == head.y && tail.x != head.x {
            tail.x = head.x - (head.x-tail.x).signum()
        } else if tail.y != head.y && tail.x == head.x {
            tail.y = head.y - (head.y-tail.y).signum()
        } else if abs(tail.y - head.y) > 1 && tail.x != head.x {
            tail.y = head.y - (head.y-tail.y).signum()
            tail.x = head.x
        } else if abs(tail.x - head.x) > 1 && tail.y != head.y {
            tail.x = head.x - (head.x-tail.x).signum()
            tail.y = head.y
        }
        positions[tail.y+offsetY][tail.x+offsetX] = "#"

        left = min(left, tail.x+offsetX)
        right = max(right, tail.x+offsetX)
        top = max(top, tail.y+offsetY)
        bottom = min(bottom, tail.y+offsetY)
    }

}
print(left,right,top,bottom)
print(right-left, top-bottom)

// prettyPrint(positions)

print(positions.reduce(0) { $0 + $1.reduce(0) { $0 + (($1=="#") ? 1 : 0 )}})
