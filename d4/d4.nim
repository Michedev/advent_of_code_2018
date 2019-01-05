import math
import sequtils
import strutils
import strformat
import sequtils2
import arraymancer
import tables

type
    EventType = enum
        WakeUp
        FallAsleep
        StartGuard
    Event = ref object
        hour: range[0..24]
        minute: range[0..60]
        day: range[0..31]
        month: range[0..12]
        year: int
        daymin: int
        date: int
        time: int
        datetime: int
        id: int
        etype: EventType

proc `$`(e: Event): string =
    fmt"([{e.year}-{e.month}-{e.day} {e.hour}:{e.minute}]  Etype: {e.etype} Id: {e.id})"

proc pow(a,b: int): int {.inline.} =
    result = a
    for i in 0..<(b-1):
        result *= a

proc new_event(hour, minute, day, month, year: int, etype: EventType, id: int = -1): Event =
    result = new(Event)
    result.hour = hour
    result.minute = minute
    result.day = day
    result.month = month
    result.year = year
    result.time = minute + hour * 100
    result.daymin = minute + hour * 60
    result.date = day  + month * 100  + year * 100.pow(2)
    result.datetime = minute + hour * 100 + day * 100.pow(2) + month * 100.pow(3)  + year * 100.pow(4) #yyyyMMddhhmm
    result.etype = etype
    result.id = id

proc adjust_events(events: seq[Event]) : seq[Event] = 
    result = events.sort_by(proc(el: Event): int = el.datetime)
    var 
        i = 0
        id_event = events[0].id
    for e in result[1..<result.len()]:
        if e.id == -1:
            e.id = id_event
        else:
            id_event = e.id
        inc i
    return result


proc parse_events(file: File): seq[Event] =
    result = new_seq[Event](0)
    const
        year_slice = 1..4
        month_slice = 6..7
        day_slice = 9..10
        hour_slice = 12..13
        minute_slice = 15..16
    for line in file.lines:
        let
            year = line[year_slice].parse_int()
            month = line[month_slice].parse_int()
            day = line[day_slice].parse_int()
            hour = line[hour_slice].parse_int()
            minute = line[minute_slice].parse_int()
        if line.ends_with "falls asleep" :
            result.add(new_event(hour, minute, day, month, year, FallAsleep))
        elif line.ends_with "wakes up" :
            result.add(new_event(hour, minute, day, month, year, WakeUp))
        elif line.ends_with "begins shift" :
            let id_guard = line.substr(26).split(' ', maxsplit=1)[0].parse_int()
            result.add(new_event(hour, minute, day, month, year, StartGuard, id_guard))
    result = adjust_events(result)


proc calc_wakeup_time(events: seq[Event]): TableRef[int, int] =
    result = newTable[int, int]()
    var 
        start_time = 0
        i = 0
    for e in events:
        let _ = result.has_key_or_put(e.id, 0)
        if e.etype == FallAsleep:
            start_time = e.minute
        elif e.etype == WakeUp:
            result[e.id] += e.minute - start_time
        elif e.etype == StartGuard and i > 0 and events[i-1].etype == FallAsleep:
                result[events[i-1].id] += 60 - start_time
        inc i

proc key_with_max_value(table: TableRef[int, int]): int =
    result = -1
    var max_val = 0
    for kv in table.mpairs():
        if kv[1] > max_val:
            max_val = kv[1]
            result = kv[0]

proc find_best_minute_with_value(events: seq[Event], id: int, get_value: bool = false) : tuple[min: int, value: int] =
    var 
        acc_array = zeros[int]([60])
        last_time = zeros[int]([60])
        start_time = 0
    let events_id = events.filter_it(it.id == id)
    for e in events_id:
        if e.etype == StartGuard:
            acc_array += last_time
            last_time = zeros[int]([60])
            start_time = 0
        elif e.etype == FallAsleep:
            start_time = e.minute
        elif e.etype == WakeUp:
            last_time[start_time..<e.minute] = 1
    acc_array += last_time
    let best_minute =  acc_array.argmax_max(0)
    return (best_minute[0].data[0], best_minute[1].data[0])
            

proc find_best_minute(events: seq[Event], id: int) : int =
    let (minute, value) = find_best_minute_with_value(events, id)
    return minute
    # var 
    #     acc_array = zeros[int]([60])
    #     last_time = zeros[int]([60])
    #     start_time = 0
    # let events_id = events.filter_it(it.id == id)
    # for e in events_id:
    #     if e.etype == StartGuard:
    #         acc_array += last_time
    #         last_time = zeros[int]([60])
    #         start_time = 0
    #     elif e.etype == FallAsleep:
    #         start_time = e.minute
    #     elif e.etype == WakeUp:
    #         last_time[start_time..<e.minute] = 1
    # acc_array += last_time
    # echo acc_array
    # let best_minute =  acc_array.argmax_max(0)[0].data[0]
    # return best_minute


proc get_ids(events: seq[Event]): set[uint16] =
    for e in events:
        if e.id != -1:
            result.incl(e.id.uint16)



proc solve_second(): int = 
    let file = open "d4.txt"
    var 
        events = parse_events file
        best_id = -1
        best_minute = -1
        best_value = -1
    let ids = get_ids(events)
    for id in ids:
        let (minute, value) = events.find_best_minute_with_value(id.int)
        if value > best_value:
            best_value = value
            best_id = id.int
            best_minute = minute
    return best_minute * best_id



proc solve_first(): int =
    let file = open "d4.txt"
    var events = parse_events(file)
    let sleep_minutes_by_elf = events.calc_wakeup_time()
    echo sleep_minutes_by_elf
    let id_sleeper = sleep_minutes_by_elf.key_with_max_value()
    echo id_sleeper, "   ", events.find_best_minute(id_sleeper)
    return events.find_best_minute(id_sleeper) * id_sleeper

echo solve_second()