import Foundation




let monkeys = stdin()
        .compactMap { Monkey($0) }
        .dictionary

print(monkeys.value(of: "root"))

enum Operation : String {
    case add
    case substract
    case multiply
    case divide
    case equals
}

struct Monkey {
    var name: String
    
    var operation: Operation
    
    var input1: String
    var input2: String
}

struct Monkeys {
    var monkeys : [String:Monkey] = [:]
    
    func value(of name: String) -> Int {
        
        guard let monkey = monkeys[name] else {
            print("Monkey \(name) does not exist")
            exit(-1)
        }
        switch monkey.operation {
        case .equals:       return Int(monkey.input1)!
        case .add:          return value(of: monkey.input1) + value(of: monkey.input2)
        case .substract:    return value(of: monkey.input1) - value(of: monkey.input2)
        case .multiply:     return value(of: monkey.input1) * value(of: monkey.input2)
        case .divide:       return value(of: monkey.input1) / value(of: monkey.input2)
        }
    }

    init(_ from : Array<Monkey>) {
        for monkey in from {
            monkeys[monkey.name] = monkey
        }
    }
}

extension Array<Monkey> {
    var dictionary : Monkeys {
        return Monkeys(self)
    }
}


extension Monkey {
    init?(_ from: any StringProtocol) {
        if let match = String(from).firstMatch(of: #/(.+): (.+) (.) (.+)/#) {
            name = String(match.1)
            input1 = String(match.2)
            switch match.3 {
            case "+": operation = .add
            case "-": operation = .substract
            case "*": operation = .multiply
            case "/": operation = .divide
            default: return nil
            }
            input2 = String(match.4)
        } else if let match = String(from).firstMatch(of: #/(.+): (\d+)/#) {
            name = String(match.1)
            operation = .equals
            input1 = String(match.2)
            input2 = ""
        } else {
            return nil
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

extension Array<Int> {
    var sum : Int {
        self.reduce(0) { $0 + $1 }
    }
    var product : Int {
        self.reduce(1) { $0 * $1 }
    }
}

extension Array where Array.Element: StringProtocol {
    var groups : Array<ArraySlice<Array.Element>> {
        self.split(separator: "")
    }
}

extension String {
    var lines : Array<String.SubSequence> {
        self.split(separator: #/\n/#)
    }
}
