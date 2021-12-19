import std/strutils
import std/streams
import std/sequtils
#import std/logging
import std/strformat
import std/parseutils
import std/options
import sugar


type
    NodeKind = enum nkPair, nkValue
    Node = ref object
        case kind: NodeKind
        of nkPair: a, b: Node
        of nkValue: v: int


func `$`(node: Node): string =
    if node.kind == nkPair:
        return fmt"[{node.a},{node.b}]"
    else:
        return fmt"{node.v}"


func P(a: Node, b: Node): Node = Node(kind: nkPair, a: a, b: b)
func P(a: int): Node = Node(kind: nkValue, v: a)
func P(a: int, b: int): Node = P(P(a), P(b))
func P(a: Node, b: int): Node = P(a, P(b))
func P(a: int, b: Node): Node = P(P(a), b)


proc P(stream: Stream): Node =
    if stream.peekStr(1) == "[":
        assert stream.readStr(1) == "["
        var a = P(stream)
        assert stream.readStr(1) == ","
        var b = P(stream)
        assert stream.readStr(1) == "]"
        return P(a, b)
    else:
        let numLength = stream.peekStr(10).find({',', ']'})
        let numberStr = stream.readStr(numLength)
        return P(parseInt(numberStr))


proc P(str: string): Node = 
    var stream = newStringStream(str)
    defer: stream.close()
    return P(stream)


func `==`(left: Node, right: Node): bool =
    #debugEcho(fmt"{left} == {right}")

    if left.kind != right.kind:
        return false
    elif left.kind == nkPair:
        return left.a == right.a and left.b == right.b
    else:
        return left.v == right.v


iterator items(root: Node): Node =
    var stack = @[root]
    while stack.len > 0:
        let node = stack.pop()
        yield node
        if node.kind == nkPair:
            stack.add(node.b)
            stack.add(node.a)


func depths(pair: Node, depth: int = 0): seq[int] =
    if pair.kind == nkPair:
        result.add(depths(pair.a, depth + 1))
        result.add(depths(pair.b, depth + 1))
    else:
        result = @[depth]


func values(pair: Node): seq[Node] =
    if pair.kind == nkPair:
        result.add(values(pair.a))
        result.add(values(pair.b))
    else:
        result = @[pair]


func replace(orig: Node, target: Node, replacement: Node): Node =
    result = deepCopy(orig)

    for node in result.items():
        if node.kind == nkPair:
            if node.a == target:
                node.a = replacement
                break
            if node.b == target:
                node.b = replacement
                break


func explode(orig: Node, left: int): Node =
    result = deepCopy(orig)
    let right = left + 1
    let values = result.values()

    # Sperad value to neighbors.
    if left - 1 >= values.low:
        values[left - 1].v += values[left].v
    if right + 1 <= values.high:
        values[right + 1].v += values[right].v
    
    # Find parent of exploding pair and replace exploding pair with zero.
    values[left].v = -1
    values[right].v = -1
    result = result.replace(P(-1, -1), P(0))


func explode(orig: Node): Node =
    let depths = orig.depths()
    let values = orig.values()
    for i in depths.low .. depths.high:
        if depths[i] == 5:
            assert values[i].kind == nkValue
            assert values[i+1].kind == nkValue
            return explode(orig, i)

    return orig


func splitValue(node: Node): Node =
    assert node.kind == nkValue
    assert node.v >= 10
    return P(node.v div 2, (node.v + 1) div 2)


func split(orig: Node): Node =
    result = deepCopy(orig)

    for node in result.items():
        if node.kind == nkPair:
            if node.a.kind == nkValue and node.a.v >= 10:
                node.a = node.a.splitValue()
                return result
            if node.b.kind == nkValue and node.b.v >= 10:
                node.b = node.b.splitValue()
                return result


func reduce(orig: Node): Node =
    # - If any pair is nested inside four pairs, the leftmost such pair explodes.
    # - If any regular number is 10 or greater, the leftmost such regular number splits.
    # - During reduction, at most one action applies, after which the process returns to
    #   the top of the list of actions.
    result = deepCopy(orig)
    debugEcho fmt"reduce  {result}"
    while true:
        let afterExplode = explode(result)
        if afterExplode != result:
            result = afterExplode
            debugEcho fmt"explode {result}"
            continue
        
        let afterSplit = split(result)
        if afterSplit != result:
            result = afterSplit
            debugEcho fmt"split   {result}"
            continue
        else:
            break


func `+`(left: Node, right: Node): Node =
    return reduce(P(left, right))


func magnitude(node: Node): int =
    if node.kind == nkPair:
        return 3 * magnitude(node.a) + 2 * magnitude(node.b)
    else:
        return node.v


proc addLines(path: string): Node =
    return lines("example/18example1").toSeq().mapIt(P(it)).foldl(a + b)


