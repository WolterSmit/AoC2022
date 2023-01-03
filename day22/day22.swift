import Foundation
let input = stdin().groups

let boardLines = input[0]
let instructionsLine = String(input[1].first!)


let instructions = Instruction.from(line: instructionsLine)

var board = Board(from: boardLines)
for instruction in instructions {
    board.execute(instruction: instruction, asFlatSurface: true)
}

print(board.position, board.direction)
print(board.position.y * 1000 + board.position.x * 4 + board.direction.rawValue)

board = Board(from: boardLines)
for instruction in instructions {
    board.execute(instruction: instruction, asFlatSurface: false)
}
print(board.position, board.direction)
print(board.position.y * 1000 + board.position.x * 4 + board.direction.rawValue)

// An enumeration indicating the contents of a tile on the map.
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

struct Board {
    var board : [[Tile]]
    let boardSize : Point
    let horizontal : ClosedRange<Int>
    let vertical : ClosedRange<Int>
    
    var direction : Direction = .right
    var position : Point
    
    mutating func execute(instruction: Instruction, asFlatSurface: Bool = false) {
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
                if board[position] == .void {
                    if asFlatSurface {

                        var lastPositionBeforeVoid : Point
                        repeat {
                            lastPositionBeforeVoid = position
                            switch direction {
                            case .right: position.x -= 1
                            case .left: position.x += 1
                            case .up: position.y += 1
                            case .down: position.y -= 1
                            }
                        } while board[position] != .void
                        position = lastPositionBeforeVoid
                        
                    } else {
                    
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
                }
                
                if board[position] == .wall {
                    direction = oldDirection
                    position = oldPosition
                    break
                }
            }
        }
    }
    
    init<Input : Sequence>(from input: Input) where Input.Element : StringProtocol {
        
        let maxCols = input.reduce(0) { max($0, $1.count)}

        let emptyLine = Array(repeating: Tile.void, count: maxCols + 3)
        board = []
        board.append(emptyLine)
        for line in input {
            var boardLine : [Tile] = [ .void ]
            
            boardLine.append(contentsOf: line.compactMap { Tile(rawValue: String($0))})
            
            for _ in boardLine.count...(maxCols + 2) {
                boardLine.append(.void)
            }
            board.append(boardLine)
        }
        board.append(emptyLine)
        
        let startPosition = (x: board[1].prefix(while: { $0 == .void }).count ,y:1)
        
        self.position = startPosition
        self.boardSize = Point(x: maxCols, y: board.count - 2)
        self.horizontal = 0...boardSize.x
        self.vertical = 0...boardSize.y
        
    }
    
    // Print the board in its present state.
    func printIt() {
        print()
        for line in board {
            print(line.concatenate)
        }
    }
}


enum Instruction {
    case move(steps: Int)
    case left
    case right
    
    //
    static func from(line: any StringProtocol) -> [Instruction] {
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
        
        return instructions
    }
}



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
}

extension Array where Array.Element: RawRepresentable, Element.RawValue == String {
    var concatenateWithSpace: String {
        String(self.reduce("") { $0 + $1.rawValue + " " }
            .dropLast())
    }

    var concatenate: String {
        String(self.reduce("") { $0 + $1.rawValue }
            .dropLast())
    }
}

extension MutableCollection where Index == Int, Element : MutableCollection, Element.Index == Int {
    subscript(idx: Point) -> Element.Element {
        get { return self[idx.y][idx.x] }
        set(newValue) { self[idx.y][idx.x] = newValue }
    }
}

extension String {
    var lines : [String.SubSequence] {
        self.split(separator: "\n", omittingEmptySubsequences: false)
    }
}

