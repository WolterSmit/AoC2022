import Foundation

var linesRead : [String] = []
while let line = readLine() {
    linesRead.append(line)
}

typealias Point = (y: Int, x: Int)

let sensors = linesRead.map { $0.matches(of: #/x=([-|\d]+), y=([-|\d]+)/#).map { (y: Int($0.2)!, x: Int($0.1)! ) } }
                        .map { ( at: $0[0], beacon: $0[1])}

// for line in lines {
//     for point in line {
//         print(point.2)
//         print(Int(point.2))
//     }
// }

// let maxX = sensors.reduce(0) { $1.reduce($0) { max($0,$1.x) }}
// let minX = sensors.reduce(Int.max) { $1.reduce($0) { min($0,$1.x) }}
// let maxY = sensors.reduce(0) { $1.reduce($0) { max($0,$1.y) }}
// let minY = sensors.reduce(Int.max) { $1.reduce($0) { min($0,$1.y) }}

// print(minX,maxX,minY,maxY)
// let range = min(minX,maxX)...max(minX,maxX)
// print(range)

// var line : [Bool] = range.map { _ in false }

// y > at.y : (beacon.y - at.y) - y 

let offset = Point(y:2, x: 10)
let size = Point(y:30, x: 50)

let row = 2000000
// let ranges = ((0-offset.y)...20).map { row in
    let ranges = sensors.compactMap { 
        let distance = abs($0.at.x - $0.beacon.x) + abs($0.at.y - $0.beacon.y) - abs(row-$0.at.y)

        return (distance >= 0 ? ($0.at.x - distance)...($0.at.x + distance) : nil)
    }
    // return ranges
// }

enum Material : String {
    case empty = "."
    case occupied = "#"
    case sensor = "S"
    case beacon = "B"
}



var newRanges : [ClosedRange<Int>] = []

let sortedRanges = ranges.sorted(by: { $0.lowerBound < $1.lowerBound})
print(sortedRanges)

var previousRange = sortedRanges.first!
for range in sortedRanges.dropFirst() {
    print(previousRange, range)
    if previousRange.upperBound < range.lowerBound - 1 {
        newRanges.append(previousRange)
        previousRange = range
    } else if previousRange.upperBound < range.upperBound {
        previousRange = previousRange.lowerBound...range.upperBound
    }
}
newRanges.append(previousRange)
print("result")
print(newRanges)
let cannot = newRanges.reduce(0) { $0 + ($1.upperBound - $1.lowerBound) + 1}
print("Occupied bij #:",cannot)

var nobeacon = sensors.filter { $0.beacon.y == row }.map { $0.beacon.x }
nobeacon.append(contentsOf: sensors.filter { $0.at.y == row}.map { $0.at.x })
let occupied = Set(nobeacon)
print("Beacon positions: ",occupied)
let occupiedCount = newRanges.reduce(0) { value, range in occupied.reduce(value) { value,sensor in value + (range.contains(sensor) ? 1 : 0)}}
print("Beacon position count", occupiedCount)
print("Result:",cannot-occupiedCount)


// let minX = ranges.reduce(Int.max) { min($0,$1.lowerBound)}
// let maxX = ranges.reduce(0) { max($0,$1.upperBound)}
// let field = minX...maxX
// print(ranges)
// print(field.lowerBound, field.upperBound)
// var line : [Material] = field.map { _ in .empty}
// var lines : [[Material]] = (0...size.y).map { _ in (0...size.x).map { _ in .empty}}

// let line = ranges[row]
// for (row,line) in ranges.enumerated() {
// print(row,line)
// for range in ranges {
//     for n in range {
//         lines[row][n+offset.x] = .occupied
//     }
// }

// for range in ranges {
//     for n in range {
//         line[n - field.lowerBound] = .occupied
//     }
// }


// for sensor in sensors {
//     // lines[sensor.at.y+offset.y][sensor.at.x+offset.x] = .sensor
//     // lines[sensor.beacon.y+offset.y][sensor.beacon.x+offset.x] = .beacon
//     if (sensor.at.y == row) {
//         line[sensor.at.x-field.lowerBound] = .sensor
//     }
//     if (sensor.beacon.y == row) {
//         line[sensor.beacon.x-field.lowerBound] = .beacon
//     }
// }


// // for (row,line) in lines.enumerated() {
//     print(("  "+String(row)).suffix(2),line.reduce("") { $0 + $1.rawValue })
// // }

// print("   09876543210123456789012345678901234567890123")
// print("             0         1         2         3   ")

// // let line = ranges[11+offset.y]
// // for range in line {
// //     print(range)
// // }

// print(line.reduce(0) { $0 + ($1 == .empty ? 0 : 1)})
