import Foundation

let field = stdin()
var elves = Elves(with: field)

// Run ten rounds

elves.updateField()
for counter in 1...10 {
    elves.moveElvesIn(round: counter)
    elves.updateField()
}

// Tally the number of empty spaces.

let emptySpaces = elves.field.dropFirst().dropLast().reduce(0) {
    $0 + $1.dropFirst().dropLast().filter({$0 == "."}).count
}

// Run more rounds until no elf has moved.

var counter = 10
var haveElvesMoved = true
repeat {
    counter += 1
    elves.updateField()
    haveElvesMoved = elves.moveElvesIn(round: counter)
    print("Round",counter)
} while haveElvesMoved

// Report the results

print("After 10 rounds we have \(emptySpaces) empty spaces.")
print("It took \(counter) rounds before no elf moved.")


// An enum with possible directions.
enum Direction : CaseIterable {
    case N, NE, NW, S, SE, SW, E, W
}

// A point on the map, including a function to move in a direction.
struct Point : Equatable, Hashable {
    var x: Int
    var y: Int
    
    func move(_ to: Direction) -> Point {
        switch to {
        case .N: return Point(x: x, y: y-1)
        case .S: return Point(x: x, y: y+1)
        case .E: return Point(x: x+1, y: y)
        case .W: return Point(x: x-1, y: y)
        case .NE: return Point(x: x+1, y: y-1)
        case .NW: return Point(x: x-1, y: y-1)
        case .SE: return Point(x: x+1, y: y+1)
        case .SW: return Point(x: x-1, y: y+1)
        }
    }
}


// The main structure keeping track of the elves.
class Elves {
    // All the elves on the map
    var elves : [Point] = []
    
    // A field that will be constructed (with updateField) of where the elves are.
    var field : [[Character]] = []
    // An offset and size of the field. Elves can have negative coordinates, and the array cannot.
    var offset = Point(x: 0, y: 0)
    var size = Point(x: 0, y: 0)
    
    
    // Move the elves according to he movement rules
    @discardableResult func moveElvesIn(round: Int) -> Bool {
        
        // A handy list with all neighbours and possible directions they can go to.
        let allNeighbours = Direction.allCases
        let proposals : [[Direction]] = [
            [ .N, .NE, .NW ],
            [ .S, .SE, .SW ],
            [ .W, .NW, .SW ],
            [ .E, .NE, .SE ],
            [ .N, .NE, .NW ],
            [ .S, .SE, .SW ],
            [ .W, .NW, .SW ]
        ]
        
        // Create an array of tuples (original: Point, propose: Int) indicating the
        // original position of an elf and the suggested new position
        
        let proposed = elves.map { elf in
            
            // Check for neighbours in any direction
            
            if hasNo(neighbours: allNeighbours, for: elf) {
                
                // No neighbours. Stay put.
                return (original: elf, propose: elf)
            }
            
            // The search for neighbours is rotated per round
            let proposalOffset = (round - 1) & 3
            for proposal in proposals[proposalOffset..<(proposalOffset+4)] {
                if hasNo(neighbours: proposal, for: elf) {
                    // It has neighbours in a direction. Use that direction as a suggestion
                    return (original: elf, propose: elf.move(proposal[0]))
                }
            }
            
            return (original: elf, propose: elf)
        }
        
        // Group the proposed new positions
        
        let elvesByDestination = Dictionary(grouping: proposed, by: { $0.propose} )
        
        // If there are collisions, reset the position to the original.
        let elvesAfterCollision = elvesByDestination.flatMap {
            if $0.value.count > 1 {
                return $0.value.map { (original: $0.original, propose: $0.original) }
            }
            return $0.value.map { (original: $0.original, propose: $0.propose) }
        }
        
        // If all the suggested positions are the same as the old ones, no elf has moved.
        let haveElvesMoved = elvesAfterCollision.contains {
            $0.original != $0.propose
        }
        
        // Set the elves to the new position.
        
        elves = elvesAfterCollision.map { $0.propose }
        
        return haveElvesMoved
    }
    
    // Check whether an elf (for elf), has neighbours as indicated by the aray of directions.
    func hasNo(neighbours: [Direction], for elf: Point) -> Bool {
        return neighbours.reduce(true) {
            let neighbour = elf.move($1)
            return $0 && field[neighbour.y-offset.y][neighbour.x-offset.x] != "#"
        }
    }
    
    // Create a field with the present positions of the elves. Add an empty border at all sides.
    func updateField() {
        
        assert(elves.count > 0)
        
        // Calculate an offset and a size of the field by looking at the elves-coordinates.
        
        let minX = elves.min(by: { $0.x < $1.x })!.x
        let maxX = elves.max(by: { $0.x < $1.x })!.x
        let minY = elves.min(by: { $0.y < $1.y })!.y
        let maxY = elves.max(by: { $0.y < $1.y })!.y

        offset = Point(x: minX-1, y: minY-1)
        size = Point(x: 3 + maxX - minX, y: 3 + maxY - minY)
        
        // Create an empty field (denoted by '.')
        
        field = Array(repeating: Array<Character>(repeating: ".", count: size.x), count: size.y)
        
        // Use the position of the elves and indicate them with '#'.
        
        for elf in elves {
            field[elf.y-offset.y][elf.x-offset.x] = "#"
        }
    }
    
    // Initialize the Elves struct with an array of strings. '#' denotes an elf.
    init(with field: [any StringProtocol]) {
        
        for (y, line) in field.enumerated() {
            for (x, symbol) in String(line).enumerated() {
                if symbol == "#" {
                    elves.append(Point(x: x, y: y))
                }
            }
        }
    }
    
    
    // Print the field
    func printField() {
        for line in field {
            print(String(line))
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
