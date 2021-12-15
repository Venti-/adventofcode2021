import std/strutils
import std/streams
import std/tables
import std/sets
import std/times
import std/sequtils
import std/algorithm
import std/os

type
    Board = seq[seq[int]]
    Point = tuple[y: int, x: int]


proc readInput(stream: Stream): Board =
    defer: stream.close()
    for line in stream.lines:
        if line == "": continue
        result.add(line.items.toSeq.mapIt(parseInt($it)))


proc repeat(board: Board, vertically: int, horizontally: int): Board =
    for y in 0 .. vertically - 1:
        for row in board:
            var newRow: seq[int] = @[]
            for x in 0 .. horizontally - 1:
                newRow.add(row.mapIt(((it + y + x - 1) mod 9) + 1))
            result.add(newRow)


iterator neighbors(cave: Board, point: Point): Point =
    let (y, x) = point
    let (minY, minX) = (cave.low, cave[0].low)
    let (maxY, maxX) = (cave.high, cave[0].high)
    if y > minY:
        yield (y - 1, x)
    if y < maxY:
        yield (y + 1, x)
    if x > minX:
        yield (y, x - 1)
    if x < maxX:
        yield (y, x + 1)


func distance(a: Point, b: Point): int =
    return abs(a.y - b.y) + abs(a.x - b.x)


func tracePath(visited: Table[Point, Point], point: Point, start: Point): seq[Point] =
    var current = point
    result.add(current)
    while current != start:
        current = visited[current]
        result.add(current)

    discard result.pop() # remove start
    
    result.reverse()


proc bfs(board: Board, start: Point, dest: Point): seq[Point] =
    var frontier = newCountTable[Point](board.len * board[0].len)
    var costs = newCountTable[Point](board.len * board[0].len)
    var visited: Table[Point, Point] = initTable[Point, Point]()

    var current = start
    var totalCost = board[start.y][start.x]
    frontier[start] = totalCost
    visited[start] = start

    while frontier.len > 0:
        let next = frontier.smallest[0]
        let nextCost = costs[next]
        #debugEcho "cost = ", nextCost, ", path = ", tracePath(visited, next, start).mapIt($it.y & "," & $it.x).join(" -> ")
        frontier.del(next)
        current = next
        totalCost = nextCost

        if current == dest:
            break

        for neighbor in board.neighbors(current):
            if not (neighbor in frontier or neighbor in visited):
                let cost = board[neighbor.y][neighbor.x]
                frontier[neighbor] = totalCost + cost
                costs[neighbor] = totalCost + cost
                visited[neighbor] = current
    
    assert current == dest

    #debugEcho "visited: ", visited

    result = tracePath(visited, current, start)


when isMainModule:
    import std/unittest
    suite "Day15":
        test "readInput":
            let board = readInput(newStringStream("12\n34\n"))
            check board == @[@[1, 2], @[3, 4]]

        test "repeat":
            let board = readInput(newStringStream("8\n"))
            check repeat(board, 2, 3) == @[@[8, 9, 1], @[9, 1, 2]]
        
        test "example 1":
            let board = readInput(newFileStream("input/15example"))
            #echo board.mapIt(it.join("")).toSeq().join("\n")

            let path = bfs(board, (0, 0), (board.high, board[0].high))
            #echo path.mapIt(($it.y & "," & $it.x, board[it.y][it.x]))
            check path.mapIt(board[it.y][it.x]).foldl(a + b) == 40

        test "example 2":
            let board = readInput(newFileStream("input/15example")).repeat(5, 5)
            #echo board.mapIt(it.join("")).toSeq().join("\n")

            let path = bfs(board, (0, 0), (board.high, board[0].high))
            #echo path.mapIt(($it.y & "," & $it.x, board[it.y][it.x]))
            check path.mapIt(board[it.y][it.x]).foldl(a + b) == 315
        
        test "solution 1":
            let board = readInput(newFileStream("input/15"))
            let path = bfs(board, (0, 0), (board.high, board[0].high))
            #echo path.mapIt(($it.y & "," & $it.x, board[it.y][it.x]))
            check path.mapIt(board[it.y][it.x]).foldl(a + b) == 540
        
        # Works buit slooooow.
        #[test "solution 2":
            let board = readInput(newFileStream("input/15")).repeat(5, 5)
            let path = bfs(board, (0, 0), (board.high, board[0].high))
            #echo path.mapIt(($it.y & "," & $it.x, board[it.y][it.x]))
            check path.mapIt(board[it.y][it.x]).foldl(a + b) == 2879]#
