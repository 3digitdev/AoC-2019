import strutils
import sequtils
import strformat
import math
import sugar

# --- HELPER FUNCTIONS --- #
proc readMultiLineInput*(day: string): seq[string] =
    return readFile(&"../inputs/{day}.txt").split('\n').filterIt(it != "")

proc readCommaSepInput*(day: string): seq[string] =
    return readFile(&"../inputs/{day}.txt").split('\n')[0].split(',')
# ------------------------ #

# --- DAY ONE --- #
proc fuelUntilZero*(mass: int): int =
    var nextFuel = mass.floorDiv(3) - 2
    while nextFuel > 0:
        result += nextFuel
        nextFuel = nextFuel.floorDiv(3) - 2

proc dayOne*(): int =
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

proc partOne(inputs: seq[int]): int =
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

if isMainModule:
    # echo dayOne()
    dayTwo()
