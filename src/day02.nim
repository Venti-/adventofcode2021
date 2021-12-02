import std/parseutils
import std/strutils
import sugar


type
    CommandType = enum 
        forward = "forward", 
        up = "up", 
        down = "down"
    Command = tuple
        name: CommandType
        value: int
    State = tuple
        up: int
        forward: int
        aim: int


func parseCommand(line: string): Command =
    let parts = split(line, " ")
    let name = parseEnum[CommandType](parts[0])
    let value = parseInt(parts[1])
    return (name: name, value: value)


proc readToSec(path: string): seq[Command] =
    let f = open(path)
    defer: f.close()

    var
        line: string
    while f.readLine(line):
        result.add(parseCommand(line))


func moveAbsolute(cmd: Command, state: State): State =
    result = state
    case cmd.name:
        of forward: result.forward += cmd.value
        of up: result.up += cmd.value
        of down: result.up -= cmd.value


func moveRelative(cmd: Command, state: State): State =
    result = state
    case cmd.name:
        of forward:
            result.forward += cmd.value
            result.up -= result.aim * cmd.value
        of up: result.aim -= cmd.value
        of down: result.aim += cmd.value


func calcState(input: seq[Command], start: State, fun: (Command, State) -> State): State =
    result = start
    for cmd in input:
        result = fun(cmd, result)


# Tests
assert calcState(@[(up, 5), (down, 3), (forward, 11)], (0, 0, 0), moveAbsolute) == (2, 11, 0)
assert calcState(@[(up, 2), (down, 4), (forward, 3)], (0, 0, 0), moveRelative) == (-6, 3, 2)

let input = readToSec("input/2")

let state1 = calcState(input, (up: 0, forward: 0, aim: 0), moveAbsolute)
echo("Problem 1: " & $state1 & " => " & $(-state1.up * state1.forward))

let state2 = calcState(input, (up: 0, forward: 0, aim: 0), moveRelative)
echo("Problem 2: " & $state2 & " => " & $(-state2.up * state2.forward))
