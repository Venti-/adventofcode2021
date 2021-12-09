import std/strutils
import std/parseutils
import std/sequtils
import std/streams
import std/tables
import std/times
import std/options
import sugar


type
    CaveRow = seq[int]
    Cave = seq[CaveRow]
    Point = tuple[y: int, x: int]


func readLine(line: string): seq[int] =
    return line.toSeq()
            .mapIt(parseInt($it))


proc readInput(input: string): seq[seq[int]] =
    return input.splitLines()
            .toSeq()
            .filterIt(it != "")
            .map(readLine)


func getHeight(cave: Cave, point: Point): Option[int] =
    let (y, x) = point
    if y < 0 or y > cave.high:
        return none(int)
    let row = cave[y]
    if x < 0 or x > row.high:
        return none(int)
    return some(row[x])


func isLowPoint(cave: Cave, point: Point): bool =
    let (y, x) = point
    let neighbors = [(y - 1, x), (y + 1, x), (y, x - 1), (y, x + 1)]
    let height = cave.getHeight((y, x)).get()
    for p in neighbors:
        let otherHeight = cave.getHeight(p)
        if otherHeight.isSome() and otherHeight.get() <= height:
            return false
    return true


func filter(cave: Cave, fun: (Cave, Point) -> bool): iterator(): int =
    return iterator(): int =
        for y in cave.low .. cave.high:
            let row = cave[y]
            for x in row.low .. row.high:
                if fun(cave, (y, x)):
                    yield cave[y][x]


when isMainModule:
    import std/unittest
    suite "Day9":
        test "Read input":
            let cave = readInput("123\n456\n789\n")
            check:
                cave == @[@[1, 2, 3], @[4, 5, 6], @[7, 8, 9]]

        test "read example":
            let cave = readInput(readFile("input/9example"))
            check:
                not cave.isLowPoint((0, 0))
                cave.isLowPoint((0, 1))
                cave.isLowPoint((0, 9))
                cave.isLowPoint((2, 2))
                cave.isLowPoint((4, 6))
                not cave.isLowPoint((4, 9))
                cave.filter(isLowPoint).mapIt(it + 1).foldl(a + b) == 15


when isMainModule:
    let cave = readInput(readFile("input/9"))
    let riskLevelSum = cave.filter(isLowPoint).mapIt(it + 1).foldl(a + b)
    echo(riskLevelSum)
