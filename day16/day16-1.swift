import Foundation

var linesRead : [String] = []
while let line = readLine() {
    linesRead.append(line)
}

// typealias Valve = (rate: Int, leadsTo: [String])

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

let position = "AA"

var minute = 1

enum Path : CustomStringConvertible {
    case open(String)
    case move(String)
    case none

    var description: String {
        switch self {
            case .open(let valve): return "You open valve \(valve)."
            case .move(let valve): return "You move to valve \(valve)."
            case .none: return "Starting"
        }
    }

    var shortDescription: String {
        switch self {
            case .open(let valve): return "O(\(valve))"
            case .move(let valve): return "M(\(valve))"
            case .none: return ""
        }
    }

    var valve: String {
        switch self {
            case .open(let valve): return valve
            case .move(let valve): return valve
            case .none: return ""
        }
    }
}

var path : [(pressure: Int, step: Path)] = []
let depth = 30

var bestPath : [Path] = []
var maxPressure = 0


func nextStep(in minute: Int, to position: String, path addToPath: Path, with totalPressure: Int = 0)  {

    if minute > 0 {
        // print("== Minute \(minute) ==")

        let lastSteps = path.reversed().prefix(while: { 
                if case .move(_) = $0.step {
                    return true 
                } else {
                    return false
                }
        }).map { $0.step.valve }    
        // print(lastSteps.count,":", lastSteps.reduce("") { $0 + $1 + " "},"-",addToPath.valve)

        if case .move(let valve) = addToPath,
           lastSteps.contains(valve) {
            // print("Breaking of, running in circles")
            return
        }
    }

    var pressure = 0
    if minute > 0 {
        let openValves = valves.filter { $0.value.open }
        if openValves.count == 0 {
            // print("No valves are open.")
        } else {
            pressure = openValves.reduce(0) { $0 + $1.value.rate }

            // print("Valves \(openValves.reduce("") { $0 + $1.key + ", " }.dropLast(2)) are open, releasing \(pressure) pressure.")
        }
        path.append((pressure: pressure, step: addToPath))
        // print("\(addToPath)")
        // print("\(minute):",path.dropFirst().reduce("") { $0 + $1.step.shortDescription + ":" + String($1.pressure) + " "},"for \(totalPressure + pressure)")
    } else {
        path.append((pressure: 0, step: addToPath))
    }
    let newTotalPressure = totalPressure + pressure

    if minute >= depth {
        // print("\(minute):",path.dropFirst().reduce("") { $0 + $1.step.shortDescription + ":" + String($1.pressure) + " "} )

        if newTotalPressure > maxPressure {
            maxPressure = newTotalPressure
            bestPath = path.map { $0.step }
            print("Found better path for pressure \(newTotalPressure):",path.dropFirst().reduce("") { $0 + $1.step.shortDescription + ":" + String($1.pressure) + " "})
        }
    } else {
        guard let valve = valves[position] else { print("Unknown valve"); return}

        if valve.open == false {
            if case .open(_) = addToPath {
                valve.open = true
            } else {
                if valve.rate > 0 {
                    nextStep(in: minute+1, to: position, path: .open(position), with: newTotalPressure)
                }
                valve.open = false
            }
        }


        for tryValve in valve.leadsTo {
            nextStep(in: minute+1, to: tryValve, path: .move(tryValve), with: newTotalPressure)
        }
    }

    path.removeLast()
}

nextStep(in: 0, to: "AA", path: .move("AA"))

// print("Best path for pressure \(maxPressure):",bestPath.dropFirst().reduce("") { $0 + $1.shortDescription + " "})

