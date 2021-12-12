import std/strutils
import std/parseutils
import std/sequtils
import std/streams
import std/tables
import std/times
import sugar


func toSet(str: string): set[char] =
    for c in str:
        result.incl(c)


#[
  0:      1:X     2:      3:      4:X
 aaaa    ....    aaaa    aaaa    ....
b    c  .    c  .    c  .    c  b    c
b    c  .    c  .    c  .    c  b    c
 ....    ....    dddd    dddd    dddd
e    f  .    f  e    .  .    f  .    f
e    f  .    f  e    .  .    f  .    f
 gggg    ....    gggg    gggg    ....

  5:      6:      7:X     8:X     9:
 aaaa    aaaa    aaaa    aaaa    aaaa
b    .  b    .  .    c  b    c  b    c
b    .  b    .  .    c  b    c  b    c
 dddd    dddd    ....    dddd    dddd
.    f  e    f  .    f  e    f  .    f
.    f  e    f  .    f  e    f  .    f
 gggg    gggg    ....    gggg    gggg
]#
let digitToSegmentsStr: Table[int, string] = 
        {0: "abcefg", 1: "ef", 2: "acdeg", 3: "acdfg", 4:"bcdf",
        5: "abdfg", 6: "abdefg", 7: "acf", 8: "abcdefg", 9: "abcdfg"}
        .toTable()
let digitToSegments: Table[int, set[char]] = collect:
    for k, v in digitToSegmentsStr.pairs(): {k: v.toSet()}
 

type
    Segment = set[char]
    Segments = seq[Segment]
let numSegmentsToDigit: Table[int, int] = toTable([(2, 1), (4, 4), (3, 7), (7, 8)])


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
            .mapIt(it.numbers.mapIt(it.len()).filterIt(it in numSegmentsToDigit))
            .mapIt(it.len())
            .foldl(a + b)


proc solve(segments: Segments): Table[set[char], int] =
    var digitToSet: Table[int, set[char]]
    for segment in segments:
        let possibilities = collect:
            for k, v in digitToSegments.pairs():
                if v.len() == segment.len(): {k: v}
        
        if possibilities.len() == 1:
            let digit = possibilities.keys().toSeq()[0]
            digitToSet[digit] = segment

    for segment in segments:
        if segment.len == 5:
            if (segment * digitToSet[1]).len == 2:
                digitToSet[3] = segment
            elif (segment * digitToSet[4]).len == 2:
                digitToSet[2] = segment
            else:
                digitToSet[5] = segment
        elif segment.len == 6:
            if (segment * digitToSet[1]).len == 1:
                digitToSet[6] = segment
            elif (segment * digitToSet[4]).len == 4:
                digitToSet[9] = segment
            else:
                digitToSet[0] = segment

    let setToDigit = collect:
        for k, v in digitToSet.pairs(): {v: k}

    assert setToDigit.len == 10
    return setToDigit


func descramble(numbers: seq[set[char]], setToDigit: Table[set[char], int]): int =
    let digits = numbers.mapIt(setToDigit[it])
    return digits.foldl(a * 10 + b, 0)


proc sumLines(path: string): int =
    for line in lines(path):
        let (signals, numbers) = parseLine(line)
        let setToDigit = solve(signals)
        result += descramble(numbers, setToDigit)


when isMainModule:
    import std/unittest
    suite "Day8":
        test "Read example input":
            let (signals, numbers) = parseLine("ga eg | fd bg")
            check:
                signals == @[{'g', 'a'}, {'e', 'g'}]
                numbers == @[{'f', 'd'}, {'b', 'g'}]

        test "solve":
            let (signals, numbers) = parseLine("be cfbegad cbdgef fgaecd cgeb fdcge agebfd fecdb fabcd edb | fdgacbe cefdb cefbgd gcbe")
            let setToDigit = solve(signals)
            check descramble(numbers, setToDigit) == 8394

        test "Example 1":
            check solve1("input/8example") == 26
        
        test "Example 2":
            check sumLines("input/8example") == 61229
        
        test "Solution 1":
            check solve1("input/8") == 349
        
        test "Solution 2":
            check sumLines("input/8") == 1070957
