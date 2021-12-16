import std/strutils
import std/streams
import std/tables
import std/sets
import std/times
import std/sequtils
import std/algorithm
import std/bitops


type
    TypeId = enum
        sum = 0, product = 1, minimum = 2, maximum = 3,
        literal = 4, greaterThan = 5, lessThan = 6, equalTo = 7
    Packet = object
        version: int
        typeId: TypeId
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


func calcValue(typeId: TypeId, packets: seq[Packet]): int =
    let values = packets.mapIt(it.value)
    #debugEcho "calcValue: ", typeId, ", ", values
    
    return case typeId:
        of TypeId.sum:
            values.foldl(a + b)
        of TypeId.product:
            values.foldl(a * b, 1)
        of TypeId.minimum:
            values.foldl(min(a, b), int.high)
        of TypeId.maximum:
            values.foldl(max(a, b), int.low)
        of TypeId.literal:
            assert false
            0
        of TypeId.greaterThan:
            assert values.len == 2
            if values[0] > values[1]: 1 else: 0
        of TypeId.lessThan:
            assert values.len == 2
            if values[0] < values[1]: 1 else: 0
        of TypeId.equalTo:
            assert values.len == 2
            if values[0] == values[1]: 1 else: 0


proc readPacket(stream: Stream): Packet =
    result.version = stream.readBitstrInt(3)
    result.typeId = TypeId(stream.readBitstrInt(3))
    result.bits = 6

    if result.typeId == TypeId.literal:
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
        
        var packets: seq[Packet]

        if lengthTypeId == 0:
            let bitsToRead = stream.readBitstrInt(15)
            result.bits += 15
            var bitsRead = 0
            while bitsRead < bitsToRead:
                let packet = readPacket(stream)
                bitsRead += packet.bits
                result.version += packet.version
                packets.add(packet)
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
                packets.add(packet)

        result.value = calcValue(result.typeId, packets)

    #debugEcho(result)
 

when isMainModule:
    import std/unittest
    suite "Day16":
        test "bitsToBinstr":
            check binstrToInt("011111100101") == 2021

        test "Example parse literal":
            check readPacket(hexstrToStream("D2FE28")) == Packet(version: 6, typeId: TypeId.literal, bits: 21, value: 2021)

        test "Example parse operator typeId 0":
            check readPacket(hexstrToStream("38006F45291200")) == Packet(version: 9, typeId: TypeId.lessThan, bits: 49, value: 1)

        test "Example parse operator typeId 1":
            check readPacket(hexstrToStream("EE00D40C823060")) == Packet(version: 14, typeId: TypeId.maximum, bits: 51, value: 3)
        
        test "Example sum":
            check readPacket(hexstrToStream("C200B40A82")).value == 3
        
        test "Example product":
            check readPacket(hexstrToStream("04005AC33890")).value == 54
        
        test "Example minimum":
            check readPacket(hexstrToStream("880086C3E88112")).value == 7
        
        test "Example maximum":
            check readPacket(hexstrToStream("CE00C43D881120")).value == 9
        
        test "Example lessThan":
            check readPacket(hexstrToStream("D8005AC2A8F0")).value == 1
        
        test "Example greaterThan":
            check readPacket(hexstrToStream("F600BC2D8F")).value == 0
        
        test "Example equalTo":
            check readPacket(hexstrToStream("9C005AC2F8F0")).value == 0
        
        test "Example function":
            check readPacket(hexstrToStream("9C0141080250320F1802104A08")).value == 1

        test "solution 1":
            check readPacket(hexstrToStream(readLines("input/16")[0])).version == 934

        test "solution 2":
            check readPacket(hexstrToStream(readLines("input/16")[0])).value == 912901337844
