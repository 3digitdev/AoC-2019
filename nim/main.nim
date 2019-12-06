import strutils
import sequtils
import strformat
import math
import sugar
import re
import tables
import hashes

# --- HELPER FUNCTIONS --- #
proc readMultiLineInput(day: string): seq[string] =
    return readFile(&"../inputs/{day}.txt").split('\n').filterIt(it != "")

proc readCommaSepInput(day: string): seq[string] =
    return readFile(&"../inputs/{day}.txt").split('\n')[0].split(',')
# ------------------------ #

# --- DAY ONE --- #
proc fuelUntilZero(mass: int): int =
    var nextFuel = mass.floorDiv(3) - 2
    while nextFuel > 0:
        result += nextFuel
        nextFuel = nextFuel.floorDiv(3) - 2

proc dayOne(): int =
    let inputs = readMultiLineInput("day1")
    return inputs.mapIt(it.parseInt.fuelUntilZero).sum
# --------------- #

# --- DAY TWO --- #
proc opcode(i: int, inputs: seq[int], op: proc (a, b: int): int): seq[int] =
    result = inputs
    result[result[i+3]] = op(result[result[i+1]], result[result[i+2]])

proc executeIntcode(inputs: var seq[int], noun, verb: int): int =
    inputs[1] = noun
    inputs[2] = verb
    for i in countup(0, inputs.len, 4):
        case inputs[i]:
            of 1:
                inputs = opcode(i, inputs, (x, y) => x + y)
            of 2:
                inputs = opcode(i, inputs, (x, y) => x * y)
            of 99:
                break
            else:
                echo &"oh shit"
    return inputs[0]

proc partOne(inputs: var seq[int]): int =
    executeIntcode(inputs, 12, 2)

proc partTwo(original: seq[int]): int =
    for noun in 0..99:
        for verb in 0..99:
            var inputs = original
            if executeIntcode(inputs, noun, verb) == 19690720:
                return 100 * noun + verb

proc dayTwo() =
    var inputs = readCommaSepInput("day2").map(parseInt)
    echo partOne(inputs)
    echo partTwo(inputs)
# --------------- #

# --- DAY THREE --- #
type
    Coords* = tuple
        x, y: int
    Line* = tuple
        start, stop: Coords

proc hash(c: Coords): Hash =
    result = c.x.hash !& c.y.hash
    result = !$result

proc isVertical(line: Line): bool = line.start.x == line.stop.x

proc isHorizontal(line: Line): bool = line.start.y == line.stop.y

proc isBetween(check, start, stop: int): bool =
    check >= min(start, stop) and check <= max(start, stop)

proc crosses(vline, hline: Line): bool =
    vline.start.x.isBetween(hline.start.x, hline.stop.x) and
    hline.start.y.isBetween(vline.start.y, vline.stop.y)

proc buildLines(directions: string): seq[Line] =
    var start, stop: Coords
    result = @[]
    # assume "center" is 0,0
    var x, y = 0
    for dir in directions.split(','):
        if dir =~ re"([UDLR])(\d+)":
            let dist = matches[1].parseInt
            start = (x: x, y: y)
            case matches[0]:
                of "U": y += dist
                of "D": y -= dist
                of "L": x -= dist
                else: x += dist
            stop = (x: x, y: y)
            result.add((start: start, stop: stop))

proc taxicabDistance(point: Coords): int =
    abs(point.x) + abs(point.y)

proc calcSteps(lines: seq[Line], intersects: seq[Coords]): Table[Coords, int] =
    result = initTable[Coords, int]()
    var curX, curY, steps = 0
    for line in lines:
        if line.isVertical:
            for y in line.start.y..line.stop.y:
                let coord = (x: line.start.x, y: y)
                if intersects.contains(coord):
                    result[coord] = steps
                steps += 1
        else:
            for x in line.start.x..line.stop.x:
                let coord = (x: x, y: line.start.y)
                if intersects.contains(coord):
                    result[coord] = steps
                steps += 1

proc partTwo(wireOneLines, wireTwoLines: seq[Line], intersects: seq[Coords]): int =
    let w1steps = wireOneLines.calcSteps(intersects)
    let w2steps = wireTwoLines.calcSteps(intersects)

proc dayThree() =
    var intersections: seq[Coords]
    # let wires = readMultiLineInput("day3")
    let wires = ["R75,D30,R83,U83,L12,D49,R71,U7,L72", "U62,R66,U55,R34,D71,R55,D58,R83"] # 159, 610
    # let wires = ["R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51", "U98,R91,D20,R16,D67,R40,U7,R15,U6,R7"] # 135, 410
    let wireOneLines = buildLines(wires[0])
    let wireTwoLines = buildLines(wires[1])
    for lineOne in wireOneLines:
        for lineTwo in wireTwoLines:
            if lineOne.isVertical and lineTwo.isHorizontal:
                if lineOne.crosses(lineTwo):
                    intersections.add((x: lineOne.start.x, y: lineTwo.start.y))
            elif lineOne.isHorizontal and lineTwo.isVertical:
                if lineTwo.crosses(lineOne):
                    intersections.add((x: lineTwo.start.x, y: lineOne.start.y))
            else: continue
    intersections.delete(0,0)
    echo intersections
    var closest = high(int)
    for cross in intersections:
        closest = min(taxicabDistance(cross), closest)
    echo &"Part 1:  {closest}"
    echo &"Part 2:  {partTwo(wireOneLines, wireTwoLines, intersections)}"

# ----------------- #

# --- DAY FOUR --- #
proc hasOneRepeat(num: int): bool =
    let check = toSeq(($num).items)
    return check.deduplicate.len < check.len

proc doesNotDecrease(num: int): bool =
    let nums = toSeq(($num).items).mapIt(($it).parseInt)
    result = true
    var last = nums[0]
    for num in nums:
        if num < last:
            return false
        last = num

proc hasTwopeat(num: int): bool =
    var table: CountTable[char]
    let check = toSeq(($num).items)
    table = check.toCountTable
    for v in table.values:
        if v == 2:
            return true

proc dayFour() =
    var total = 0
    var partOne, partTwo: seq[int]
    partOne = @[]
    partTwo = @[]
    for num in 168630..718098:
        if num.hasOneRepeat and num.doesNotDecrease:
            partOne.add(num)
    echo &"Part One: {partOne.len}"
    for num in partOne:
        if num.hasTwopeat:
            partTwo.add(num)
    echo &"Part Two: {partTwo.len}"
# ---------------- #

if isMainModule:
    # echo dayOne()
    # dayTwo()
    # dayThree()
    dayFour()
