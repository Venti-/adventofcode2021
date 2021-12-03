import std/sequtils
import sugar


proc readToSec(path: string): seq[string] =
    let f = open(path)
    defer: f.close()

    var line: string
    while f.readLine(line):
        if line != "":
            result.add(line)


func lineToBits(line: string): seq[int] =
    for letter in line:
        let bit = case letter:
            of '0': 0
            of '1': 1
            else:
                raise newException(AssertionError, "Got character other than 0 or 1")
        result.add(bit)


# Count sum for each index of sequence
func sum(lines: seq[seq[int]]): seq[int] =
    for bits in lines[0]:
        result.add(0)
    for bits in lines:
        for index, value in bits:
            result[index] += value


func seqToInt(bits: seq[int]): int =
    result = 0
    for bit in bits:
        result = result * 2 + bit


assert lineToBits("1011101") == [1, 0, 1, 1, 1, 0, 1]
assert sum(@[@[1,1], @[1,0]]) == @[2,1]
assert seqToInt(@[0, 1, 0, 1]) == 5


func calcCommon(bits: seq[seq[int]]): seq[int] =
    let sums = sum(bits)
    for value in sums:
        if value >= ((bits.len + 1) div 2):
            result.add(1)
        else:
            result.add(0)


assert calcCommon(@[@[0, 1]]) == @[0, 1]
assert calcCommon(@[@[0], @[1]]) == @[1]
assert calcCommon(@[@[0], @[0]]) == @[0]
assert calcCommon(@[@[0], @[0], @[1]]) == @[0]
assert calcCommon(@[@[0], @[1], @[1]]) == @[1]


func calcUncommon(bits: seq[seq[int]]): seq[int] =
    let sums = sum(bits)
    for value in sums:
        if value == 0:
            result.add(0)
        elif value == bits.len:
            result.add(1)
        elif value >= ((bits.len + 1) div 2):
            result.add(0)
        else:
            result.add(1)


assert calcUncommon(@[@[0, 1]]) == @[0, 1]
assert calcUncommon(@[@[0], @[1]]) == @[0]
assert calcUncommon(@[@[0], @[0]]) == @[0]
assert calcUncommon(@[@[0], @[0], @[1]]) == @[1]
assert calcUncommon(@[@[0], @[1], @[1]]) == @[0]


func filterBitCriteria(bits: seq[seq[int]], fun: (seq[seq[int]] -> seq[int])): seq[int] =
    var filtered = bits
    for i in 0..11:
        let criteria = fun(filtered)
        filtered = filter(filtered, (x) => x[i] == criteria[i])
        #debugEcho(i, criteria)
        #debugEcho(filtered)
        if filtered.len == 1:
            break

    if filtered.len != 1:
        return @[]

    return filtered[0]


assert filterBitCriteria(@[@[0], @[1]], calcCommon) == @[1]
assert filterBitCriteria(@[@[1], @[0]], calcCommon) == @[1]
assert filterBitCriteria(@[@[0], @[1]], calcUncommon) == @[0]
assert filterBitCriteria(@[@[1], @[0]], calcUncommon) == @[0]
assert filterBitCriteria(@[@[1, 1], @[1, 0]], calcCommon) == @[1, 1]
assert filterBitCriteria(@[@[1, 1], @[1, 0]], calcUncommon) == @[1, 0]


proc solution(path: string): int =
    let lines = readToSec(path)
    let bits = map(lines, lineToBits)

    let gamma = seqToInt(calcCommon(bits))
    let epsilon = seqToInt(calcUncommon(bits))

    echo("Power: ", gamma * epsilon)

    let o2rating = seqToInt(filterBitCriteria(bits, calcCommon))
    let co2rating = seqToInt(filterBitCriteria(bits, calcUncommon))

    echo("Life support rating: ", o2rating * co2rating)


#echo(solution("input/3example"))
echo(solution("input/3"))
