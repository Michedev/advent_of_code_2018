import sets
import sequtils
import simple_graph
import worker
import problem_chooser

  
proc parse_constraints(file: File): DirectedGraph[char] =
    result = DirectedGraph[char]()
    result.init_graph()
    for line in file.lines:
        let (by, to) = (line[5], line[36])
        if not(result.has_node(by)):
            result.add_node by
        if not(result.has_node(to)):
            result.add_node to
        result.add_edge(by, to)

proc has_enter_edge[T](g: DirectedGraph[T], n: T): bool =
    for e in g.edges:
        if e.dst == n:
            return true
    return false

proc find_available_chars(constraints: DirectedGraph[char]): seq[char] = 
    constraints.nodes.filter_it(not has_enter_edge(constraints, it))


proc find_order(constraints: DirectedGraph[char]): string = 
    result = ""
    while constraints.nodes.len() > 0:
        let next_char = find_available_chars(constraints).min()
        result &= next_char
        constraints.del_node next_char


proc solve_first(): string = 
    let file = open "d7.txt"
    let constraints = parse_constraints file
    return find_order(constraints)

proc assign_tasks_if_available(workers: seq[Worker], constraints: DirectedGraph[char], t, base_time: int) =
    for w in workers:
        if not w.has_task():
            var available = find_available_chars(constraints)
            let other = workers.map_it(it.get_task())
            available = available.filter_it(not(it in other))
            if available.len() > 0:
                let next_char = available.min()
                echo next_char, " at time ", t
                w.assign_task(next_char, t + next_char.int - 'A'.int + 1 + base_time)       



proc simulate(workers: seq[Worker], constraints: DirectedGraph[char], base_time: int): int = 
    var t = -1
    var output = ""
    while constraints.nodes.len() > 0 or workers.any_it(it.has_task()):
        for w in workers:
            if w.is_finished(t):
                if w.has_task():
                    output &= w.get_task()
                    constraints.del_node w.get_task()
                    w.remove_task()
                workers.assign_tasks_if_available(constraints, t, base_time)
        inc t
    return t

proc solve_second(base_time, num_workers: int): int =
    let file = open "d7.txt"
    let constraints = parse_constraints file
    var workers = new_seq[Worker](num_workers)
    for i in 0..<num_workers: workers[i] = new_worker()
    return simulate(workers, constraints, base_time)


solve_problem(solve_first, proc():int = solve_second(60, 5))