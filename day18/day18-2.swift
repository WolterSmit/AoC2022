import Foundation

var linesRead : [String] = []
while let line = readLine() {
   linesRead.append(line)
}

struct Point {
    var x: Int
    var y: Int
    var z: Int
    
    var left : Point { Point(x: x-1, y: y, z: z) }
    var right : Point { Point(x: x+1, y: y, z: z) }
    var up: Point { Point(x: x, y: y, z: z+1) }
    var down: Point { Point(x: x, y: y, z: z-1) }
    var forward: Point { Point(x: x, y: y+1, z: z) }
    var back: Point { Point(x: x, y: y-1, z: z) }
    
    func neighbours() -> [Point]  { [ left, right, up, down, forward, back] }
}

let cubes = linesRead.compactMap { $0.firstMatch(of: #/(\d+),(\d+),(\d+)/#) }
    .map { Point(x: Int($0.1)!, y: Int($0.2)!, z: Int($0.3)!) }

let minX = cubes.reduce(Int.max) { min($0, $1.x) }
let minY = cubes.reduce(Int.max) { min($0, $1.y) }
let minZ = cubes.reduce(Int.max) { min($0, $1.z) }

let mins = Point(x: minX, y: minY, z: minZ)

let maxX = cubes.reduce(0) { max($0, $1.x) }
let maxY = cubes.reduce(0) { max($0, $1.y) }
let maxZ = cubes.reduce(0) { max($0, $1.z) }

let maxs = Point(x: maxX, y: maxY, z: maxZ)

struct Field {
    
    var field : [[[Int]]]
    var offset : Point
    
    init(with maxs : Point, mins: Point) {
        self.offset = Point(x: 1-mins.x, y: 1-mins.y, z: 1-mins.z)
        self.field = Array(repeating: Array(repeating: Array(repeating: 7, count: maxs.x - mins.x + 3), count: maxs.y - mins.y + 3), count: maxs.z - mins.z + 3)
    }
    
    subscript(_ point: Point) -> Int {
        get {
            return field[point.z+offset.z][point.y+offset.y][point.x+offset.x]
        }
        set(newValue) {
            field[point.z+offset.z][point.y+offset.y][point.x+offset.x] = newValue
        }
    }
    
}
    

var field = Field(with: maxs, mins: mins)

for cube in cubes {
    
    guard field[cube] == 7 else { print("already something there"); exit(-1) }
    
    var value = 6
    
    for neighbour in cube.neighbours() {
        if field[neighbour] < 7  {
            value -= 1
            field[neighbour] = field[neighbour] - 1
        }
    }
    
    field[cube] = value
}

printWithoutBorders()

var openSides = field.field.reduce(0) { $1.reduce($0) { $1.filter({ $0 < 7 }).reduce($0) { $0 + $1 }}}

print(openSides)

fillWithSteam(for: Point(x:1, y:1, z:1), depth: 0)

printWithoutBorders()

var trappedSides = 0
for z in minZ...maxZ {
    for y in minY...maxY {
        for x in minX...maxX {
            let point = Point(x: x, y: y, z: z)
            
            if field[point] == 7 {
                trappedSides += point.neighbours().reduce(0) { $0 + ( field[$1] < 7 ? 1 : 0 ) }
            }
        }
    }
}

print(trappedSides)

print("We have a surface area of \(openSides)")

print("We have an external surface area of \(openSides - trappedSides)")



func printWithoutBorders() {
    
    let printAs : [String] = [ "0","1","2","3","4","5","6",".","~"]
    let short = Array(field.field.dropFirst().dropLast())
        .map { Array($0.dropFirst().dropLast())
                .map { Array($0.dropFirst().dropLast())}
        }
    for plane in short.prefix(3) {
        print()
        for row in plane {
            print(row.reduce("") { $0 + printAs[$1]})
        }
    }
}


func fillWithSteam(for point: Point, depth: Int) {
    
    if depth > 10000 {
        return
    }
    
    if field[point] == 7 {
        
        field[point] = 8
        
        for neighbour in point.neighbours() {
            
            if (minX-1)...(maxX+1)~=neighbour.x && (minY-1)...(maxY+1)~=neighbour.y && (minZ-1)...(maxZ+1)~=neighbour.z {
                fillWithSteam(for: neighbour, depth: depth + 1)
            }
        }
    }
}



