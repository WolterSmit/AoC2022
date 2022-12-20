import Foundation

var linesRead : [String] = []
while let line = readLine() {
  linesRead.append(line)
}

class DoubleLinkedList<Element> : Collection {
    
    typealias Node = DoubleLinkedListNode
    
    var head: Node? = nil
    var count = 0
    
    init() {
        
    }
    
    init(with value: Element) {
        self.head = Node(value)
        self.head?.nextNode = self.head
        self.head?.previousNode = self.head
        
        self.count = 1
    }
    
    
    class DoubleLinkedListNode {
        weak var previousNode: Node? = nil
        var nextNode: Node? = nil
        
        var value: Element
        
        init(_ value: Element) {
            self.value = value
        }
    }
    
    struct DoubleLinkedListIterator : IteratorProtocol {
        var at: Node?
        
        mutating func next() -> Element? {
            guard let node = at else { return nil }
            
            at = node.nextNode
            
            return node.value
        }
    }
    
    var testCount : Int {
        guard var node = head else { return 0 }
        
        var count = 1
        
        while let next = node.nextNode, next !== head {
            node = next
            count += 1
        }
        
        return count
    }
    
    func append(_ value: Element) {
        append(Node(value))
    }
    
    
    func append(_ node: Node) {
        let newNode = node
        if let head = head {
            if let previous = head.previousNode {
                previous.nextNode = newNode
                head.previousNode = newNode
                newNode.nextNode = head
                newNode.previousNode = previous
            }
        } else {
            head = newNode
            head?.nextNode = newNode
            head?.previousNode = newNode
        }
        count += 1
    }
    
    func insert(_ value: Element, at index: Int) {
        insert(Node(value), at: index)
    }
    
    func insert(_ newNode: Node, at index: Int) {
        
        var idx = index
        let blocks = index/count
        idx -= blocks * count

        if head == nil {
            head = newNode
            head?.nextNode = newNode
            head?.previousNode = newNode
        } else {
            let nodeAtIndex = self[idx]
            let previous = nodeAtIndex.previousNode!
            
            previous.nextNode = newNode
            nodeAtIndex.previousNode = newNode
            newNode.nextNode = nodeAtIndex
            newNode.previousNode = previous
        }
        count += 1
    }
    
    func remove(_ node: Node) -> Element {
        let previous = node.previousNode
        let next = node.nextNode
        
        
        previous?.nextNode = next
        next?.previousNode = previous
        
        node.previousNode = nil
        node.nextNode = nil
        
        if node === head {
            head = next
        }
        
        count -= 1

        return node.value
    }
    
    var startIndex: DoubleLinkedListIndex {
        get {
            return DoubleLinkedListIndex(node: head, tag: 0)
        }
    }
    
    var endIndex: DoubleLinkedListIndex {
        get {
            if let head {
                return DoubleLinkedListIndex(node: head, tag: count)
            } else {
                return DoubleLinkedListIndex(node: nil, tag: startIndex.tag)
            }
        }
    }
    
    subscript(position: DoubleLinkedListIndex) -> Element {
        get {
            return position.node!.value
        }
    }
    
    subscript(index: Int) -> DoubleLinkedListNode {
        get {
            assert(head != nil, "List is empty")
            
            if index == 0 {
                return head!
            } else if index > 0 {
                var node = head!.nextNode!
                for _ in 1..<index {
                    node = node.nextNode!
                }
                return node
            } else {
                var node = head!.previousNode!
                for _ in index..<(-1) {
                    node = node.previousNode!
                }
                return node
            }
        }
    }
    
    func index(after idx: DoubleLinkedListIndex) -> DoubleLinkedListIndex {
        return DoubleLinkedListIndex(node: idx.node?.nextNode, tag: idx.tag + 1)
    }
    
    func indexOf(_ node: DoubleLinkedListNode) -> Int? {
        assert(head != nil, "List is empty")
        
        if node === head {
            return 0
        }
        
        var index = 0
        var next = head!.nextNode!
        repeat {
            index += 1
            if next === node {
                return index
            }
            next = next.nextNode!
        } while next !== head
        
        return nil
    }
    
    struct DoubleLinkedListIndex: Comparable {
        let node : Node?
        let tag: Int
        
        static func==(lhs: DoubleLinkedListIndex, rhs: DoubleLinkedListIndex) -> Bool {
            return lhs.tag == rhs.tag
        }
        
        static func<(lhs: DoubleLinkedListIndex, rhs: DoubleLinkedListIndex) -> Bool {
            return lhs.tag < rhs.tag
        }
    }
    
//    func map<U>(transform: (Element) -> U) -> DoubleLinkedList<U> {
//        let result = DoubleLinkedList<U>()
//
//        guard var node = head else { return result }
//
//        while node !== head {
//            result.append(transform(node.value))
//            node = node.nextNode!
//        }
//
//        return result
//    }
}

typealias IntList = DoubleLinkedList<Int>

var list = IntList()

for value in linesRead {
    list.append(value * 811589153)
}

var original : [DoubleLinkedList<Int>.DoubleLinkedListNode] = []

let count = list.count

for n in 0..<list.count {
    original.append(list[n])
}

//print(list.map { $0 })

for n in 1...10 {
    print(n)
    for node in original {
        
        //    print(node)
        
        let index = list.indexOf(node)!
        let value = list.remove(node)
        
        list.insert(node, at: index + value)
        
    }
//    print(list.map { $0 })
}

let nilIndex = list.firstIndex(of: 0)!
let thousandIdx = list.index(nilIndex, offsetBy: 1000)
let twoThousandIdx = list.index(thousandIdx, offsetBy: 1000)
let threeThousandIdx = list.index(twoThousandIdx, offsetBy: 1000)

print(list[thousandIdx],list[twoThousandIdx],list[threeThousandIdx],
      list[thousandIdx]+list[twoThousandIdx]+list[threeThousandIdx])
