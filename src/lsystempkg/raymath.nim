# 
#   raymath v1.2 - Math functions to work with Vector3, Matrix and Quaternions
# 
#   CONFIGURATION:
# 
#   #define RAYMATH_IMPLEMENTATION
#       Generates the implementation of the library into the included file.
#       If not defined, the library is in header only mode and can be included in other headers
#       or source files without problems. But only ONE file should hold the implementation.
# 
#   #define RAYMATH_HEADER_ONLY
#       Define static inline functions code, so #include header suffices for use.
#       This may use up lots of memory.
# 
#   #define RAYMATH_STANDALONE
#       Avoid raylib.h header inclusion in this file.
#       Vector3 and Matrix data types are defined internally in raymath module.
# 
# 
#   LICENSE: zlib/libpng
# 
#   Copyright (c) 2015-2021 Ramon Santamaria (@raysan5)
# 
#   This software is provided "as-is", without any express or implied warranty. In no event
#   will the authors be held liable for any damages arising from the use of this software.
# 
#   Permission is granted to anyone to use this software for any purpose, including commercial
#   applications, and to alter it and redistribute it freely, subject to the following restrictions:
# 
#     1. The origin of this software must not be misrepresented; you must not claim that you
#     wrote the original software. If you use this software in a product, an acknowledgment
#     in the product documentation would be appreciated but is not required.
# 
#     2. Altered source versions must be plainly marked as such, and must not be misrepresented
#     as being the original software.
# 
#     3. This notice may not be removed or altered from any source distribution.
# 
template RAYMATH_H*(): auto = RAYMATH_H
# #define RAYMATH_STANDALONE
# #define RAYMATH_HEADER_ONLY
import raylib
{.pragma: RMDEF, cdecl, discardable, dynlib: "libraylib" & LEXT.}
# ----------------------------------------------------------------------------------
# Defines and Macros
# ----------------------------------------------------------------------------------
# Get float vector for Matrix
# Get float vector for Vector3
# ----------------------------------------------------------------------------------
# Types and Structures Definition
# ----------------------------------------------------------------------------------
# NOTE: Helper types to be used instead of array return types for *ToFloat functions
type float3* {.bycopy.} = object
    v*: array[0..2, float32]
type float16* {.bycopy.} = object
    v*: array[0..15, float32]
