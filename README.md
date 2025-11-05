# Lab-3

## Controls
- **Arrow Keys / WASD** - Move around
- **Space** - Dash (has cooldown)

## Systems

### Player
- Has health that decreases when hit by enemies
- Invincibility frames after taking damage (flashing effect)
- Can dash to move quickly and avoid enemies
- Dies and respawns when health reaches zero

### Enemies (Paperman)
- Follows the player automatically
- Deals damage on contact
- Takes damage from player attacks
- Has knockback when hit
- Dies when health reaches zero

### Spawner
- Automatically spawns items at set intervals
- Can be manually triggered
- Uses marker position for spawn location

### Damage System
- Enemies and hazards deal damage on contact
- Knockback pushes entities away from damage source
- Visual feedback when taking damage (color flash)
