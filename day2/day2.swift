let points : [Character:Int] = [ "X": 1, "Y":2, "Z":3 ]
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

var count = 0

while let str = readLine() {

    guard str.count == 3 else { fatalError("Line with other than three characters")}
    guard let match = move[str] else { fatalError("Unknown match \(str)")}

    let third = str.index(str.startIndex, offsetBy: 2)
    guard let move = points[str[third]] else { fatalError("Unknown points \(str[third])")}

    count += match + move

} 

print(count)