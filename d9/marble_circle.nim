import math
import lists

type
    MarbleCircle* = ref object
        series: DoublyLinkedRing[int]
        current_value: DoublyLinkedNode[int]
        size: int

proc new_marble_circle*(): MarbleCircle =
    result = new(MarbleCircle)
    result.series = initDoublyLinkedRing[int]()
    result.size = 0

proc `$`*(m: MarbleCircle): string = $m.series

proc get_value(m: MarbleCircle, offset: int): DoublyLinkedNode[int] =
    result = m.current_value
    if offset > 0:
        for i in 0..<offset:
            result = result.next
    else:
        for i in 0..<(-offset):
            result = result.prev

proc insert*(m: MarbleCircle, offset, n: int): DoublyLinkedNode[int] {.inline.} =
    let prev = m.get_value(offset)
    let next = prev.next
    let new_node = new_doubly_linked_node(n)
    prev.next = new_node
    next.prev = new_node
    new_node.prev = prev
    new_node.next = next
    return new_node

proc delete*(m: MarbleCircle, offset: int): int {.inline.} =
    let to_delete = m.get_value(offset)
    let prev = to_delete.prev
    let next = to_delete.next
    prev.next = next
    next.prev = prev
    return to_delete.value

proc add_marble*(m: MarbleCircle): int = 
    result = -1
    if m.size == 0:
        m.series.append 0
        m.current_value = m.series.head
    elif m.size == 1:
        m.series.append 1
        m.current_value = m.series.head.next
    elif (m.size mod 23) == 0:
        let removed = m.delete(-7)
        m.current_value = m.get_value(-6)
        result = m.size + removed
    else:
        let inserted = m.insert(1, m.size)
        m.current_value = inserted
    inc m.size
    # echo "turn ", m.size-1 
    # echo m
    # echo "Current is node with value ", m.current_value.value

