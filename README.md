# Dungeon-search - Powershell

Found some interesting videos on Dungeons with rocks and searching for an exit. I thought I'd do this in an hour, tops. 6 hours in and I have a half-baked script that doesn't quite work right but works enough to give results most of the times :D

Grid is automatically square in dimensions.

# Generate a grid to get a starting point (bigger grid leads to exponential slowing of the script)
$grid = new-DungeonGrid  -dimensions 15

# Then find the route, though it just outputs where it found the exit and which cells it traversed.
Find-Route -grid $grid



![image](https://github.com/FeliciaFiction/Dungeon-search/assets/120337827/5c98d714-77bc-4b2b-acd8-7d95278f18ed)
