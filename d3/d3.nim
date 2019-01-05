import strutils
import strformat
import sets
import arraymancer
import problem_chooser

type
    Point = tuple[x,y: int]
    Rectangle = ref object
        size: Point
        top: int
        left: int
        right: int
        bottom: int
        id: int

proc new_rectangle(start_point, size: Point, id: int = -1): Rectangle =
    result = new(Rectangle)
    result.size = size
    result.top = start_point.y
    result.bottom = start_point.y + size.y
    result.left = start_point.x
    result.right = start_point.x + size.x
    result.id = id

proc `$`(r: Rectangle): string =
    return fmt"top: {r.top} - bottom: {r.bottom} - left: {r.left} - right: {r.right}"

proc extract_rects(file: File): seq[Rectangle] =
    let nlines: Natural = 1305
    result = newSeq[Rectangle](nlines)
    var i = 0
    for line in file.lines:
        let start_position = line.substr(line.find('@')+1, line.find(':')-1).strip(leading=true, trailing=true)
        let position_seq = start_position.split(',')
        let start_x = position_seq[0].parse_int()
        let start_y = position_seq[1].parse_int()
        let size_rectangle_str = line.substr(line.find(':')+1).strip(leading=true, trailing=true)
        let size_rectangle_seq = size_rectangle_str.split('x')
        let size_x = size_rectangle_seq[0].parse_int()
        let size_y = size_rectangle_seq[1].parse_int()
        result[i] = new_rectangle((start_x, start_y), (size_x, size_y), i+1)
        inc i

proc get_overlap(a,b: Rectangle): int =
    let mya = min(a.right, b.right) - max(a.left, b.left)
    let overlap_x = max(0, mya)
    let overlap_y = max(0, min(a.bottom, b.bottom) - max(a.top, b.top))
    return overlap_x * overlap_y

proc solve_first(): int = 
    let file = open "./d3.txt"
    let rectangles = extract_rects file
    file.close()
    var space = zeros[uint8](1000, 1000)
    for r in rectangles:
        space[r.left ..< r.right, r.top ..< r.bottom] = space[r.left ..< r.right, r.top ..< r.bottom] + ones[uint8](r.left-r.right, r.top - r.bottom)
    let overlap = space.map(proc(i: uint8): int = (if i > 1.uint8: 1 else: 0)).sum()
    return overlap

proc solve_second(): int =
    let file = open "./d3.txt"
    let rectangles = extract_rects file
    file.close()
    var overlapping_indexes: HashSet[uint16]
    init(overlapping_indexes, 512)
    for i in 0..<rectangles.len():
        for j in (i+1)..<rectangles.len():
            if i.uint16 in overlapping_indexes and j.uint16 in overlapping_indexes:
                continue
            if get_overlap(rectangles[i], rectangles[j]) > 0:
                overlapping_indexes.incl(i.uint16)
                overlapping_indexes.incl(j.uint16)
    for i in 0..<rectangles.len():
        if not(i.uint16 in overlapping_indexes):
            return i+1
    return -1


    
solve_problem(solve_first, solve_second)