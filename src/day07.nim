import std/strutils
import std/parseutils
import std/sequtils
import std/streams
import std/tables
import std/times
import sugar


type
    Crabs = CountTableRef[int]


func newCrabs(): Crabs =
    return newCountTable[int](9)


func newCrabs(crabs: openArray[int]): Crabs =
    result = newCrabs()
    for pos in crabs:
        result.inc(pos)


func calcFuel(crabs: Crabs, level: int): int =
    for pos, cnt in crabs:
        result += abs(pos - level) * cnt


func calcExpFuel(crabs: Crabs, level: int): int =
    for pos, cnt in crabs:
        let n = abs(pos - level)
        result += ((n * (n + 1)) div 2) * cnt


proc parseInput(s: string): Crabs =
    result = newCrabs()
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
    suite "Day7":
        test "Read example input":
            let crabs = parseInput(readFile("example/7example"))
            check:
                crabs == newCrabs([16,1,2,0,4,2,7,1,2,14])

        test "calcFuel":
            let crabs = parseInput(readFile("example/7example"))
            check:
                calcFuel(crabs, 1) == 41
                calcFuel(crabs, 2) == 37
                calcFuel(crabs, 3) == 39
                calcFuel(crabs, 10) == 71
                findLowestFuel(crabs, calcFuel) == 2

        test "calcExpFuel":
            let crabs = parseInput(readFile("example/7example"))
            check:
                calcExpFuel(crabs, 0) == 290
                calcExpFuel(crabs, 2) == 206
                calcExpFuel(crabs, 5) == 168
                findLowestFuel(crabs, calcExpFuel) == 5

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
