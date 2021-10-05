import lsystempkg/raylib, lsystempkg/raygui
import math, os
import algorithm, heapqueue, random, options, sequtils, sugar, tables, system

# Seed RNG with current time
randomize()

type Term = enum LeafTerm, LineTerm, GoLeft, GoRight, PushTerm, PopTerm
type Terms = seq[Term]

iterator rewrite(terms: Terms) : Terms =
  var currentTerms: Terms = terms
  var newTerms: Terms
  
  while true:
    # Reset this each iteration to gather new expansions
    newTerms = @[]
    for term in currentTerms:
      case term:
        of LeafTerm: newTerms &= @[LineTerm, LineTerm, PushTerm, GoRight, LeafTerm, PopTerm, GoLeft, LeafTerm]
        else: newTerms &= @[term]
    currentTerms = newTerms
    yield currentTerms
    
type StackControl = enum Push, Pop

# An intruction along with a change in angle and magnitude (i.e. a vector)
type DrawInstruction = object
  angle_change: float64
  magnitude: float64

type 
  InstructionKind = enum pkDraw, pkStack
  Instruction = object
    case kind: InstructionKind
      of pkDraw: drawInstruction: DrawInstruction
      of pkStack: stackInstruction: StackControl

proc `$` (i: Instruction): string =
  case i.kind:
    of pkDraw: return "angle_change = " & $i.drawInstruction.angle_change & ", magnitude = " & $i.drawInstruction.magnitude
    of pkStack: return "direction = " & $i.stackInstruction

iterator axiomToInstructions(maxIterations: int) : Instruction =
  let axiom = @[LeafTerm]
  var n = 0
  var termsToConvert: Terms
  for terms in rewrite(axiom):
    n += 1
    if n == maxIterations:
      termsToConvert = terms
      break

  var magnitudes: seq[float64] = @[18.float64, 34.float64, 50.float64]
  let magnitude_weights = [3, 6, 1]
  let magnitude_cdf = math.cumsummed(magnitude_weights)

  let angles: seq[float64] = @[10 * 1.618, 20 * 1.618, 30 * 1.618]
  let angle_weights = [3, 5, 2]
  let angle_cdf = math.cumsummed(angle_weights)

  var angle_delta: float64
  var magnitude: float64
  # every time you encounter a push divide, and a pop multiply
  # type Term = enum LeafTerm, LineTerm, GoLeft, GoRight, PushTerm, PopTerm

  # axiom
  yield Instruction(kind: pkDraw, drawInstruction: DrawInstruction(angle_change: 180, magnitude: 180))
  for term in termsToConvert:
    angle_delta = sample(angles, angle_cdf)
    magnitude = sample(magnitudes, magnitude_cdf)
    case term:
      of LeafTerm:
        magnitude = magnitude / 1.5
        yield Instruction(kind: pkDraw, drawInstruction: DrawInstruction(angle_change: angle_delta, magnitude: magnitude))
        yield Instruction(kind: pkDraw, drawInstruction: DrawInstruction(angle_change: 0, magnitude: -magnitude)) # hack
        yield Instruction(kind: pkDraw, drawInstruction: DrawInstruction(angle_change: -(angle_delta*2), magnitude: magnitude))
      of LineTerm:
        yield Instruction(kind: pkDraw, drawInstruction: DrawInstruction(angle_change: 0, magnitude: magnitude)) # don't change direction
      of GoLeft:
        yield Instruction(kind: pkDraw, drawInstruction: DrawInstruction(angle_change: angle_delta, magnitude: magnitude)) # change direction to left 45 degrees
      of GoRight:
        yield Instruction(kind: pkDraw, drawInstruction: DrawInstruction(angle_change: -angle_delta, magnitude: magnitude)) # change direction to right 45 degrees
      of PushTerm:
        yield Instruction(kind: pkStack, stackInstruction: Push)
      of PopTerm:
        magnitude = magnitude * 1.5
        yield Instruction(kind: pkStack, stackInstruction: Pop)

