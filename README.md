# Kids Modern City Game

A low-poly 3D exploration game for kids, built with Blender and Godot. The goal is to create a small modern city where children can explore, discover different districts, and learn through play.

## Current Status

The project is currently an early movement prototype:

- A 3D city world exported from Blender
- A playable character exported from Blender
- Walking, running, jumping, and third-person mouse camera controls
- Idle, run, and jump animation playback

Planned features include NPCs, dialogue, quests, interactive objects, and learning mini-games.

## Project Structure

```text
Design/                  Project roadmap and design notes
GodotProject/game/       Godot project
  Scenes/                Demo and player scenes
  Scripts/               GDScript gameplay code
  Models/                Imported GLB models and textures
ModelsBlender/           Source Blender files
```

## Running the Game

1. Open `GodotProject/game/project.godot` in Godot 4.7 or newer.
2. Run the project. The main scene is `Scenes/Demo.tscn`.

### Controls

| Action | Key |
| --- | --- |
| Move | W/A/S/D |
| Jump | Space |
| Run | Shift |
| Look around | Mouse |
| Release mouse | Escape |

## Blender to Godot Workflow

- Keep one Blender file for each district.
- Keep buildings and reusable props as separate, clearly named objects.
- Export districts and characters as glTF 2.0 `.glb` files.
- Use simple collision shapes for buildings instead of one large mesh collider.
- Turn reusable props such as lamps, benches, and cars into instanced Godot scenes.

The source assets are in `ModelsBlender/` and the imported assets are in `GodotProject/game/Models/`.

## Animation Playback Note

The `Run` animation in `Hero1.blend` uses frames 1-19 at 24 FPS, which is approximately 0.75 seconds per loop.

The run animation is played at a constant speed in `Scripts/player.gd`:

```gdscript
animation_player.speed_scale = 1.0
```

The demo scene overrides `RUN_SPEED` to `1.0`. The animation now keeps its native playback speed while the character is moving, regardless of acceleration or current movement speed.

## Roadmap

See [`Design/ProjectPhases.md`](Design/ProjectPhases.md) for the current plan:

1. Block out one street and validate scale.
2. Build the first district and add NPC dialogue.
3. Add learning mini-games.
4. Connect multiple districts with small quests.

## Design Principles

- Build one small area well before expanding the city.
- Prefer reusable modular assets.
- Let the kids help design districts, choose colors and names, write dialogue, and playtest each feature.
