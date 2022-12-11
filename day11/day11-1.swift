import Foundation

var lines : [String] = []
while let line = readLine() {
    lines.append(line)
}

let rawMonkeys = lines.split(whereSeparator: { $0 == ""})
print(rawMonkeys.count)

class Monkey : CustomStringConvertible {
    var items : [Int] = []
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

let monkeys = rawMonkeys.map { rawMonkey in
    let lines = Array(rawMonkey)
    let monkey = Monkey()
    monkey.items = lines[1].split(separator: ": ")[1].split(separator: ", ").compactMap { Int($0) }
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

print(monkeys)

for round in 1...20 {
    
    for monkey in monkeys {
        while monkey.items.count > 0 {
            monkey.inspections += 1
            
            var worry = monkey.items.removeFirst()
            //        print("Monkey inspects an item with a worry level of \(worry).")
            switch monkey.operation {
            case "*":
                worry *= monkey.operationValue
                //            print("  Worry level is multiplied by \(monkey.operationValue) to \(worry).")
            case "+":
                worry += monkey.operationValue
                //            print("  Worry level increases by \(monkey.operationValue) to \(worry).")
            case "^":
                worry *= worry
                //            print("  Worry level is multiplied by itself to \(worry).")
            default: print(monkey.operation)
            }
            worry /= 3
            //        print("  Monkey gets bored with item. Worry level is divided by 3 to \(worry).")
            if worry % monkey.divisibleBy == 0 {
                monkeys[monkey.ifTrue].items.append(worry)
                //            print("  Current worry level is divisible by \(monkey.divisibleBy).")
                //            print("  Item with worry level \(worry) is thrown to monkey \(monkey.ifTrue).")
            } else {
                monkeys[monkey.ifFalse].items.append(worry)
                //            print("  Current worry level is not divisible by \(monkey.divisibleBy).")
                //            print("  Item with worry level \(worry) is thrown to monkey \(monkey.ifFalse).")
            }
            
        }
        //    print("----")
        //    print(monkeys)
    }
    print(round,monkeys)
}
print(monkeys)

let activities = monkeys.map {$0.inspections}.sorted(by: >)

print(activities, activities[0]*activities[1])
