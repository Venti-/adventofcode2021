import std/strutils
import std/sequtils
import std/streams
import std/times
import std/sets
import std/algorithm


type
    Cave = seq[seq[int]]
    Point = tuple[y: int, x: int]


func readLine(line: string): seq[int] =
    return line.toSeq()
            .mapIt(parseInt($it))


proc readInput(input: string): seq[seq[int]] =
    return input.splitLines()
            .toSeq()
            .filterIt(it != "")
            .map(readLine)


func getHeight(cave: Cave, point: Point): int =
    return cave[point.y][point.x]


iterator neighbors(cave: Cave, point: Point): Point =
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


func isLowPoint(cave: Cave, point: Point): bool =
    let height = cave.getHeight(point)
    for p in cave.neighbors(point):
        let otherHeight = cave.getHeight(p)
        if otherHeight <= height:
            return false
    return true


iterator points(cave: Cave): Point =
    for y in cave.low .. cave.high:
        let row = cave[y]
        for x in row.low .. row.high:
            yield (y, x)


func floodFill(cave: Cave, start: Point, height: int): seq[Point] =
    var toVisit: HashSet[Point]
    var visited: HashSet[Point]
    toVisit.incl(start)
    while toVisit.len > 0:
        let curPoint = toVisit.pop()
        visited.incl(curPoint)
        for adjacentPoint in cave.neighbors(curPoint):
            let adjacentHeight = cave.getHeight(adjacentPoint)
            if adjacentHeight < height and not visited.contains(adjacentPoint):
                toVisit.incl(adjacentPoint)
    
    return visited.toSeq()


func basinSize(cave: Cave, point: Point): int =
    return floodFill(cave, point, 9).len


when isMainModule:
    import std/unittest
    suite "Day9":
        test "Read input":
            let cave = readInput("123\n456\n789\n")
            check:
                cave == @[@[1, 2, 3], @[4, 5, 6], @[7, 8, 9]]

        test "Example 1":
            let cave = readInput(readFile("input/9example"))
            check:
                not cave.isLowPoint((0, 0))
                cave.isLowPoint((0, 1))
                cave.isLowPoint((0, 9))
                cave.isLowPoint((2, 2))
                cave.isLowPoint((4, 6))
                not cave.isLowPoint((4, 9))
                cave.points().toSeq().filterIt(cave.isLowPoint(it)).mapIt(cave.getHeight(it) + 1).foldl(a + b) == 15

        test "Example 2":
            let cave = readInput(readFile("input/9example"))
            check:
                cave.basinSize((0, 0)) == 3
                cave.basinSize((0, 9)) == 9
                cave.basinSize((2, 2)) == 14
                cave.basinSize((4, 6)) == 9


when isMainModule:
    template benchmark(code: untyped) =
        block:
            let cpu = cpuTime()
            code
            echo("cpuTime: ", cpuTime() - cpu)

    benchmark:
        let cave = readInput(readFile("input/9"))
        let riskLevelSum = cave.points
                .toSeq()
                .filterIt(cave.isLowPoint(it))
                .mapIt(cave.getHeight(it) + 1)
                .foldl(a + b)
        echo("Solution 1: ", riskLevelSum)

    benchmark:
        let cave = readInput(readFile("input/9"))
        let lowPoints = cave.points().toSeq().filterIt(cave.isLowPoint(it))
        let orderedSizes = lowPoints.mapIt(cave.basinSize(it)).sorted(system.cmp[int], SortOrder.Descending)
        let solution = orderedSizes[0 .. 2].toSeq().foldl(a * b, 1)
        echo("Solution 2: ", solution)
