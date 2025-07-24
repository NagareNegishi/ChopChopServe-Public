Based on the official GDScript styleguide: 
https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html

This is not final, but please suggest changes ASAP so we do not need to adapt written code.

In the following documentation "parentheses" refer to ( ), "brackets" refer to [ ], and "braces" refer to { }

# Indentation/Whitespace:
* Use one tab—not four spaces—for indents.
* Character limit per line is 80 (soft limit) to 100 (hard limit). 
Upon exceeding this limit, move to a new line with a __double indent__ (2 tabs) in a suitable 
location (e.g. before a keyword/operator, after a comma).
  * In some cases (e.g. conditionals) you may be required to surround the statement with parentheses 
in order to wrap it.
  * You may copy/paste the following guide to check your line length. Alternatively, the Godot editor
has two vertical lines, one immediately after 80 and one immediately after 100.
```
#---v----x----v----x----v----x----v----x----v----x----v----x----v----x----v----x80--v----x----v----x100
```
* Include two blank lines between functions.
* Operators (e.g. =, ==, +, %, ->) should have a preceding and a succeeding space.
  * Please do not add more than one space to align expressions vertically.
* Commas, colons, and open braces should have a following space, unless this results 
in trailing whitespace.
* Closing braces should have a preceding space.

# Collections:
* Although collections may be single-line or multi-line at the discretion of the programmer, enums should always be written in multi-line format.
  * If a single-line collections would exceed the line limit, then it should instead be written in multi-line format.
  * Multi-line collections should have one element per line, utilising a single indent, and feature a 
__trailing comma__ at the end for easier refactoring. Enums should always be multi-line.
  * Single-line collections should not feature a trailing comma.
```
Good:
var integer_array = [
	1,
	2,
	3,
]

var integer_array = [1,2,3]

Bad:
var integer_array = [
		1,
		2,
		3
]
var integer_array = [1,2,3,]
```

# Conditionals:
* Avoid combining multiple statements on a single line, unless using a ternary:
```
Good:
if position.x > width:
	position.x = 0
else:
	position.x += 1

Good:
position.x = 0 if position.x > width else position.x + 1

Bad:
if position.x > width: position.x = 0
else: position.x += 1
```
* Parentheses should only be used if the conditional spans multiple lines:
```
Good:
if (position.x > 200
		and position.y > 200):

if (
		position.x > 200
		and position.y > 200
):

if position.x > 200:

Bad:
if (position.x > 200):
```
* Use operator names not symbols (````&&/||/!```` instead of ````and/or/not````)

# Comments:
* Comments/Doc-comments should begin with a space; commented out code should not:
```
## Moves the player in response to the w key
# TODO Fix this function
#func move_up():
```
# Data Types:
* Use double quotes, not single quotes, to reference Strings
* Include the trailing ```.0``` in floats.
* Separate any numbers with more than six digits using underscores: ```1_000_000_000```

# Naming Conventions:
* Use snake_case for file names
* Use PascalCase for classes, nodes, and enums
* Use snake_case for variables and functions
  * Append an underscore at the start of private and virtual (abstract/overridden) variables/functions
* Use CONSTANT_CASE for constants and enum constants

# Script Layout:
* While not a hard-and-fast rule, the following order is recommended:
  * class_name
  * extends
  * \## doc-comment
  * signals
  * enums
  * constants
  * @export variables
  * public variables
  * private variables
  * @onready variables
  * _init()
  * _enter_tree()
  * _ready()
  * other built-in methods
  * public methods
  * private methods
  * subclasses
* Declare local variables as close as possible to their first use.

# Variables:
* Only use the walrus operator if the type is unambiguous/explicitly stated elsewhere:
```
Good:
var direction := Vector3(1,2,3)

var health: int = 0

Bad:
var direction := complex_function()
	
var health := 0
```
