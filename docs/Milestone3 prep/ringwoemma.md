ringwoemma

| Section | How Much I Did |
|---------|----------------|
| Food    | All |
| GameState | Most |
| MenuItem | All |
| Appliance | Touched |
| Plate | All |
| OrderSystem | Half |

## Food
I did all the coding for the ingredients which we put under the name food. The ingredients needed to have the states that they've been though so that later the plate is able to make sure that the player has done the correct things to make the menu item.

The food is linked to scenes so that the food can have meshes. They have a couple different meshes depending on the ingredient. There is a raw mesh (before food is processed), a cooked mesh, a burnt mesh. Some ingredients/food have mixed and chopped meshes aswell.

The food changes states after a certain time within each appliance. for example the chopping board will result in the chopped mesh

## MenuItem
I also did all the coding for the menu items which is the name we gave for the available recipes you can make. The menu items were assembled on the plate (will talk about later). The menuitems all have a list of ingredients needed to make each recipe and then they also contained a dictionary that matches up each of the required ingredients with the states that each of them is supposed to have gone through. 

There is a function in menuitem that checks to see if all the ingreidents on the plate match the list and dictionary of the menuitem. It decides which menu item to create by iterating through a preloaded list of menu item subclasses.

## Plate
The plate was an import script that I wrote for the game as it is what all the food needs to be served on and also the customers need to return them dirty. 

When ingredients were put onto the plate it called a function to check to if a menu item could be made and if it could it would then add the menu item scene onto the plate (added it to the plate scene) so that it was placed on the plate. 

The plate also has functions that allow you to set it to be dirty/clean and then allowed other scripts to call those functions so that the plate can be cleaned.

## GameState
The game state was another important part of the game that I did most of with the help of Johno who then connected it up to the rest of the game. 

I created the code so that the days were counted so that every hour in game equated to one minute in real life.  

I created the different phases, the prep and the cooking so that they would chnage with the timer

Not within this script but to do with the gamestate I had to create a json file so that the gamestate could track all the available menuitems/recipes that the players were able to make. I just did this by basically creating a massive dictionary that the gamestate could read through. 

Doing this I had to edit the order system (talk more about later) so that instead of choosing menuitems that the customers could order from one massive list of everything, the order system then had to choose a menu item from the list of available menu items that the gamestate created and made a global list


## OrderSystem
I created a basic ordersystem which Josh then edited to make it return what he needed for the customers. But the basic idea that I created, had a big list of menuitems and that was passed to a function which that randomly selected a number and then grabbed the menuitem at that random number index. 

Josh had to have it reworked as when we tried to do it in multiplayer it would give the same customer different orders which was not ideal.

And as I stated before this was then chnaged so that it used the gamestates available menuitems instead of the subclass list of every menuitem.

## Appliance
I only touched some things in the appliance like when i changed what was required from the ingreidnets I would then have to go into the appliances to change the functions it needed to call. for example the start and stop cooking, I chnaged the name for those and also a parameter for the start cooking which led to some errors in the appliance scripts and therefore I had to go in and fix all of that up.

I also had to add what food can be cooked by each appliance. As each appliance had a list within of what food/ingredients can be accepted.