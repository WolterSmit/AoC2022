import Foundation

var linesRead : [String] = []
while let line = readLine() {
    linesRead.append(line)
}

typealias Point = (y: Int, x: Int)

let sensors = linesRead.map { $0.matches(of: #/x=([-|\d]+), y=([-|\d]+)/#).map { (y: Int($0.2)!, x: Int($0.1)! ) } }
                        .map { ( at: $0[0], beacon: $0[1])}

enum Material : String {
    case empty = "."
    case occupied = "#"
    case sensor = "S"
    case beacon = "B"
}


for row in 0...4_000_000 {
    if (row & 65535 == 0) {
        print(row)
    }
    let ranges = sensors.compactMap { 
        let distance = abs($0.at.x - $0.beacon.x) + abs($0.at.y - $0.beacon.y) - abs(row-$0.at.y)

        return (distance >= 0 ? ($0.at.x - distance)...($0.at.x + distance) : nil)
    }

    let sortedRanges = ranges.sorted(by: { $0.lowerBound < $1.lowerBound})
    // print(sortedRanges)

    var newRanges : [ClosedRange<Int>] = []
    var previousRange = sortedRanges.first!
    for range in sortedRanges.dropFirst() {
        // print(previousRange, range)
        if previousRange.upperBound < range.lowerBound - 1 {
            newRanges.append(previousRange)
            previousRange = range
        } else if previousRange.upperBound < range.upperBound {
            previousRange = previousRange.lowerBound...range.upperBound
        }
    }
    newRanges.append(previousRange)

    // let field = 0...20
    // var line : [Material] = field.map { _ in .empty}

    // for range in ranges {
    //     for n in range {
    //         if field ~= n {
    //             line[n] = .occupied
    //         }
    //     }
    // }
    // print(("  "+String(row)).suffix(2),line.reduce("") { $0 + $1.rawValue }, newRanges.count)
    if newRanges.count > 1 {

        let x = newRanges[0].upperBound+1
        print("Empty found at : \(row),\(x)")
        print(newRanges)
        print("Tuning frequency:", x*4000000 + row)
    }
}

// print("   012345678901234567890")
// print("   0         1         2")

// print("result")
// print(newRanges)
// let cannot = newRanges.reduce(0) { $0 + ($1.upperBound - $1.lowerBound) + 1}
// print("Occupied bij #:",cannot)

// var nobeacon = sensors.filter { $0.beacon.y == row }.map { $0.beacon.x }
// nobeacon.append(contentsOf: sensors.filter { $0.at.y == row}.map { $0.at.x })
// let occupied = Set(nobeacon)
// print("Beacon positions: ",occupied)
// let occupiedCount = newRanges.reduce(0) { value, range in occupied.reduce(value) { value,sensor in value + (range.contains(sensor) ? 1 : 0)}}
// print("Beacon position count", occupiedCount)
// print("Result:",cannot-occupiedCount)

