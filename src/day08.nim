import std/strutils
import std/parseutils
import std/sequtils
import std/streams
import std/tables
import std/times
import sugar


type
    Segment = set[char]
    Segments = seq[Segment]


let segmentsToDigit: Table[int, char] = toTable([(2, '1'), (4, '4'), (3, '7'), (7, '8')])

func parseSegments(s: string): Segments =
    for segmentStr in s.split(" "):
        if segmentStr == "":
            continue
        var segment: Segment = {}
        for letter in segmentStr:
            incl(segment, letter)
        result.add(segment)


func parseLine(input: string): tuple[signals: Segments, numbers: Segments] =
    let parts = split(input, "|")
    let (left, right) = (parts[0], parts[1])
    let signals = parseSegments(left)
    let numbers = parseSegments(right)
    return (signals, numbers)


proc solve1(path: string): int =
    return lines(path)
            .toSeq()
            .map(parseLine)
            .mapIt(it.numbers.mapIt(it.len()).filterIt(it in segmentsToDigit))
            .mapIt(it.len())
            .foldl(a + b)


when isMainModule:
    import std/unittest
    suite "Day8":
        test "Read example input":
            let (signals, numbers) = parseLine("ga eg | fd bg")
            check:
                signals == @[{'g', 'a'}, {'e', 'g'}]
                numbers == @[{'f', 'd'}, {'b', 'g'}]

        test "Example 1":
            let digitCnt = solve1("input/8example")
            check:
                digitCnt == 26


when isMainModule:
    template benchmark(code: untyped) =
        block:
            let cpu = cpuTime()
            code
            echo("cpuTime: ", cpuTime() - cpu)

    benchmark:
        echo("DigitCnt: ", solve1("input/8"))
