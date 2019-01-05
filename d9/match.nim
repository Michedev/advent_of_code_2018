import marble_circle
import sequtils
import strformat

type
    Player = ref object
        points: int


    

proc new_player(): Player =
    result = new(Player)
    result.points = 0

proc best_player_and_points(players: seq[Player]): tuple[id: int, points: int] =
    var 
        id_player = 0
        points = -1
    for i in 1..players.len():
        let player = players[i-1]
        if player.points > points:
            id_player = i
            points = player.points
    return (id_player, points)


proc simulate_match*(n_players, turns: int): int =
    var players = new_seq[Player](n_players)
    # let logfile = open("log.csv", fmWrite, 64)
    for i in 0..<n_players: players[i] = new_player()
    var circle = new_marble_circle()
    # logfile.write_line "turn,best_player_id,points"
    for i in 0..turns:
        let points = circle.add_marble()
        if points != -1:
            players[(i-1) mod players.len()].points += points
        # let (best_id, best_pts) = players.best_player_and_points()
        # logfile.write_line fmt"{i},{best_id},{best_pts}"
    for i in 1..players.len():
        echo "Player ", i, " ends with ", players[i-1].points, " points"
    return players.map_it(it.points).max()
        
