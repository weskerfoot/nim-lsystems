# 
#   rlgl v3.7 - raylib OpenGL abstraction layer
# 
#   rlgl is a wrapper for multiple OpenGL versions (1.1, 2.1, 3.3 Core, ES 2.0) to
#   pseudo-OpenGL 1.1 style functions (rlVertex, rlTranslate, rlRotate...).
# 
#   When chosing an OpenGL version greater than OpenGL 1.1, rlgl stores vertex data on internal
#   VBO buffers (and VAOs if available). It requires calling 3 functions:
#       rlglInit()  - Initialize internal buffers and auxiliary resources
#       rlglClose() - De-initialize internal buffers data and other auxiliar resources
# 
#   CONFIGURATION:
# 
#   #define GRAPHICS_API_OPENGL_11
#   #define GRAPHICS_API_OPENGL_21
#   #define GRAPHICS_API_OPENGL_33
#   #define GRAPHICS_API_OPENGL_ES2
#       Use selected OpenGL graphics backend, should be supported by platform
#       Those preprocessor defines are only used on rlgl module, if OpenGL version is
#       required by any other module, use rlGetVersion() to check it
# 
#   #define RLGL_IMPLEMENTATION
#       Generates the implementation of the library into the included file.
#       If not defined, the library is in header only mode and can be included in other headers
#       or source files without problems. But only ONE file should hold the implementation.
# 
#   #define RLGL_STANDALONE
#       Use rlgl as standalone library (no raylib dependency)
# 
#   #define SUPPORT_GL_DETAILS_INFO
#       Show OpenGL extensions and capabilities detailed logs on init
# 
#   DEPENDENCIES:
#       raymath     - 3D math functionality (Vector3, Matrix, Quaternion)
#       GLAD        - OpenGL extensions loading (OpenGL 3.3 Core only)
# 
# 
#   LICENSE: zlib/libpng
# 
#   Copyright (c) 2014-2021 Ramon Santamaria (@raysan5)
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
template RLGL_H*(): auto = RLGL_H
{.pragma: RLAPI, cdecl, discardable, dynlib: "libraylib" & LEXT.}
import raylib
# Security check in case no GRAPHICS_API_OPENGL_* defined
# Security check in case multiple GRAPHICS_API_OPENGL_* defined
# OpenGL 2.1 uses most of OpenGL 3.3 Core functionality
# WARNING: Specific parts are checked with #if defines
template SUPPORT_RENDER_TEXTURES_HINT*(): auto = SUPPORT_RENDER_TEXTURES_HINT
# ----------------------------------------------------------------------------------
# Defines and Macros
# ----------------------------------------------------------------------------------
# Default internal render batch limits
# Internal Matrix stack
# Vertex buffers id limit
# Shader and material limits
# Projection matrix culling
# Texture parameters (equivalent to OpenGL defines)
template RL_TEXTURE_WRAP_S*(): auto = 0x2802
template RL_TEXTURE_WRAP_T*(): auto = 0x2803
template RL_TEXTURE_MAG_FILTER*(): auto = 0x2800
template RL_TEXTURE_MIN_FILTER*(): auto = 0x2801
template RL_TEXTURE_FILTER_NEAREST*(): auto = 0x2600
template RL_TEXTURE_FILTER_LINEAR*(): auto = 0x2601
template RL_TEXTURE_FILTER_MIP_NEAREST*(): auto = 0x2700
template RL_TEXTURE_FILTER_NEAREST_MIP_LINEAR*(): auto = 0x2702
template RL_TEXTURE_FILTER_LINEAR_MIP_NEAREST*(): auto = 0x2701
template RL_TEXTURE_FILTER_MIP_LINEAR*(): auto = 0x2703
template RL_TEXTURE_FILTER_ANISOTROPIC*(): auto = 0x3000
template RL_TEXTURE_WRAP_REPEAT*(): auto = 0x2901
template RL_TEXTURE_WRAP_CLAMP*(): auto = 0x812F
template RL_TEXTURE_WRAP_MIRROR_REPEAT*(): auto = 0x8370
template RL_TEXTURE_WRAP_MIRROR_CLAMP*(): auto = 0x8742
# Matrix modes (equivalent to OpenGL)
template RL_MODELVIEW*(): auto = 0x1700
template RL_PROJECTION*(): auto = 0x1701
template RL_TEXTURE*(): auto = 0x1702
# Primitive assembly draw modes
template RL_LINES*(): auto = 0x0001
template RL_TRIANGLES*(): auto = 0x0004
template RL_QUADS*(): auto = 0x0007
# GL equivalent data types
template RL_UNSIGNED_BYTE*(): auto = 0x1401
template RL_FLOAT*(): auto = 0x1406
# ----------------------------------------------------------------------------------
# Types and Structures Definition
# ----------------------------------------------------------------------------------
type FramebufferAttachType* = enum 
    RL_ATTACHMENT_COLOR_CHANNEL0 = 0 
    RL_ATTACHMENT_COLOR_CHANNEL1 
    RL_ATTACHMENT_COLOR_CHANNEL2 
    RL_ATTACHMENT_COLOR_CHANNEL3 
    RL_ATTACHMENT_COLOR_CHANNEL4 
    RL_ATTACHMENT_COLOR_CHANNEL5 
    RL_ATTACHMENT_COLOR_CHANNEL6 
    RL_ATTACHMENT_COLOR_CHANNEL7 
    RL_ATTACHMENT_DEPTH = 100 
    RL_ATTACHMENT_STENCIL = 200 
