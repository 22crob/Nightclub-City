# Nightclub City

Fresh rebuild of the nightclub management game using Phaser 4.

## Engine
- Phaser 4.2.1
- Vite 8.3.0
- JavaScript ES modules

## Current milestone
This repo is now the permanent game foundation rather than one giant HTML prototype. The first vertical slice focuses on the systems that caused the most trouble before:

- Isometric grid and depth sorting
- Camera pan and zoom
- Grid collision and pathfinding
- Object footprints so guests do not walk through solid furniture
- Explicit seat approach points and seat-facing metadata
- Guest state machine: walk -> dance -> walk to seat -> sit -> stand -> repeat
- Level 1-10 design catalog
- Working Design drawer and object placement
- Modular scenes, systems, state, data, and UI

The current club and guest visuals are intentionally procedural placeholders. The next art pass swaps these for final sprite sheets and object PNG/WebP assets without replacing the movement, seating, navigation, or progression systems.

## Run locally
1. Install Node.js 20.19+ or 22.12+.
2. Run npm install.
3. Run npm run dev.
4. Open the local address Vite prints in the terminal.

Production build: npm run build.

## Structure
- src/scenes/ - Phaser scenes
- src/systems/ - isometric grid, navigation, furniture rendering, guest behavior
- src/data/ - progression catalog and starter club layout
- src/state/ - game economy/progression state
- src/ui/ - DOM HUD and Design drawer
- public/assets/characters/ - future character sprite sheets
- public/assets/club/ - future club object art
- docs/ - art and animation rules

## Next target
Create one final-quality customer sprite set and one final-quality seating asset, then plug them into the existing walk/dance/sit loop. Once that looks correct in Safari, expand the same proven pipeline to the full customer roster and Levels 1-10 assets.
