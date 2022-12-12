import Foundation

var lines : [String] = []
while let line = readLine() {
    lines.append(line)
}

typealias Tile = (height: Int, steps: Int)

var tiles : [[Tile]] = lines.map { Array($0.utf8) }.map { $0.map { (height: Int($0)-96, steps: -1) } }
let rows = tiles.count
let cols = tiles.first!.count

var start = (y: 0, x: 0)
var end = (y: 0, x: 0)

for y in 0..<rows {
    for x in 0..<cols {
        let height = tiles[y][x].height
        if height == -13 { 
            start.y = y
            start.x = x
        }
        if height == -27 { 
            end.y = y
            end.x = x
        }
    }
}
tiles[start.y][start.x].height = 0
tiles[end.y][end.x].height = 26

func move(distance: Int, from: (y: Int, x: Int), with height: Int, path: String) {

    guard 0..<rows ~= from.y && 0..<cols ~= from.x else { return }

    let tile = tiles[from.y][from.x]

    if tile.steps != -1 && tile.steps <= distance { return }
    if tile.height < height - 1  { return }
    
    tiles[from.y][from.x].steps = distance

    move(distance: distance+1, from: (y: from.y+1, x: from.x), with: tile.height, path: path + "<")
    move(distance: distance+1, from: (y: from.y-1, x: from.x), with: tile.height, path: path + ">")
    move(distance: distance+1, from: (y: from.y, x: from.x+1), with: tile.height, path: path + "^")
    move(distance: distance+1, from: (y: from.y, x: from.x-1), with: tile.height, path: path + ".")
}

move(distance: 0, from: end, with: 27, path: "")

print(tiles[start.y][start.x].steps)

var shortestStart = (y:0, x:0)
var shortest = 1000

for y in 0..<rows {
    var line = ""
    for x in 0..<cols {
        let tile = tiles[y][x]
        line += "   \(tile.steps)".suffix(4) + "    (\(tile.height))".suffix(5)
        if tile.height == 1  && tile.steps < shortest && tile.steps >= 0 {
            shortest = tile.steps
            shortestStart = (y:y, x:x)
        }
    }
    print(line)
}

print(shortestStart, shortest)