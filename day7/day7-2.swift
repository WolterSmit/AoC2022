import Foundation

var lines : [String] = []
while let line = readLine() {
    lines.append(line)
}

class Directory { 
    var files : [String:Int] = [:]
    var directories : [String:Directory] = [:]

    var size : Int {
        let sizeOfFiles = files.reduce(0) { $0 + $1.value }
        let sizeOfDirectories = directories.reduce(0) { $0 + $1.value.size }
        return sizeOfFiles + sizeOfDirectories
    }

    var sizes : [Int] {
        [size] + directories.flatMap { $0.value.sizes }
    }
}

var tree = Directory()
var path : [Directory] = [tree]

for line in lines {
    let tokens = line.split(separator: #/\s+/#).map { String($0) }
    let tokenCount = tokens.count

    guard tokenCount > 1 else { exit(-1) }
    switch tokens[0] {
        case "$":
            switch tokens[1] {
                case "cd": 
                    guard tokenCount > 2 else { exit(-3) }
                    switch tokens[2] {
                        case "/":  path = [path[0]]
                        case "..": path = path.dropLast()
                        default:   guard let descendInto = path.last?.directories[tokens[2]] else { exit(-4) }
                                   path.append(descendInto)
                    }
                default: break
            }
        case "dir":
            path.last!.directories[tokens[1]] = Directory()
        default: 
            guard let size = Int(tokens[0]) else { exit(-5) }
            path.last!.files[tokens[1]] = size
    }
}

tree.prettyPrint()
print(tree.sizes.filter { $0 < 100_000}.reduce(0,+))

let necessarySpace = 30_000_000 - (70_000_000 - tree.size)
print("necessary space: \(necessarySpace)")
print(tree.sizes.sorted(by: <).filter { $0 >= necessarySpace}.first!)



extension Directory {

    func prettyPrint(indentBy: Int = 0) {
        if indentBy == 0 {
            print("/ \(size)")
        }
        let indent = String(repeating: " ", count: indentBy+2)

        for (name, directory) in directories {
            print("\(indent)/\(name) \(directory.size)")
            directory.prettyPrint(indentBy: indentBy+2)
        }
        for (name, size) in files {
            print("\(indent)\(name) \(size)")
        }
    }

}
