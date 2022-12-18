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

let size = Point(x: maxX, y: maxY, z: maxZ)

struct Field {
    
    var field : [[[Int]]]
    var offset : Point
    
    init(with maxs : Point, mins: Point) {
        self.offset = Point(x: 1-mins.x, y: 1-mins.y, z: 1-mins.z)
        self.field = Array(repeating: Array(repeating: Array(repeating: 0, count: maxs.x - mins.x + 3), count: maxs.y - mins.y + 3), count: maxs.z - mins.z + 3)
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
    

var field = Field(with: size, mins: mins)

for cube in cubes {
    
    guard field[cube] == 0 else { print("already something there"); exit(-1) }
    
    var value = 6
    
    for neighbour in cube.neighbours() {
        if field[neighbour] > 0 {
            value -= 1
            field[neighbour] = field[neighbour] - 1
        }
    }
    
    field[cube] = value
    
//    print(cube)
//    print(field)

}

print(field)

let openSides = field.field.reduce(0) { $1.reduce($0) { $1.reduce($0) { $0 + $1 }}}

print(openSides)
