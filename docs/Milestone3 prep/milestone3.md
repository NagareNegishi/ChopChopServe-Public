## Development Team from CGRA359

- Johno Devine (CGRA 359, programming)
- Emma Ringwood (CGRA 359, programming)
- Nagare Negishi (CGRA 359, programming)
- Joshua Neylan (CGRA 359, programming)
- Jessica Morrison (CGRA 359, programming)

From GAME 390:
- Mitchell (GAME 390)
- Bradley (GAME 390)

### Related Repositories:
**Main repository:**  
https://github.com/ringwoodem/ChopChopServe

**Latest packed version as zip:**  
https://drive.google.com/file/d/1qFo67JbDxIZJGFl3xJr9CHLaLxIKrBTO/view

**Prototype release:**  
https://github.com/ringwoodem/ChopChopServe/releases/tag/v1.0.0-beta

### Gameplay Video:

[Gameplay Video 480p or 720p](https://drive.google.com/drive/folders/1EhMbnfnV3FOfkzANZhnrQCnGl2lvUeJ7)

## Strengths and weaknesses of the game you have developed

**Strengths:**
- **Visual appeal**: Having three designers on the team made the game visually unique and appealing.
- **Modular development and organization**: At the project start, programmers divided up the different systems within the game (e.g., Customers, Appliances, Sabotages), with each team member focusing on their own core areas. This modular approach increased rapid experimentation and feature implementation as less consensus was needed when leading individual modules, and it prevented accidental overlap while keeping files clear. The Godot project files were kept well-organized with clear, understandable folder names, allowing easy access and navigation. This organizational structure enabled us to implement relatively complicated cooking logic that is mostly functional.
- **Team collaboration and consensus**: All team members were able to have their say when deciding on ideas to implement, code changes, or choosing what to include in milestones, with no major conflicts regarding cooperation. This ease of agreement and lack of friction was significant in helping us move forward quickly.
- **Multiplayer implementation**:
The multiplayer system creates a fun, competitive, replayable aspect to our game that makes it stand out. Limited playtesting indicated players enjoyed the multiplayer aspect and the cooking gameplay derived from similar games in the genre. Having a dedicated team member focus on networking made it significantly easier for other team members to implement multiplayer functionality into their code. While everyone had to learn about networking, it will be a valuable skill to take with us after this project.  
While not supporting browser-based hosting or perfect internet hosting, the game supports:
  - LAN multiplayer
  - Automatic UPnP configuration when the host environment supports it
  - Room code generation when the host provides a valid IP format, simplifying the joining process for clients


**Weaknesses:**
- **Design-first approach challenges**: While visual strength is a key asset, some aspects were developed design-first without adequate discussion of implementation feasibility or functional necessity beyond aesthetics. This created implementation challenges including:
  - Extensive hardcoding through the editor
  - Added dependencies that could have been avoided

- **Steep learning curve and insufficient player feedback**: The game has numerous controls, with players able to interact with many different things, sometimes using the same keys. This may make it hard for new players to quickly learn the controls and could cause cognitive confusion when trying to remember what to do when. While the controls create a rewarding system overall, this learning curve might prevent players from fully enjoying the game. Additionally, although complicated cooking logic was successfully implemented, visual feedback communicating gameplay state and player objectives was inadequate (this was being addressed late in development and may be improved before submission).

- **Multiplayer integration**: Although we always intended to add multiplayer, the networking code wasn't added until a few weeks into development and required most team members to spend significant time learning client-server interactions. This required going back through existing code to rework it for networking compatibility, setting us back and causing small bugs throughout the development process. While this knowledge is valuable long-term, it was inefficient given our limited time budget, and appointing specialists to spearhead this area could have allowed faster development.

- **Limited accessibility for non-technical players**: Multiplayer functionality lacks sufficient support for non-technical users, requiring either manual port forwarding configuration or a relay server solution.

- **Module integration bottlenecks**: Modular development created integration challenges, with module inter-dependencies often leading to "dependency chaining." Person A might be unable to finish their module until receiving code from Person B, who was also waiting on code from Person C. This indicates we should have implemented strategies to address these dependencies.

- **Project management deficiencies**: Lack of hard deadlines led to tasks taking longer than necessary and being deprioritized. Without upfront discussion of mockup methods and general class structures, time was wasted when code had to be refactored to align with others' work. Having no clear deadlines led to insufficient time for proper playtesting to verify if our loop, mechanics, and systems were actually fun. This management weakness hindered polishing of the final product.


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
  - Type labels: development, test, bug, etc.
  - Priority tags for important tasks

**Continuous Deployment:**
- Connected GitHub to Railway for automatic deployment of the room code lookup server whenever implementation changes were pushed


## Discussion of best parts of the game/development process as a group

**Positive Team Dynamics:**
The strongest aspect of our development process was how team members remained positive and engaged throughout the project. Even when facing disagreements on implementation approaches, each member made genuine efforts to understand others' intentions and worked collaboratively to polish the game in the most engaging direction possible. All team members were able to have their say when deciding on ideas to implement, code changes, or choosing what to include in milestones, with no major conflicts regarding cooperation. This ease of agreement and respectful communication allowed for a really smooth process that encouraged group collaboration to its fullest and was significant in helping us move forward quickly.

**Effective Meeting Structure:**
During development, we were consistent in holding meetings with everyone, discussing our issues, bugs, and progress we had made throughout each week. We maintained weekly in-person meetings on Wednesday which were really effective, providing time to catch up and creating a space for us to work together on solutions if anyone had problems. These meetings proved particularly valuable for debugging, as members could showcase issues in real-time. If the game crashed on a specific line of code, we could have each person instantly check if it was their module, allowing us to quickly decide whether to fix it immediately or schedule it for later if it was a more serious problem. A weekly online meeting on Sunday for the programmers provided similar benefits and kept us accountable for the work we had done.

**Code Reviews and Knowledge Sharing:**
The programmers had a meeting at the start of the project to discuss what we each wanted to do, how we thought things could be done, and what we expected from this project. We conducted a code review session about halfway through the project to review our work and touch base. In hindsight, we should have conducted code reviews more frequently from the start. Reviewing each person's code as a group not only provided opportunities for improvements but, more critically, it allowed the team to build an understanding of what was being done outside of their individual focus points, ensuring all programmers stayed aligned.

**Communication:**
Our group's Discord was integral to our development. We used it for scheduling meetings, showcasing work updates, and bringing up small issues. This asynchronous communication was particularly valuable, as it was much more efficient than trying to sync everyone's schedules for minor issues, especially when they only concerned one or two team members. For project management, we used GitHub issues to track tasks we were working on during the week. Although most of us didn't utilise issues and project planning as much as we should have, when we did use them, they helped keep us organized and on track.
As a group of 7 with varying schedules, timing coordination was not always perfect. However, members consistently made their best efforts to respond promptly. When issues arose requiring specific team members' attention, we typically received responses within 12 hours, with most issues being addressed within 48 hours. When delays were unavoidable, members proactively communicated their schedules and estimated response times.

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