when isMainModule:
    import std/unittest
    suite "Day17":
        test "parseInput":
            check P("[[9,8],7]") == P(P(9, 8), 7)

        test "items":
            check P("[[1,2],3]").items().toSeq() == @[P(P(1, 2), 3), P(1, 2), P(1), P(2), P(3)]

        test "explode":
            check explode(P("[[[[[9,8],1],2],3],4]")) == P("[[[[0,9],2],3],4]")
            check explode(P("[7,[6,[5,[4,[3,2]]]]]")) == P("[7,[6,[5,[7,0]]]]")
            check explode(P("[[6,[5,[4,[3,2]]]],1]")) == P("[[6,[5,[7,0]]],3]")
            check explode(P("[[3,[2,[1,[7,3]]]],[6,[5,[4,[3,2]]]]]")) == P("[[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]]")
            check explode(P("[[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]]")) == P("[[3,[2,[8,0]]],[9,[5,[7,0]]]]")

        test "splitValue":
            check splitValue(P(10)) == P(5, 5)
            check splitValue(P(11)) == P(5, 6)
            check splitValue(P(12)) == P(6, 6)

        test "split":
            check split(P("[[[[0,7],4],[15,[0,13]]],[1,1]]")) == P("[[[[0,7],4],[[7,8],[0,13]]],[1,1]]")
            check split(P("[[[[0,7],4],[[7,8],[0,13]]],[1,1]]")) == P("[[[[0,7],4],[[7,8],[0,[6,7]]]],[1,1]]")

        test "reduce":
            check reduce(P("[[[[[4,3],4],4],[7,[[8,4],9]]],[1,1]]")) == P("[[[[0,7],4],[[7,8],[6,0]]],[8,1]]")

        test "add":
            check (1..4).mapIt(P(it, it)).foldl(a + b) == P("[[[[1,1],[2,2]],[3,3]],[4,4]]")
            check (1..5).mapIt(P(it, it)).foldl(a + b) == P("[[[[3,0],[5,3]],[4,4]],[5,5]]")
            check (1..6).mapIt(P(it, it)).foldl(a + b) == P("[[[[5,0],[7,4]],[5,5]],[6,6]]")


        test "magnitude":
            check magnitude(P("[9,1]")) == 29
            check magnitude(P("[[9,1],[1,9]]")) == 129
            check magnitude(P("[[[[0,7],4],[[7,8],[6,0]]],[8,1]]")) == 1384

        test "example 1":
            #check addLines("example/18example1") == P("[[[[8,7],[7,7]],[[8,6],[7,7]]],[[[0,7],[6,6]],[8,7]]]")
            #check addLines("example/18example2") == P("[[[[6,6],[7,6]],[[7,7],[7,0]]],[[[7,7],[7,7]],[[7,8],[9,9]]]]")

            let l0 = P("[[[0,[4,5]],[0,0]],[[[4,5],[2,6]],[9,5]]]")
            let l1 = P("[7,[[[3,7],[4,3]],[[6,3],[8,8]]]]")
            let r1 = P("[[[[4,0],[5,4]],[[7,7],[6,0]]],[[8,[7,7]],[[7,9],[5,0]]]]")

            let l2 = P("[[2,[[0,8],[3,4]]],[[[6,7],1],[7,[1,6]]]]")
            let r2 = P("[[[[6,7],[6,7]],[[7,7],[0,7]]],[[[8,7],[7,7]],[[8,8],[8,0]]]]")

            let l3 = P("[[[[2,4],7],[6,[0,5]]],[[[6,8],[2,8]],[[2,1],[4,5]]]]")
            let r3 = P("[[[[7,0],[7,7]],[[7,7],[7,8]]],[[[7,7],[8,8]],[[7,7],[8,7]]]]")

            let l4 = P("[7,[5,[[3,8],[1,4]]]]")
            let r4 = P("[[[[7,7],[7,8]],[[9,5],[8,7]]],[[[6,8],[0,8]],[[9,9],[9,0]]]]")
            #           [[[[7,7],[7,8]],[[9,5],[8,7]]],[[[7,8],[0,8]],[[8,9],[9,0]]]]

            let l5 = P("[[2,[2,2]],[8,[8,1]]]")
            let r5 = P("[[[[6,6],[6,6]],[[6,0],[6,7]]],[[[7,7],[8,9]],[8,[8,1]]]]")

            let l6 = P("[2,9]")
            let r6 = P("[[[[6,6],[7,7]],[[0,7],[7,7]]],[[[5,5],[5,6]],9]]")

            let l7 = P("[1,[[[9,3],9],[[9,0],[0,7]]]]")
            let r7 = P("[[[[7,8],[6,7]],[[6,8],[0,8]]],[[[7,7],[5,0]],[[5,5],[5,6]]]]")
            #           [[[[7,8],[6,7]],[[7,8],[0,8]]],[[9,[7,7]],[[5,0],[5,6]]]]

            let l8 = P("[[[5,[7,4]],7],1]")
            let r8 = P("[[[[7,7],[7,7]],[[8,7],[8,7]]],[[[7,0],[7,7]],9]]")
            #           [[[[7,7],[7,7]],[[8,7],[8,7]]],[[[7,0],[8,7]],8]]

            let l9 = P("[[[[4,2],2],6],[8,7]]")
            let r9 = P("[[[[8,7],[7,7]],[[8,6],[7,7]]],[[[0,7],[6,6]],[8,7]]]")
            #           [[[[8,7],[7,7]],[[8,7],[7,6]]],[[[0,7],[6,6]],[8,7]]]

            #check l0 + l1 == r1
            #check r1 + l2 == r2
            #check r2 + l3 == r3
            #check r3 + l4 == r4 #fail
            #check r4 + l5 == r5
            #check r5 + l6 == r6
            #check r6 + l7 == r7 #fail
            check r7 + l8 == r8 #fail
            #check r8 + l9 == r9 #fail
