import Foundation

let numbers = stdin()
    .map { $0.compactMap { Pentimal($0) } }

let zero = [Pentimal.zero]
let result = numbers.reduce(zero) { $0.add($1) }

print(result.asString)

// An enumeration describing a Pentimal: A character in a pentimal system
enum Pentimal: Int, RawRepresentable {
    case minmin = 0
    case min = 1
    case zero = 2
    case one = 3
    case two = 4
    
    // Initialize from character input
    init?(_ symbol: Character) {
        switch symbol {
        case "=": self = .minmin
        case "-": self = .min
        case "0": self = .zero
        case "1": self = .one
        case "2": self = .two
        default: return nil
        }
    }
    
    // Give a description as a string
    var symbol: String {
        switch self {
        case .minmin: return "="
        case .min: return "-"
        case .zero: return "0"
        case .one: return "1"
        case .two: return "2"
        }
    }
    
    // An implementation of an addition table, returing a carry and the actual solution.
    func add(_ rhs: Pentimal, with carry: Pentimal = .zero) -> (Pentimal,Pentimal) {
        let addTable : [(Pentimal, Pentimal)] = [
            (.min,.min),
            (.min,.zero),
            (.min,.one),
            (.min,.two),
            (.zero,.minmin),
            (.zero,.min),
            (.zero,.zero),
            (.zero,.one),
            (.zero,.two),
            (.one,.minmin),
            (.one,.min),
            (.one,.zero),
            (.one,.one)
        ]
        
        return addTable[self.rawValue + rhs.rawValue + carry.rawValue]
    }
}

// Extend an array of Pentimals so we can lightweight arithmetic, like adding.
extension Array<Pentimal> {
    
    // return the array as a printable string in original characters
    var asString : String {
        return self.reduce("") { $0 + $1.symbol}
    }
    
    // Add another arraay (pentimal number) to this one.
    
    func add(_ to: Array<Pentimal>) -> Array<Pentimal> {
        
        // Reverse the left-hand and right-hand-side.
        var lhs = self.reversed().makeIterator()
        var rhs = to.reversed().makeIterator()
        
        // Set teh carry to zero.
        var carry = Pentimal.zero
        var pentimal = Pentimal.zero
        
        var result : [Pentimal] = []
        
        // Have iterators for the left and right hand side.
        var left = lhs.next()
        var right = rhs.next()
        
        // As long as left or right still has values
        while left != nil || right != nil {
            
            // Add them up, If either left or rigth ran out of values, use .zero
            (carry, pentimal) = (left ?? .zero).add((right ?? .zero), with: carry)
            
            // Record the result.
            result.insert(pentimal, at: 0)
            
            left = lhs.next()
            right = rhs.next()
        }
        
        // Do not forget the carry
        if carry != .zero {
            result.insert(carry, at: 0)
        }
        return result
    }
}

func stdin() -> [String] {
    var linesRead : [String] = []
    while let line = readLine() {
        linesRead.append(line)
    }
    return linesRead
}
