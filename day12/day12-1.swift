import Foundation

var lines : [String] = []
while let line = readLine() {
    lines.append(line)
}

var heights : [[Int]] = lines.map { Array($0.utf8) }.map { $0.map { Int($0)-96} }
let rows = heights.count
let cols = heights.first!.count

var distances : [[Int]] = Array(repeating: Array(repeating: -1, count: cols), count: rows)

prettyPrint(heights)
var start = (y: 0, x: 0)
var end = (y: 0, x: 0)

for y in 0..<rows {
    for x in 0..<cols {
        if heights[y][x] == -13 { 
            start.y = y
            start.x = x
        }
        if heights[y][x] == -27 { 
            end.y = y
            end.x = x
        }
    }
}
heights[start.y][start.x] = 0
heights[end.y][end.x] = 26
// distances[end.y][end.x] = 1

func prettyPrint(_ map: [[Int]]) {
    for line in map {
        print(line.reduce("") { $0 + "    \($1)".suffix(4)})
    }
}


print("-----")
prettyPrint(distances)
print(start, end)

var count = 0
var lowestHeight = 30

func move(distance: Int, from: (y: Int, x: Int), with height: Int, path: String) {

    count += 1
    if count > 10_000_000 { return }

    guard 0..<rows ~= from.y && 0..<cols ~= from.x else { return }

    let thisDistance = distances[from.y][from.x]


    if thisDistance != -1 && thisDistance <= distance { return }
    let thisHeight = heights[from.y][from.x]

    // if height == 12 {
    //     print("Distance \(distance) (\(thisDistance)) from \(from) on height \(height) (\(thisHeight))with \(path)")
    // }


    if  thisHeight < height - 1  { return }
    // guard (height-1)...(height) ~= thisHeight else { return } 

    distances[from.y][from.x] = distance
    lowestHeight = min(lowestHeight, thisHeight)
    // if distance > 250 {
    //     prettyPrint(distances)
    // }

    move(distance: distance+1, from: (y: from.y+1, x: from.x), with: thisHeight, path: path + "<")
    move(distance: distance+1, from: (y: from.y-1, x: from.x), with: thisHeight, path: path + ">")
    move(distance: distance+1, from: (y: from.y, x: from.x+1), with: thisHeight, path: path + "^")
    move(distance: distance+1, from: (y: from.y, x: from.x-1), with: thisHeight, path: path + ".")
}

move(distance: 0, from: end, with: 27, path: "")

prettyPrint(distances)
print(distances[start.y][start.x])

var shortestStart = (y:0, x:0)
var shortest = 1000

for y in 0..<rows {
    var line = ""
    for x in 0..<cols {
        line += "   \(distances[y][x])".suffix(4) + "    (\(heights[y][x]))".suffix(5)
        if heights[y][x] == 1  && distances[y][x] < shortest && distances[y][x] >= 0 {
            shortest = distances[y][x]
            shortestStart = (y:y, x:x)
        }
    }
    print(line)
}

print(shortestStart, shortest)