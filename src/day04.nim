import std/strutils
import std/parseutils
import std/sequtils
import std/streams


type
    Board = seq[seq[int]]


proc readNumbers(f: Stream): seq[int] =
    result = map(split(f.readLine(), ","), parseInt)
    assert result.len > 0


proc readBoard(f: Stream, width: int, height: int): Board =
    for i in 1..height:
        let rowStr = split(f.readLine(), " ").filterIt(it != "")
        let rowInt = map(rowStr, parseInt)
        assert rowInt.len == width
        result.add(rowInt)
    assert result.len() == height


proc readInput(f: Stream, width: int, height: int): 
        (seq[int], seq[Board]) =
    let numbers = readNumbers(f)
    discard f.readLine() # discard blank line

    var boards: seq[Board]
    while not f.atEnd():
        let board = readBoard(f, width, height)
        boards.add(board)

        try:
            discard f.readLine() # discard blank line
        except IOError:
            break

    return (numbers, boards)


proc readInputFromPath(path: string, width: int, height: int): 
        (seq[int], seq[Board]) =
    let f = newFileStream(path)
    defer: f.close()
    return readInput(f, width, height)


func takeNumber(board: Board, value: int): Board =
    for row in board:
        var newRow: seq[int] = @[]
        for number in row:
            if number != value:
                newRow.add(number)
            else:
                newRow.add(-1)
        result.add(newRow)


func isBingo(board: Board): bool =
    # Is any row a bingo?
    for y in 0 .. board.high:
        for x in 0 .. board[y].high:
            if board[y][x] != -1:
                break
            if x == board.high:
                return true
    # Is any column a bingo?
    for x in 0 .. board.high:
        for y in 0 .. board.high:
            if board[y][x] != -1:
                break
            if y == board.high:
                return true
    return false


proc findWinner(path: string): (Board, int) =
    var (numbers, boards) = readInputFromPath(path, 5, 5)
    for number in numbers:
        var newBoards: seq[Board]
        for board in boards:
            let newBoard = takeNumber(board, number)
            if isBingo(newBoard):
                return (newBoard, number)
            else:
                newBoards.add(newBoard)
        boards = newBoards


proc findLastWinner(path: string): (Board, int) =
    var (numbers, boards) = readInputFromPath(path, 5, 5)
    for number in numbers:
        var newBoards: seq[Board]
        for board in boards:
            let newBoard = takeNumber(board, number)
            if boards.len == 1 and isBingo(newBoard):
                return (newBoard, number)
            elif not isBingo(newBoard):
                newBoards.add(newBoard)
        boards = newBoards


proc calcBoardSum(board: Board): int =
    var sum = 0
    for row in board:
        for number in row:
            if number != -1:
                result += number


when isMainModule:
    import std/unittest
    suite "Test solution":
        test "readNumbers":
            let stream = newStringStream("""1,2,3,4
            """)
            let numbers = readNumbers(stream)
            check: numbers == @[1, 2, 3, 4]

        test "readBoard":
            let stream = newStringStream("""1 2
            3 4
            
            """)
            let board = readBoard(stream, 2, 2)
            check: board == @[@[1, 2], @[3, 4]]

        test "readInput":
            let stream = newStringStream("""1,2,3

            1 2
            3 4

            5 6
            7 8
            """)
            let (numbers, boards) = readInput(stream, 2, 2)
            check:
                numbers == @[1, 2, 3]
                boards == @[
                    @[@[1, 2], @[3, 4]],
                    @[@[5, 6], @[7, 8]]
                ]

        test "takeNumber":
            let board = @[
                @[1, 2],
                @[3, 4]
            ]
            let newBoard = takeNumber(board, 2)
            check: newBoard == @[
                @[1, -1],
                @[3, 4]
            ]

        test "isBingo":
            let board1 = @[
                @[1, 2],
                @[3, 4]
            ]
            let board2 = @[
                @[1, 2],
                @[-1, -1]
            ]
            let board3 = @[
                @[1, -1],
                @[3, -1]
            ]
            check:
                isBingo(board1) == false
                isBingo(board2) == true
                isBingo(board3) == true
        
        test "calcBoardSum":
            let board = @[
                @[1, 2],
                @[-1, 4]
            ]
            check: calcBoardSum(board) == 7

        test "example 1":
            let (board, number) = findWinner("example/4example")
            check:
                number == 24
                calcBoardSum(board) == 188

        test "example 2":
            let (board, number) = findLastWinner("example/4example")
            check:
                number == 13
                calcBoardSum(board) == 148

when isMainModule:
    block:
        let (board, number) = findWinner("input/4")
        echo("Number: " & $number)
        echo("Board: " & $board)
        let solution = calcBoardSum(board) * number
        echo("Solution 1: " & $solution)
    block:
        let (board, number) = findLastWinner("input/4")
        echo("Number: " & $number)
        echo("Board: " & $board)
        let solution = calcBoardSum(board) * number
        echo("Solution 2: " & $solution)
