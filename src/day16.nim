import std/strutils
import std/streams
import std/tables
import std/sets
import std/times
import std/sequtils
import std/algorithm
import std/bitops


type Packet = object
    version: int
    typeId: int
    bits: int
    value: int


# Convert hex string to binary string.
func bitsToBinstr(binstr: string): string =
    for c in binstr:
        for i in [7, 6, 5, 4, 3, 2, 1, 0]:
            let bit = ord(c).bitsliced(i..i)
            result = result & (if bit == 0: '0' else: '1')


# Convert hex string to stringstream of bits.
func hexstrToStream(hexstr: string): Stream =
    let rendered = hexstr.parseHexStr().bitsToBinstr()
    return newStringStream(rendered)


# Convert binary string to int.
func binstrToInt(rendered: string): int =
    assert rendered.len <= 64
    for c in rendered:
        let value = if c == '0': 0 else: 1
        result = (result shl 1) + value


# Read N bits from stream and return as int.
proc readBitstrInt(stream: Stream, bits: int): int =
    return stream.readStr(bits).binstrToInt()


proc readPacket(stream: Stream): Packet =
    result.version = stream.readBitstrInt(3)
    result.typeId = stream.readBitstrInt(3)
    result.bits = 6

    if result.typeId == 4:
        var lastPacket = false
        var value = 0
        while not lastPacket:
            let group = stream.readStr(5)
            result.bits += 5
            lastPacket = group[0] == '0'
            value = (value shl 4) + binstrToInt(group[1..4])
        result.value = value
    else:
        let lengthTypeId = stream.readBitstrInt(1)
        result.bits += 1
        
        if lengthTypeId == 0:
            debugEcho("Parsing 15")
            let bitsToRead = stream.readBitstrInt(15)
            result.bits += 15
            var bitsRead = 0
            while bitsRead < bitsToRead:
                let packet = readPacket(stream)
                bitsRead += packet.bits
                result.version += packet.version
            result.bits += bitsRead
        else:
            let packetsToRead = stream.readBitstrInt(11)
            result.bits += 11
            var backetsRead = 0
            while backetsRead < packetsToRead:
                let packet = readPacket(stream)
                backetsRead += 1
                result.version += packet.version
                result.bits += packet.bits

    debugEcho(result)
 

when isMainModule:
    import std/unittest
    suite "Day16":
        test "bitsToBinstr":
            check binstrToInt("011111100101") == 2021

        test "parseLiteral":
            check readPacket(hexstrToStream("D2FE28")) == Packet(version: 6, typeId: 4, bits: 21, value: 2021)

        test "parseOperator0":
            check readPacket(hexstrToStream("38006F45291200")) == Packet(version: 9, typeId: 6, bits: 49, value: 0)

        test "parseOperator1":
            check readPacket(hexstrToStream("EE00D40C823060")) == Packet(version: 14, typeId: 3, bits: 51, value: 0)
        
        test "solution 1":
            check readPacket(hexstrToStream(readLines("input/16")[0])).version == 934
