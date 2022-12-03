var lines : [String] = []
while let line = readLine() {
    lines.append(line)
}

let response : [String:Int] = [
    "A Y": 3 + 1,
    "B Y": 3 + 2,
    "C Y": 3 + 3, 
    "A X": 0 + 3,
    "B X": 0 + 1,
    "C X": 0 + 2,
    "A Z": 6 + 2,
    "B Z": 6 + 3,
    "C Z": 6 + 1
]

let count = lines.reduce(0) { $0 + response[$1]! }

print(count)