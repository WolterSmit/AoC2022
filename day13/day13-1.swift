import Foundation

var lines : [String] = []
while let line = readLine() {
    lines.append(line)
}

let pairs = lines.split(separator: "").map { Array($0)}

var total = 0
for (n,pair) in pairs.enumerated() {
    let left = Item.from(pair[0])
    let right = Item.from(pair[1])

    print(left,right,left<=right)

    if left<=right {
        print(n+1)
        total += n + 1
    }
}
print(total)


enum Item : Equatable, Comparable {
    case value(Int)
    case list([Item])

    static func from(_ contents: String) -> Item {
        let (item, _) = item(of: contents)
        return item
    }
    
    static func < (left: Item, right: Item) -> Bool {
        switch (left, right) {
        case let (.value(lv), .value(rv)):
            return lv < rv
        case let (.list(ll), .list(rl)):
            var rightIterator = rl.makeIterator()
            for lv in ll {
                guard let rv = rightIterator.next() else { return false }
                if lv == rv { continue }
                return lv < rv
            }
            return rightIterator.next() != nil 
        case (.value(_), .list(_)):
            return Item.list([left]) < right
        case (.list(_), .value(_)):
            return left < Item.list([right])
        }
    }
}

func item(of contents: String, index: String.Index? = nil) -> (item: Item, idx: String.Index) {
    var idx = index ?? contents.startIndex
    var char : Character = contents[idx]
    var token : String = ""
    
    var items : [Item] = []
    
    repeat {
        idx = contents.index(after: idx)
        char = contents[idx]
        
        if char == "[" {
            var content : Item
            (content, idx) = item(of: contents, index: idx)
            items.append(content)
        }
        else if char == "]" {
            if token.count > 0 {
                items.append(Item.value(Int(token)!))
            }
            return (item: Item.list(items) ,idx: idx)
        } else if char == "," {
            if token.count > 0 {
                items.append(Item.value(Int(token)!))
            }
            token = ""
        } else {
            token.append(char)
        }
    } while true
    
}

