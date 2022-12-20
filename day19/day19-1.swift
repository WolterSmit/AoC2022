import Foundation

var linesRead : [String] = []
while let line = readLine() {
   linesRead.append(line)
}

enum Robot : String, CaseIterable {
    case ore
    case clay
    case obsidian
    case geode
}


struct Materials : CustomStringConvertible {
    var ore: Int = 0
    var clay: Int = 0
    var obsidian: Int = 0
    var geode: Int = 0
    
    func add(_ material: Robot) -> Materials {
        switch material {
        case .ore: return Materials(ore: ore+1, clay: clay, obsidian: obsidian, geode: geode)
        case .clay: return Materials(ore: ore, clay: clay+1, obsidian: obsidian, geode: geode)
        case .obsidian: return Materials(ore: ore, clay: clay, obsidian: obsidian+1, geode: geode)
        case .geode: return Materials(ore: ore, clay: clay, obsidian: obsidian, geode: geode+1)
        }
    }
    
    var description : String { "\(ore) ore, \(clay) clay, \(obsidian) obsidian and \(geode) geodes"}
}

struct Blueprint {
    var id: Int
    
    var robot : [Robot:Materials]
    
    init(id: Int, oreRobot: Materials, clayRobot: Materials, obsidianRobot: Materials, geodeRobot: Materials) {
        self.id = id
        self.robot = [ .ore: oreRobot, .clay: clayRobot, .obsidian: obsidianRobot, .geode: geodeRobot]
    }
    
}