converter FramebufferAttachType2int32* (self: FramebufferAttachType): int32 = self.int32 
type FramebufferAttachTextureType* = enum 
    RL_ATTACHMENT_CUBEMAP_POSITIVE_X = 0 
    RL_ATTACHMENT_CUBEMAP_NEGATIVE_X 
    RL_ATTACHMENT_CUBEMAP_POSITIVE_Y 
    RL_ATTACHMENT_CUBEMAP_NEGATIVE_Y 
    RL_ATTACHMENT_CUBEMAP_POSITIVE_Z 
    RL_ATTACHMENT_CUBEMAP_NEGATIVE_Z 
    RL_ATTACHMENT_TEXTURE2D = 100 
    RL_ATTACHMENT_RENDERBUFFER = 200 
converter FramebufferAttachTextureType2int32* (self: FramebufferAttachTextureType): int32 = self.int32 
# Dynamic vertex buffers (position + texcoords + colors + indices arrays)
type VertexBuffer* {.bycopy.} = object
    elementsCount*: int32 # Number of elements in the buffer (QUADS)
    vCounter*: int32 # Vertex position counter to process (and draw) from full buffer
    tcCounter*: int32 # Vertex texcoord counter to process (and draw) from full buffer
    cCounter*: int32 # Vertex color counter to process (and draw) from full buffer
    vertices*: float32 # Vertex position (XYZ - 3 components per vertex) (shader-location = 0)
    texcoords*: float32 # Vertex texture coordinates (UV - 2 components per vertex) (shader-location = 1)
    colors*: uint8 # Vertex colors (RGBA - 4 components per vertex) (shader-location = 3)
    indices*: uint32 # Vertex indices (in case vertex data comes indexed) (6 indices per quad)
    # Skipped another *indices
    vaoId*: uint32 # OpenGL Vertex Array Object id
    vboId*: array[0..3, uint32] # OpenGL Vertex Buffer Objects id (4 types of vertex data)
# Draw call type
# NOTE: Only texture changes register a new draw, other state-change-related elements are not
# used at this moment (vaoId, shaderId, matrices), raylib just forces a batch draw call if any
# of those state-change happens (this is done in core module)
type DrawCall* {.bycopy.} = object
    mode*: int32 # Drawing mode: LINES, TRIANGLES, QUADS
    vertexCount*: int32 # Number of vertex of the draw
    vertexAlignment*: int32 # Number of vertex required for index alignment (LINES, TRIANGLES)
    textureId*: uint32 # Texture id to be used on the draw -> Use to create new draw call if changes
# RenderBatch type
type RenderBatch* {.bycopy.} = object
    buffersCount*: int32 # Number of vertex buffers (multi-buffering support)
    currentBuffer*: int32 # Current buffer tracking in case of multi-buffering
    vertexBuffer*: ptr VertexBuffer # Dynamic buffer(s) for vertex data
    draws*: ptr DrawCall # Draw calls array, depends on textureId
    drawsCounter*: int32 # Draw calls counter
    currentDepth*: float32 # Current depth value for next draw
