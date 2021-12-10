import std/strutils
import std/sequtils
import std/streams
import std/times
import std/sets
import std/algorithm
import std/tables


let openToClose: Table[char, char] = toTable([('<', '>'), ('(', ')'), ('[', ']'), ('{', '}')])
let closeToPoints: Table[char, int] = toTable([(')', 3), (']', 57), ('}', 1197), ('>', 25137)])


proc corruptionPoints(line: string): int =
    var stack: seq[char] = @[]
    for c in line:
        #debugEcho(stack)
        if c in openToClose:
            stack.add(openToClose[c])
        elif c in closeToPoints:
            if c != stack.pop():
                return closeToPoints[c]
    if stack.len() > 0:
        # Apparently this is fine?
        return 0
    else:
        return 0


when isMainModule:
    import std/unittest
    suite "Day10":
        test "Example 1":
            check:
                lines("input/10example").toSeq().map(corruptionPoints).foldl(a + b) == 26397


when isMainModule:
    template benchmark(code: untyped) =
        block:
            let cpu = cpuTime()
            code
            echo("cpuTime: ", cpuTime() - cpu)

    benchmark:
        let sum = lines("input/10").toSeq().map(corruptionPoints).foldl(a + b)
        echo("Total syntax error: ", sum)
