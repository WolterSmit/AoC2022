var lines : [String] = []

while let line = readLine() {
    lines.append(line)
}

let groups = stride(from: 0, to: lines.count, by: 3)
                .map { lines[$0..<$0+3].map { Set($0)} }

let badge = groups
            .compactMap { group in group[0].intersection(group[1].intersection(group[2])).first?.asciiValue }
            .map { ascii in Int(ascii>96 ? ascii-96 : ascii-64+26) }
            .reduce(0,+)

print(badge)

