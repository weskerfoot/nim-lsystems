# 
#   raygui v2.9-dev - A simple and easy-to-use immediate-mode gui library
# 
#   DESCRIPTION:
# 
#   raygui is a tools-dev-focused immediate-mode-gui library based on raylib but also
#   available as a standalone library, as long as input and drawing functions are provided.
# 
#   Controls provided:
# 
#   # Container/separators Controls
#       - WindowBox
#       - GroupBox
#       - Line
#       - Panel
# 
#   # Basic Controls
#       - Label
#       - Button
#       - LabelButton   --> Label
#       - ImageButton   --> Button
#       - ImageButtonEx --> Button
#       - Toggle
#       - ToggleGroup   --> Toggle
#       - CheckBox
#       - ComboBox
#       - DropdownBox
#       - TextBox
#       - TextBoxMulti
#       - ValueBox      --> TextBox
#       - Spinner       --> Button, ValueBox
#       - Slider
#       - SliderBar     --> Slider
#       - ProgressBar
#       - StatusBar
#       - ScrollBar
#       - ScrollPanel
#       - DummyRec
#       - Grid
# 
#   # Advance Controls
#       - ListView
#       - ColorPicker   --> ColorPanel, ColorBarHue
#       - MessageBox    --> Window, Label, Button
#       - TextInputBox  --> Window, Label, TextBox, Button
# 
#   It also provides a set of functions for styling the controls based on its properties (size, color).
# 
#   CONFIGURATION:
# 
#   #define RAYGUI_IMPLEMENTATION
#       Generates the implementation of the library into the included file.
#       If not defined, the library is in header only mode and can be included in other headers
#       or source files without problems. But only ONE file should hold the implementation.
# 
#   #define RAYGUI_STATIC (defined by default)
#       The generated implementation will stay private inside implementation file and all
#       internal symbols and functions will only be visible inside that file.
# 
#   #define RAYGUI_STANDALONE
#       Avoid raylib.h header inclusion in this file. Data types defined on raylib are defined
#       internally in the library and input management and drawing functions must be provided by
#       the user (check library implementation for further details).
# 
#   #define RAYGUI_SUPPORT_ICONS
#       Includes riconsdata.h header defining a set of 128 icons (binary format) to be used on
#       multiple controls and following raygui styles
# 
# 
#   VERSIONS HISTORY:
#       2.9 (17-Mar-2021) Removed tooltip API
#       2.8 (03-May-2020) Centralized rectangles drawing to GuiDrawRectangle()
#       2.7 (20-Feb-2020) Added possible tooltips API
#       2.6 (09-Sep-2019) ADDED: GuiTextInputBox()
#                         REDESIGNED: GuiListView*(), GuiDropdownBox(), GuiSlider*(), GuiProgressBar(), GuiMessageBox()
#                         REVIEWED: GuiTextBox(), GuiSpinner(), GuiValueBox(), GuiLoadStyle()
#                         Replaced property INNER_PADDING by TEXT_PADDING, renamed some properties
#                         Added 8 new custom styles ready to use
#                         Multiple minor tweaks and bugs corrected
#       2.5 (28-May-2019) Implemented extended GuiTextBox(), GuiValueBox(), GuiSpinner()
#       2.3 (29-Apr-2019) Added rIcons auxiliar library and support for it, multiple controls reviewed
#                         Refactor all controls drawing mechanism to use control state
#       2.2 (05-Feb-2019) Added GuiScrollBar(), GuiScrollPanel(), reviewed GuiListView(), removed Gui*Ex() controls
#       2.1 (26-Dec-2018) Redesign of GuiCheckBox(), GuiComboBox(), GuiDropdownBox(), GuiToggleGroup() > Use combined text string
#                         Complete redesign of style system (breaking change)
#       2.0 (08-Nov-2018) Support controls guiLock and custom fonts, reviewed GuiComboBox(), GuiListView()...
#       1.9 (09-Oct-2018) Controls review: GuiGrid(), GuiTextBox(), GuiTextBoxMulti(), GuiValueBox()...
#       1.8 (01-May-2018) Lot of rework and redesign to align with rGuiStyler and rGuiLayout
#       1.5 (21-Jun-2017) Working in an improved styles system
#       1.4 (15-Jun-2017) Rewritten all GUI functions (removed useless ones)
#       1.3 (12-Jun-2017) Redesigned styles system
#       1.1 (01-Jun-2017) Complete review of the library
#       1.0 (07-Jun-2016) Converted to header-only by Ramon Santamaria.
#       0.9 (07-Mar-2016) Reviewed and tested by Albert Martos, Ian Eito, Sergio Martinez and Ramon Santamaria.
#       0.8 (27-Aug-2015) Initial release. Implemented by Kevin Gato, Daniel Nicolás and Ramon Santamaria.
# 
#   CONTRIBUTORS:
#       Ramon Santamaria:   Supervision, review, redesign, update and maintenance...
#       Vlad Adrian:        Complete rewrite of GuiTextBox() to support extended features (2019)
#       Sergio Martinez:    Review, testing (2015) and redesign of multiple controls (2018)
#       Adria Arranz:       Testing and Implementation of additional controls (2018)
#       Jordi Jorba:        Testing and Implementation of additional controls (2018)
#       Albert Martos:      Review and testing of the library (2015)
#       Ian Eito:           Review and testing of the library (2015)
#       Kevin Gato:         Initial implementation of basic components (2014)
#       Daniel Nicolas:     Initial implementation of basic components (2014)
# 
# 
#   LICENSE: zlib/libpng
# 
#   Copyright (c) 2014-2020 Ramon Santamaria (@raysan5)
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
template RAYGUI_H*(): auto = RAYGUI_H
template RAYGUI_VERSION*(): auto = "2.9-dev"
import raylib
# Define functions scope to be used internally (static) or externally (extern) to the module including this file
{.pragma: RAYGUIDEF, cdecl, discardable, dynlib: "raygui" & LEXT.}
# Allow custom memory allocators
# ----------------------------------------------------------------------------------
# Defines and Macros
# ----------------------------------------------------------------------------------
template NUM_CONTROLS*(): auto = 16
template NUM_PROPS_DEFAULT*(): auto = 16
template NUM_PROPS_EXTENDED*(): auto = 8
template TEXTEDIT_CURSOR_BLINK_FRAMES*(): auto = 20
# ----------------------------------------------------------------------------------
# Types and Structures Definition
# NOTE: Some types are required for RAYGUI_STANDALONE usage
# ----------------------------------------------------------------------------------
# Style property
type GuiStyleProp* {.bycopy.} = object
    controlId*: uint16 
    propertyId*: uint16 
    propertyValue*: int32 
