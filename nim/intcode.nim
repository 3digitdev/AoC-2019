import sequtils
import strutils
import strformat
import re
import tables
import algorithm
import rdstdin

type
    Parameter = object
        mode: int
        value: int
    Instruction = object
        op: string
        params: seq[Parameter]

const OPS = {
    "01": "ADD",
    "02": "MULT",
    "03": "INPUT",
    "04": "OUTPUT",
    "05": "JUMP-IF-TRUE",
    "06": "JUMP-IF-FALSE",
    "07": "LESS-THAN",
    "08": "EQUALS",
    "99": "HALT"
}.toTable
const PARAM_COUNT = {
    "01": 3, # Add
    "02": 3, # Multiply
    "03": 1, # Input
    "04": 1, # Output
    "05": 2, # Jump-if-true
    "06": 2, # Jump-if-false
    "07": 3, # Less-than
    "08": 3, # Equls
    "99": 0, # Halt
}.toTable

proc buildInstruction*(program: seq[string], curPos: int): Instruction =
    var paramList: seq[Parameter]
    var opStr = program[curPos]
    if opStr =~ re"^\d$":
        opStr = &"0{opStr}"
    if opStr =~ re"([01]+)?([\d]{2})":
        let code = matches[1]
        let pCount = PARAM_COUNT[code]
        let params = alignString(matches[0], pCount, '>', '0')
        for i in 0..<pCount:
            paramList.add(Parameter(
                mode: ($params[i]).parseInt,
                value: ($program[curPos + (pCount - i)]).parseInt
            ))
        result = Instruction(op: OPS[code], params: paramList.reversed)
    # NOTE: Add (curPos + Instruction.opcode.params) when you get return value

proc `$`*(p: Parameter): string =
    result = &"[mode: {p.mode}, value: {p.value}]"

proc `$`*(i: Instruction): string =
    result = &"Instruction:\n  Op: {i.op}\n  Params:\n    {i.params}"

proc run*(instruction: Instruction, program: var seq[string], curPos: var int): int =
    var opParts: seq[int]
    for i in 0..<instruction.params.len:
        var param = instruction.params[i]
        case param.mode
            of 0: opParts.add(program[param.value].parseInt)
            of 1: opParts.add(param.value)
            else: opParts.add(0) # should never happen
    case instruction.op
        of "ADD":
            program[instruction.params[2].value] = $(opParts[0] + opParts[1])
        of "MULT":
            program[instruction.params[2].value] = $(opParts[0] * opParts[1])
        of "INPUT":
            program[instruction.params[0].value] = readLineFromStdin "[INPUT]: "
        of "OUTPUT":
            var output: int
            if instruction.params[0].mode == 1:
                output = instruction.params[0].value
            else:
                output = program[instruction.params[0].value].parseInt
            echo &"[OUTPUT]: {output}"
        of "JUMP-IF-TRUE":
            if opParts[0] != 0:
                curPos = opParts[1]
                return 0
        of "JUMP-IF-FALSE":
            if opParts[0] == 0:
                curPos = opParts[1]
                return 0
        of "LESS-THAN":
            if opParts[0] < opParts[1]:
                program[instruction.params[2].value] = "1"
            else:
                program[instruction.params[2].value] = "0"
        of "EQUALS":
            if opParts[0] == opParts[1]:
                program[instruction.params[2].value] = "1"
            else:
                program[instruction.params[2].value] = "0"
        of "HALT":
            result = -1
    curPos += instruction.params.len + 1

proc execute*(program: var seq[string]) =
    var curPos = 0
    while curPos < program.len:
        var inst = buildInstruction(program, curPos)
        # echo inst
        var code = inst.run(program, curPos)
        if code < 0: # halting
            break
        # echo curPos
        # echo program

if isMainModule:
    var program = "".split(',')
    program.execute()
    # echo program
