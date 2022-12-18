import Foundation

var linesRead : [String] = []
while let line = readLine() {
   linesRead.append(line)
}

class Valve {
    var rate: Int
    var leadsTo: [String]
    var open: Bool = false

    init(rate: Int, leadsTo: [String]) {
        self.rate = rate
        self.leadsTo = leadsTo
    }
}

let valveDescription = linesRead.compactMap { $0.firstMatch(of: #/Valve (..) has flow rate=(\d+); tunnels? leads? to valves? (.+)/#) }
                                .map { (key: String($0.1), rate: Int($0.2)!, leadsTo: $0.3.matches(of: #/(..)(, )?/#).map { String($0.1) }) }

var valves : [String:Valve] = [:]
for valve in valveDescription {
    valves[valve.key] = Valve(rate: valve.rate, leadsTo: valve.leadsTo)
}
for valve in valves {
    valve.value.leadsTo = valve.value.leadsTo.sorted(by: { valves[$0]!.rate > valves[$1]!.rate })
}
print(valves.filter({ !$0.value.open && $0.value.rate > 0 }).count)


enum StepType : String { case move = "M", open = "O", none = " " }
enum TargetType : String { case man = "m", elephant = "e" }

struct Step : CustomStringConvertible {
    var valve: String
    var type: StepType = .none
    var target: TargetType = .man

    var description: String {
        switch (target, type) {
        case (.man,.open): return "You open valve \(valve)"
        case (.man,.move): return "You move to valve \(valve)"
        case (.man,.none): return "You do nothing"
        case (.elephant,.open): return "The elephant opens valve \(valve)"
        case (.elephant,.move): return "The elephant moves to valve \(valve)"
        case (.elephant,.none): return "The elephant does nothing"
        }
    }
        
    var shortDescription: String { "\(type.rawValue)\(target.rawValue)\(valve)" }
}


var path : [Step] = [Step(valve: "AA", type: .none, target: .man)]
var pressures : [Int] = [ 0, 0 ]
let depth = 50
let minutes = depth/2

var bestPath : [Step] = []
var maxPressure = 0

var limit = 0
let stopLimit = 100



print("----------------------------------------")
nextStep(in: 0, target: .elephant, step: .none, man: "AA", elephant: "AA", pressure: 0, totalPressure: 0)

print(bestPath.dropFirst().reduce("") { $0 + $1.shortDescription + " "})
print(maxPressure)


func nextStep(in minute: Int, target: TargetType, step: StepType, man: String, elephant: String, pressure previousPressure: Int, totalPressure previousTotalPressure: Int) {
    
//    limit += 1
//    if limit > stopLimit {
//        return
//    }
    
    if step == .move {
        let valve = (target == .man ? man : elephant)
        let lastSteps = path.reversed().filter { $0.target == target}.prefix(while: { $0.type != .open }).map { $0.valve }
//        print(lastSteps.count,":", lastSteps.reduce("") { $0 + $1 + " "},"-\(target)", valve)
        
        if lastSteps.contains(valve) {
            return
//            print("Stopping here")
        }
    }
    
    var pressure : Int
    var totalPressure : Int = previousTotalPressure
    if target == .man {
        pressure = pressures.last!
        totalPressure += pressure
    } else {
        pressure = pressures.dropLast(1).last!
    }
    
    let rateForClosedValves = valves.filter { !$0.value.open && $0.value.rate > 0 }.map { $0.value.rate }.sorted(by: >)
    
    if minute > 6 && totalPressure == 0 {
        return
    }
    
    if minute > depth / 2 && rateForClosedValves.count > 9 { return }
    if minute > 40 && rateForClosedValves.count > 6 { return }
    
    var theoreticalPossible = 0
    for (n,rate) in rateForClosedValves.enumerated() {
        let remainingTime = minutes - (minute+2*n)/2 + (target == .elephant ? n & 1 : 0)
        if remainingTime > 0 {
            theoreticalPossible += remainingTime * rate
//            print(remainingTime, rate, theoreticalPossible)
        }
    }
    
    let remainingTime = minutes-(minute+1)/2+1
    
    if theoreticalPossible + remainingTime * previousPressure + totalPressure < maxPressure {
//        print("Breaking off")
        return
    }

    
    path.append(Step(valve: target == .man ? man : elephant, type: step, target: target))
    pressures.append(previousPressure)
    
//        print(
//                      ("  "+String(rateForClosedValves.count)).suffix(2),
//            //          ("  "+String(minutes-(minute+1)/2+1)).suffix(2),
//            ("    "+String(theoreticalPossible)).suffix(4),
//            ("    "+String(previousPressure*(minutes-(minute+1)/2+1))).suffix(4),
//            ("    "+String(totalPressure)).suffix(4),
//            ("    "+String(pressure)).suffix(4),
//            ("    "+String(previousPressure)).suffix(4),
//            path.dropFirst().reduce("") { $0 + $1.shortDescription + " "})
//    }

    if minute < depth {
        
        if valves.filter( { !$0.value.open && $0.value.rate > 0}).count == 0 {
            nextStep(in: minute+1, target: (target == .man ? .elephant : .man), step: .none, man: man, elephant: elephant, pressure: previousPressure, totalPressure: totalPressure)
        } else
        if target == .elephant {
            
            guard let valve = valves[man] else { print("Unknown valve"); return }
            
            // Next step for man
                        
            if !valve.open && valve.rate > 0 {
                valve.open = true
                nextStep(in: minute+1, target: .man, step: .open, man: man, elephant: elephant, pressure: previousPressure + valve.rate, totalPressure: totalPressure)
                valve.open = false
            }
            
            for nextValve in valve.leadsTo {
                nextStep(in: minute+1, target: .man, step: .move, man: nextValve, elephant: elephant, pressure: previousPressure, totalPressure: totalPressure)
            }
        } else {
            guard let valve = valves[elephant] else { print("Unknown valve"); return }

            // Next step for elephant
                        
            if !valve.open && valve.rate > 0 {
                valve.open = true
                nextStep(in: minute+1, target: .elephant, step: .open, man: man, elephant: elephant, pressure: previousPressure + valve.rate, totalPressure: totalPressure)
                valve.open = false
            }
            
            for nextValve in valve.leadsTo {
                nextStep(in: minute+1, target: .elephant, step: .move, man: man, elephant: nextValve, pressure: previousPressure, totalPressure: totalPressure)
            }

        }
        
        
    } else {
        
        totalPressure += previousPressure
        
        limit += 1
//        if limit & 8191 == 0 {
            print(
                "  ",
                "    ",
                "    ",
                ("    "+String(totalPressure)).suffix(4),
                "    ",
                ("    "+String(previousPressure)).suffix(4),
                path.dropFirst().reduce("") { $0 + $1.shortDescription + " "},
                Step(valve: man, type: .none, target: .man).shortDescription,
                Step(valve: elephant, type: .none, target: .elephant).shortDescription
            )
//        }

        if totalPressure > maxPressure {
            
            bestPath = path
            bestPath.append(Step(valve: man, type: .none, target: .man))
            bestPath.append(Step(valve: elephant, type: .none, target: .elephant))
            
            maxPressure = totalPressure
            print(
//                    "--",
                ("----" + String(valves.filter ({!$0.value.open  && $0.value.rate > 0}).count).suffix(4)),
                  ("----"),
                  ("    "+String(totalPressure)).suffix(4),
                   "    ",
                   "    ",
                  bestPath.dropFirst().reduce("") { $0 + $1.shortDescription + " "})
        }
    }
    
    path.removeLast()
    pressures.removeLast()

}

