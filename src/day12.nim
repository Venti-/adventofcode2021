import std/strutils
import std/streams
import std/tables
import std/sets
import std/times
import sugar
import std/macros


macro toItr(x: ForLoopStmt): untyped =
  let expr = x[0]
  let call = x[1][1] # Get foo out of toItr(foo)
  let body = x[2]
  result = quote do:
    block:
      let itr = `call`
      for `expr` in itr():
          `body`


type
    Nodes = HashSet[string]
    Edges = TableRef[string, Nodes]


proc readInput(stream: Stream): Edges =
    defer: stream.close()
    result = newTable[string, Nodes]()
    for line in stream.lines:
        let parts = line.split("-")
        let (a, b) = (parts[0], parts[1])
        if b != "start" and a != "end":
            result.mgetOrPut(a, initHashSet[string]()).incl(b)
        if a != "start" and b != "end":
            result.mgetOrPut(b, initHashSet[string]()).incl(a)
    result["end"] = initHashSet[string]()


func isUpperCase(node: string): bool = node.toUpper == node


# start,b,A,c,A,c,A,end
func findEnd(edges: Edges, node: string, visitLimit: int, visited: CountTable[string]): iterator(): seq[string] =
    return iterator (): seq[string] =
        if node == "end":
            yield @[node]
        for neighbor in edges[node]:
            if node in visited:
                if visited.largest[1] == visitLimit:
                    continue

            var visited2: CountTable[string] = visited
            if not node.isUpperCase:
                visited2.inc(node)
            for route in toItr(findEnd(edges, neighbor, visitLimit, visited2)):
                yield @[node] & route


iterator iterRoutes(edges: Edges, visitLimit: int): seq[string] =
    var visited: CountTable[string]
    for route in toItr(findEnd(edges, "start", visitLimit, visited)):
        yield route


template benchmark(code: untyped) =
    block:
        let cpu = cpuTime()
        code
        echo("cpuTime: ", cpuTime() - cpu)


when isMainModule:
    import std/unittest
    suite "Day12":
        test "readInput":
            let edges = readInput(newStringStream("start-A\nA-b\nA-end\n"))
            let expected: Edges = {
                        "start": ["A"].toHashSet,
                        "A": ["b", "end"].toHashSet,
                        "b": ["A"].toHashSet,
                        "end": initHashSet[string](),
                    }.newTable()
            check edges == expected

        test "example 1":
            let edges = readInput(newFileStream("example/12example"))
            let routes = collect:
                for route in iterRoutes(edges, 1): route
            check routes.len == 10

        test "example 2":
            let edges = readInput(newFileStream("example/12example"))
            let routes = collect:
                for route in iterRoutes(edges, 2): route
            check routes.len == 36
        
        test "solution 1":
            let edges = readInput(newFileStream("input/12"))
            benchmark:
                let routes = collect:
                    for route in iterRoutes(edges, 1): route
                check routes.len == 4304

        test "solution 2":
            let edges = readInput(newFileStream("input/12"))
            benchmark:
                let routes = collect:
                    for route in iterRoutes(edges, 2): route
                check routes.len == 118242