# ----------------------------------------------------------------------------------
# Module Functions Definition - Utils math
# ----------------------------------------------------------------------------------
# Clamp float value
proc Clamp*(value: float32; min: float32; max: float32): float32 {.RMDEF, importc: "Clamp".} 
# Calculate linear interpolation between two floats
proc Lerp*(start: float32; endx: float32; amount: float32): float32 {.RMDEF, importc: "Lerp".} 
# Normalize input value within input range
proc Normalize*(value: float32; start: float32; endx: float32): float32 {.RMDEF, importc: "Normalize".} 
# Remap input value within input range to output range
proc Remap*(value: float32; inputStart: float32; inputEnd: float32; outputStart: float32; outputEnd: float32): float32 {.RMDEF, importc: "Remap".} 
# ----------------------------------------------------------------------------------
# Module Functions Definition - Vector2 math
# ----------------------------------------------------------------------------------
# Vector with components value 0.0f
proc Vector2Zero*(): Vector2 {.RMDEF, importc: "Vector2Zero".} 
# Vector with components value 1.0f
proc Vector2One*(): Vector2 {.RMDEF, importc: "Vector2One".} 
# Add two vectors (v1 + v2)
proc Vector2Add*(v1: Vector2; v2: Vector2): Vector2 {.RMDEF, importc: "Vector2Add".} 
# Add vector and float value
proc Vector2AddValue*(v: Vector2; add: float32): Vector2 {.RMDEF, importc: "Vector2AddValue".} 
# Subtract two vectors (v1 - v2)
proc Vector2Subtract*(v1: Vector2; v2: Vector2): Vector2 {.RMDEF, importc: "Vector2Subtract".} 
# Subtract vector by float value
proc Vector2SubtractValue*(v: Vector2; sub: float32): Vector2 {.RMDEF, importc: "Vector2SubtractValue".} 
# Calculate vector length
proc Vector2Length*(v: Vector2): float32 {.RMDEF, importc: "Vector2Length".} 
# Calculate vector square length
proc Vector2LengthSqr*(v: Vector2): float32 {.RMDEF, importc: "Vector2LengthSqr".} 
# Calculate two vectors dot product
proc Vector2DotProduct*(v1: Vector2; v2: Vector2): float32 {.RMDEF, importc: "Vector2DotProduct".} 
# Calculate distance between two vectors
proc Vector2Distance*(v1: Vector2; v2: Vector2): float32 {.RMDEF, importc: "Vector2Distance".} 
# Calculate angle from two vectors in X-axis
proc Vector2Angle*(v1: Vector2; v2: Vector2): float32 {.RMDEF, importc: "Vector2Angle".} 
# Scale vector (multiply by value)
proc Vector2Scale*(v: Vector2; scale: float32): Vector2 {.RMDEF, importc: "Vector2Scale".} 
# Multiply vector by vector
proc Vector2Multiply*(v1: Vector2; v2: Vector2): Vector2 {.RMDEF, importc: "Vector2Multiply".} 
# Negate vector
proc Vector2Negate*(v: Vector2): Vector2 {.RMDEF, importc: "Vector2Negate".} 
# Divide vector by vector
proc Vector2Divide*(v1: Vector2; v2: Vector2): Vector2 {.RMDEF, importc: "Vector2Divide".} 
# Normalize provided vector
proc Vector2Normalize*(v: Vector2): Vector2 {.RMDEF, importc: "Vector2Normalize".} 
# Calculate linear interpolation between two vectors
proc Vector2Lerp*(v1: Vector2; v2: Vector2; amount: float32): Vector2 {.RMDEF, importc: "Vector2Lerp".} 
# Calculate reflected vector to normal
proc Vector2Reflect*(v: Vector2; normal: Vector2): Vector2 {.RMDEF, importc: "Vector2Reflect".} 
# Rotate Vector by float in Degrees.
proc Vector2Rotate*(v: Vector2; degs: float32): Vector2 {.RMDEF, importc: "Vector2Rotate".} 
# Move Vector towards target
proc Vector2MoveTowards*(v: Vector2; target: Vector2; maxDistance: float32): Vector2 {.RMDEF, importc: "Vector2MoveTowards".} 
# ----------------------------------------------------------------------------------
# Module Functions Definition - Vector3 math
# ----------------------------------------------------------------------------------
# Vector with components value 0.0f
proc Vector3Zero*(): Vector3 {.RMDEF, importc: "Vector3Zero".} 
# Vector with components value 1.0f
proc Vector3One*(): Vector3 {.RMDEF, importc: "Vector3One".} 
# Add two vectors
proc Vector3Add*(v1: Vector3; v2: Vector3): Vector3 {.RMDEF, importc: "Vector3Add".} 
# Add vector and float value
proc Vector3AddValue*(v: Vector3; add: float32): Vector3 {.RMDEF, importc: "Vector3AddValue".} 
# Subtract two vectors
proc Vector3Subtract*(v1: Vector3; v2: Vector3): Vector3 {.RMDEF, importc: "Vector3Subtract".} 
# Subtract vector by float value
proc Vector3SubtractValue*(v: Vector3; sub: float32): Vector3 {.RMDEF, importc: "Vector3SubtractValue".} 
# Multiply vector by scalar
proc Vector3Scale*(v: Vector3; scalar: float32): Vector3 {.RMDEF, importc: "Vector3Scale".} 
# Multiply vector by vector
proc Vector3Multiply*(v1: Vector3; v2: Vector3): Vector3 {.RMDEF, importc: "Vector3Multiply".} 
# Calculate two vectors cross product
proc Vector3CrossProduct*(v1: Vector3; v2: Vector3): Vector3 {.RMDEF, importc: "Vector3CrossProduct".} 
# Calculate one vector perpendicular vector
proc Vector3Perpendicular*(v: Vector3): Vector3 {.RMDEF, importc: "Vector3Perpendicular".} 
# Calculate vector length
proc Vector3Length*(v: ptr Vector3): float32 {.RMDEF, importc: "Vector3Length".} 
# Calculate vector square length
proc Vector3LengthSqr*(v: ptr Vector3): float32 {.RMDEF, importc: "Vector3LengthSqr".} 
# Calculate two vectors dot product
proc Vector3DotProduct*(v1: Vector3; v2: Vector3): float32 {.RMDEF, importc: "Vector3DotProduct".} 
# Calculate distance between two vectors
proc Vector3Distance*(v1: Vector3; v2: Vector3): float32 {.RMDEF, importc: "Vector3Distance".} 
# Negate provided vector (invert direction)
proc Vector3Negate*(v: Vector3): Vector3 {.RMDEF, importc: "Vector3Negate".} 
# Divide vector by vector
proc Vector3Divide*(v1: Vector3; v2: Vector3): Vector3 {.RMDEF, importc: "Vector3Divide".} 
# Normalize provided vector
proc Vector3Normalize*(v: Vector3): Vector3 {.RMDEF, importc: "Vector3Normalize".} 
# Orthonormalize provided vectors
# Makes vectors normalized and orthogonal to each other
# Gram-Schmidt function implementation
proc Vector3OrthoNormalize*(v1: ptr Vector3; v2: ptr Vector3) {.RMDEF, importc: "Vector3OrthoNormalize".} 
# Transforms a Vector3 by a given Matrix
proc Vector3Transform*(v: Vector3; mat: Matrix): Vector3 {.RMDEF, importc: "Vector3Transform".} 
# Transform a vector by quaternion rotation
proc Vector3RotateByQuaternion*(v: Vector3; q: Quaternion): Vector3 {.RMDEF, importc: "Vector3RotateByQuaternion".} 
# Calculate linear interpolation between two vectors
proc Vector3Lerp*(v1: Vector3; v2: Vector3; amount: float32): Vector3 {.RMDEF, importc: "Vector3Lerp".} 
# Calculate reflected vector to normal
proc Vector3Reflect*(v: Vector3; normal: Vector3): Vector3 {.RMDEF, importc: "Vector3Reflect".} 
# Get min value for each pair of components
proc Vector3Min*(v1: Vector3; v2: Vector3): Vector3 {.RMDEF, importc: "Vector3Min".} 
# Get max value for each pair of components
proc Vector3Max*(v1: Vector3; v2: Vector3): Vector3 {.RMDEF, importc: "Vector3Max".} 
# Compute barycenter coordinates (u, v, w) for point p with respect to triangle (a, b, c)
# NOTE: Assumes P is on the plane of the triangle
proc Vector3Barycenter*(p: Vector3; a: Vector3; b: Vector3; c: Vector3): Vector3 {.RMDEF, importc: "Vector3Barycenter".} 
# Get Vector3 as float array
proc Vector3ToFloatV*(v: Vector3): float3 {.RMDEF, importc: "Vector3ToFloatV".} 
# ----------------------------------------------------------------------------------
# Module Functions Definition - Matrix math
# ----------------------------------------------------------------------------------
# Compute matrix determinant
proc MatrixDeterminant*(mat: Matrix): float32 {.RMDEF, importc: "MatrixDeterminant".} 
# Get the trace of the matrix (sum of the values along the diagonal)
proc MatrixTrace*(mat: Matrix): float32 {.RMDEF, importc: "MatrixTrace".} 
# Transposes provided matrix
proc MatrixTranspose*(mat: Matrix): Matrix {.RMDEF, importc: "MatrixTranspose".} 
# Invert provided matrix
proc MatrixInvert*(mat: Matrix): Matrix {.RMDEF, importc: "MatrixInvert".} 
# Normalize provided matrix
proc MatrixNormalize*(mat: Matrix): Matrix {.RMDEF, importc: "MatrixNormalize".} 
# Get identity matrix
proc MatrixIdentity*(): Matrix {.RMDEF, importc: "MatrixIdentity".} 
# Add two matrices
proc MatrixAdd*(left: Matrix; right: Matrix): Matrix {.RMDEF, importc: "MatrixAdd".} 
# Subtract two matrices (left - right)
proc MatrixSubtract*(left: Matrix; right: Matrix): Matrix {.RMDEF, importc: "MatrixSubtract".} 
# Get two matrix multiplication
# NOTE: When multiplying matrices... the order matters!
proc MatrixMultiply*(left: Matrix; right: Matrix): Matrix {.RMDEF, importc: "MatrixMultiply".} 
# Get translation matrix
proc MatrixTranslate*(x: float32; y: float32; z: float32): Matrix {.RMDEF, importc: "MatrixTranslate".} 
# Create rotation matrix from axis and angle
# NOTE: Angle should be provided in radians
proc MatrixRotate*(axis: Vector3; angle: float32): Matrix {.RMDEF, importc: "MatrixRotate".} 
# Get x-rotation matrix (angle in radians)
proc MatrixRotateX*(angle: float32): Matrix {.RMDEF, importc: "MatrixRotateX".} 
# Get y-rotation matrix (angle in radians)
proc MatrixRotateY*(angle: float32): Matrix {.RMDEF, importc: "MatrixRotateY".} 
# Get z-rotation matrix (angle in radians)
proc MatrixRotateZ*(angle: float32): Matrix {.RMDEF, importc: "MatrixRotateZ".} 
# Get xyz-rotation matrix (angles in radians)
proc MatrixRotateXYZ*(ang: Vector3): Matrix {.RMDEF, importc: "MatrixRotateXYZ".} 
# Get zyx-rotation matrix (angles in radians)
proc MatrixRotateZYX*(ang: Vector3): Matrix {.RMDEF, importc: "MatrixRotateZYX".} 
# Get scaling matrix
proc MatrixScale*(x: float32; y: float32; z: float32): Matrix {.RMDEF, importc: "MatrixScale".} 
# Get perspective projection matrix
proc MatrixFrustum*(left: float64; right: float64; bottom: float64; top: float64; near: float64; far: float64): Matrix {.RMDEF, importc: "MatrixFrustum".} 
# Get perspective projection matrix
# NOTE: Angle should be provided in radians
proc MatrixPerspective*(fovy: float64; aspect: float64; near: float64; far: float64): Matrix {.RMDEF, importc: "MatrixPerspective".} 
# Get orthographic projection matrix
proc MatrixOrtho*(left: float64; right: float64; bottom: float64; top: float64; near: float64; far: float64): Matrix {.RMDEF, importc: "MatrixOrtho".} 
# Get camera look-at matrix (view matrix)
proc MatrixLookAt*(eye: Vector3; target: Vector3; up: Vector3): Matrix {.RMDEF, importc: "MatrixLookAt".} 
# Get float array of matrix data
proc MatrixToFloatV*(mat: Matrix): float16 {.RMDEF, importc: "MatrixToFloatV".} 
# ----------------------------------------------------------------------------------
# Module Functions Definition - Quaternion math
# ----------------------------------------------------------------------------------
# Add two quaternions
proc QuaternionAdd*(q1: Quaternion; q2: Quaternion): Quaternion {.RMDEF, importc: "QuaternionAdd".} 
# Add quaternion and float value
proc QuaternionAddValue*(q: Quaternion; add: float32): Quaternion {.RMDEF, importc: "QuaternionAddValue".} 
# Subtract two quaternions
proc QuaternionSubtract*(q1: Quaternion; q2: Quaternion): Quaternion {.RMDEF, importc: "QuaternionSubtract".} 
# Subtract quaternion and float value
proc QuaternionSubtractValue*(q: Quaternion; sub: float32): Quaternion {.RMDEF, importc: "QuaternionSubtractValue".} 
# Get identity quaternion
proc QuaternionIdentity*(): Quaternion {.RMDEF, importc: "QuaternionIdentity".} 
# Computes the length of a quaternion
proc QuaternionLength*(q: Quaternion): float32 {.RMDEF, importc: "QuaternionLength".} 
# Normalize provided quaternion
proc QuaternionNormalize*(q: Quaternion): Quaternion {.RMDEF, importc: "QuaternionNormalize".} 
# Invert provided quaternion
proc QuaternionInvert*(q: Quaternion): Quaternion {.RMDEF, importc: "QuaternionInvert".} 
# Calculate two quaternion multiplication
proc QuaternionMultiply*(q1: Quaternion; q2: Quaternion): Quaternion {.RMDEF, importc: "QuaternionMultiply".} 
# Scale quaternion by float value
proc QuaternionScale*(q: Quaternion; mul: float32): Quaternion {.RMDEF, importc: "QuaternionScale".} 
# Divide two quaternions
proc QuaternionDivide*(q1: Quaternion; q2: Quaternion): Quaternion {.RMDEF, importc: "QuaternionDivide".} 
# Calculate linear interpolation between two quaternions
proc QuaternionLerp*(q1: Quaternion; q2: Quaternion; amount: float32): Quaternion {.RMDEF, importc: "QuaternionLerp".} 
# Calculate slerp-optimized interpolation between two quaternions
proc QuaternionNlerp*(q1: Quaternion; q2: Quaternion; amount: float32): Quaternion {.RMDEF, importc: "QuaternionNlerp".} 
# Calculates spherical linear interpolation between two quaternions
proc QuaternionSlerp*(q1: Quaternion; q2: Quaternion; amount: float32): Quaternion {.RMDEF, importc: "QuaternionSlerp".} 
# Calculate quaternion based on the rotation from one vector to another
proc QuaternionFromVector3ToVector3*(fromx: Vector3; to: Vector3): Quaternion {.RMDEF, importc: "QuaternionFromVector3ToVector3".} 
# Get a quaternion for a given rotation matrix
proc QuaternionFromMatrix*(mat: Matrix): Quaternion {.RMDEF, importc: "QuaternionFromMatrix".} 
# Get a matrix for a given quaternion
proc QuaternionToMatrix*(q: Quaternion): Matrix {.RMDEF, importc: "QuaternionToMatrix".} 
# Get rotation quaternion for an angle and axis
# NOTE: angle must be provided in radians
proc QuaternionFromAxisAngle*(axis: Vector3; angle: float32): Quaternion {.RMDEF, importc: "QuaternionFromAxisAngle".} 
# Get the rotation angle and axis for a given quaternion
proc QuaternionToAxisAngle*(q: Quaternion; outAxis: ptr Vector3; outAngle: float32) {.RMDEF, importc: "QuaternionToAxisAngle".} 
# Get the quaternion equivalent to Euler angles
# NOTE: Rotation order is ZYX
proc QuaternionFromEuler*(pitch: float32; yaw: float32; roll: float32): Quaternion {.RMDEF, importc: "QuaternionFromEuler".} 
# Get the Euler angles equivalent to quaternion (roll, pitch, yaw)
# NOTE: Angles are returned in a Vector3 struct in degrees
proc QuaternionToEuler*(q: Quaternion): Vector3 {.RMDEF, importc: "QuaternionToEuler".} 
# Transform a quaternion given a transformation matrix
proc QuaternionTransform*(q: Quaternion; mat: Matrix): Quaternion {.RMDEF, importc: "QuaternionTransform".} 
# Projects a Vector3 from screen space into object space
proc Vector3Unproject*(source: Vector3; projection: Matrix; view: Matrix): Vector3 {.RMDEF, importc: "Vector3Unproject".} 