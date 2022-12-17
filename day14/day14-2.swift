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
let minY = 0 // lines.reduce(Int.max) { $1.reduce($0) { min($0,$1.y) }}


let cols = 2 * maxY + 8
let rows = maxY-minY+3
let offset : Point = (y: minY, x: 500 - cols/2)
print(rows)

enum Material : String { case air = ".", sand = "o", rock = "#", dust = "+" }

var cave : [[Material]] = Array(repeating: Array(repeating: .air, count: cols), count: rows )

var segments = lines.flatMap { zip($0.dropLast(),$0.dropFirst()).map {
    ( rows: (min($0.0.y, $0.1.y)-offset.y)...(max($0.0.y, $0.1.y)-offset.y),
      cols: (min($0.0.x, $0.1.x)-offset.x)...(max($0.0.x, $0.1.x)-offset.x))
} }

segments.append((rows: (rows-1)...(rows-1), cols: 0...(cols-1)))

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

let source = Point(y:0, x: 500-offset.x)

repeat {

    n += 1
    sand = source

    while sand.y < rows - 1 {
        let below = Point(y: sand.y+1, x: sand.x)
        let left = Point(y:sand.y+1, x: sand.x-1)
        let right = Point(y:sand.y+1, x: sand.x+1)

        if cave[below.y][below.x] == .air {
            sand = below
        } else if cave[left.y][left.x] == .air {
            sand = left
        } else if cave[right.y][right.x] == .air {
            sand = right
        } else {
            cave[sand.y][sand.x] = .sand
            break
        }

    }
    if n % 1000 == 0 {
        print("-------\(n)-------")
        prettyPrint(cave)
    }

} while (sand.y < rows - 1 && sand != source && n < 100000)

print(n)

