NEBULA - Godot 4.7.x mobile-friendly 2D action platformer

PROJECT
- Main scene: scenes/main.tscn
- Main gameplay script: scripts/main.gd
- Landscape 1280x720 project viewport.
- Current prototype visuals are drawn by GDScript; no external art assets are required.

GAMEPLAY
- Side-scrolling sci-fi combat prototype.
- Play as an armed soldier with a rifle and a visible muzzle flash.
- Five enemy soldiers patrol the sector and fire back when you approach.
- Hold the fire control to shoot; enemy soldiers take several hits before being defeated.
- Enemy projectiles can damage the player.
- Existing energy cells, security drones, floor hazards, checkpoint, health and exit remain.
- You have 3 health points. Damage sends you back to the last checkpoint.

CONTROLS
- Keyboard: A/D or Left/Right to move; Space/W/Up to jump; J, X or Ctrl to fire; P or Escape to pause; R to restart after the end.
- Touch: lower-left buttons move; lower-right FIRE button shoots; JUMP button jumps.
- Tap the pause icon at the upper-right corner.

IMPORT
1. Download the repository as a ZIP and extract it.
2. In Godot Project Manager, choose Import.
3. Select project.godot in the extracted folder.
4. Open the project. This combat update has been committed to GitHub but has not yet been runtime-tested on the Android device.


METAL SLUG-STYLE SOLDIER SPRITE ATLAS
------------------------------------
The main script now supports a 4-column x 4-row soldier atlas at:
res://assets/player_atlas.png

Create an "assets" folder in the Godot project and place the supplied
player atlas PNG inside it with the exact filename:
player_atlas.png

Atlas rows (top to bottom):
0 = idle
1 = run
2 = jump / airborne
3 = firing

Each cell is 256 x 384 pixels. The script animates four frames per row.
If the PNG is missing, the old temporary fallback drawing is used.

IMPORTANT:
The updated script has not yet been run in Godot on a device. Import the
PNG, reopen the project, and check the animation and sprite alignment.


ENEMY SOLDIER SPRITE ATLAS
--------------------------
The main script also supports a 4-column x 4-row enemy atlas at:
res://assets/enemy_atlas.png

Place the supplied enemy atlas PNG in the same assets folder and name it:
enemy_atlas.png

Enemy atlas rows (top to bottom):
0 = idle
1 = run
2 = firing
3 = hit / defeat (reserved for a later death-animation update)

If the enemy PNG is missing, the temporary procedural enemy drawing remains.
