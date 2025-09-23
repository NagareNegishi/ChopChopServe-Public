- [The Standard of Code Review](https://google.github.io/eng-practices/review/reviewer/standard.html)
- [Code review process](https://developers.google.com/blockly/guides/contribute/get-started/pr_review_process)

If coding with Godot editor: Project Settings → Debug → Settings → Verbose Stdout

Potential quick tool "gdtoolkit" (but it's not great):
1. pip install gdtoolkit
2. Navigate to that file directory
3. python -m gdtoolkit.linter ????????.gd

```
gdlint your_file.gd  # See what issues exist
gdformat --diff your_file.gd  # Shows what WOULD change without changing
gdformat your_file.gd  # Actually makes changes
```


## Template comment in general

```
#[REVIEW][PERFORMANCE] N+1 query pattern here - consider batching
#[REVIEW][SECURITY] User input not validated - potential injection risk
#[REVIEW][ARCHITECTURE] Direct node access - should use signals instead
#[REVIEW][NITPICK] Missing type hints on parameters
#[REVIEW][TECHNICAL_DEBT] Hardcoded magic numbers - move to constants
#[REVIEW][POTENTIAL_BUG] Null reference exception possible here
#[REVIEW][CODE_STYLE] Inconsistent naming convention with project standards
#[REVIEW][DOCUMENTATION] Missing function documentation and parameter descriptions
#[REVIEW][MAINTAINABILITY] Complex nested logic - consider refactoring
#[REVIEW][GODOT_BEST_PRACTICE] Should use built-in Godot patterns here
```

## Code Quality & Structure

```
#[REVIEW][CODE_COMPLEXITY]      # Functions too long, nested loops, high cyclomatic complexity
#[REVIEW][CODE_DUPLICATION]     # Repeated code blocks that should be extracted
#[REVIEW][COUPLING]             # Classes/modules too tightly coupled
#[REVIEW][COHESION]             # Class doing too many unrelated things
#[REVIEW][ABSTRACTION]          # Missing interfaces, poor abstractions
#[REVIEW][SEPARATION_OF_CONCERNS] # Business logic mixed with UI/data access
```

## Godot Engine Specific

```
#[REVIEW][SIGNAL_USAGE]         # Missing signals, direct node coupling
#[REVIEW][SCENE_STRUCTURE]      # Node hierarchy issues, scene organization
#[REVIEW][AUTOLOAD_MISUSE]      # Singleton pattern violations
#[REVIEW][EXPORT_VARIABLES]     # Missing @export annotations, inspector setup
#[REVIEW][NODE_REFERENCES]      # get_node() vs @onready var usage
#[REVIEW][TOOL_SCRIPT]          # Editor script functionality issues
#[REVIEW][PHYSICS_PERFORMANCE]  # Physics calculations in wrong methods
#[REVIEW][ANIMATION_LOGIC]      # AnimationPlayer/Tween usage issues
```

## Data & State Management

```
#[REVIEW][DATA_VALIDATION]      # Input sanitization, type checking
#[REVIEW][STATE_MANAGEMENT]     # Global state issues, state synchronization
#[REVIEW][DATA_PERSISTENCE]     # Save/load logic, file handling
#[REVIEW][MEMORY_LEAK]          # Objects not properly freed, circular references
#[REVIEW][VARIABLE_SCOPE]       # Global variables, scope issues
#[REVIEW][IMMUTABILITY]         # Unintended state mutations
```

## User Experience & Interface

```
#[REVIEW][USER_EXPERIENCE]      # Poor UX patterns, confusing interactions
#[REVIEW][INPUT_HANDLING]       # Keyboard/mouse/controller input issues
#[REVIEW][LOCALIZATION]         # Hardcoded strings, translation missing
#[REVIEW][RESPONSIVE_DESIGN]    # UI doesn't adapt to different screen sizes
#[REVIEW][FEEDBACK_SYSTEMS]     # Missing visual/audio feedback for actions
```

## Development & Process

```
#[REVIEW][VERSION_CONTROL]      # Large files, binary assets in repo
#[REVIEW][BACKWARDS_COMPATIBILITY] # Breaking changes, migration issues
#[REVIEW][API_DESIGN]           # Public interface design, method signatures
#[REVIEW][DEPENDENCY_MANAGEMENT] # External dependencies, version conflicts
#[REVIEW][BUILD_PROCESS]        # Export settings, build configuration
#[REVIEW][DEBUGGING_CODE]       # print() statements, debug flags left in
```

## Business Logic & Domain

```
#[REVIEW][BUSINESS_LOGIC]       # Game rules, domain logic errors
#[REVIEW][EDGE_CASES]           # Unhandled boundary conditions
#[REVIEW][REQUIREMENTS]         # Implementation doesn't match specs
#[REVIEW][SCALABILITY]          # Won't work with larger datasets/users
#[REVIEW][ASSUMPTIONS]          # Implicit assumptions that may not hold
```