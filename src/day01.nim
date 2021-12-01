import std/strutils
import std/sequtils


proc countIncreasing() : int =
    let f = open("input/1")
    defer: f.close()

    var line: string
    var prevValue: int = parseInt(f.readLine())
    var increasingCnt = 0
    while f.readLine(line):
        let curValue = parseInt(line)
        if curValue > prevValue:
            increasingCnt += 1
        prevValue = curValue
    
    return increasingCnt


proc readToSeq(path: string): seq[int] =
    let f = open(path)
    defer: f.close()

    var
        numbers: seq[int]
        line: string
    while f.readLine(line):
        numbers.add(parseInt(line))

    return numbers


proc sum(values: seq[int]): int =
    return foldl(values, a + b, 0)


proc countIncreasingWindow(windowSize: int): int = 
    let numbers: seq[int] = readToSeq("input/1")
    let size = numbers.len

    assert windowSize <= size

    var increasingCnt = 0

    for i in 0 .. (size - windowSize - 1):
        let a = numbers[i ..< i+windowSize]
        let b = numbers[i+1 ..< i+1+windowSize]
        if sum(a) < sum(b):
            increasingCnt += 1

    return increasingCnt


assert countIncreasing() == countIncreasingWindow(1)

echo(countIncreasing())
echo(countIncreasingWindow(3))
