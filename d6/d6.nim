import strutils
import sequtils
import sequtils2
import tables
import problem_chooser

type
    Point = tuple[x: int, y: int]
    Rectangle = ref object
        x1: int
        x2: int
        y1: int
        y2: int

proc new_rectangle(x1, x2, y1, y2: int): Rectangle =
    result = new(Rectangle)
    result.x1 = x1
    result.x2 = x2
    result.y1 = y1
    result.y2 = y2

proc manhattan_distance(p1, p2: Point): int =
    abs(p1.x - p2.x) + abs(p1.y - p2.y)

proc parse_input(file: File): seq[Point] =
    result = new_seq[Point](0)
    for line in file.lines:
        let splitted = line.split ','
        let p: Point = (splitted[0].parse_int(), splitted[1].strip().parse_int())
        result.add p

proc min_distance_from(points: seq[Point], p: Point): Point = 
    points.min_by(proc(p1: Point): int = p1.manhattan_distance(p))

proc calc_areas(r: Rectangle, points: seq[Point]): CountTable[Point] =
    var 
        mesh = new_seq[Point]((abs(r.x2 - r.x1) + 1) * (abs(r.y2 - r.y1) + 1))
        i = 0
    for x in r.x1..r.x2:
        for y in r.y1..r.y2:
            mesh[i] = (x, y)
            inc i
    let mesh_points = mesh.map_it points.min_distance_from(it)
    return mesh_points.to_count_table()


proc build_rectangle(points: seq[Point]): Rectangle = 
    let x_points = points.map_it(it.x)
    let y_points = points.map_it(it.y)
    let max_x = x_points.max()
    let max_y = y_points.max()
    let min_y = y_points.min()
    let min_x = x_points.min()
    return new_rectangle(min_x, max_x, min_y, max_y)

proc solve_first(): int =
    let file = open "d6.txt"
    let points = parse_input(file)
    let r = points.build_rectangle()
    let areas = calc_areas(r, points)
    return areas.largest().val

proc is_distant_more_than(p: Point, max_dist: int, points: seq[Point]): bool =
    var cumsum_dist = 0
    for point in points:
        cumsum_dist += abs(point.x - p.x) + abs(point.y - p.y)
        if cumsum_dist >= max_dist:
            return true
    return false

proc find_points_size_less_than(points: seq[Point], max_dist: int): int =
    var r = build_rectangle points
    r = new_rectangle(r.x1 - max_dist, r.x2 + max_dist, r.y1 - max_dist, r.y2 + max_dist)
    for i in r.x1..r.x2:
        for j in r.y1..r.y2:
            if not (i,j).is_distant_more_than(max_dist, points):
                inc result


proc solve_second(): int = 
    let file = open "d6.txt"
    let points = parse_input file
    return points.find_points_size_less_than(10000)


solve_problem(solve_first, solve_second)