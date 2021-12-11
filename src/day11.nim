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


func get(cave: Cave, point: Point): int =
    return cave[point.y][point.x]


func set(cave: var Cave, point: Point, value: int): void =
    cave[point.y][point.x] = value


func incr(cave: var Cave, point: Point): void =
    cave[point.y][point.x] += 1


iterator neighbors(cave: Cave, point: Point): Point =
    let (minY, minX) = (cave.low, cave[0].low)
    let (maxY, maxX) = (cave.high, cave[0].high)
    for y in point.y - 1 .. point.y + 1:
        for x in point.x - 1 .. point.x + 1:
            if y == point.y and x == point.x:
                continue
            if y >= minY and y <= maxY and x >= minX and x <= maxX:
                yield (y, x)


iterator points(cave: Cave): Point =
    for y in cave.low .. cave.high:
        let row = cave[y]
        for x in row.low .. row.high:
            yield (y, x)


iterator values(cave: Cave): int =
    for y in cave.low .. cave.high:
        let row = cave[y]
        for x in row.low .. row.high:
            yield row[x]


func simulate(startCave: Cave): Cave =
    var cave = startCave
    var toFlashSet: HashSet[Point]
    var flashedSet: HashSet[Point]

    for point in cave.points():
        cave.incr(point)
        if cave.get(point) > 9:
            toFlashSet.incl(point)
            flashedSet.incl(point)

    while toFlashSet.len() > 0:
        let point = toFlashSet.pop()
        flashedSet.incl(point)
        for neighbor in cave.neighbors(point):
            cave.incr(neighbor)
            if cave.get(neighbor) > 9 and not (neighbor in flashedSet):
                toFlashSet.incl(neighbor)
                flashedSet.incl(point)

    for point in flashedSet:
        cave.set(point, 0)

    return cave


func countFlashes(startCave: Cave, steps: int): int =
    var cave = startCave
    for step in 1 .. steps:
        cave = cave.simulate()
        result += cave.values().toSeq().filterIt(it == 0).len()


when isMainModule:
    import std/unittest
    suite "Day10":
        test "simulate":
            check:
                simulate(readInput("900\n000")) == @[@[0, 2, 1], @[2, 2, 1]]
                simulate(readInput("980\n000")) == @[@[0, 0, 2], @[3, 3, 2]]
                simulate(readInput("980\n700")) == @[@[0, 0, 2], @[0, 4, 2]]
        
        test "example 1":
            check:
                countFlashes(readInput(readFile("input/11example")), 10) == 204
                countFlashes(readInput(readFile("input/11example")), 100) == 1656


when isMainModule:
    template benchmark(code: untyped) =
        block:
            let cpu = cpuTime()
            code
            echo("cpuTime: ", cpuTime() - cpu)

    benchmark:
        echo("Solution 1: ", countFlashes(readInput(readFile("input/11")), 100))
