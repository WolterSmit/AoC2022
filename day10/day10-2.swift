import Foundation

var lines : [String] = []
while let line = readLine() {
    lines.append(line)
}

let instructionsSplit = lines.map { $0.split(separator: " ") }
let instructions = instructionsSplit.map { (opcode: String($0[0]), value: $0.count>1 ? (Int($0[1]) ?? 0) : 0)}

var display : [[Character]] = Array(repeating: [], count: 6)

var opcodeLengh = [
    "noop" : 1,
    "addx" : 2
]

var col = 0
var row = 0

var x = 1

for instruction in instructions {
    let opcode = instruction.opcode

    for _ in 1...opcodeLengh[opcode]! {
        if (x-1)...(x+1) ~= col {
            display[row].append("#")
        } else {
            display[row].append(".")
        }

        col += 1
        if col > 39 {
            col = 0
            row += 1
        }
    }
    switch opcode {
        case "addx":
            x += instruction.value
        default: break
    }
}

for line in display {
    print(String(line))
}

