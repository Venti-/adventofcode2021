import std/strutils
import std/parseutils
import std/sequtils
import std/streams
import std/tables
import std/times
import sugar


type
    Ages = CountTableRef[int]


func newAges(): Ages =
    return newCountTable[int](9)


func newAges(ages: openArray[int]): Ages =
    return newCountTable[int](ages)


func sum(ages: Ages): int =
    return ages.values.toSeq.foldl(a + b, 0)


proc parseInput(s: string): Ages =
    result = newAges()
    for ageStr in split(s, {',', '\n', '\r'}):
        if ageStr != "":
            result.inc(parseInt(ageStr))


func simulate(ages: Ages): Ages =
    result = newAges()
    for age, cnt in ages:
        if age == 0:
            result.inc(8, cnt)
            result.inc(6, cnt)
        else:
            result.inc(age - 1, cnt)


func simulate(ages: Ages, days: int): Ages =
    result = ages
    for i in 1 .. days:
        result = simulate(result)


when isMainModule:
    import std/unittest
    suite "Day6":
        test "Read example input":
            let ages = parseInput(readFile("input/6example"))
            check:
                ages == newAges([3,4,3,1,2])

        test "simulate":
            let day0 = parseInput("3,4,3,1,2")
            check:
                simulate(day0, 0) == newAges([3,4,3,1,2])
                simulate(day0, 1) == newAges([2,3,2,0,1])
                simulate(day0, 2) == newAges([1,2,1,6,0,8])
                simulate(day0, 3) == newAges([0,1,0,5,6,7,8])


when isMainModule:
    block:
        let day0 = parseInput(readFile("input/6"))
        let day80 = simulate(day0, 80)
        echo("Day 80 sum: ", day80.sum())
