import Foundation

var lines : [String] = []
while let line = readLine() {
    lines.append(line)
}

let rawMonkeys = lines.split(whereSeparator: { $0 == ""})
print(rawMonkeys.count)

class PrimeInt : CustomStringConvertible {
    var value : Int

    var divisors : [Int:Int] = [:]

    init(_ value: Int, keepTrackOf: [Int] = []) {
        self.value = value

        for divisor in keepTrackOf {
            divisors[divisor] = value % divisor
        }
    }

    init(_ primeInt: PrimeInt) {
        self.value = primeInt.value
        for (divisor,_) in primeInt.divisors {
            divisors[divisor] = primeInt.divisors[divisor]
        }
    }

    func addPrimes(primes : [Int]) {
        for prime in primes {
            divisors[prime] = value % prime
        }
    }

    static func += (left: inout PrimeInt, right: Int) {
        for (divisor,value) in left.divisors {
            left.divisors[divisor] = (value + right) % divisor
        }
    }
    
    static func *= (left: inout PrimeInt, right: Int) {
        for (divisor,value) in left.divisors {
            left.divisors[divisor] = (value * right) % divisor
        }
    }

    static func *= (left: inout PrimeInt, right: PrimeInt) {
        for (divisor,value) in left.divisors {
            left.divisors[divisor] = (value * right.divisors[divisor]!) % divisor
        }
    }

    static func % (left: PrimeInt, right: Int) -> Int {
        return left.divisors[right]!
    }

    var description: String {
        "\(value) (" + divisors.reduce("") { "\($0),\($1.value)" }.dropFirst() + ")"
    }
}

class Monkey : CustomStringConvertible {
    var number : Int = 0
    var items : [PrimeInt] = []
    var operation : Character = " "
    var operationValue : Int = 0
    var divisibleBy : Int = 0
    var ifTrue : Int = 0
    var ifFalse : Int = 0
    
    var description: String {
        "\(items)"
    }
    
    var inspections = 0
}

let monkeys = rawMonkeys.enumerated().map { n, rawMonkey in
    let lines = Array(rawMonkey)
    let monkey = Monkey()
    monkey.number = n
    monkey.items = lines[1].split(separator: ": ")[1].split(separator: ", ").map { PrimeInt(Int($0)!) } 
    if let _ = lines[2].firstMatch(of: #/old \* old/#) {
        monkey.operation = "^"
    }
    if let match = lines[2].firstMatch(of: #/old (.) (\d+)/#) {
        monkey.operation = match.1.first!
        monkey.operationValue = Int(match.2)!
    }
    monkey.divisibleBy = Int(lines[3].firstMatch(of: #/by (\d+)/#)?.1 ?? "")!
    monkey.ifTrue = Int(lines[4].firstMatch(of: #/monkey (\d+)/#)?.1 ?? "")!
    monkey.ifFalse = Int(lines[5].firstMatch(of: #/monkey (\d+)/#)?.1 ?? "")!

    return monkey
}


let divisors = monkeys.map { $0.divisibleBy }.sorted()
for monkey in monkeys {
    for item in monkey.items {
        item.addPrimes(primes: divisors)
    }
}
print(divisors)


print(0,monkeys)

for round in 1...10000 {
    
    for monkey in monkeys {
        while monkey.items.count > 0 {
            monkey.inspections += 1
            
            var worry = monkey.items.removeFirst()
            switch monkey.operation {
            case "*":
                worry *= monkey.operationValue
            case "+":
                worry += monkey.operationValue
            case "^":
                worry *= worry
                break
            default: print(monkey.operation)
            }

            if worry % monkey.divisibleBy == 0 {
                monkeys[monkey.ifTrue].items.append(worry)
            } else {
                monkeys[monkey.ifFalse].items.append(worry)
            }
            
        }
    }
    print(round,monkeys)
}


let activities = monkeys.map {$0.inspections}.sorted(by: >)

print(monkeys.map {$0.inspections}, activities[0]*activities[1])