# Gui control state
type GuiControlState* = enum 
    GUI_STATE_NORMAL = 0 
    GUI_STATE_FOCUSED 
    GUI_STATE_PRESSED 
    GUI_STATE_DISABLED 
converter GuiControlState2int32* (self: GuiControlState): int32 = self.int32 
# Gui control text alignment
type GuiTextAlignment* = enum 
    GUI_TEXT_ALIGN_LEFT = 0 
    GUI_TEXT_ALIGN_CENTER 
    GUI_TEXT_ALIGN_RIGHT 
converter GuiTextAlignment2int32* (self: GuiTextAlignment): int32 = self.int32 
# Gui controls
type GuiControl* = enum 
    DEFAULT = 0 
    LABEL # LABELBUTTON
    BUTTON # IMAGEBUTTON
    TOGGLE # TOGGLEGROUP
    SLIDER # SLIDERBAR
    PROGRESSBAR 
    CHECKBOX 
    COMBOBOX 
    DROPDOWNBOX 
    TEXTBOX # TEXTBOXMULTI
    VALUEBOX 
    SPINNER 
    LISTVIEW 
    COLORPICKER 
    SCROLLBAR 
    STATUSBAR 
converter GuiControl2int32* (self: GuiControl): int32 = self.int32 
# Gui base properties for every control
type GuiControlProperty* = enum 
    BORDER_COLOR_NORMAL = 0 
    BASE_COLOR_NORMAL 
    TEXT_COLOR_NORMAL 
    BORDER_COLOR_FOCUSED 
    BASE_COLOR_FOCUSED 
    TEXT_COLOR_FOCUSED 
    BORDER_COLOR_PRESSED 
    BASE_COLOR_PRESSED 
    TEXT_COLOR_PRESSED 
    BORDER_COLOR_DISABLED 
    BASE_COLOR_DISABLED 
    TEXT_COLOR_DISABLED 
    BORDER_WIDTH 
    TEXT_PADDING 
    TEXT_ALIGNMENT 
    RESERVED 
