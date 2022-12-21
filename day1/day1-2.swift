var lines : [String] = []

while let line = readLine() {
    lines.append(line)
}

let calories = lines
                .split(separator: "")
                .map { $0
                        .compactMap { Int($0)}
                        .reduce(0,+)
                }
                .sorted(by: >)

print("Max: \(calories.first!)")

print("Top 3: \(calories.prefix(3).reduce(0,+))")

