import std/strutils
import std/streams
import std/sequtils
import std/bitops
import std/logging
import std/strformat
import std/re


type Area = object
    y: Slice[int]
    x: Slice[int]


type Vector2D = tuple[y: int, x: int]


type Probe = object
    position: Vector2D
    velocity: Vector2D


func newProbe(y: int, x: int): Probe =
    return Probe(position: (0, 0), velocity: (y, x))


func step(probe: Probe): Probe =
    result = probe
    result.position.y += probe.velocity.y
    result.position.x += probe.velocity.x
    if probe.velocity.x > 0:
        result.velocity.x -= 1
    elif probe.velocity.x < 0:
        result.velocity.x += 1
    result.velocity.y -= 1

func doSteps(probe: Probe, steps: int): Probe =
    result = probe
    for i in 1 .. steps:
        result = step(result)
        #debugEcho i, " ", result


func parseInput(input: string): Area =
    if input =~ re"^target area: x\=([-]?\d+)\.\.([-]?\d+), y\=([-]?\d+)\.\.([-]?\d+)$":
        let bounds = matches.filterIt(it != "").map(parseInt)
        return Area(x: bounds[0]..bounds[1], y: bounds[2]..bounds[3])


func findHighestYVelocity(area: Area): int =
    # Probe always comes back to exactly 0 y position, with velocity.y+1 velocity.
    # Find the highest value where this does not immediately jump over target area.
    let (y, x) = (area.y.a, area.x.b)
    for i in 1..1000:
        let probe = step(newProbe(-(i + 1), 0))
        let pos = probe.position
        if pos.y < y or pos.x > x:
            return i - 1


func hitsArea(area: Area, velocity: Vector2D): bool =
    let (y, x) = (area.y.a, area.x.b)
    var probe = newProbe(velocity.y, velocity.x)
    while true:
        let pos = probe.position
        if pos.y < y or pos.x > x:
            return false
        elif pos.y in area.y and pos.x in area.x:
            return true
        probe = step(probe)


func findVelocities(area: Area): seq[Vector2D] =
    let maxY = findHighestYVelocity(area)
    for y in area.y.a .. maxY:
        for x in 0 .. area.x.b:
            let velocity = (y, x)
            if hitsArea(area, velocity):
                result.add(velocity)


when isMainModule:
    import std/unittest
    suite "Day17":
        test "parseInput":
            check parseInput("target area: x=20..30, y=-10..-5") == Area(y: -10..(-5), x: 20..30)
        
        test "doSteps":
            check:
                doSteps(newProbe(2, 7), 1).position == (2, 7)
                doSteps(newProbe(2, 7), 2).position == (3, 13)
                doSteps(newProbe(2, 7), 3).position == (3, 18)
                doSteps(newProbe(2, 7), 4).position == (2, 22)
                doSteps(newProbe(2, 7), 5).position == (0, 25)

        test "example 1":
            let area = parseInput("target area: x=20..30, y=-10..-5")
            check: findHighestYVelocity(area) == 9

        test "example 2":
            let area = parseInput("target area: x=20..30, y=-10..-5")
            check findVelocities(area).len == 112

        test "solution 1":
            let area = parseInput("target area: x=282..314, y=-80..-45")
            let yVelocity = findHighestYVelocity(area)
            check doSteps(newProbe(yVelocity, 0), yVelocity).position.y == 3160

        test "solution 2":
            let area = parseInput("target area: x=282..314, y=-80..-45")
            check findVelocities(area).len == 1928
