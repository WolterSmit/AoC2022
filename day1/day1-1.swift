
var ranking : [Int] = []

while true {

    var this_elf = 0

    while let str = readLine() , let number = Int(str) {
        this_elf += number
    }

    guard this_elf > 0 else { break }

    ranking.append(this_elf)
} 

ranking.sort(by: >)

guard ranking.count > 0 else { fatalError("Not enough values.") }

print("Max: \(ranking[0])")

guard ranking.count >= 3 else { fatalError("Not enough values.") }

print("Top 3: \(ranking[0]+ranking[1]+ranking[2])")
