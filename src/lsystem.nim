import lsystempkg/raylib, lsystempkg/raygui
import math, os
import algorithm, heapqueue, random, options, sequtils, sugar, tables, system

# Seed RNG with current time
randomize()

type Term = enum LeafTerm, LineTerm, GoLeft, GoRight, PushTerm, PopTerm
type Terms = seq[Term]

proc rewrite(terms: Terms, maxIterations: int) : Terms =
  var currentTerms: Terms = terms
  var newTerms: Terms
  var n = 0
  
  while true:
    n += 1
    # Reset this each iteration to gather new expansions
    newTerms = @[]
    for term in currentTerms:
      case term:
        of LeafTerm: newTerms &= @[LineTerm, LineTerm, PushTerm, GoRight, LeafTerm, PopTerm, GoLeft, LeafTerm]
        else: newTerms &= @[term]
    currentTerms = newTerms
    if n == maxIterations:
      return currentTerms
    
type StackControl = enum Push, Pop

# An intruction along with a change in angle and magnitude (i.e. a vector)
type DrawInstruction = object
  angle_change: float64
  width: float64
  magnitude: float64
  color: Color

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

iterator axiomToInstructions(maxIterations: int, magnitude: float64, angle: float64) : Instruction =
  let axiom = @[LeafTerm]
  let termsToConvert = rewrite(axiom, maxIterations)
  var angle_delta: float64 = angle
  var magnitudes: seq[float64] = @[magnitude]
  var widths: seq[float64] = @[maxIterations.float64 + 3]
  var current_magnitude = magnitude
  var current_width: float64 = widths[0]
  # axiom
  yield Instruction(kind: pkDraw, drawInstruction: DrawInstruction(angle_change: 180, magnitude: magnitude))
  for term in termsToConvert:
    let angle_delta = angle_delta * sample(@[0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1])
    case term:
      of LeafTerm:
        # when there's a leaf we want to make the magnitude smaller
        let leaf_width = (10 * sample(@[0.50, 0.10, 0.25]))
        yield Instruction(kind: pkDraw, drawInstruction: DrawInstruction(color: DARKGREEN, width: leaf_width, angle_change: angle_delta, magnitude: magnitudes[0]))
        yield Instruction(kind: pkDraw, drawInstruction: DrawInstruction(color: DARKGREEN, width: leaf_width, angle_change: 0, magnitude: -magnitudes[0])) # hack
        yield Instruction(kind: pkDraw, drawInstruction: DrawInstruction(color: DARKGREEN, width: leaf_width, angle_change: -(angle_delta*2), magnitude: magnitudes[0]))
      of LineTerm:
        # Draw without changing direction
        yield Instruction(kind: pkDraw, drawInstruction: DrawInstruction(color: DARKBROWN, width: current_width, angle_change: 0, magnitude: magnitudes[0]))

      # L-systems don't go "backwards"
      # So you can go left or right on the x-axis at a given angle delta
      of GoLeft:
        current_magnitude = current_magnitude - (current_magnitude * sample(@[0.05, 0.01]))
        current_width = current_width - (current_width * sample(@[0.15, 0.10]))
        yield Instruction(kind: pkDraw, drawInstruction: DrawInstruction(color: DARKBROWN, width: current_width, angle_change: angle_delta, magnitude: current_magnitude))
      of GoRight:
        current_magnitude = current_magnitude - (current_magnitude * sample(@[0.05, 0.01]))
        current_width = current_width - (current_width * sample(@[0.15, 0.10]))
        yield Instruction(kind: pkDraw, drawInstruction: DrawInstruction(color: DARKBROWN, width: current_width, angle_change: -angle_delta, magnitude: current_magnitude))

      # Control the stack of saved positions
      of PushTerm:
        # Save current location
        magnitudes = @[current_magnitude] & magnitudes
        widths = @[current_width] & widths
        yield Instruction(kind: pkStack, stackInstruction: Push)
      of PopTerm:
        current_magnitude = magnitudes[0]
        current_width = widths[0]
        magnitudes = magnitudes[1..^1]
        widths = widths[1..^1]
        # Pop location stack and set current location to it
        # reset magnitude
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
  width: float64
  angle: float64
  color: Color

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
  result.width = inst.width
  result.color = inst.color
  result.angle = new_angle

proc executeProgram(instructions: seq[Instruction], starting_pos: Position) : seq[DrawLine] =
  # each instruction will be followed by a stack control instruction
  var insts = instructions
  var positions = @[starting_pos]
  var current_pos = starting_pos

  var draw_lines : seq[DrawLine] = @[]

  while insts.len > 0:
    let inst = insts[0]

    var nextLine: DrawLine

    case inst.kind:
      of pkStack:
        if inst.stackInstruction == Push:
          insts = insts[1..^1]
          positions = current_pos & positions
        elif inst.stackInstruction == Pop:
          current_pos = positions[0]
          insts = insts[1..^1]
          positions = positions[1..^1]
        else:
          continue
      of pkDraw:
        nextLine = calculateNextLine(inst.drawInstruction, current_pos)
        let new_position = Position(x: nextLine.end_pos.x,
                                    y: nextLine.end_pos.y,
                                    angle: nextLine.angle)
        # leave the stack alone, set the current position however

        draw_lines = draw_lines & @[nextLine]
        insts = insts[1..^1]
        current_pos = new_position
  return draw_lines

proc guiLoop*() =
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
  var restartSimulation = false

  var restartButton = false

  var magnitude: float64 = 10
  var angle: float64 = 30

  SetTargetFPS(60)

  var iterations = 2

  # "axiom"
  let startingPosition = Position(x: screenWidth/2, y: screenHeight.float64, angle: 90)
  var instructions = toSeq(axiomToInstructions(iterations, magnitude, angle))
  for inst in instructions:
    echo inst
  var drawLines = executeProgram(instructions, startingPosition)
  while not WindowShouldClose():
    BeginDrawing()

    restartSimulation = GuiButton(Rectangle(x: 0.float32, y: 0.float32, width: 100.float32, height: 20.float32), "Restart".cstring)

    let fewerIterations = GuiButton(Rectangle(x: 0.float32, y: 20.float32, width: 100.float32, height: 20.float32), "Fewer".cstring)
    let moreIterations = GuiButton(Rectangle(x: 0.float32, y: 40.float32, width: 100.float32, height: 20.float32), "More".cstring)

    magnitude = GuiSliderBar(Rectangle(
                                    x: 0.float32,
                                    y: 60.float32,
                                    width: 80.float32,
                                    height: 20.float32),
                                  "Smaller",
                                  "Larger",
                                  magnitude,
                                  10, 100)

    angle = GuiSliderBar(Rectangle(
                                    x: 0.float32,
                                    y: 90.float32,
                                    width: 80.float32,
                                    height: 20.float32),
                                  "Narrower",
                                  "Wider",
                                  angle,
                                  1, 45)
    if fewerIterations:
      if iterations > 1:
        iterations -= 1
      restartSimulation = true
    if moreIterations:
      restartSimulation = true
      iterations += 1

    if restartSimulation:
      echo "Re-executing"
      instructions = toSeq(axiomToInstructions(iterations, magnitude, angle))
      drawLines = executeProgram(instructions, startingPosition)

    screenWidth = (monitor.GetMonitorWidth() / 2).int
    screenHeight = (monitor.GetMonitorHeight() / 2).int
    # This must come before anything else!
    ClearBackground(BLACK)
    for line in drawLines:
      DrawLineEx(line.start_pos, line.end_pos, line.width, line.color)

    EndDrawing()
  CloseWindow()

when isMainModule:
  guiLoop()
