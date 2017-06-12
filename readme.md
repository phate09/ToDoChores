To Do Chores
===================
Automate some tasks like gathering resources, cutting down trees, digging turfs etc

***IMPORTANT***

I forked the project because the original developer stopped maintaining it and i thought it was a great mod.
You can find the original at:
http://steamcommunity.com/sharedfiles/filedetails/?id=377330400
I modified the project for personal use but wanted to share some added features with the community

I will NOT fix "strange" bugs: if it works on my machine it is fine to me, you most likely have something wrong on yours, check your other mods. Otherwise, misfortune.
If it is a bug I can replicate I will fix it.


How To Use
----------------------
1. Open Widget (default Key "V") 
2. Select Option
 in widget, column 1 is chores icon, column 2~5 is option icon. 
3. Start Chores
4. Don't Close Widget while do chores
5. after task end (or when you want), close widget ( Key "V") 

Open Mod in-game menu (default Key "O") for changing some options
1. Size of the planting batch
2. Chop down only adult trees
3. Prefer tools made of gold when crafting new tools
 
Widget Icon Explain
-----------------------------
Each first column icon is button for starting chores.
The other is option of chores.

* Row 1. 
  * axe - chop down tree
  * pine cone - toggle pick cones/acorns when finished cutting the trees
  * charcoal - toogle cut burnt trees and pick charcoal
  * shovel - toggle shovel stumps

* Row 2
  * pickaxe - mining
  * nitro - toggle mine nitro boulders
  * gold - toggle mine gold boulders
  * moonstone - toggle the option to mine moonstone

* Row 3
  * backpack - collect items
  * flint - toggle collect or not. it didn't mine work. just collect on ground.
  * grass - toggle pick or not from grass or ground.
  * twigs - same like grass
  * berries - same again

* Row 4
  * shovel - dig and pick
  * dug grass - dig grass and collect its loot
  * dug berry bush - same
  * dug saplings - same too

* Row 5
  * book - This book is "Applied Horticulture". yes, it stand for "Planting"
  * dug grass - plant automatically each item close to each other (depending on your configuration). 
  * dug berry bush - same
  * dug saplings - same 
  * pine cone - same 
  * twiggy cone - same
  
 * Row 6
  * guano - fertilise crops
  * poop - use poop to fertilise
  * bucket-o-poop - use bucket or make one to fertilise
  * guano - use guano to fertilise
  * rot - same
  * rotten eggs - same
  * glommer goop - same

Planned Changes and ideas
------------------------
* [X]In-game menu for configuration
* [ ]Actions as checkboxes: the actions are going to be toggleable so that the character will perform any actions turned on. (Picking up carrots while shoveling saplings? Want to dig but not pick? etc)
* [X]Auto Fertilise action
* [ ]Auto Check traps?
* [ ]Auto Cooking?
* [ ]Auto dry meat?
* [ ]Auto Harvest fields?

Changes Log
------------------------
1.3
	Added option to auto-fertilise fields, it will build the bucket-o-poop if possible
	Fixed error when mining ice
1.2
	Added option to cut only adult trees
	Added option to prefer tools made of gold
	Fixed planting
	Added toggle button for shovelling trees
1.1.0
	Added in-game menu that allows to change options
	Fixed error with ice
	Added support for twiggy trees
	
1.0.1
	Solved teleport bug when pressing N
	Reduced radius at which to dig stumps
	Added Ice as a an option in the "Dig" row
	
1.0
	Solved issue with planting when the user was not the host of the server (FINALLY!)
0.7
	added pickup of mushrooms
	added pickup of carrots
	added pickup of flowers
	reduced radius at which bush berries are planted
	added planting of birchnuts
	reduced radius at which cones and birchnuts are planted
	integrated picking up from juicy berry bushes (into the pick berries action)
	added planting of juicy berries (planted along with common berry bushes)
	added configuration for size of field when planting
	solved some minor bugs that were spotted in the previous version but not implemented
  

Fork
------------------------
0.6
	change pickup item radious(25 -> 5)
0.5
	bugfix : modmain.lua for DS/ROG (working correctly, now ) 
	new : add 'berrybush2'
	new : add 'charcoal'
	reposition widget to left side

0.4
	fix crash planting on client
	fix planting color bug on client
	fix planting location on client
	fix crash placer == nil (tnk to iRukario)

0.3 
	fix crash when planting from backpack  ( thx to Solo feeder )


