# Project Roadmap

A low-poly modern city with small districts, where the kids explore and learn. (Story comes later.)

## How I'd structure the project

- **Phase 1:** One street blockout (gray boxes), one character who can walk/run/jump. Feel the scale first. (2–4 weeks of evenings)
- **Phase 2:** Build the first real district (e.g. market street) + NPC dialogue
- **Phase 3:** Learning mini-games tied to the district (money/shopping, safety, quizzes)
- **Phase 4:** Multiple districts connected (park, library, fire station...), small quests per district

## District ideas (learning themes)

- **Market street** → money, buying/selling
- **Fire station / hospital** → safety and jobs
- **Library** → reading, quizzes, mini-games
- **Park** → nature
- **Workshop/garage** → building things

## World building workflow (Blender → Godot)

- **Modular kit:** model pieces once (wall sections, windows, doors, roofs, props like lamps/benches/cars) and assemble like LEGO
- **One Blender file per district**, buildings as separate objects, clearly named (`bld_bakery`, `bld_house_01`, `prop_lamp`)
- **Export:** one .glb per district (with separate objects inside) — Godot imports it as one scene with multiple meshes, so culling works
- **Reusable props** (lamps, benches, cars) become instanced scenes in Godot: one resource, many placements
- **Collision:** simple box colliders per building, not one giant mesh collider

Rule of thumb: *merge what never changes and is always seen together; separate what might move, be reused, or be culled.*

## Involving the kids

- They design their dream district on paper → their ideas become the asset list
- They pick colors, names, dialogue, and story
- They playtest and report what's fun
