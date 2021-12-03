import std/sequtils


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


func commonBit(sums: seq[int], length: int): seq[int] =
    for value in sums:
        if value > (length div 2):
            result.add(1)
        else:
            result.add(0)


func seqToInt(bits: seq[int]): int =
    result = 0
    for bit in bits:
        result = result * 2 + bit


func invert(bits: seq[int]): seq[int] =
    for bit in bits:
        result.add(1 - bit)


assert lineToBits("1011101") == [1, 0, 1, 1, 1, 0, 1]
assert sum(@[@[1,1], @[1,0]]) == @[2,1]
assert commonBit(@[1, 2, 3, 4, 5, 6], 6) == @[0, 0, 0, 1, 1, 1]
assert invert(@[0, 1, 0, 1]) == @[1, 0, 1, 0]
assert seqToInt(@[0, 1, 0, 1]) == 5


let lines = readToSec("input/3")
let bits = map(lines, lineToBits)
let sums = sum(bits)
let common = commonBit(sums, bits.len)

let gamma = seqToInt(common)
let epsilon = seqToInt(invert(common))

echo("Power: ", gamma * epsilon)
