import std/strutils
import std/parseutils
import std/sequtils
import std/streams
import std/tables
import std/times
import sugar

type
    Point = tuple
        y: int
        x: int
    Line = tuple
        a: Point
        b: Point


func parsePoint(str: string): Point =
    let points: seq[int] = split(str, ",").map(parseInt)
    return (points[0], points[1])


func parseLine(str: string): Line =
    let points: seq[string] = split(str, " -> ")
    return (parsePoint(points[0]), parsePoint(points[1]))


func getDirection(value: int): int =
    if value < 0:
        return -1
    elif value > 0:
        return 1
    else:
        return 0


iterator getLine(line: Line): Point =
    var a: Point = line.a
    let b: Point = line.b
    let dy = getDirection(b.y - a.y)
    let dx = getDirection(b.x - a.x)

    yield (a.y, a.x)
    while a.y != b.y or a.x != b.x:
        #debugEcho("a: ", a, " b: ", b)
        a.y += dy
        a.x += dx
        yield (a.y, a.x)


func drawLine(buffer: CountTableRef[Point], line: Line): void =
    for point in getLine(line):
        buffer.inc(point)


func isStraight(line: Line): bool =
    let a: Point = line.a
    let b: Point = line.b
    return a.x == b.x or a.y == b.y


proc countOverlaps(path: string, pred: (Line) -> bool): int =
    let buffer: CountTableRef[Point] = newCountTable[Point]()
    let f = newFileStream(path)
    defer: f.close()
    var lineStr: string
    while f.readLine(lineStr):
        let line = parseLine(lineStr)
        if pred(line):
            drawLine(buffer, line)

    for v in buffer.values:
        if v > 1:
            result += 1


when isMainModule:
    import std/unittest
    suite "Test solution":
        test "readNumbers":
            check:
                parsePoint("1,2") == (1,2)

        test "readLines":
            check:
                parseLine("1,2 -> 3,4") == ((1,2), (3,4))
        
        test "getLine":
            check:
                # Point
                getLine(((1,1), (1,1))).toSeq() == [(1,1)]
                # Horizontal line
                getLine(((1,1), (1,2))).toSeq() == [(1,1), (1,2)]
                getLine(((1,2), (1,1))).toSeq() == [(1,2), (1,1)]
                # Vertical line
                getLine(((1,1), (2,1))).toSeq() == [(1,1), (2,1)]
                getLine(((2,1), (1,1))).toSeq() == [(2,1), (1,1)]

        test "drawLinearLine":
            let buffer: CountTableRef[Point] = newCountTable[Point]()
            drawLine(buffer, ((1,1), (1,1)))
            let cnt1 = buffer.len()
            drawLine(buffer, ((1,1), (4,1)))
            let cnt2 = buffer.len()
            drawLine(buffer, ((1,1), (1,4)))
            let cnt3 = buffer.len()
            check:
                cnt1 == 1
                cnt2 == 4
                cnt3 == 7
        
        test "example 1":
            check:
                countOverlaps("example/5example", isStraight) == 5
        
        test "example 2":
            check:
                countOverlaps("example/5example", (line) => true) == 12

when isMainModule:
    block:
        let cpu = cpuTime()
        echo("solition 1: ", countOverlaps("input/5", isStraight))
        echo("time: ", cpuTime() - cpu)

    block:
        let cpu = cpuTime()
        echo("solition 2: ", countOverlaps("input/5", (line) => true))
        echo("time: ", cpuTime() - cpu)
