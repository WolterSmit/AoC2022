import Foundation

let input = stdin()
let first = Field.findShortestPath(for: input, minutes: 300)
let second = Field.findShortestPath(for: input, moveTowardsEnd: false, startingAtMinute: 1+first, minutes: 300)
let third = Field.findShortestPath(for: input, startingAtMinute: 1+first+second, minutes: 300)
print("Shortest path from start to end is \(first) minutes")
print("Shortest time to reach the goal, go back and reach the goal again is \(first+second+third) minutes")

// find the blizzards

struct Field {
    
    var blizzards : [Blizzard] = []
    let emptyField : [[FieldType]]
    
    var fieldByMinute : [[[FieldType]]] = []
    
    let leftEdge : Int
    let rightEdge : Int
    let bottomEdge : Int
    let upperEdge : Int
    var maxMinutes = 0
    
    let goal : Point
    var expedition : Point
    
    // Helper function to start the process. It initatiates a field, and calls the right functions to find the answer
    static func findShortestPath(for field: [any StringProtocol], moveTowardsEnd: Bool = true, startingAtMinute: Int = 1, minutes: Int = 300) -> Int {
        var field = Field(for: field, moveTowardsEnd: moveTowardsEnd)
        
        field.generateFields(startingAtMinute: startingAtMinute, for: minutes)
        
        field.shortestTime = field.maxMinutes
        field.search(minute: 0, from: field.expedition)
        
        return field.shortestTime + 1
    }
    
    // Initialize the field
    init(for input: [any StringProtocol], moveTowardsEnd: Bool = true) {
        
        // Transform the input into a double array of FieldType's.
        var field = input.map { $0.compactMap { FieldType(rawValue: String($0))}}
        
        // Find out where the blizzards are and record them.
        for (y, line) in field.enumerated() {
            for (x, type) in line.enumerated() {
                let position = Point(x: x, y: y)
                
                switch type {
                case .left: blizzards.append(Blizzard(at: position, moving: .left))
                case .right: blizzards.append(Blizzard(at: position, moving: .right))
                case .up: blizzards.append(Blizzard(at: position, moving: .up))
                case .down: blizzards.append(Blizzard(at: position, moving: .down))
                default: break
                }
            }
        }
        
        // Empty the field of the blizzards, so we have an empty template
        for blizzard in blizzards {
            field[blizzard.at] = .empty
        }
        
        // Note the size of the field.
        self.leftEdge = 1
        self.rightEdge = field[0].count - 2
        self.bottomEdge = field.count - 2
        self.upperEdge = 1
        
        // Record the start and the end
        if moveTowardsEnd {
            goal = Point(x: rightEdge, y: bottomEdge+1)
            field[goal] = .goal
            expedition = Point(x: 1, y: 0)
        } else {
            goal = Point(x: 1, y: 0)
            field[goal] = .goal
            expedition = Point(x: rightEdge, y: bottomEdge+1)
        }

        // Record the template
        self.emptyField = field
    }
    
    
    // Generate the snapshots for each minute, starting at a requested minute and
    // proceeding for minutes.
    mutating func generateFields(startingAtMinute: Int, for minutes: Int) {
        // Start with empty templates
        fieldByMinute = Array(repeating: emptyField, count: minutes+1)
        
        // Skip the start phase, but do advance the blizzards
        for _ in 1..<startingAtMinute {
            advanceBlizzards()
        }

        // Now start recording snapshots.
        for minute in 0...minutes {
            advanceBlizzards()
            
            for blizzard in blizzards {
                fieldByMinute[minute][blizzard.at] = .multiple
            }
        }
        
        maxMinutes = minutes
    }

    // Move the blizzard according to its direction. When it hits a wall, start at the other end.
    mutating func advanceBlizzards() {
        blizzards = blizzards.map { blizzard in
            var moveTo = blizzard.at.move(blizzard.moving)
            
            if emptyField[moveTo] == .wall {
                switch blizzard.moving {
                case .right: moveTo.x = leftEdge
                case .left: moveTo.x = rightEdge
                case .down: moveTo.y = upperEdge
                case .up: moveTo.y = bottomEdge
                }
            }
            return Blizzard(at: moveTo, moving: blizzard.moving)
        }
    }
    
    var path : [Point] = []
    var shortestTime = 0

    // Do a recursive search for the shortest path
    mutating func search(minute: Int, from: Point) {
        
        // If we exceeded the maximum number of minutes, return.
        if minute > maxMinutes { return }
        
        // If we are outside our boundaries, return.
        if from.y < 0 || from.y > bottomEdge + 1 { return }
        
        // If we bumped into our goal, check if this path is shorter. And return of course.
        if fieldByMinute[minute][from] == .goal {
            if shortestTime > minute {
                shortestTime = minute
                
//                print("Found \(shortestTime)")
            }
            return
        }
        
        // If the field isn't empty (e.g. there is a blizzard), return.
        if fieldByMinute[minute][from] != .empty { return }
        
        // If we can't reach the goal faster than the shortest path found, return.
        let minimumMovesToExit = abs(goal.x - from.x) + abs(goal.y - from.y)
        
        if minimumMovesToExit + minute > shortestTime {
            return
        }
        
        // March one. Add the present point to the path.
        
        path.append(from)
        
        // And explore all directions, including waiting.
        
        search(minute: minute+1, from: from.move(.up))
        search(minute: minute+1, from: from.move(.down))
        search(minute: minute+1, from: from.move(.right))
        search(minute: minute+1, from: from.move(.left))
        search(minute: minute+1, from: from)
        
        // Mark this point at this time as visited.
        
        fieldByMinute[minute][from] = .wall
        
        path.removeLast()
        
    }

}



// An enum describing the field, including blizzards, the start, the goal, walls and empty spaces.
enum FieldType : String, RawRepresentable {
    case wall = "#"
    case empty = "."
    case up = "^"
    case down = "v"
    case left = "<"
    case right = ">"
    case multiple = "+"
    case goal = "G"
    case start = "S"
}

// An enumeration describing the possible directions of a blizzard and are explorers.
enum Direction {
    case up
    case down
    case left
    case right
}

// A struct describing a point on the map, including a function to move one step in a direction.
struct Point {
    var x: Int
    var y: Int
    
    func move(_ to: Direction) -> Point {
        switch to {
        case .up: return Point(x: self.x, y: self.y - 1)
        case .down: return Point(x: self.x, y: self.y + 1)
        case .left: return Point(x: self.x - 1, y: self.y)
        case .right: return Point(x: self.x + 1, y: self.y)
        }
    }
}

// A struct describing a blizzard, which has a position and a direction.
struct Blizzard {
    var at: Point
    var moving: Direction
}

extension Array<FieldType> {
    var asString : String {
        self.reduce("") { $0 + $1.rawValue }
    }
}

extension Array<Array<FieldType>> {
    
    subscript(at: Point) -> FieldType {
        get {
            return self[at.y][at.x]
        }
        set(newValue) {
            self[at.y][at.x] = newValue
        }
    }
    
    func printIt() {
        for line in self {
            print(line.asString)
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
