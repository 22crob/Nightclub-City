# Nightclub City

A clean rebuild of the nightclub management game project.

## Current direction
- Isometric nightclub management/building
- Stylized semi-3D/chibi nightlife presentation
- Visual progression through unlockable bars, seating, dance floors, walls, decor, staff, and customers
- Modular codebase instead of one giant HTML file
- Performance-conscious rendering for Safari and other browsers

## Structure
- `index.html` – game shell
- `styles/game.css` – UI and game presentation
- `src/game.js` – main loop and renderer
- `src/ui.js` – HUD and design drawer
- `src/building.js` – build catalog and placement state
- `src/progression.js` – levels and unlocks
- `src/characters.js` – customer/staff state
- `src/animations.js` – animation helpers
- `assets/` – art assets added as the project grows

## First milestone
Build a polished Levels 1–10 vertical slice with a compact club, correct object orientation, stable character movement/seating, progression unlocks, and a visual Design menu.