# A Position along with its angle
type Position = object
  x: float64
  y: float64
  angle: float64

proc `$` (p: Position): string =
  return "x = " & $p.x & ", " & "y = " & $p.y & ", " & "angle = " & $p.angle

# Line (along with the angle relative to origin
type DrawLine = object
  start_pos: Vector2
  end_pos: Vector2
  angle: float64

proc `$` (d: DrawLine): string =
  return "start_pos = " & $d.start_pos & ", " & "end_pos = " & $d.end_pos

proc calculateNextLine(inst: DrawInstruction, pos: Position) : DrawLine =
  # Change the angle
  let new_angle = inst.angle_change + pos.angle

  # Use the same magnitude as before
  let magnitude = inst.magnitude

  # Convert from polar coordinates to cartesian
  let new_x = -(magnitude * cos(degToRad(new_angle)))
  let new_y = magnitude * sin(degToRad(new_angle))

  result.start_pos = Vector2(x: pos.x, y: pos.y)

  # Ending position is relative to the starting position, so add the coordinates
  result.end_pos = Vector2(x: result.start_pos.x+new_x, y: result.start_pos.y+new_y)

  result.angle = new_angle

proc executeProgram(instructions: seq[Instruction], positions: seq[Position], current_pos: Position) : seq[DrawLine] =
  # each instruction will be followed by a stack control instruction
  if instructions.len <= 0:
    echo "Returning"
    return @[]

  let inst = instructions[0]

  var nextLine: DrawLine

  case inst.kind:
    of pkStack:
      if inst.stackInstruction == Push:
        return executeProgram(instructions[1..^1], current_pos & positions, current_pos)
      elif inst.stackInstruction == Pop:
        let newCurrent = positions[0]
        return executeProgram(instructions[1..^1], positions[1..^1], newCurrent)
      else:
        return
    of pkDraw:
      nextLine = calculateNextLine(inst.drawInstruction, current_pos)
      let new_position = Position(x: nextLine.end_pos.x,
                                  y: nextLine.end_pos.y,
                                  angle: nextLine.angle)
      # leave the stack alone, set the current position however
      return @[nextLine] & executeProgram(instructions[1..^1], positions, new_position)

proc guiLoop*(instructions: seq[Instruction]) =
  # TODO get from xlib
  var screenWidth: int = 100
  var screenHeight: int = 100

  SetConfigFlags(ord(ConfigFlags.FLAG_WINDOW_UNDECORATED))

  InitWindow(screenWidth, screenHeight, "L-Systems")

  let monitor = GetCurrentMonitor()
  screenWidth = (monitor.GetMonitorWidth()).int
  screenHeight = (monitor.GetMonitorHeight()).int

  SetWindowSize(screenWidth, screenHeight)
  SetWindowTitle("L-Systems")
  MaximizeWindow()

  #GuiLoadStyle("styles/terminal/terminal.rgs")

  var mousePos = Vector2(x: 0, y: 0)
  var windowPos = Vector2(x: screenWidth.float64, y: screenHeight.float64)
  var panOffset = mousePos

  var dragWindow = false
  var exitWindow = false

  var restartButton = false

  SetTargetFPS(60)

  # "axiom"
  let startingPosition = Position(x: screenWidth/2, y: screenHeight.float64-100, angle: 90)
  let drawLines = executeProgram(instructions, @[startingPosition], startingPosition)

  while not exitWindow and not WindowShouldClose():
    BeginDrawing()

    screenWidth = (monitor.GetMonitorWidth() / 2).int
    screenHeight = (monitor.GetMonitorHeight() / 2).int
    # This must come before anything else!
    ClearBackground(BLACK)
    for line in drawLines:
      DrawLineEx(line.start_pos, line.end_pos, 3, WHITE)

    EndDrawing()
  CloseWindow()

when isMainModule:
  #guiLoop()
  guiLoop(toSeq(axiomToInstructions(7)))
