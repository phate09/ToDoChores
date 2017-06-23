# To Do Chores

Automate gathering, chopping, digging, planting, fertilizing, traping and drying!

# Usage

* Press V to toggle chores widget
    1. Select Option (column 2+ is option icon)
    2. Start Chores (column 1 is start chores icon)
    3. Don't Close Widget while do chores
    4. after task end (or when you want), close widget ( Key "V")
* Press O to open in-game settings
    1. Size of the planting batch
    2. Chop down only adult trees
    3. Prefer tools made of gold when crafting new tools

# FAQ

* "Geometric Placement" mod messes up with the placement of plants. Hold CTRL when planting so that it temporarily disables geometric placement

# Widget Icon Explain

Each first column icon is button for starting chores.
The other is option of chores.

* Row 1
  * axe - start to chop tree
  * pinecone - toggle pick cones/acorns when finished cutting the trees
  * charcoal - toogle cut burnt trees and pick charcoal
  * shovel - toggle shovel stumps

* Row 2
  * pickaxe - start to mine
  * nitro - toggle mine nitro boulders
  * goldnugget - toggle mine gold boulders
  * rocks - toggle mine flintless boulders
  * ice - toggle mine ice boulders
  * moonrocknugget - toggle mine moonstone boulders
  * marble - toggle to mine marble

* Row 3
  * backpack - start to collect items. If you equip shovel, it will only pickup item on the ground.
  * flint - toggle pickup flint. it didn't mine boulders. just collect on ground.
  * cutgrass, twigs, petals, carrot - toggle pick selection from plant and ground.
  * berries - toggle pickup berries and berries_juicy from plant and ground.
  * green_cap - toggle pickup red_cap, green_cap and blue_cap from plant and ground.
  * guano - toggle pickup poop, guano, spoiled_food, rottenegg, fertilizer and glommerfuel from ground.

* Row 4
  * shovel - start to dig and pickup
  * dug grass, dug berry bush, dug saplings - dig selection and pickup

* Row 5
  * book_gardening - This book is "Applied Horticulture". yes, it stand for "Planting"
  * dug grass - plant automatically each item close to each other (depending on your configuration).
  * dug berry bush, dug saplings, pine cone, twiggy cone - auto plant selection close to each other (depending on your configuration).
  * marblebean - auto plant marblebean, auto craft marblebean if needed (but you still need one marblebean to start job)

* Row 6
  * guano - start to fertilize crops and pickup fertilizer
  * poop - use poop and guano to fertilise
  * bucket-o-poop - use bucket or make one to fertilise
  * guano, rot, rottenegg, glommerfuel - use selection to fertilise

* Row 7
  * trap - checks all the traps and re-set at original position (craft trap if needed)
  * rabbit - put a trap on the rabbit holes as close as possible (craft trap if needed)
  * morsel, froglegs, silk, spider gland, monster meat, rot - pickup selection on the ground

* Row 8
  * smallmeat_dried - Start to dry, harvest and pickup
  * smallmeat, meat, monstermeat, froglegs, fish, drumstick, eel, batwing - toggle dry and pickup selection

# Planned Changes and ideas

* [ ] Actions as checkboxes: the actions are going to be toggleable so that the character will perform any actions turned on. (Picking up carrots while shoveling saplings? Want to dig but not pick? etc)
* [ ] Auto Cooking?
* [ ] Auto Harvest fields?

# Changes Log

### 1.5

* support Traditional Chinese and Simplified Chinese (with Chinese Plus mod)
* fix race condition of in-game settings variable with other mod (like Auto Actions)
* planting feature now can craft marblebean if needed (but still need one marblebean to start job)
* Added dry feature: auto harvest Drying Rack, dry meats and pickup meats

### 1.4

* Added auto-trap feature: auto set trap and check trap

### 1.3

* Added option to auto-fertilise fields, it will build the bucket-o-poop if possible
* Fixed error when mining ice

### 1.2

* Added option to cut only adult trees
* Added option to prefer tools made of gold
* Fixed planting
* Added toggle button for shovelling trees

### 1.1.0

* Added in-game menu that allows to change options
* Fixed error with ice
* Added support for twiggy trees

### 1.0.1

* Solved teleport bug when pressing N
* Reduced radius at which to dig stumps
* Added Ice as a an option in the "Dig" row

### 1.0

* Solved issue with planting when the user was not the host of the server (FINALLY!)

### 0.7

* added pickup of mushrooms
* added pickup of carrots
* added pickup of flowers
* reduced radius at which bush berries are planted
* added planting of birchnuts
* reduced radius at which cones and birchnuts are planted
* integrated picking up from juicy berry bushes (into the pick berries action)
* added planting of juicy berries (planted along with common berry bushes)
* added configuration for size of field when planting
* solved some minor bugs that were spotted in the previous version but not implemented
