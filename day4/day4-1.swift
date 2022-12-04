import RegexBuilder

var lines : [String] = []
while let line = readLine() {
    lines.append(line)
}

let regex = Regex {
    Capture { OneOrMore(.digit) }
    "-"
    Capture { OneOrMore(.digit) }
    ","
    Capture { OneOrMore(.digit) }
    "-"
    Capture { OneOrMore(.digit) }
}

let areas = lines
        .compactMap { $0.firstMatch(of: regex) }
        .map { [$0.1,$0.2,$0.3,$0.4].compactMap { Int($0)} }

let overlapping = areas.filter { pair in 
    if pair[0] <= pair[2] && pair[3] <= pair[1] { return true }
    if pair[2] <= pair[0] && pair[1] <= pair[3] { return true }
    return false
}

print(overlapping.count)