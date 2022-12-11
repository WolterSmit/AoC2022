import Foundation

var lines : [String] = []
while let line = readLine() {
    lines.append(line)
}

let instructionsSplit = lines.map { $0.split(separator: " ") }
let instructions = instructionsSplit.map { (opcode: String($0[0]), value: $0.count>1 ? (Int($0[1]) ?? 0) : 0)}

for line in display {
    print(String(line))
}

var opcodeLengh = [
    "noop" : 1,
    "addx" : 2
]

var strengths = [20,60,100,140,180,220]
var signalStrengths = 0

var x = 1
var cycle = 0

for instruction in instructions {
    let opcode = instruction.opcode

    for n in 1...opcodeLengh[opcode]! {
        cycle += 1
        
        if strengths.contains(cycle) {
            print("\(cycle): \(x) doing \(opcode) \(n) ")
            signalStrengths += cycle * x
        }
    }
    switch opcode {
        case "addx":
            x += instruction.value
        default: break
    }
}
// cycle += 1
// print("\(cycle): \(x)  ")

print(signalStrengths)