# ------------------------------------------------------------------------------------
# Functions Declaration - Matrix operations
# ------------------------------------------------------------------------------------
proc rlMatrixMode*(mode: int32) {.RLAPI, importc: "rlMatrixMode".} # Choose the current matrix to be transformed
proc rlPushMatrix*() {.RLAPI, importc: "rlPushMatrix".} # Push the current matrix to stack
proc rlPopMatrix*() {.RLAPI, importc: "rlPopMatrix".} # Pop lattest inserted matrix from stack
proc rlLoadIdentity*() {.RLAPI, importc: "rlLoadIdentity".} # Reset current matrix to identity matrix
proc rlTranslatef*(x: float32; y: float32; z: float32) {.RLAPI, importc: "rlTranslatef".} # Multiply the current matrix by a translation matrix
proc rlRotatef*(angleDeg: float32; x: float32; y: float32; z: float32) {.RLAPI, importc: "rlRotatef".} # Multiply the current matrix by a rotation matrix
proc rlScalef*(x: float32; y: float32; z: float32) {.RLAPI, importc: "rlScalef".} # Multiply the current matrix by a scaling matrix
proc rlMultMatrixf*(matf: float32) {.RLAPI, importc: "rlMultMatrixf".} # Multiply the current matrix by another matrix
proc rlFrustum*(left: float64; right: float64; bottom: float64; top: float64; znear: float64; zfar: float64) {.RLAPI, importc: "rlFrustum".} 
proc rlOrtho*(left: float64; right: float64; bottom: float64; top: float64; znear: float64; zfar: float64) {.RLAPI, importc: "rlOrtho".} 
proc rlViewport*(x: int32; y: int32; width: int32; height: int32) {.RLAPI, importc: "rlViewport".} # Set the viewport area
# ------------------------------------------------------------------------------------
# Functions Declaration - Vertex level operations
# ------------------------------------------------------------------------------------
proc rlBegin*(mode: int32) {.RLAPI, importc: "rlBegin".} # Initialize drawing mode (how to organize vertex)
proc rlEnd*() {.RLAPI, importc: "rlEnd".} # Finish vertex providing
proc rlVertex2i*(x: int32; y: int32) {.RLAPI, importc: "rlVertex2i".} # Define one vertex (position) - 2 int
proc rlVertex2f*(x: float32; y: float32) {.RLAPI, importc: "rlVertex2f".} # Define one vertex (position) - 2 float
proc rlVertex3f*(x: float32; y: float32; z: float32) {.RLAPI, importc: "rlVertex3f".} # Define one vertex (position) - 3 float
proc rlTexCoord2f*(x: float32; y: float32) {.RLAPI, importc: "rlTexCoord2f".} # Define one vertex (texture coordinate) - 2 float
proc rlNormal3f*(x: float32; y: float32; z: float32) {.RLAPI, importc: "rlNormal3f".} # Define one vertex (normal) - 3 float
proc rlColor4ub*(r: uint8; g: uint8; b: uint8; a: uint8) {.RLAPI, importc: "rlColor4ub".} # Define one vertex (color) - 4 byte
proc rlColor3f*(x: float32; y: float32; z: float32) {.RLAPI, importc: "rlColor3f".} # Define one vertex (color) - 3 float
proc rlColor4f*(x: float32; y: float32; z: float32; w: float32) {.RLAPI, importc: "rlColor4f".} # Define one vertex (color) - 4 float
# ------------------------------------------------------------------------------------
# Functions Declaration - OpenGL style functions (common to 1.1, 3.3+, ES2)
# NOTE: This functions are used to completely abstract raylib code from OpenGL layer,
# some of them are direct wrappers over OpenGL calls, some others are custom
# ------------------------------------------------------------------------------------
# Vertex buffers state
proc rlEnableVertexArray*(vaoId: uint32): bool {.RLAPI, importc: "rlEnableVertexArray".} # Enable vertex array (VAO, if supported)
proc rlDisableVertexArray*() {.RLAPI, importc: "rlDisableVertexArray".} # Disable vertex array (VAO, if supported)
proc rlEnableVertexBuffer*(id: uint32) {.RLAPI, importc: "rlEnableVertexBuffer".} # Enable vertex buffer (VBO)
proc rlDisableVertexBuffer*() {.RLAPI, importc: "rlDisableVertexBuffer".} # Disable vertex buffer (VBO)
proc rlEnableVertexBufferElement*(id: uint32) {.RLAPI, importc: "rlEnableVertexBufferElement".} # Enable vertex buffer element (VBO element)
proc rlDisableVertexBufferElement*() {.RLAPI, importc: "rlDisableVertexBufferElement".} # Disable vertex buffer element (VBO element)
proc rlEnableVertexAttribute*(index: uint32) {.RLAPI, importc: "rlEnableVertexAttribute".} # Enable vertex attribute index
proc rlDisableVertexAttribute*(index: uint32) {.RLAPI, importc: "rlDisableVertexAttribute".} # Disable vertex attribute index
proc rlEnableStatePointer*(vertexAttribType: int32; buffer: pointer) {.RLAPI, importc: "rlEnableStatePointer".} 
proc rlDisableStatePointer*(vertexAttribType: int32) {.RLAPI, importc: "rlDisableStatePointer".} 
# Textures state
proc rlActiveTextureSlot*(slot: int32) {.RLAPI, importc: "rlActiveTextureSlot".} # Select and active a texture slot
proc rlEnableTexture*(id: uint32) {.RLAPI, importc: "rlEnableTexture".} # Enable texture
proc rlDisableTexture*() {.RLAPI, importc: "rlDisableTexture".} # Disable texture
proc rlEnableTextureCubemap*(id: uint32) {.RLAPI, importc: "rlEnableTextureCubemap".} # Enable texture cubemap
proc rlDisableTextureCubemap*() {.RLAPI, importc: "rlDisableTextureCubemap".} # Disable texture cubemap
proc rlTextureParameters*(id: uint32; param: int32; value: int32) {.RLAPI, importc: "rlTextureParameters".} # Set texture parameters (filter, wrap)
# Shader state
proc rlEnableShader*(id: uint32) {.RLAPI, importc: "rlEnableShader".} # Enable shader program
proc rlDisableShader*() {.RLAPI, importc: "rlDisableShader".} # Disable shader program
# Framebuffer state
proc rlEnableFramebuffer*(id: uint32) {.RLAPI, importc: "rlEnableFramebuffer".} # Enable render texture (fbo)
proc rlDisableFramebuffer*() {.RLAPI, importc: "rlDisableFramebuffer".} # Disable render texture (fbo), return to default framebuffer
# General render state
proc rlEnableDepthTest*() {.RLAPI, importc: "rlEnableDepthTest".} # Enable depth test
proc rlDisableDepthTest*() {.RLAPI, importc: "rlDisableDepthTest".} # Disable depth test
proc rlEnableDepthMask*() {.RLAPI, importc: "rlEnableDepthMask".} # Enable depth write
proc rlDisableDepthMask*() {.RLAPI, importc: "rlDisableDepthMask".} # Disable depth write
proc rlEnableBackfaceCulling*() {.RLAPI, importc: "rlEnableBackfaceCulling".} # Enable backface culling
proc rlDisableBackfaceCulling*() {.RLAPI, importc: "rlDisableBackfaceCulling".} # Disable backface culling
proc rlEnableScissorTest*() {.RLAPI, importc: "rlEnableScissorTest".} # Enable scissor test
proc rlDisableScissorTest*() {.RLAPI, importc: "rlDisableScissorTest".} # Disable scissor test
proc rlScissor*(x: int32; y: int32; width: int32; height: int32) {.RLAPI, importc: "rlScissor".} # Scissor test
proc rlEnableWireMode*() {.RLAPI, importc: "rlEnableWireMode".} # Enable wire mode
proc rlDisableWireMode*() {.RLAPI, importc: "rlDisableWireMode".} # Disable wire mode
proc rlSetLineWidth*(width: float32) {.RLAPI, importc: "rlSetLineWidth".} # Set the line drawing width
proc rlGetLineWidth*(): float32 {.RLAPI, importc: "rlGetLineWidth".} # Get the line drawing width
proc rlEnableSmoothLines*() {.RLAPI, importc: "rlEnableSmoothLines".} # Enable line aliasing
proc rlDisableSmoothLines*() {.RLAPI, importc: "rlDisableSmoothLines".} # Disable line aliasing
proc rlEnableStereoRender*() {.RLAPI, importc: "rlEnableStereoRender".} # Enable stereo rendering
proc rlDisableStereoRender*() {.RLAPI, importc: "rlDisableStereoRender".} # Disable stereo rendering
proc rlIsStereoRenderEnabled*(): bool {.RLAPI, importc: "rlIsStereoRenderEnabled".} # Check if stereo render is enabled
proc rlClearColor*(r: uint8; g: uint8; b: uint8; a: uint8) {.RLAPI, importc: "rlClearColor".} # Clear color buffer with color
proc rlClearScreenBuffers*() {.RLAPI, importc: "rlClearScreenBuffers".} # Clear used screen buffers (color and depth)
proc rlCheckErrors*() {.RLAPI, importc: "rlCheckErrors".} # Check and log OpenGL error codes
proc rlSetBlendMode*(mode: int32) {.RLAPI, importc: "rlSetBlendMode".} # Set blending mode
proc rlSetBlendFactors*(glSrcFactor: int32; glDstFactor: int32; glEquation: int32) {.RLAPI, importc: "rlSetBlendFactors".} # Set blending mode factor and equation (using OpenGL factors)
# ------------------------------------------------------------------------------------
# Functions Declaration - rlgl functionality
# ------------------------------------------------------------------------------------
# rlgl initialization functions
proc rlglInit*(width: int32; height: int32) {.RLAPI, importc: "rlglInit".} # Initialize rlgl (buffers, shaders, textures, states)
proc rlglClose*() {.RLAPI, importc: "rlglClose".} # De-inititialize rlgl (buffers, shaders, textures)
proc rlLoadExtensions*(loader: pointer) {.RLAPI, importc: "rlLoadExtensions".} # Load OpenGL extensions (loader function required)
proc rlGetVersion*(): int32 {.RLAPI, importc: "rlGetVersion".} # Get current OpenGL version
proc rlGetFramebufferWidth*(): int32 {.RLAPI, importc: "rlGetFramebufferWidth".} # Get default framebuffer width
proc rlGetFramebufferHeight*(): int32 {.RLAPI, importc: "rlGetFramebufferHeight".} # Get default framebuffer height
proc rlGetShaderDefault*(): Shader {.RLAPI, importc: "rlGetShaderDefault".} # Get default shader
proc rlGetTextureDefault*(): Texture2D {.RLAPI, importc: "rlGetTextureDefault".} # Get default texture
# Render batch management
# NOTE: rlgl provides a default render batch to behave like OpenGL 1.1 immediate mode
# but this render batch API is exposed in case of custom batches are required
proc rlLoadRenderBatch*(numBuffers: int32; bufferElements: int32): RenderBatch {.RLAPI, importc: "rlLoadRenderBatch".} # Load a render batch system
proc rlUnloadRenderBatch*(batch: RenderBatch) {.RLAPI, importc: "rlUnloadRenderBatch".} # Unload render batch system
proc rlDrawRenderBatch*(batch: ptr RenderBatch) {.RLAPI, importc: "rlDrawRenderBatch".} # Draw render batch data (Update->Draw->Reset)
proc rlSetRenderBatchActive*(batch: ptr RenderBatch) {.RLAPI, importc: "rlSetRenderBatchActive".} # Set the active render batch for rlgl (NULL for default internal)
proc rlDrawRenderBatchActive*() {.RLAPI, importc: "rlDrawRenderBatchActive".} # Update and draw internal render batch
proc rlCheckRenderBatchLimit*(vCount: int32): bool {.RLAPI, importc: "rlCheckRenderBatchLimit".} # Check internal buffer overflow for a given number of vertex
proc rlSetTexture*(id: uint32) {.RLAPI, importc: "rlSetTexture".} # Set current texture for render batch and check buffers limits
# ------------------------------------------------------------------------------------------------------------------------
# Vertex buffers management
proc rlLoadVertexArray*(): uint32 {.RLAPI, importc: "rlLoadVertexArray".} # Load vertex array (vao) if supported
proc rlLoadVertexBuffer*(buffer: pointer; size: int32; dynamic: bool): uint32 {.RLAPI, importc: "rlLoadVertexBuffer".} # Load a vertex buffer attribute
proc rlLoadVertexBufferElement*(buffer: pointer; size: int32; dynamic: bool): uint32 {.RLAPI, importc: "rlLoadVertexBufferElement".} # Load a new attributes element buffer
proc rlUpdateVertexBuffer*(bufferId: int32; data: pointer; dataSize: int32; offset: int32) {.RLAPI, importc: "rlUpdateVertexBuffer".} # Update GPU buffer with new data
proc rlUnloadVertexArray*(vaoId: uint32) {.RLAPI, importc: "rlUnloadVertexArray".} 
proc rlUnloadVertexBuffer*(vboId: uint32) {.RLAPI, importc: "rlUnloadVertexBuffer".} 
proc rlSetVertexAttribute*(index: uint32; compSize: int32; typex: int32; normalized: bool; stride: int32; pointer: pointer) {.RLAPI, importc: "rlSetVertexAttribute".} 
proc rlSetVertexAttributeDivisor*(index: uint32; divisor: int32) {.RLAPI, importc: "rlSetVertexAttributeDivisor".} 
proc rlSetVertexAttributeDefault*(locIndex: int32; value: pointer; attribType: int32; count: int32) {.RLAPI, importc: "rlSetVertexAttributeDefault".} # Set vertex attribute default value
proc rlDrawVertexArray*(offset: int32; count: int32) {.RLAPI, importc: "rlDrawVertexArray".} 
proc rlDrawVertexArrayElements*(offset: int32; count: int32; buffer: pointer) {.RLAPI, importc: "rlDrawVertexArrayElements".} 
proc rlDrawVertexArrayInstanced*(offset: int32; count: int32; instances: int32) {.RLAPI, importc: "rlDrawVertexArrayInstanced".} 
proc rlDrawVertexArrayElementsInstanced*(offset: int32; count: int32; buffer: pointer; instances: int32) {.RLAPI, importc: "rlDrawVertexArrayElementsInstanced".} 
# Textures management
proc rlLoadTexture*(data: pointer; width: int32; height: int32; format: int32; mipmapCount: int32): uint32 {.RLAPI, importc: "rlLoadTexture".} # Load texture in GPU
proc rlLoadTextureDepth*(width: int32; height: int32; useRenderBuffer: bool): uint32 {.RLAPI, importc: "rlLoadTextureDepth".} # Load depth texture/renderbuffer (to be attached to fbo)
proc rlLoadTextureCubemap*(data: pointer; size: int32; format: int32): uint32 {.RLAPI, importc: "rlLoadTextureCubemap".} # Load texture cubemap
proc rlUpdateTexture*(id: uint32; offsetX: int32; offsetY: int32; width: int32; height: int32; format: int32; data: pointer) {.RLAPI, importc: "rlUpdateTexture".} # Update GPU texture with new data
proc rlGetGlTextureFormats*(format: int32; glInternalFormat: uint32; glFormat: uint32; glType: uint32) {.RLAPI, importc: "rlGetGlTextureFormats".} # Get OpenGL internal formats
proc rlGetPixelFormatName*(format: uint32): cstring {.RLAPI, importc: "rlGetPixelFormatName".} # Get name string for pixel format
proc rlUnloadTexture*(id: uint32) {.RLAPI, importc: "rlUnloadTexture".} # Unload texture from GPU memory
proc rlGenerateMipmaps*(texture: ptr Texture2D) {.RLAPI, importc: "rlGenerateMipmaps".} # Generate mipmap data for selected texture
proc rlReadTexturePixels*(texture: Texture2D): pointer {.RLAPI, importc: "rlReadTexturePixels".} # Read texture pixel data
proc rlReadScreenPixels*(width: int32; height: int32): uint8 {.RLAPI, importc: "rlReadScreenPixels".} # Read screen pixel data (color buffer)
# Framebuffer management (fbo)
proc rlLoadFramebuffer*(width: int32; height: int32): uint32 {.RLAPI, importc: "rlLoadFramebuffer".} # Load an empty framebuffer
proc rlFramebufferAttach*(fboId: uint32; texId: uint32; attachType: int32; texType: int32; mipLevel: int32) {.RLAPI, importc: "rlFramebufferAttach".} # Attach texture/renderbuffer to a framebuffer
proc rlFramebufferComplete*(id: uint32): bool {.RLAPI, importc: "rlFramebufferComplete".} # Verify framebuffer is complete
proc rlUnloadFramebuffer*(id: uint32) {.RLAPI, importc: "rlUnloadFramebuffer".} # Delete framebuffer from GPU
# Shaders management
proc rlLoadShaderCode*(vsCode: cstring; fsCode: cstring): uint32 {.RLAPI, importc: "rlLoadShaderCode".} # Load shader from code strings
proc rlCompileShader*(shaderCode: cstring; typex: int32): uint32 {.RLAPI, importc: "rlCompileShader".} # Compile custom shader and return shader id (type: GL_VERTEX_SHADER, GL_FRAGMENT_SHADER)
proc rlLoadShaderProgram*(vShaderId: uint32; fShaderId: uint32): uint32 {.RLAPI, importc: "rlLoadShaderProgram".} # Load custom shader program
proc rlUnloadShaderProgram*(id: uint32) {.RLAPI, importc: "rlUnloadShaderProgram".} # Unload shader program
proc rlGetLocationUniform*(shaderId: uint32; uniformName: cstring): int32 {.RLAPI, importc: "rlGetLocationUniform".} # Get shader location uniform
proc rlGetLocationAttrib*(shaderId: uint32; attribName: cstring): int32 {.RLAPI, importc: "rlGetLocationAttrib".} # Get shader location attribute
proc rlSetUniform*(locIndex: int32; value: pointer; uniformType: int32; count: int32) {.RLAPI, importc: "rlSetUniform".} # Set shader value uniform
proc rlSetUniformMatrix*(locIndex: int32; mat: Matrix) {.RLAPI, importc: "rlSetUniformMatrix".} # Set shader value matrix
proc rlSetUniformSampler*(locIndex: int32; textureId: uint32) {.RLAPI, importc: "rlSetUniformSampler".} # Set shader value sampler
proc rlSetShader*(shader: Shader) {.RLAPI, importc: "rlSetShader".} # Set shader currently active
# Matrix state management
proc rlGetMatrixModelview*(): Matrix {.RLAPI, importc: "rlGetMatrixModelview".} # Get internal modelview matrix
proc rlGetMatrixProjection*(): Matrix {.RLAPI, importc: "rlGetMatrixProjection".} # Get internal projection matrix
proc rlGetMatrixTransform*(): Matrix {.RLAPI, importc: "rlGetMatrixTransform".} # Get internal accumulated transform matrix
proc rlGetMatrixProjectionStereo*(eye: int32): Matrix {.RLAPI, importc: "rlGetMatrixProjectionStereo".} # Get internal projection matrix for stereo render (selected eye)
proc rlGetMatrixViewOffsetStereo*(eye: int32): Matrix {.RLAPI, importc: "rlGetMatrixViewOffsetStereo".} # Get internal view offset matrix for stereo render (selected eye)
proc rlSetMatrixProjection*(proj: Matrix) {.RLAPI, importc: "rlSetMatrixProjection".} # Set a custom projection matrix (replaces internal projection matrix)
proc rlSetMatrixModelview*(view: Matrix) {.RLAPI, importc: "rlSetMatrixModelview".} # Set a custom modelview matrix (replaces internal modelview matrix)
proc rlSetMatrixProjectionStereo*(right: Matrix; left: Matrix) {.RLAPI, importc: "rlSetMatrixProjectionStereo".} # Set eyes projection matrices for stereo rendering
proc rlSetMatrixViewOffsetStereo*(right: Matrix; left: Matrix) {.RLAPI, importc: "rlSetMatrixViewOffsetStereo".} # Set eyes view offsets matrices for stereo rendering
# Quick and dirty cube/quad buffers load->draw->unload
proc rlLoadDrawCube*() {.RLAPI, importc: "rlLoadDrawCube".} # Load and draw a cube
proc rlLoadDrawQuad*() {.RLAPI, importc: "rlLoadDrawQuad".} # Load and draw a quad
# 
#   RLGL IMPLEMENTATION
# 
type rlglLoadProc* = proc()
# ----------------------------------------------------------------------------------
# Global Variables Definition
# ----------------------------------------------------------------------------------