var lines : [String] = []
while let line = readLine() {
    lines.append(line)
}

let points : [Substring:Int] = [ "X": 1, "Y":2, "Z":3 ]
let move : [String:Int] = [
    "A X": 3,
    "B Y": 3,
    "C Z": 3,
    "A Y": 6,
    "A Z": 0,
    "B X": 0,
    "B Z": 6,
    "C X": 6,
    "C Y": 0
]


let count = lines.reduce(0) {
    $0 + move[$1]! + points[$1.suffix(1)]!
}

print(count)