# NOT FINISHED !!
# Contribution to the project
Name: Jessica Morrison

I mainly worked on the programming of the Sabotage System, with some work on the Reputation and Currency Systems at the beginning of the project.

## Currency System (Half)
This is the system surrounding the money within the game. This was the first thing I worked on, getting the code working that allowed people to add or minus currency using buttons. However when it came to networking the game a few weeks in, I didn't know how to network yet and I working on something else. Therefore it made sense for Johno to quickly revamp my code to be networked and connected to his UI. This means the code is a mixutre of both of ours work.

## Reputation System (Half)
A Key component within the game as it tracks the success of the players within the game. The code is very similarly worked to the currency system. I worked on this right after/ at the same time as the currency system and therefore Johno also revamped this code for networking. So while it isn't fully my code anymore I created the bones and a jumping point for Johno.

# Sabogate System (All)
This was what I hav spent most of my time working on. It is a key feature of the game and involved different styles of implemention. I worked on the main structure of the system but most of the actually sabotages actions where created by my teammates within their own classes. The main path of the code is **request_sabotage -> execute_sabotage -> do_sabotage -> the Specific sabotages' function**. There are a few differnt helper functions along the way, but this worked best for me because it means that I only needed to network the first two functions instead of having to do all of them. So any information that needs to be networked (eg. what bench to set on fire) is done within those calls and it works fine.

The Specific Sabotages Functions all work pretty similarly, they instantiate() a scene that is connected to a script (and sometimes an object like waterSpill or ratBoy) that handles the sabotage. They all handle their own timers and uses signals to signal when they start/ finish.

## Water Spill (Most)
For this section it finds a random location round the other player and places a 'waterSprout' particle effect near them. There is a the ability for the customers to fall over when within the spill. To achieve this I created an Area3D around the effect and used its '_on_area_3d_body_entered' and '_on_area_3d_body_exited' signals to get the player body and effect their speed etc. It also works for making the customers fall over. While did write some mock up code, Josh added the final customer fall code because he was working on customer side of it. 

## Fire Spread (All)
This section finds a random inflammable appilance and sets it on fire, then after a time spreads the fire until all the benches are on fire. The actual ingnite() code was written by Nagare within the applicance class. This ment I just needed to call it, make sure the firers where networked. I added a signal back to sabotagSystem when the timer ended to spread the fire. This needed to be networked because otherwise it wouldn't get the same benches for the different players. This is because it doesn't go through the main path just straight to the spawn_fire() function.

## Food Critic (Touched)
Spawn_food_critic() is unique in the fact that it doesn't instantiate() anything. What it does is emit a signal to the customer class, which then makes a customer that is a critic come into the restraunt. Because of this all the logic is handled within the customer class by Josh, and he added the signal call within in code. Hense why I only touched this section of the code.

## Switch Controls (All)
Switch Contols involves changing the direction of the keys for the other player (right becomes left, left becomes right etc). Because this was a control change it is handled in the Player class by Johno and I call his inver_controls() function. On that account the switch_controls class file uses ENetManager and teamID to get the player bodys. As the invert_controls() needed to be called on a player body, and couldn't be done with just their ids. 

## Rat Swarm (All)
The rat stuff was a little bigger then the other sections of this system, the only thing the anyone else did was the rat object. Most of the process it was just a rat mesh but last minute our designers added in a ratboy.glb with cute walking animations. This required a quick change to the code but not much. The rats are handled through a ratboy.tscn/.gd for the instantiate(), but the bulk of their code is in rat_attack and some in the rat_manager. Up to five rats are created in the corner of the kitchens and they run to collect any food left on the other teams benches. The rats run towards the foods position, moving each frame until they are close enough to the object then they turn around and go home.

## Power Outage (All)
This section goes through and turns off all the applicances for the other team using the power_off() function in the PowerApplicance class. Then when the timer is done calling power_on().