converter GuiControlProperty2int32* (self: GuiControlProperty): int32 = self.int32 
# Gui extended properties depend on control
# NOTE: We reserve a fixed size of additional properties per control
# DEFAULT properties
type GuiDefaultProperty* = enum 
    TEXT_SIZE = 16 
    TEXT_SPACING 
    LINE_COLOR 
    BACKGROUND_COLOR 
converter GuiDefaultProperty2int32* (self: GuiDefaultProperty): int32 = self.int32 
# Label
# typedef enum { } GuiLabelProperty;
# Button
# typedef enum { } GuiButtonProperty;
# Toggle / ToggleGroup
type GuiToggleProperty* = enum 
    GROUP_PADDING = 16 
converter GuiToggleProperty2int32* (self: GuiToggleProperty): int32 = self.int32 
# Slider / SliderBar
type GuiSliderProperty* = enum 
    SLIDER_WIDTH = 16 
    SLIDER_PADDING 
converter GuiSliderProperty2int32* (self: GuiSliderProperty): int32 = self.int32 
# ProgressBar
type GuiProgressBarProperty* = enum 
    PROGRESS_PADDING = 16 
converter GuiProgressBarProperty2int32* (self: GuiProgressBarProperty): int32 = self.int32 
# CheckBox
type GuiCheckBoxProperty* = enum 
    CHECK_PADDING = 16 
converter GuiCheckBoxProperty2int32* (self: GuiCheckBoxProperty): int32 = self.int32 
# ComboBox
type GuiComboBoxProperty* = enum 
    COMBO_BUTTON_WIDTH = 16 
    COMBO_BUTTON_PADDING 
converter GuiComboBoxProperty2int32* (self: GuiComboBoxProperty): int32 = self.int32 
# DropdownBox
type GuiDropdownBoxProperty* = enum 
    ARROW_PADDING = 16 
    DROPDOWN_ITEMS_PADDING 
converter GuiDropdownBoxProperty2int32* (self: GuiDropdownBoxProperty): int32 = self.int32 
# TextBox / TextBoxMulti / ValueBox / Spinner
type GuiTextBoxProperty* = enum 
    TEXT_INNER_PADDING = 16 
    TEXT_LINES_PADDING 
    COLOR_SELECTED_FG 
    COLOR_SELECTED_BG 
converter GuiTextBoxProperty2int32* (self: GuiTextBoxProperty): int32 = self.int32 
# Spinner
type GuiSpinnerProperty* = enum 
    SPIN_BUTTON_WIDTH = 16 
    SPIN_BUTTON_PADDING 
converter GuiSpinnerProperty2int32* (self: GuiSpinnerProperty): int32 = self.int32 
# ScrollBar
type GuiScrollBarProperty* = enum 
    ARROWS_SIZE = 16 
    ARROWS_VISIBLE 
    SCROLL_SLIDER_PADDING 
    SCROLL_SLIDER_SIZE 
    SCROLL_PADDING 
    SCROLL_SPEED 
