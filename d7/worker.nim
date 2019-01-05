type Worker* = ref object
    curr_task: char
    end_task: int

proc new_worker*(): Worker =
    result = new(Worker)
    result.curr_task = ' '
    result.end_task = -1

proc has_task*(w: Worker): bool =
    w.curr_task != ' '

proc is_finished*(w: Worker, t: int): bool =
    w.end_task == t

proc remove_task*(w: Worker) = 
    w.curr_task = ' '
    w.end_task = -1

proc assign_task*(w: Worker, c: char, end_time: int) = 
    w.curr_task = c
    w.end_task = end_time

proc get_task*(w: Worker): char =
    w.curr_task