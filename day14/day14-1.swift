import Foundation

var linesRead : [String] = []
while let line = readLine() {
    linesRead.append(line)
}

typealias Point = (y: Int, x: Int)

let lines = linesRead.map { $0.matches(of: #/(\d+),(\d+)/#).map { (y: Int($0.2)!, x: Int($0.1)! ) } }

let maxX = lines.reduce(0) { $1.reduce($0) { max($0,$1.x) }}
let minX = lines.reduce(Int.max) { $1.reduce($0) { min($0,$1.x) }}
let maxY = lines.reduce(0) { $1.reduce($0) { max($0,$1.y) }}
let minY = 0 

let offset : Point = (y: minY, x: minX-1)

let cols = maxX-minX+3
let rows = maxY-minY+3

enum Material : String { 
    case air = "."
    case sand = "o"
    case rock = "#"
    case dust = "~" 
}

var cave : [[Material]] = (1...rows).map { _ in (1...cols).map { _ in .air}}

let segments = lines.flatMap { zip($0.dropLast(),$0.dropFirst()).map {
    ( rows: (min($0.0.y, $0.1.y)-offset.y)...(max($0.0.y, $0.1.y)-offset.y),
      cols: (min($0.0.x, $0.1.x)-offset.x)...(max($0.0.x, $0.1.x)-offset.x))
} }

for segment in segments {
    for y in segment.rows {
        for x in segment.cols {
            cave[y][x] = .rock
        }
    }
}

func prettyPrint(_ cave: [[Material]]) {
    for line in cave {
        print(line.reduce("") { $0 + $1.rawValue })
    }
}

var n = 0
var sand : Point

cave[0][500-offset.x] = .dust
prettyPrint(cave)

repeat {

    n += 1
    print("-------\(n)-------")
    sand = Point(y:0, x: 500-offset.x)

    while sand.y < rows - 1 {
        let below = Point(y: sand.y+1, x: sand.x)
        let left = Point(y: sand.y+1, x: sand.x-1)
        let right = Point(y: sand.y+1, x: sand.x+1)

        cave[sand.y][sand.x] = .dust

        if cave[below.y][below.x] == .air || cave[below.y][below.x] == .dust {
            sand = below
        } else if cave[left.y][left.x] == .air || cave[left.y][left.x] == .dust {
            sand = left
        } else if cave[right.y][right.x] == .air || cave[right.y][right.x] == .dust {
            sand = right
        } else {
            cave[sand.y][sand.x] = .sand
            break
        }

    }
    prettyPrint(cave)

} while (sand.y < rows - 1 && n < 1000)

print(n-1)

