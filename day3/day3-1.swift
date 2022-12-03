var lines : [String] = []

while let line = readLine() {
    lines.append(line)
}

let groups = lines
    .map { rucksack in [rucksack.prefix(rucksack.count/2),rucksack.suffix(rucksack.count/2)]}
    .map { rucksack in rucksack.map { compartment in Set(compartment)} }

let priority = groups
    .compactMap { compartments in compartments[0].intersection(compartments[1]).first?.asciiValue }
    .map { ascii in Int(ascii>96 ? ascii-96 : ascii-64+26) }
    .reduce(0,+)

print(priority)
