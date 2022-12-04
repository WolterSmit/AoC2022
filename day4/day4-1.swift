import RegexBuilder

var lines : [String] = []
while let line = readLine() {
    lines.append(line)
}

let number = TryCapture { OneOrMore(.digit) } transform: { Int($0) }

let regex = Regex {
    number
    "-"
    number
    ","
    number
    "-"
    number
}

let overlapping = lines
        .compactMap { $0.firstMatch(of: regex) }
        .filter { pair in 
                    if pair.1 <= pair.3 && pair.4 <= pair.2 { return true }
                    if pair.3 <= pair.1 && pair.2 <= pair.4 { return true }
                    return false
                }

print(overlapping.count)
