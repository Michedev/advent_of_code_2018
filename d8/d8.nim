import strutils
import sequtils
import math
import problem_chooser

type Node = ref object
    sons: seq[Node]
    metadatas: seq[int]
    size: int
    value: int

proc new_node(nsons, n_metadatas: int): Node = 
    result = new(Node)
    result.sons = new_seq[Node](nsons)
    result.metadatas = new_seq[int](n_metadatas)
    result.size = 0
    result.value = -1

proc first_index[T](s: openArray[T], cond: proc(el: T): bool): int =
    var i = 0
    for el in s:
        if cond(el):
            return i
        inc i
    return -1

proc first_index_nil[T](s: openArray[T]): int =
    first_index(s, proc(el: T): bool = el.is_nil() )

proc add_son(n: Node, son: Node) =
    let i = n.sons.first_index_nil()
    assert i != -1, "Has already all sons"
    n.sons[i] = son

proc array_size(n: Node): int =
    2 + n.metadatas.len() + (if n.sons.len() > 0: n.sons.map_it(it.array_size()).sum() else: 0)
    
proc parse_node(input: seq[int], father: Node = nil): Node =
    let nsons = input[0]
    let n_metadatas = input[1]
    result = new_node(nsons, n_metadatas)
    result.size += 2
    if not father.is_nil():
        father.add_son result
    if nsons > 0:
        var sons_input = input[2..<input.len()]
        for i in 0..<nsons:
            let son = parse_node(sons_input, result)
            result.size += son.size
            sons_input = sons_input[son.size..<sons_input.len()]
    for i in 0..<n_metadatas:
        result.metadatas[i] = input[result.size + i]
    result.size += n_metadatas  

proc sum_metadatas(tree: Node): int =
    tree.metadatas.sum() + (if tree.sons.len() > 0: tree.sons.map_it(it.sum_metadatas()).sum() else: 0)

proc solve_first(): int =
    let text = readFile "d8.txt"
    let input = text.split(' ').map_it(it.parse_int())
    let tree = parse_node(input)
    return tree.sum_metadatas()
    
proc eval_node(n: Node): int =
    if n.value == -1:
        if n.sons.len() == 0:
            n.value = n.metadatas.sum()
        else:
            var total = 0
            for m in n.metadatas:
                let i = m - 1
                if i < n.sons.len():
                    total += n.sons[i].eval_node()
            n.value = total
    return n.value

proc solve_second(): int =
    let text = readFile "d8.txt"
    let input = text.split(' ').map_it(it.parse_int())
    let tree = parse_node(input)
    echo tree.metadatas
    return eval_node(tree)


solve_problem(solve_first, solve_second)