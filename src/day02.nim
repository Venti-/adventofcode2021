import std/parseutils
import std/strutils


type
    CommandType = enum 
        forward = "forward", 
        up = "up", 
        down = "down"
    Command = tuple
        name: CommandType
        value: int
    Position = tuple
        up: int
        forward: int


proc parseCommand(line: string): Command =
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


proc calcPosition(input: seq[Command], start: Position): Position =
    result = start
    for cmd in input:
        case cmd.name:
            of forward: result.forward += cmd.value
            of up: result.up += cmd.value
            of down: result.up -= cmd.value
    
    echo(result)


# Tests
assert calcPosition(@[(up, 5), (down, 3), (forward, 11)], (0, 0)) == (2, 11)


let input = readToSec("input/2")
let position = calcPosition(input, (up: 0, forward: 0))
echo($position & " => " & $(position.up * position.forward))
