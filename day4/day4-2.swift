var lines : [String] = []
while let line = readLine() {
    lines.append(line)
}

let areas = lines
        .compactMap { $0.firstMatch(of: #/(\d+)-(\d+),(\d+)-(\d+)/#) }
        .map { [$0.1,$0.2,$0.3,$0.4].compactMap { Int($0)} }

let overlapping = areas.filter { pair in 
    if pair[1] < pair[2] { return false }
    if pair[3] < pair[0] { return false }
    return true
}

print(overlapping.count)