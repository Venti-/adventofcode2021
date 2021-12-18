import std/strutils
import std/streams
import std/tables
import std/sets
import std/times


type
    Rules = Table[string, char]
    Input = tuple[polymer: string, rules: Rules]
    Memory = Table[tuple[steps: int, pair: string], CountTable[char]]


proc readInput(input: Stream): Input =
    defer: input.close()

    let polymer = input.readLine()
    discard input.readLine()

    var rules: Rules
    var line: string
    while input.readLine(line):
        if line == "":
            continue
        let parts = line.split(" -> ")
        let (before, after) = (parts[0], parts[1][0])
        rules[before] = after

    return (polymer, rules)


func recurseSteps(left: char, right: char, rules: Rules, steps: int, memory: var Memory): CountTable[char] =
    # Return number of letters for a pair of characters, as expanded by $rules after $steps.
    result = initCountTable[char]()    

    let middle = rules.getOrDefault(left & right, ' ')
    if middle == ' ':
        return result

    let key = (steps, left & right)
    if key in memory:
        return memory[key]

    result.inc(middle)
    if steps > 0:
        result.merge(recurseSteps(left, middle, rules, steps - 1, memory))
        result.merge(recurseSteps(middle, right, rules, steps - 1, memory))
        memory[key] = result


func countLetters(polymer: string, rules: Rules, steps: int): CountTable[char] =
    # Return number of letters for a string, as expanded by $rules after $steps.
    var memory: Memory = initTable[tuple[steps: int, pair: string], CountTable[char]]()

    result = toCountTable(polymer)
    for i in polymer.low .. polymer.high - 1:
        result.merge(recurseSteps(polymer[i], polymer[i + 1], rules, steps - 1, memory))

    debugEcho("memory.len = ", memory.len)


template benchmark(code: untyped) =
    block:
        let cpu = cpuTime()
        code
        echo("cpuTime: ", cpuTime() - cpu)


when isMainModule:
    import std/unittest
    suite "Day14":
        test "read example":
            let (polymer, rules) = readInput(newFileStream("example/14example"))
            check polymer == "NNCB"
            check rules.len == 16
            check rules["CH"] == 'B'

        test "Example":
            let (polymer, rules) = readInput(newFileStream("example/14example"))
            check countLetters(polymer, rules, 1) == toCountTable("NCNBCHB")
            check countLetters(polymer, rules, 4) == toCountTable("NBBNBNBBCCNBCNCCNBBNBBNBBBNBBNBBCBHCBHHNHCBBCBHCB")
            
            let step10 = countLetters(polymer, rules, 10)
            check step10.largest[1] - step10.smallest[1] == 1588
        
        test "Solution 1":
            benchmark:
                let (polymer, rules) = readInput(newFileStream("input/14"))
                let step10 = countLetters(polymer, rules, 10)
                check step10.largest[1] - step10.smallest[1] == 3411

        test "Solution 2":
            benchmark:
                let (polymer, rules) = readInput(newFileStream("input/14"))
                let step40 = countLetters(polymer, rules, 40)
                check step40.largest[1] - step40.smallest[1] == 7477815755570