let blueprints = linesRead.compactMap { $0.firstMatch(of: #/Blueprint (\d+): Each ore robot costs (\d+) ore. Each clay robot costs (\d+) ore. Each obsidian robot costs (\d+) ore and (\d+) clay. Each geode robot costs (\d+) ore and (\d+) obsidian./#) }
            .map { (
                Blueprint(id: Int($0.1)!, oreRobot: Materials(ore: Int($0.2)!, clay: 0, obsidian: 0),
                          clayRobot: Materials(ore: Int($0.3)!, clay: 0, obsidian: 0),
                          obsidianRobot: Materials(ore: Int($0.4)!, clay: Int($0.5)!, obsidian: 0),
                          geodeRobot: Materials(ore: Int($0.6)!, clay: 0, obsidian: Int($0.7)!))
            ) }


var showProgress = false
print("Read \(blueprints.count) lines")

if showProgress {
    print(blueprints)
}

struct Production {
    
    var material = Materials()
    
    var robots: [Robot:Int] = [.ore:1]
    
    var blueprint: Blueprint
    
    func enoughFor(robot: Robot) -> Bool {
        let materialsNeeded = blueprint.robot[robot]!
        
        if material.ore >= materialsNeeded.ore &&
            material.clay >= materialsNeeded.clay &&
            material.obsidian >= materialsNeeded.obsidian {
            
            if showProgress {
                print("Spend \(materialsNeeded) to start building a \(robot)-collecting robot.")
            }

            return true
        } else {
            return false
        }
        
    }
    
    mutating func buildRobot(_ robot: Robot) {
        let materialsNeeded = blueprint.robot[robot]!
        
        material.ore -= materialsNeeded.ore
        material.clay -= materialsNeeded.clay
        material.obsidian -= materialsNeeded.obsidian
        
        robots[robot] = (robots[robot] ?? 0) + 1
        
        if showProgress {
            print("The new \(robot)-collecting robot is ready; you now have \(robots[robot]!) of them.")
        }
    }
    
    mutating func produce() {
        for (robot,amount) in robots {
            switch robot {
            case .ore: material.ore += amount
            case .clay: material.clay += amount
            case .obsidian: material.obsidian += amount
            case .geode: material.geode += amount
            }
            if showProgress {
                print("\(amount) \(robot)-collecting robot collects \(amount) \(robot)")
            }
        }
        if showProgress {
            print("You now have \(material)")
        }
    }
    
    
    mutating func materialAfterRounds(for robotOrder: [Robot], rounds: Int = 24) -> Materials? {
        
        var robotIterator = robotOrder.makeIterator()
        
        var robot = robotIterator.next()
        for minute in 1...rounds {
            if showProgress {
                print("== Minute \(minute) ==")
            }
            guard let new = robot else {
//                print("Not enough robots")
                return nil
            }
            if enoughFor(robot: new) {
                produce()
                buildRobot(new)
                robot = robotIterator.next()
            } else {
                produce()
            }
            if showProgress {
                print(material)
            }
        }
        
        return material
    }
    
}

// 1: (0,4,2,2) : .clay, .clay, .clay, .obsidian, .clay, .obsidian, .geode, .geode


// 16 - 10 - 97

struct FindGeodes {
    
    let maxDepth = 24
    var rounds = 24
    
    var order : [Robot] = []// [ .clay, .clay, .clay, .obsidian, .clay, .obsidian, .geode, .geode, .geode ]
    var maxSought = 0
    var bestOrder : [Robot] = []
    let blueprint : Blueprint
    
    let maxOre : Int
    let maxClay : Int
    
    
//     1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17
//    1,2,4,7,11,16,22,
//    1,2,3,3,4,4,4,5,5,5,5,6,6,6,6,6,7,7,7,7,7,7
    
    let buildUp : [Int] = [1,2,3,3,4,4,4,5,5,5,5,6,6,6,6,6,7,7,7,7,7,7]
    
    init(with: Blueprint, rounds: Int = 24) {
        self.blueprint = with
        self.rounds = rounds
        self.maxOre = max(max(with.robot[.clay]!.ore,with.robot[.obsidian]!.ore),with.robot[.geode]!.ore)
        self.maxClay = max(with.robot[.obsidian]!.clay,with.robot[.geode]!.clay)
    }
    
    static func most(for blueprint: Blueprint) -> FindGeodes {
        var find = FindGeodes(with: blueprint)
        find.testPath(depth: 1)
        return find
    }
    
    mutating func testPath(depth: Int, material: Materials = Materials()) {
        guard depth < maxDepth else { return }
//        guard material.ore + material.clay < 10 else { return }
//        guard material.clay < 7 else { return }
//        guard material.obsidian < 5 else { return }

        var result : Materials? = nil
        if material.geode > 0 &&
              material.obsidian > 0 &&
              material.clay > 0  {
//        if material.clay > 0  {

            var production = Production(blueprint: blueprint)
            result = production.materialAfterRounds(for: order, rounds: rounds)
//            geodes = production.material.geode
            if let geodes = result?.geode, maxSought < geodes {
                maxSought = geodes
                bestOrder = order
                print(geodes, bestOrder.map { $0.rawValue })
            }
        }
        
//        if depth == 1 {
//            order.append(.clay)
//            testPath(depth: depth+1, material: material.add(.clay))
//            order.removeLast()
//
//        } else {
            if result == nil {
                for robot in Robot.allCases {
                    if robot == .ore && depth > maxOre { continue }
                    if robot == .clay && depth > maxOre+maxClay { continue }
                    if robot == .obsidian && material.clay == 0 { continue }
//                    if robot == .obsidian && depth < buildUp[blueprint.robot[.obsidian]!.clay] { continue }
                    if robot == .geode && material.obsidian == 0 { continue }
                    
                    order.append(robot)
                    testPath(depth: depth+1, material: material.add(robot))
                    order.removeLast()
                }
            }
//        }
    }
}

//showProgress = true
//let order : [Robot] =  [ .clay, .clay, .clay, .obsidian, .clay, .obsidian, .geode, .geode, .geode ]
//var production = Production(blueprint: blueprints[0])
//print(production.stopAtObsidian(for: order, rounds:24))
////print(production.howManyGeodes(for: order, rounds:24)?.geode ?? -1)
//showProgress = false

//Blueprint 1: Each ore robot costs 4 ore. Each clay robot costs 2 ore. Each obsidian robot costs 3 ore and 14 clay. Each geode robot costs 2 ore and 7 obsidian.
//Blueprint 2: Each ore robot costs 2 ore. Each clay robot costs 3 ore. Each obsidian robot costs 3 ore and 8 clay. Each geode robot costs 3 ore and 12 obsidian.
//Blueprint 1: Each ore robot costs 3 ore. Each clay robot costs 3 ore. Each obsidian robot costs 3 ore and 19 clay. Each geode robot costs 3 ore and 17 obsidian.
//Blueprint 18: Each ore robot costs 2 ore. Each clay robot costs 4 ore. Each obsidian robot costs 4 ore and 15 clay. Each geode robot costs 2 ore and 15 obsidian.


let start = Date()
//let blueprint = blueprints[2]
//let result = FindGeodes.most(for: blueprint)
//print(blueprint.robot[.ore]!.ore,"-",blueprint.robot[.clay]!.ore,"=",result.maxSought, ":", result.bestOrder.map { $0.rawValue })

//showProgress = true
//var production = Production(blueprint: blueprint)
//_ = production.materialAfterRounds(for: result.bestOrder, rounds:24)


var results = blueprints.map { blueprint in
    print("----\(blueprint.id)------",blueprint.robot[.ore]!.ore,",",blueprint.robot[.clay]!.ore,
          ",",blueprint.robot[.obsidian]!.clay,",",blueprint.robot[.geode]!.obsidian)

    return FindGeodes.most(for: blueprint)
    
}
    
for result in results {
    print(result.blueprint.robot[.ore]!.ore,",",result.blueprint.robot[.clay]!.ore,
          ",",result.blueprint.robot[.obsidian]!.clay,",",result.blueprint.robot[.geode]!.obsidian,
          "=",result.maxSought, ":", result.bestOrder.map { $0.rawValue })
}
print("Elapsed time: \(-start.timeIntervalSinceNow) seconds")


print(results.reduce(0) { $0 + $1.blueprint.id * $1.maxSought})


