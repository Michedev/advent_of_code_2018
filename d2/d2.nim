import tables
import problem_chooser
import strutils
import sequtils

proc solve_first() : int= 
    let input_data = open "d2.txt"
    var
        twice = 0
        trice = 0
        contains_twice = false
        contains_trice = false
    for line in input_data.lines:
        var counter = line.toCountTable()
        for v in counter.values:
            if contains_trice and contains_twice:
                break
            if v == 2: contains_twice = true
            elif v == 3: contains_trice = true
        if contains_twice: inc twice
        if contains_trice: inc trice
        contains_twice = false
        contains_trice = false
    return twice * trice

proc calc_distance(a, b: string): int =
    # assert a.len() == b.len()
    for i in 0..<a.len():
        if a[i] != b[i]:
            inc result

proc toString(str: seq[char]): string =
    result = newStringOfCap(len(str))
    for ch in str:
        add(result, ch)
              

proc find_same_chars(a,b: string, distance: int): string =
    var dest_array = newSeq[char](a.len() - distance)
    var j = 0
    for i in 0..<a.len():
        if a[i] == b[i]:
            dest_array[j] = a[i]
            inc j
    return dest_array.to_string()

proc solve_second(): string = 
    let input_data = readFile("d2.txt").split('\n')
    var 
        min_distance: int = -1
        string1: string
        string2: string
    for i in 0..<input_data.len():
        for j in (i+1)..<input_data.len():
            let curr_distance = calc_distance(input_data[i], input_data[j])
            if min_distance == -1 or min_distance > curr_distance:
                min_distance = curr_distance
                string1 = input_data[i]
                string2 = input_data[j]
    return find_same_chars(string1, string2, min_distance)


solve_problem(solve_first, solve_second)