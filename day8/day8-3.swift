import Foundation

var lines : [String] = []
while let line = readLine() {
    lines.append(line)
}

let patch = lines.map { $0.compactMap { Int(String($0)) } }
let rows = patch.count
let cols = patch.first!.count

var columns = (0..<cols).map { col in (0..<rows).map { row in patch[row][col] }}

var visibleTrees = rows * cols

for line in patch {
    // var col = columns.makeIterator()
    var leftOfTree : [Int] = []
    var rightOfTree = line
    for tree in line {
        let left = leftOfTree.max() ?? -1
        let right = rightOfTree.max() ?? -1

        leftOfTree.append(tree)
        rightOfTree.removeFirst()
    }
}

for (row, line) in patch.enumerated() {
    for (col,tree) in line.enumerated() {

        let top = columns[col].prefix(row).max() ?? -1
        let bottom = columns[col].suffix(rows-row-1).max() ?? -1

        let left = line.prefix(col).max() ?? -1
        let right = line.suffix(cols-col-1).max() ?? -1

        if left >= tree && right >= tree && top >= tree && bottom >= tree {
            visibleTrees -= 1
        }
    }
}

print(visibleTrees)