converter GuiScrollBarProperty2int32* (self: GuiScrollBarProperty): int32 = self.int32 
# ScrollBar side
type GuiScrollBarSide* = enum 
    SCROLLBAR_LEFT_SIDE = 0 
    SCROLLBAR_RIGHT_SIDE 
converter GuiScrollBarSide2int32* (self: GuiScrollBarSide): int32 = self.int32 
# ListView
type GuiListViewProperty* = enum 
    LIST_ITEMS_HEIGHT = 16 
    LIST_ITEMS_PADDING 
    SCROLLBAR_WIDTH 
    SCROLLBAR_SIDE 
converter GuiListViewProperty2int32* (self: GuiListViewProperty): int32 = self.int32 
# ColorPicker
type GuiColorPickerProperty* = enum 
    COLOR_SELECTOR_SIZE = 16 
    HUEBAR_WIDTH # Right hue bar width
    HUEBAR_PADDING # Right hue bar separation from panel
    HUEBAR_SELECTOR_HEIGHT # Right hue bar selector height
    HUEBAR_SELECTOR_OVERFLOW # Right hue bar selector overflow
converter GuiColorPickerProperty2int32* (self: GuiColorPickerProperty): int32 = self.int32 
# ----------------------------------------------------------------------------------
# Global Variables Definition
# ----------------------------------------------------------------------------------
# ...
# ----------------------------------------------------------------------------------
# Module Functions Declaration
# ----------------------------------------------------------------------------------
# State modification functions
proc GuiEnable*() {.RAYGUIDEF, importc: "GuiEnable".} # Enable gui controls (global state)
proc GuiDisable*() {.RAYGUIDEF, importc: "GuiDisable".} # Disable gui controls (global state)
proc GuiLock*() {.RAYGUIDEF, importc: "GuiLock".} # Lock gui controls (global state)
proc GuiUnlock*() {.RAYGUIDEF, importc: "GuiUnlock".} # Unlock gui controls (global state)
proc GuiFade*(alpha: float32) {.RAYGUIDEF, importc: "GuiFade".} # Set gui controls alpha (global state), alpha goes from 0.0f to 1.0f
proc GuiSetState*(state: int32) {.RAYGUIDEF, importc: "GuiSetState".} # Set gui state (global state)
proc GuiGetState*(): int32 {.RAYGUIDEF, importc: "GuiGetState".} # Get gui state (global state)
# Font set/get functions
proc GuiSetFont*(font: Font) {.RAYGUIDEF, importc: "GuiSetFont".} # Set gui custom font (global state)
proc GuiGetFont*(): Font {.RAYGUIDEF, importc: "GuiGetFont".} # Get gui custom font (global state)
# Style set/get functions
proc GuiSetStyle*(control: int32; property: int32; value: int32) {.RAYGUIDEF, importc: "GuiSetStyle".} # Set one style property
proc GuiGetStyle*(control: int32; property: int32): int32 {.RAYGUIDEF, importc: "GuiGetStyle".} # Get one style property
# Container/separator controls, useful for controls organization
proc GuiWindowBox*(bounds: Rectangle; title: cstring): bool {.RAYGUIDEF, importc: "GuiWindowBox".} # Window Box control, shows a window that can be closed
proc GuiGroupBox*(bounds: Rectangle; text: cstring) {.RAYGUIDEF, importc: "GuiGroupBox".} # Group Box control with text name
proc GuiLine*(bounds: Rectangle; text: cstring) {.RAYGUIDEF, importc: "GuiLine".} # Line separator control, could contain text
proc GuiPanel*(bounds: Rectangle) {.RAYGUIDEF, importc: "GuiPanel".} # Panel control, useful to group controls
proc GuiScrollPanel*(bounds: Rectangle; content: Rectangle; scroll: ptr Vector2): Rectangle {.RAYGUIDEF, importc: "GuiScrollPanel".} # Scroll Panel control
# Basic controls set
proc GuiLabel*(bounds: Rectangle; text: cstring) {.RAYGUIDEF, importc: "GuiLabel".} # Label control, shows text
proc GuiButton*(bounds: Rectangle; text: cstring): bool {.RAYGUIDEF, importc: "GuiButton".} # Button control, returns true when clicked
proc GuiLabelButton*(bounds: Rectangle; text: cstring): bool {.RAYGUIDEF, importc: "GuiLabelButton".} # Label button control, show true when clicked
proc GuiImageButton*(bounds: Rectangle; text: cstring; texture: Texture2D): bool {.RAYGUIDEF, importc: "GuiImageButton".} # Image button control, returns true when clicked
proc GuiImageButtonEx*(bounds: Rectangle; text: cstring; texture: Texture2D; texSource: Rectangle): bool {.RAYGUIDEF, importc: "GuiImageButtonEx".} # Image button extended control, returns true when clicked
proc GuiToggle*(bounds: Rectangle; text: cstring; active: bool): bool {.RAYGUIDEF, importc: "GuiToggle".} # Toggle Button control, returns true when active
proc GuiToggleGroup*(bounds: Rectangle; text: cstring; active: int32): int32 {.RAYGUIDEF, importc: "GuiToggleGroup".} # Toggle Group control, returns active toggle index
proc GuiCheckBox*(bounds: Rectangle; text: cstring; checked: bool): bool {.RAYGUIDEF, importc: "GuiCheckBox".} # Check Box control, returns true when active
proc GuiComboBox*(bounds: Rectangle; text: cstring; active: int32): int32 {.RAYGUIDEF, importc: "GuiComboBox".} # Combo Box control, returns selected item index
proc GuiDropdownBox*(bounds: Rectangle; text: cstring; active: pointer; editMode: bool): bool {.RAYGUIDEF, importc: "GuiDropdownBox".} # Dropdown Box control, returns selected item
proc GuiSpinner*(bounds: Rectangle; text: cstring; value: pointer; minValue: int32; maxValue: int32; editMode: bool): bool {.RAYGUIDEF, importc: "GuiSpinner".} # Spinner control, returns selected value
proc GuiValueBox*(bounds: Rectangle; text: cstring; value: pointer; minValue: int32; maxValue: int32; editMode: bool): bool {.RAYGUIDEF, importc: "GuiValueBox".} # Value Box control, updates input text with numbers
proc GuiTextBox*(bounds: Rectangle; text: ptr char; textSize: int32; editMode: bool): bool {.RAYGUIDEF, importc: "GuiTextBox".} # Text Box control, updates input text
proc GuiTextBoxMulti*(bounds: Rectangle; text: ptr char; textSize: int32; editMode: bool): bool {.RAYGUIDEF, importc: "GuiTextBoxMulti".} # Text Box control with multiple lines
proc GuiSlider*(bounds: Rectangle; textLeft: cstring; textRight: cstring; value: float32; minValue: float32; maxValue: float32): float32 {.RAYGUIDEF, importc: "GuiSlider".} # Slider control, returns selected value
proc GuiSliderBar*(bounds: Rectangle; textLeft: cstring; textRight: cstring; value: float32; minValue: float32; maxValue: float32): float32 {.RAYGUIDEF, importc: "GuiSliderBar".} # Slider Bar control, returns selected value
proc GuiProgressBar*(bounds: Rectangle; textLeft: cstring; textRight: cstring; value: float32; minValue: float32; maxValue: float32): float32 {.RAYGUIDEF, importc: "GuiProgressBar".} # Progress Bar control, shows current progress value
proc GuiStatusBar*(bounds: Rectangle; text: cstring) {.RAYGUIDEF, importc: "GuiStatusBar".} # Status Bar control, shows info text
proc GuiDummyRec*(bounds: Rectangle; text: cstring) {.RAYGUIDEF, importc: "GuiDummyRec".} # Dummy control for placeholders
proc GuiScrollBar*(bounds: Rectangle; value: int32; minValue: int32; maxValue: int32): int32 {.RAYGUIDEF, importc: "GuiScrollBar".} # Scroll Bar control
proc GuiGrid*(bounds: Rectangle; spacing: float32; subdivs: int32): Vector2 {.RAYGUIDEF, importc: "GuiGrid".} # Grid control
# Advance controls set
proc GuiListView*(bounds: Rectangle; text: cstring; scrollIndex: pointer; active: int32): int32 {.RAYGUIDEF, importc: "GuiListView".} # List View control, returns selected list item index
proc GuiListViewEx*(bounds: Rectangle; text: cstring; count: int32; focus: pointer; scrollIndex: pointer; active: int32): int32 {.RAYGUIDEF, importc: "GuiListViewEx".} # List View with extended parameters
proc GuiMessageBox*(bounds: Rectangle; title: cstring; message: cstring; buttons: cstring): int32 {.RAYGUIDEF, importc: "GuiMessageBox".} # Message Box control, displays a message
proc GuiTextInputBox*(bounds: Rectangle; title: cstring; message: cstring; buttons: cstring; text: ptr char): int32 {.RAYGUIDEF, importc: "GuiTextInputBox".} # Text Input Box control, ask for text
proc GuiColorPicker*(bounds: Rectangle; color: Color): Color {.RAYGUIDEF, importc: "GuiColorPicker".} # Color Picker control (multiple color controls)
proc GuiColorPanel*(bounds: Rectangle; color: Color): Color {.RAYGUIDEF, importc: "GuiColorPanel".} # Color Panel control
proc GuiColorBarAlpha*(bounds: Rectangle; alpha: float32): float32 {.RAYGUIDEF, importc: "GuiColorBarAlpha".} # Color Bar Alpha control
proc GuiColorBarHue*(bounds: Rectangle; value: float32): float32 {.RAYGUIDEF, importc: "GuiColorBarHue".} # Color Bar Hue control
# Styles loading functions
proc GuiLoadStyle*(fileName: cstring) {.RAYGUIDEF, importc: "GuiLoadStyle".} # Load style file (.rgs)
proc GuiLoadStyleDefault*() {.RAYGUIDEF, importc: "GuiLoadStyleDefault".} # Load style default over global style
proc GuiIconText*(iconId: int32; text: cstring): cstring {.RAYGUIDEF, importc: "GuiIconText".} # Get text with icon id prepended (if supported)
# Gui icons functionality
proc GuiDrawIcon*(iconId: int32; position: Vector2; pixelSize: int32; color: Color) {.RAYGUIDEF, importc: "GuiDrawIcon".}
proc GuiGetIcons*(): uint32 {.RAYGUIDEF, importc: "GuiGetIcons".} # Get full icons data pointer
proc GuiGetIconData*(iconId: int32): uint32 {.RAYGUIDEF, importc: "GuiGetIconData".} # Get icon bit data
proc GuiSetIconData*(iconId: int32; data: uint32) {.RAYGUIDEF, importc: "GuiSetIconData".} # Set icon bit data
proc GuiSetIconPixel*(iconId: int32; x: int32; y: int32) {.RAYGUIDEF, importc: "GuiSetIconPixel".} # Set icon pixel value
proc GuiClearIconPixel*(iconId: int32; x: int32; y: int32) {.RAYGUIDEF, importc: "GuiClearIconPixel".} # Clear icon pixel value
proc GuiCheckIconPixel*(iconId: int32; x: int32; y: int32): bool {.RAYGUIDEF, importc: "GuiCheckIconPixel".} # Check icon pixel value
# 
#   RAYGUI IMPLEMENTATION
# 
