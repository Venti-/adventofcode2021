import std/strutils
import std/sequtils
import std/streams
import std/times
import std/sets
import std/algorithm
import std/tables


let openToClose: Table[char, char] = toTable([('<', '>'), ('(', ')'), ('[', ']'), ('{', '}')])
let closeToPoints: Table[char, int] = toTable([(')', 3), (']', 57), ('}', 1197), ('>', 25137)])
let completeToPoints: Table[char, int] = toTable([(')', 1), (']', 2), ('}', 3), ('>', 4)])

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
        for c in stack.reversed():
            result *= 5
            result -= completeToPoints[c]
    else:
        return 0


proc calcCorruption(input: string): int =
    return lines(input).toSeq()
            .map(corruptionPoints)
            .filterIt(it > 0)
            .foldl(a + b)


proc calcScore(input: string): int =
    let scores = lines(input).toSeq()
            .map(corruptionPoints)
            .filterIt(it < 0)
            .mapIt(-1 * it)
            .sorted()
    return scores[scores.len div 2]


when isMainModule:
    import std/unittest
    suite "Day10":
        test "Example 1":
            check:
                calcCorruption("input/10example") == 26397

        test "Example 2":
            check:
                calcScore("input/10example") == 288957


when isMainModule:
    template benchmark(code: untyped) =
        block:
            let cpu = cpuTime()
            code
            echo("cpuTime: ", cpuTime() - cpu)

    benchmark:
        echo("Total syntax error: ", calcCorruption("input/10"))

    benchmark:
        echo("Middle score: ", calcScore("input/10"))
