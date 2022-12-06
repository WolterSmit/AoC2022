var lines : [String] = []
while let line = readLine() {
    lines.append(line)
}

let transmission = lines[0]
let length = transmission.count

print("Length: \(length)")

let markerLength = 14
var n = 0
while n < length-markerLength {
    let snippet = transmission.dropFirst(n)
    let set = Set(snippet.prefix(markerLength))
    if set.count == markerLength { break }
    n += 1
}
print(n+markerLength)