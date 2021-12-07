import std/strutils
import std/parseutils
import std/sequtils
import std/streams
import std/tables
import std/times
import sugar


type
    Crabs = CountTableRef[int]


func newAges(): Crabs =
    return newCountTable[int](9)


func newAges(ages: openArray[int]): Crabs =
    result = newAges()
    for age in ages:
        result.inc(int(age))


func calcFuel(ages: Crabs, level: int): int =
    for pos, cnt in ages:
        result += abs(pos - level) * cnt


func calcExpFuel(ages: Crabs, level: int): int =
    for pos, cnt in ages:
        let n = abs(pos - level)
        result += ((n * (n + 1)) div 2) * cnt


proc parseInput(s: string): Crabs =
    result = newAges()
    for pos in split(s, {',', '\n', '\r'}):
        if pos != "":
            result.inc(parseInt(pos))


func calcAvg(crabs: Crabs): int =
    var sumAll: int = 0
    var cntAll: int = 0
    for pos, cnt in crabs:
        sumAll += pos * cnt
        cntAll += cnt
    return sumAll div cntAll


func findLowestFuel(crabs: Crabs, fun: (Crabs, int) -> int): int =
    var bestLevel: int = 0
    var bestFuel: int = fun(crabs, bestLevel)
    while true:
        #debugEcho("level ", bestLevel, " fuel ", bestFuel)
        let nextFuel = fun(crabs, bestLevel + 1)
        if nextFuel >= bestFuel:
            break
        bestFuel = nextFuel
        bestLevel += 1
    return bestLevel


when isMainModule:
    import std/unittest
    suite "Day6":
        test "Read example input":
            let ages = parseInput(readFile("input/7example"))
            check:
                ages == newAges([16,1,2,0,4,2,7,1,2,14])

        test "calcFuel":
            let day0 = parseInput(readFile("input/7example"))
            check:
                calcFuel(day0, 1) == 41
                calcFuel(day0, 2) == 37
                calcFuel(day0, 3) == 39
                calcFuel(day0, 10) == 71
                findLowestFuel(day0, calcFuel) == 2
        
        test "calcExpFuel":
            let day0 = parseInput(readFile("input/7example"))
            check:
                calcExpFuel(day0, 0) == 290
                calcExpFuel(day0, 2) == 206
                calcExpFuel(day0, 5) == 168
                findLowestFuel(day0, calcExpFuel) == 5

when isMainModule:
    block:
        let cpu = cpuTime()
        let crabs = parseInput(readFile("input/7"))
        let level = findLowestFuel(crabs, calcFuel)
        echo("Lowest fuel level: ", level, ", fuel: ", calcFuel(crabs, level))
        echo("time: ", cpuTime() - cpu)

    block:
        let cpu = cpuTime()
        let crabs = parseInput(readFile("input/7"))
        let level = findLowestFuel(crabs, calcExpFuel)
        echo("Lowest expFuel level: ", level, ", fuel: ", calcExpFuel(crabs, level))
        echo("time: ", cpuTime() - cpu)
