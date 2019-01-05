import strutils
import problem_chooser
import sets

proc solve_first(): int =
    var file = open("d1_1.txt")
    result = 0
    for line in file.lines:
        result += line.parseInt()


proc solve_second(): int =
    var old_freq: HashSet[int]
    old_freq.init(512)
    result = 0
    var once = false
    while true:
        var file = open "d1_1.txt"
        for line in file.lines:
            result += line.parseInt()
            if once and result in old_freq:
                file.close()
                return result
            else:
                old_freq.incl result
        once = true
        file.close()

solve_problem(solve_first, solve_second)