import std/strutils

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

echo(countIncreasing())
