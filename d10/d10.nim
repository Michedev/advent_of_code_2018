import strutils
import sequtils
import os
import problem_chooser

type
    Point = tuple[x: int, y: int]
    Star = ref object
        position: Point
        velocity: Point

proc `+`(p1, p2: Point): Point {.inline.} =
    return (p1.x + p2.x, p1.y + p2.y)

proc `+=`(p1: var Point, p2: Point) {.inline.} =
    p1 = p1 + p2

proc abs_dist(p1, p2: Point): int {.inline.} =
    abs(p1.x - p2.x) + abs(p1.y - p2.y)

proc `$`(stars: seq[Star]): string =
    let 
        x_s = stars.map_it(it.position.y)
        y_s = stars.map_it(it.position.x)
    var 
        min_x = x_s.min() - 10
        max_x = x_s.max() + 10
        min_y = y_s.min() - 10
        max_y = y_s.max() + 10
    echo "min_x: ", min_x, " max_x: ", max_x, " min_y: ", min_y, " max_y: ", max_y
    var output = new_seq[seq[char]](max_x - min_x)
    for i in 0..<(max_x - min_x):
        output[i] = new_seq[char](max_y - min_y)
        for j in 0..<output[i].len():
            output[i][j] = '.'
    for i in 0..<stars.len():
        let x = x_s[i] - min_x
        let y = y_s[i] - min_y
        output[x][y] = '#'
    return ($output).replace("[", "").replace("]", "").replace("'", "").replace(",", "").replace(" ", "").replace("@", "\n")
    



proc new_star(position, velocity: Point): Star {.inline.} =
    result = new(Star)
    result.position = position
    result.velocity = velocity

proc move(s: Star) {.inline.} =
    s.position += s.velocity

proc move(stars: seq[Star]) {.inline.} =
    for s in stars:
        s.move()

proc parse_point(s: string): Point =
    let point = s.substr(s.find('<')+1, s.find('>')-1)
    let splitted = point.split(',')
    let x_str = splitted[0]
    let y_str = splitted[1]
    result = (-1,-1)
    result.x = x_str.strip(leading=true, trailing=true).parse_int()
    result.y = y_str.strip(leading=true, trailing=true).parse_int()

proc parse_line(line: string): Star =
    let splitted = line.split(" v")
    let pos_str = splitted[0]
    let vel_str = splitted[1]
    return new_star(pos_str.parse_point(), vel_str.parse_point())

proc parse_input(input: File): seq[Star] =
    result = new_seq[Star](0)
    for l in input.lines:
        result.add l.parse_line()

proc exists_adiacent(stars: seq[Star], i: int): bool =
    for j in 0..<stars.len():
        if j != i and (stars[i].position.abs_dist(stars[j].position)) <= 2:
            return true
    return false

proc is_message(stars: seq[Star]): bool {.inline.} =
    for i in 0..<stars.len():
        if not exists_adiacent(stars, i):
            return false
    return true

proc solve_first(): string =
    let file = open param_str(2)
    let stars = parse_input file
    while not is_message(stars):
        stars.move()
    return $stars

proc solve_second(): int =
    let file = open param_str(2)
    let stars = parse_input file
    var t = 0
    while not is_message(stars):
        stars.move()
        inc t
    return t

solve_problem(solve_first, solve_second)