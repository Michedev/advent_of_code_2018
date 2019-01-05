import strformat
import strutils
import tables
import sequtils
import sets
import threadpool


proc has_reaction(a,b: char): bool {.inline.} =
    const ascii_lower_upper_distance = 32
    return abs(a.int - b.int) == ascii_lower_upper_distance

proc first_reaction(text: string): int {.inline.} =
    for i in 0..<(text.len()-1):
        if has_reaction(text[i], text[i+1]):
            return i
    return -1            

proc fixed_polymer(material: string): string =
    var has_reactions = true
    result = material
    while has_reactions:
        let i_reaction = first_reaction(result)
        has_reactions = i_reaction != -1
        if has_reactions:
            result = result[0..<i_reaction] & result[(i_reaction+2)..<result.len()]
                

proc solve_first(): int =
    let text = readFile "d5.txt"
    return fixed_polymer(text).len()

proc without_one_polymer(text: string, polymer: string): string =
    text.replace(polymer).replace(polymer.capitalize_ascii())

proc without_one_fixed_polymer(text, polymer: string): string =
    let without_polymer = text.without_one_polymer(polymer)
    let fixed = fixed_polymer(without_polymer)
    return fixed

proc solve_second_parallel(): int =
    let text = readFile "d5.txt"
    var lengths = new_seq[FlowVar[int]](0)
    for chr in 'a'..'z':
        let m = spawn(without_one_fixed_polymer(text, $chr).len())
        lengths.add m
    sync()
    return lengths.map_it(^it).min()

proc solve_second(): int =
    let text = readFile "d5.txt"
    var lengths = new_seq[int](0)
    for chr in 'a'..'z':
        lengths.add without_one_fixed_polymer(text, $chr).len()
    return lengths.min()
    

echo solve_second_parallel()