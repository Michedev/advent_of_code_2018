import match
import os
import strutils

proc solve_first(): int =
    let args = command_line_params()
    return simulate_match(args[0].parse_int(), args[1].parse_int())

echo solve_first()