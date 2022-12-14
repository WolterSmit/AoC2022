import Foundation

var lines : [String] = []
while let line = readLine() {
    lines.append(line)
}

var pairs = lines.filter { $0 != ""}.map { Item.from(String($0)) }

pairs.append(Item.list([Item.value(2)]))
pairs.append(Item.list([Item.value(6)]))

var first = 0
var second = 0
for (n, pair) in pairs.sorted().enumerated() {
    if pair == Item.list([Item.value(6)]) {
        print("\(n + 1) Found: ",pair)
        first = n+1
    }
    if pair == Item.list([Item.value(2)]) {
        print("\(n) Found: ",pair)
        second = n+1
    }
}
print(first*second)


enum Item : Equatable {
    case value(Int)
    case list([Item])

    static func from(_ contents: String) -> Item {
        let (item, _) = item(of: contents)
        return item
    }
    
    static func <= (left: Item, right: Item) -> Bool {
        switch (left, right) {
        case let (.value(lv), .value(rv)):
            return lv <= rv
        case let (.list(ll), .list(rl)):
            var rightIterator = rl.makeIterator()
            for lv in ll {
                guard let rv = rightIterator.next() else { return false }
                // print(lv,rv,lv<=rv,rv<=lv)
                guard lv <= rv else { return false }
                guard rv <= lv else { break }
            }
            return true
        case (.value(_), .list(_)):
            return Item.list([left]) <= right
        case (.list(_), .value(_)):
            return left <= Item.list([right])
        }
    }
}

func item(of contents: String, index: String.Index? = nil) -> (item: Item, idx: String.Index) {
    var idx = index ?? contents.startIndex
    var char : Character = contents[idx]
    var token : String = ""
    
    var items : [Item] = []
//    print("In")
    
    repeat {
        idx = contents.index(after: idx)
        char = contents[idx]
        
        if char == "[" {
            var result : Item
            (result, idx) = item(of: contents, index: idx)
            items.append(result)
        }
        else if char == "]" {
            if token.count > 0 {
//                print("Token: \(token)")
                items.append(Item.value(Int(token)!))
            }
//            print("Out")
            return (item: Item.list(items) ,idx: idx)
        } else if char == "," {
            if token.count > 0 {
//                print("Token: \(token)")
                items.append(Item.value(Int(token)!))
            }
            token = ""
        } else {
            token.append(char)
        }
    } while true
    
}


// var total = 0
// for (n,pair) in pairs.enumerated() {
//     let (left,_) = list(of: pair[0])
//     let (right, _) = list(of: pair[1])


//     if left<=right {
//         print(n+1)
//         total += n + 1
//     }
// }
// print(total)