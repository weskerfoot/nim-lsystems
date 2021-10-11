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

  for _ in repeat(0, maxIterations):
    # Reset this each iteration to gather new expansions
    newTerms = @[]
    for term in currentTerms:
      case term:
        of LeafTerm:
          case sample(toSeq(0..15)):
            # Instead of using sample, make it a markov chain grammar
            # Allow defining a set of productions that choose randomly
            of 0..10: newTerms &= @[LineTerm, LineTerm, PushTerm, GoRight, LeafTerm, PopTerm, GoLeft, LeafTerm]
            of 11..12: newTerms &= @[LineTerm, LineTerm, PushTerm, GoRight, PopTerm, GoLeft, LeafTerm]
            of 13..15: newTerms &= @[LineTerm, LineTerm, PushTerm, GoRight, LeafTerm, PopTerm, GoLeft]
            else:
              continue

        else: newTerms &= @[term]
    currentTerms = newTerms

  # Add a trunk proportional to the number of iterations
  # Maybe should be proportional to the total magnitude of the entire thing somehow?
  for _ in repeat(0, maxIterations):
    currentTerms = @[LineTerm] & currentTerms
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

iterator axiomToInstructions(maxIterations: int, magnitude: float64, angle: float64, leafColor: Color = DARKGREEN) : Instruction =
  var currentLeafColor = leafColor
  let axiom = @[LeafTerm]
  let termsToConvert = rewrite(axiom, maxIterations)
  var angle_delta: float64 = angle
  var magnitudes: seq[float64] = @[magnitude]
  var widths: seq[float64] = @[maxIterations.float64]
  var current_magnitude = magnitude
  var current_width: float64 = widths[0]
  # axiom
  yield Instruction(kind: pkDraw, drawInstruction: DrawInstruction(angle_change: 180, magnitude: magnitude))

  for term in termsToConvert:
    # TODO make this definable by the grammar and/or tweakable
    let angle_delta = angle_delta * sample(@[1.0, 1.0, 0.9])
    case term:
      of LeafTerm:
        # when there's a leaf we want to make the magnitude smaller
        # TODO make this definable by the grammar and/or tweakable
        let leaf_width = (16 * sample(@[1.2, 1.0, 0.50]))

        # TODO make this definable by the grammar and/or tweakable
        currentLeafColor.r += (sample(@[5, 2, 10, -1, -2, 3]).uint8)

        yield Instruction(kind: pkDraw, drawInstruction: DrawInstruction(color: currentLeafColor, width: leaf_width, angle_change: angle_delta, magnitude: magnitudes[0]))
        yield Instruction(kind: pkDraw, drawInstruction: DrawInstruction(color: currentLeafColor, width: leaf_width, angle_change: 0, magnitude: -magnitudes[0])) # hack
        yield Instruction(kind: pkDraw, drawInstruction: DrawInstruction(color: currentLeafColor, width: leaf_width, angle_change: -(angle_delta*2), magnitude: magnitudes[0]))
      of LineTerm:
        # Draw without changing direction
        yield Instruction(kind: pkDraw, drawInstruction: DrawInstruction(color: DARKBROWN, width: current_width, angle_change: 0, magnitude: magnitudes[0]))

      # L-systems don't go "backwards"
      # So you can go left or right on the x-axis at a given angle delta
      of GoLeft:
        # TODO make this definable by the grammar and/or tweakable
        current_magnitude = current_magnitude - (current_magnitude * sample(@[0.05, 0.10]))
        current_width = current_width - (current_width * sample(@[0.15, 0.10]))
        yield Instruction(kind: pkDraw, drawInstruction: DrawInstruction(color: DARKBROWN, width: current_width, angle_change: angle_delta, magnitude: current_magnitude))
      of GoRight:
        # TODO make this definable by the grammar and/or tweakable
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
type StartingPosition = object
  x: float64
  y: float64
  mid: Vector2
  angle: float64 # Defines which direction it will start in

type TreeLocation = object
  iterationAngle: float64
  iterationNumber: int
  startingMagnitude: float64
  startingPosition: StartingPosition
  startingColor: Color

proc `$` (p: StartingPosition): string =
  return "x = " & $p.x & ", y = " & $p.y & ", angle = " & $p.angle

# Line (along with the angle relative to origin
type DrawLine = object
  start_pos: Vector2
  mid_pos: Vector2
  end_pos: Vector2
  width: float64
  angle: float64
  color: Color

proc `$` (d: DrawLine): string =
  return "start_pos = " & $d.start_pos & ", " & "end_pos = " & $d.end_pos

proc calculateNextLine(inst: DrawInstruction, pos: StartingPosition) : DrawLine =
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
  result.mid_pos = Vector2(x: result.start_pos.x, y: result.end_pos.y)

  result.width = inst.width
  result.color = inst.color
  result.angle = new_angle

