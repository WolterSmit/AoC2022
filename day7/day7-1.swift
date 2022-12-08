import Foundation

var lines : [String] = []
while let line = readLine() {
    lines.append(line)
}


class Directory { 
    var name : String
    var files : [(name: String, size: Int)] = []
    var directories : [Directory] = []

    init(_ name: String) {
        self.name = name
    }

    var size : Int {
        let sizeOfFiles = files.reduce(0) { $0 + $1.size }
        let sizeOfDirectories = directories.reduce(0) { $0 + $1.size }
        return sizeOfFiles + sizeOfDirectories
    }

    var sizes : [Int] {
        [size] + directories.flatMap { $0.sizes }
    }
}

var tree = Directory("")
var path : [Directory] = [tree]

for line in lines {
    let tokens = line.split(separator: #/\s+/#)
    let count = tokens.count

    // print(path.map { $0.name+"/" }.joined())

    guard count > 1 else { exit(-1) }
    switch tokens[0] {
        case "$":
            switch tokens[1] {
                case "cd": 
                    guard count > 2 else { exit(-3) }
                    switch tokens[2] {
                        case "/":  path = [path[0]]
                        case "..": path = path.dropLast()
                        default:   path.append(path.last!.directories.filter { $0.name == tokens[2]}.first!)
                    }
                // case "ls": 
                default: break
            }
        case "dir":
            path.last!.directories.append(Directory(String(tokens[1])))
        default: 
            guard let size = Int(tokens[0]) else { exit(-4) }
            path.last!.files.append((name: String(tokens[1]), size: size))
    }
}

tree.prettyPrint()

print(tree.sizes)
print(tree.sizes.filter { $0 < 100_000}.reduce(0,+))

let necessarySpace = 30_000_000 - (70_000_000 - tree.size)
print("necessary space: \(necessarySpace)")
print(tree.sizes.sorted(by: <).filter { $0 >= necessarySpace}.first!)



extension Directory {

    func prettyPrint(indentBy: Int = 0) {
        let indent = String(repeating: " ", count: indentBy)

        print("\(indent)/\(name) \(size)")
        for directory in directories {
            directory.prettyPrint(indentBy: indentBy+2)
        }
        for file in files {
            print("\(indent)  \(file.name) \(file.size)")
        }
    }

}
