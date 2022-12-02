var lines : [String] = []

while let line = readLine() {
    lines.append(line)
}

let calories = lines
                .split(whereSeparator: { $0 == ""})
                .map { $0
                        .compactMap { Int($0)}
                        .reduce(0,+)
                }
                .sorted(by: >)

print("Max: \(calories.first!)")

print("Top 3: \(calories[0]+calories[1]+calories[2])")

