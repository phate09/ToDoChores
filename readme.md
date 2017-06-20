# To Do Chores

Automate gathering, chopping, digging, planting, fertilizing and traping!

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

# Widget Icon Explain

Each first column icon is button for starting chores.
The other is option of chores.

* Row 1
    - axe - chop down tree
    - pine cone - toggle pick cones/acorns when finished cutting the trees
    - charcoal - toogle cut burnt trees and pick charcoal
    - shovel - toggle shovel stumps

* Row 2
    - pickaxe - mining
    - nitro - toggle mine nitro boulders
    - gold - toggle mine gold boulders
    - moonstone - toggle the option to mine moonstone

* Row 3
    - backpack - collect items
    - flint - toggle collect or not. it didn't mine work. just collect on ground.
    - grass - toggle pick or not from grass or ground.
    - twigs - same like grass
    - berries - same again

* Row 4
    - shovel - dig and pick
    - dug grass - dig grass and collect its loot
    - dug berry bush - same
    - dug saplings - same too

* Row 5
    - book - This book is "Applied Horticulture". yes, it stand for "Planting"
    - dug grass - plant automatically each item close to each other (depending on your configuration).
    - dug berry bush - same
    - dug saplings - same
    - pine cone - same
    - twiggy cone - same
NB. "Geometric Placement" mod messes up with the placement of plants. Hold CTRL when planting so that it temporarily disables geometric placement

* Row 6
    - guano - fertilise crops
    - poop - use poop to fertilise
    - bucket-o-poop - use bucket or make one to fertilise
    - guano - use guano to fertilise
    - rot - same
    - rotten eggs - same
    - glommer goop - same

* Row 7
    - trap - checks all the traps
    - rabbit - put a trap on the rabbit holes as close as possible (create the trap if not already in inventory)
    - morsel - pickup morsels on the ground
    - frog legs - same
    - silk - same
    - spider gland - same
    - monster meat - same
    - rot - same

# Planned Changes and ideas

* [ ] Actions as checkboxes: the actions are going to be toggleable so that the character will perform any actions turned on. (Picking up carrots while shoveling saplings? Want to dig but not pick? etc)
* [ ] Auto Cooking?
* [ ] Auto dry meat?
* [ ] Auto Harvest fields?

# Changes Log

### 1.5

* support Traditional Chinese and Simplified Chinese
* fix race condition of in-game settings with other mod (like Auto Actions)
* planting feature now can craft marblebean (but still need one to start job)

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