proc executeProgram(instructions: seq[Instruction], starting_pos: StartingPosition) : seq[DrawLine] =
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
        let new_position = StartingPosition(x: nextLine.end_pos.x,
                                            y: nextLine.end_pos.y,
                                            mid: nextLine.mid_pos,
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
  SetTargetFPS(60)

  # Control variables
  var dragWindow = false
  var restartSimulation = false
  var clearForest = false
  var restartButton = false
  var magnitude: int = 10
  var angle: int = 30
  var iterations = 2

  var startingPosition_x: float32 = screenWidth/2
  var startingPosition_y: float32 = screenHeight.float32
  var treeLocations: seq[TreeLocation] = @[]

  var instructionLists: seq[seq[Instruction]] = @[]
  var drawLinesList: seq[seq[DrawLine]] = @[]
  var zoom: float32 = 1
  var rotation: float32 = 0
  var camera_x_offset = screenWidth/2
  var camera_y_offset = screenHeight/2
  var color: Color = DARKGREEN

  var camera: Camera2D

  camera.offset = Vector2(x: camera_x_offset, y: camera_y_offset)
  camera.target = Vector2(x: screenWidth/2, y: screenHeight/2)

  camera.rotation = rotation
  camera.zoom = zoom

  while not WindowShouldClose():
    BeginDrawing()

    restartSimulation = GuiButton(Rectangle(x: 0.float32, y: 20.float32, width: 200.float32, height: 50.float32), "Restart".cstring)
    clearForest = GuiButton(Rectangle(x: 0.float32, y: 70.float32, width: 200.float32, height: 50.float32), "Clear".cstring)

    let iterationsBox = Rectangle(x: 0.float32, y: 120.float32, width: 200.float32, height: 50.float32)
    let magnitudeBox = Rectangle(x: 0.float32, y: 170.float32, width: 200.float32, height: 50.float32)
    let angleBox = Rectangle(x: 0.float32, y: 220.float32, width: 200.float32, height: 50.float32)
    let colorPickerBox = Rectangle(x: 0.float32, y: 270.float32, width: 200.float32, height: 50.float32)
    let mouseVector = Vector2(x: GetMouseX().float64, y: GetMouseY().float64)

    GuiValueBox(bounds=iterationsBox,
                text="Iterations".cstring,
                value=iterations.addr,
                minValue=1,
                maxValue=15,
                editMode=CheckCollisionPointRec(mouseVector, iterationsBox))

    GuiValueBox(bounds=magnitudeBox,
                text="Size".cstring,
                value=magnitude.addr,
                minValue=1,
                maxValue=500,
                editMode=CheckCollisionPointRec(mouseVector, magnitudeBox))

    GuiValueBox(bounds=angleBox,
                text="Angle".cstring,
                value=angle.addr,
                minValue=1,
                maxValue=360,
                editMode=CheckCollisionPointRec(mouseVector, angleBox))

    color = GuiColorPicker(colorPickerBox, color)

    if IsKeyDown(KEY_DOWN) and IsKeyDown(KEY_LEFT_CONTROL):
      zoom -= 0.01
    if IsKeyDown(KEY_UP) and IsKeyDown(KEY_LEFT_CONTROL):
      zoom += 0.01

    if IsKeyDown(KEY_LEFT) and IsKeyDown(KEY_LEFT_CONTROL) and rotation < 360:
      rotation += 1
    if IsKeyDown(KEY_RIGHT) and IsKeyDown(KEY_LEFT_CONTROL) and rotation > -360:
      rotation -= 1

    camera.zoom = zoom
    camera.rotation = rotation

    if GetMouseX() <= 0:
      camera_x_offset += 5

    if GetMouseX() >= (GetScreenWidth() - 10):
      camera_x_offset -= 5

    if GetMouseY() <= 10:
      camera_y_offset += 5

    if GetMouseY() >= (GetScreenHeight() - 10):
      camera_y_offset -= 5

    camera.offset = Vector2(x: camera_x_offset, y: camera_y_offset)

    if IsKeyDown(KEY_LEFT_CONTROL) and IsMouseButtonPressed(MOUSE_LEFT_BUTTON):
      # Save and place an object
      let newPositionVector = GetScreenToWorld2D(Vector2(x: mouseVector.x, y: mouseVector.y), camera)
      let newPosition = StartingPosition(x: newPositionVector.x, y: newPositionVector.y, angle: 90)

      # Store the location of the tree and its starting attributes
      treeLocations &= @[TreeLocation(startingPosition: newPosition,
                                      iterationAngle: angle.float32,
                                      iterationNumber: iterations,
                                      startingMagnitude: magnitude.float64,
                                      startingColor: color)]

      let newInstructions = toSeq(axiomToInstructions(iterations, magnitude.float64, angle.float64, color))
      drawLinesList &= @[executeProgram(newInstructions, newPosition)]

    if restartSimulation:
      echo "Re-executing"
      drawLinesList = @[]
      for tree in treeLocations:
        let instructions = toSeq(axiomToInstructions(tree.iterationNumber,
                                                     tree.startingMagnitude,
                                                     tree.iterationAngle,
                                                     tree.startingColor))

        drawLinesList &= @[executeProgram(instructions, tree.startingPosition)]

    if clearForest:
      drawLinesList = @[]
      instructionLists = @[]
      treeLocations = @[]

    # Make sure to clear the background before drawing
    ClearBackground(BLACK)

    # Only want the camera to apply to drawn stuff, not controls
    BeginMode2D(camera)
    for drawLines in drawLinesList:
      for line in drawLines:
        DrawLineEx(line.start_pos, line.end_pos, line.width, line.color)

    EndMode2D()
    EndDrawing()

  CloseWindow()

when isMainModule:
  guiLoop()
