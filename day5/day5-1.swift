import RegexBuilder

var lines : [String] = []
while let line = readLine() {
    lines.append(line)
}

var halves = lines.split(separator: "")

let numbersLine = halves[0].popLast()!

let numberOfCrates = Int(numbersLine.split(separator: #/\s+/#).last!)!

var stacks : [[Character]] = Array(repeating: [], count: numberOfCrates + 1)

for crateLine in halves[0] {
    let line = crateLine.map { $0 }
    for stack in 0..<numberOfCrates {
        let crate = line[1 + stack*4]
        if crate != " " {
            stacks[stack+1].insert(crate, at: 0)
        }
    }
}

let moveRegex = Regex {
    "move "
    Capture(OneOrMore(.digit))
    " from "
    Capture(One(.digit))
    " to "
    Capture(One(.digit))
}

let moves = halves[1].compactMap { $0.firstMatch(of: moveRegex)}
                     .map { (cnt: Int($0.1)!, from: Int($0.2)!, to: Int($0.3)!) }

for move in moves {
    for n in 1...move.cnt {
        guard let crate = stacks[move.from].popLast() else {
            print("In \(move) found empty stack \(move.from) on item \(n)")
            break
        }
        stacks[move.to].append(crate)
    }
}

print(stacks.compactMap { $0.last }.map { String($0) }.joined())

