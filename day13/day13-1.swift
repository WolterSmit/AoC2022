import Foundation

var lines : [String] = []
while let line = readLine() {
    lines.append(line)
}

let pairs = lines.split(separator: "").map { Array($0)}
// print(pairs)



enum Item {
    case value(Int)
    case list([Item])
    
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

func list(of contents: String, index: String.Index? = nil) -> (item: Item, idx: String.Index) {
    var idx = index ?? contents.startIndex
    var char : Character = contents[idx]
    var token : String = ""
    
    var items : [Item] = []
//    print("In")
    
    repeat {
        idx = contents.index(after: idx)
        char = contents[idx]
        
        if char == "[" {
            var item : Item
            (item, idx) = list(of: contents, index: idx)
            items.append(item)
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

var total = 0
for (n,pair) in pairs.enumerated() {
    let (left,_) = list(of: pair[0])
    let (right, _) = list(of: pair[1])


    if left<=right {
        print(n+1)
        total += n + 1
    }
}
print(total)