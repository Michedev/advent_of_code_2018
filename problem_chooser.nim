import os

proc solve_problem*[T,V](first: proc(): T, second: proc(): V) =
    let args = commandLineParams()
    assert args.len() >= 1
    if args[0] == "1":
        echo "First problem output: ", first()
    elif args[0] == "2":
        echo "Second problem output: ", second()
    elif args[0] == "all":
        echo "First problem output: ", first()
        echo "Second problem output: ", second()

