var lines : [String] = []
while let line = readLine() {
    lines.append(line)
}

let transmission = lines[0]
let length = transmission.count

print("Length: \(length)")

var n = 0
while n < length-4 {
    let snippet = transmission.dropFirst(n)
    let set = Set(snippet.prefix(4))
    if set.count == 4 { break }
    n += 1
}
print(n+4)