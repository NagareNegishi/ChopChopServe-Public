* Group discussion on the **development process**

## Strenghts and weaknesses of the game you have developed


**Strengths:**
- **Visual appeal**: Having three designers on the team made the game visually unique and appealing
- **Functional complexity**: The game implements relatively complicated cooking logic that is mostly functional
- **Multiplayer flexibility**: While not supporting browser-based hosting or perfect internet hosting, the game supports:
  - LAN multiplayer
  - Automatic UPnP configuration when the host environment supports it
  - Room code generation when the host provides a valid IP format, simplifying the joining process for clients

**Weaknesses:**
- **Design-first approach challenges**: While visual strength is a key asset, some aspects were developed design-first without adequate discussion of implementation feasibility or functional necessity beyond aesthetics. This created implementation challenges including:
  - Extensive hardcoding through the editor
  - Added dependencies that could have been avoided
- **Insufficient player feedback**: Although complicated cooking logic was successfully implemented, visual feedback communicating gameplay state and player objectives was inadequate (this was being addressed late in development and may be improved before submission)
- **Limited accessibility for non-technical players**: Multiplayer functionality lacks sufficient support for non-technical users, requiring either manual port forwarding configuration or a relay server solution


## How you controlled the process and communication systems during development


**Project Management (GitHub):**
- Used GitHub as the primary project management platform
- Organized work into 4 milestones corresponding to each course submission
- Maintained a roadmap to manage timelines and deliverables
- Each member created and managed their own issues using smart commits for tracking
- Established Wednesday as a mandatory merge day in addition to frequent merges

**Team Meetings:**
- Held a minimum of 2 weekly meetings for team communication:
  - In-person meeting every Wednesday
  - Online meeting every Sunday
- Conducted occasional additional meetings specifically for programmers to discuss technical implementation

**Daily Communication (Discord):**
- Used Discord intensively for day-to-day communication:
  - Addressing bugs and discussing new ideas as they arose
  - Reporting daily tasks and progress updates
  - Sharing ideas and coordinating implementation details
  - Hosting online meetings

**Design and Documentation Tools:**
- **Figma**: Attempted to use for sharing high-level design concepts, but this approach was not successful
- **Google Docs**: Used to create shared documents, particularly for the Milestone 2 report

**Code Quality:**
- Conducted one formal code review session, which also served as an opportunity to share high-level implementation approaches across the team


## Use of version control systems, ticket tracking, branching, version control


**Version Control and Branching (Git/GitHub):**
- Each member created and developed in their own feature branch, merging into main upon completion
- Initially agreed on a pull request policy requiring 2 approvals; while this was not consistently maintained, most pull requests received at least one approval
- Members merged from the latest main branch before creating pull requests to minimize conflicts
- Frequent merges combined with the mandatory weekly merge schedule successfully avoided serious conflicts
- **Challenges encountered:**
  - At key deadlines with multiple concurrent pull requests, merge order was occasionally ignored, creating small conflicts
  - Issues included: code duplication, old code overriding latest work, and pull requests modifying others' code without their approval

**Repository Structure:**
- Used one member's private repository as the main repository
- Some members forked the main repository and configured both upstream and downstream connections

**Ticket Tracking (GitHub Issues):**
- Created issues for tasks estimated to require more than 3 hours of work
- Used smart commits to link each commit to its corresponding issue
- Applied labels to categorize tasks:
  - Type labels: development, test, bug.....
  - Priority tags for important tasks

**Continuous Deployment:**
- Connected GitHub to Railway for automatic deployment of the room code lookup server whenever implementation changes were pushed


## Discussion of best parts of the game/development process as a group


**Positive Team Dynamics:**
The strongest aspect of our development process was how team members remained positive and engaged throughout the project. Even when facing disagreements on implementation approaches, each member made genuine efforts to understand others' intentions and worked collaboratively to polish the game in the most engaging direction possible.

**Collaborative Problem-Solving:**
The food crate implementation exemplifies our collaborative approach well. This feature underwent multiple iterations during development:

1. **Initial design**: Simple player key input → each food crate contained one food item that players could obtain with a single key press

2. **First redesign - Challenge identified**: This design made stage layout difficult as it required too many food crates in the kitchen
   - **Team solution**: Held a meeting and collectively decided to redesign food crates to contain multiple food items, which required:
     - Redesigning the food crate implementation
     - Creating a UI system to display multiple selection options
     - Modifying how player interactions were triggered
     - Began discussions about how to categorize food types
     - Discarded the already-implemented "fridge" (which was for cooking cold food) in favor of a type-based food crate system

3. **Second redesign - Simplification**: Having multiple food crates still made stage design difficult
   - **Team solution**: Discarded the multiple ingredient food crate implementation and consolidated everything into a single "fridge" containing all food types
   - Implemented a UI for this unified fridge system; however, the team identified two concerns about how it fit into the game flow:
     - **Mouse-based input limitation**: The mouse input system limited user interaction options and conflicted with gamepad control implementation that another member was developing
     - **Charging mechanic**: Introduced an ingredient charging system to compensate for the simplified design, as moving to the food crate takes time and the consolidated system needed a balancing mechanism to prevent it from being overpowered

4. **Final redesign - Integration phase**: After another team discussion and consulting with course coordinators, we decided to:
   - Completely redo the UI system
   - Refactor the food factory (the latest version of the food crate)
   - Create a new class to represent the visual aspect of the food crate
   - This required integrating the work of 3 team members

Despite this feature requiring significant rework and creating substantial additional work for one part of the game, the team remained positive and constructive throughout. No team member displayed negative attitudes or opinions during these multiple pivots. When members had different implementation ideas, conversations about merging approaches were consistently conducted in a friendly, constructive manner, demonstrating our commitment to collaborative development and quality outcomes.

**Responsive Communication:**
As a group of 7 with varying schedules, timing coordination was not always perfect. However, members consistently made their best efforts to respond promptly. When issues arose requiring specific team members' attention, we typically received responses within 12 hours, with most issues being addressed within 48 hours. When delays were unavoidable, members proactively communicated their schedules and estimated response times.






