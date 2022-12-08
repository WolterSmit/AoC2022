import Foundation

var lines : [String] = []
while let line = readLine() {
    lines.append(line)
}

let patch = lines.map { $0.compactMap { Int(String($0)) } }
let rows = patch.count
let cols = patch.first!.count

func score(height: Int, line : [Int]) -> Int {
    var score = 0 
    for tree in line {
        score += 1
        if tree >= height {
            break
        }
    }
    return score
}

var columns = (0..<cols).map { col in (0..<rows).map { row in patch[row][col] }}

var scenicScore = 0
for (row, line) in patch.enumerated() {
    for (col,tree) in line.enumerated() {

        let top = score(height: tree, line: columns[col].prefix(row).reversed())
        let bottom = score(height: tree, line: columns[col].suffix(rows-row-1))

        let left = score(height: tree, line: line.prefix(col).reversed())
        let right = score(height: tree, line: line.suffix(cols-col-1))

        let scenic = top*bottom*left*right
        scenicScore = max(scenic,scenicScore)

    }
}

print(scenicScore)