import Foundation
let input = stdin()
                .groups


let boardLines = input[0]
let instructionsLine = String(input[1].first!)

enum Tile : String {
    case void = " "
    case empty = "."
    case wall = "#"
    case right = ">"
    case left = "<"
    case up = "^"
    case down = "v"
}


typealias Point = (x: Int, y: Int)
let boardSize = Point(x: (boardLines.reduce(0) { max($0, $1.count)}), y: boardLines.count)
let horizontal = 0...boardSize.x
let vertical = 0...boardSize.y



var board : [[Tile]] = [Array(repeating: .void, count: boardSize.x + 3)]
for line in boardLines {
    var boardLine : [Tile] = [ .void ]

    boardLine.append(contentsOf: line.compactMap { Tile(rawValue: String($0))})
    
    for _ in boardLine.count...(boardSize.x+2) {
        boardLine.append(.void)
    }
    board.append(boardLine)
}
board.append(Array(repeating: .void, count: boardSize.x + 3))

let startPosition = (x: board[1].prefix(while: { $0 == .void }).count ,y:1)

func printBoard() {
    print()
    for line in board {
        print(line.concatenate)
    }
}

print(instructionsLine)

enum Instruction {
    case move(steps: Int)
    case left
    case right
}

var instructions : [Instruction] = []
if let firstMove = instructionsLine.firstMatch(of: #/(\d+)/#) {
    let steps = Int(String(firstMove.1))!
    instructions.append(.move(steps: steps))
}
let ranges = instructionsLine.ranges(of: #/(L|R)(\d+)/#)
for range in ranges {
    if instructionsLine[range].prefix(1) == "L" {
        instructions.append(.left)
    } else {
        instructions.append(.right)
    }
    let steps = Int(String(instructionsLine[range].dropFirst()))!
    instructions.append(.move(steps: steps))
}

//print(instructions)
//print(startPosition)

enum Direction : Int {
    case up = 3, down = 1, left = 2, right = 0
    
    var tile : Tile {
        switch self {
        case .up: return .up
        case .left: return .left
        case .down: return .down
        case .right: return .right
        }
    }
    
    func go(_ turn : Instruction) -> Direction {
        switch turn {
        case .left:
            switch self {
            case .up: return .left
            case .left: return .down
            case .down: return .right
            case .right: return .up
            }
        case .right:
            switch self {
            case .up: return .right
            case .right: return .down
            case .down: return .left
            case .left: return .up
            }
        default: return self
        }
    }
}

var direction : Direction = .right
var position : Point = startPosition

for instruction in instructions {
    switch instruction {
    case .left: direction = direction.go(.left)
    case .right: direction = direction.go(.right)
    case .move(var steps):
        
        while steps > 0 {
            let oldPosition = position
            let oldDirection = direction
            switch direction {
            case .right: position.x += 1
            case .left: position.x -= 1
            case .up: position.y -= 1
            case .down: position.y += 1
            }

            board[oldPosition.y][oldPosition.x] = direction.tile
            steps -= 1
            
            // Bumping into a void?
            if board[position.y][position.x] == .void {
                switch (position.x, position.y) {
                case (51...100, 151):
                    position = Point(x: 50, y: 100+position.x )
                    direction = .left
                case (0,151...200):
                    position = Point(x: position.y-100, y: 1)
                    direction = .down
                case (51...100, 0):
                    position = Point(x: 1, y: position.x+100)
                    direction = .right
                case (51, 151...200):
                    position = Point(x: position.y-100,y: 150)
                    direction = .up
                    
                case (151, 1...50):
                    position = Point(x: 100, y: 151-position.y)
                    direction = .left
                case (0, 101...150):
                    position = Point(x: 51, y: 151-position.y)
                    direction = .right
                case (50, 1...50):
                    position = Point(x: 1, y: 151-position.y)
                    direction = .right
                case (101, 101...150):
                    position = Point(x: 150, y: 151-position.y)
                    direction = .left
                    
                case (101...150,51):
                    position = Point(x: 100, y: position.x-50)
                    direction = .left
                case (50,51...100):
                    position = Point(x: position.y-50, y:101)
                    direction = .down
                case (1...50,201):
                    position = Point(x: position.x+100, y:1)
                    direction = .down
                case (101...150,0):
                    position = Point(x: position.x-100, y:200)
                    direction = .up
                case (1...50,100):
                    position = Point(x: 51, y: position.x + 50)
                    direction = .right
                case (101,51...100):
                    position = Point(x: position.y+50, y: 50)
                    direction = .up
                    
                default: print("Reached default. Weird")
                }
            }

            if board[position.y][position.x] == .wall {
                direction = oldDirection
                position = oldPosition
                break
            }
        }
    }
}

printBoard()
print(position, direction)

print(position.y * 1000 + position.x * 4 + direction.rawValue)

func stdin() -> [String] {
  var linesRead : [String] = []
  while let line = readLine() {
    linesRead.append(line)
  }
  return linesRead
}

extension Array where Array.Element: StringProtocol {
    var groups : Array<ArraySlice<Array.Element>> {
        self.split(separator: "")
    }
    
    var concatenate : String  {
        self.reduce("",+)
    }
    
    var concatenateWithSpace : String {
        String(self.reduce("") { $0 + $1 + " "}
                   .dropLast())
    }
    
    var intValues : [Int] {
        self.map { $0.intValue.expect(or: "Cannot convert to Int") }
    }
}

extension Array where Array.Element: RawRepresentable ,Element.RawValue == String {
    var concatenateWithSpace: String {
        String(self.reduce("") { $0 + $1.rawValue + " " }
                    .dropLast())
    }
        
    var concatenate: String {
        String(self.reduce("") { $0 + $1.rawValue }
            .dropLast())
    }
}

extension Array where Array.Element == Int {
    var concatenateWithSpace: String {
        String(self.reduce("") { $0 + String($1) + " " }
                    .dropLast())
    }
}

extension String {
    var lines : Array<String.SubSequence> {
        self.split(separator: "\n")
    }
}

extension StringProtocol {
    var intValue : Int? { Int(self) }
}

extension Optional {
    func expect(or message: String) -> Wrapped {
        guard let value = self else { print(message); exit(-1) }
        return value
    }
}

