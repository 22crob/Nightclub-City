# Architecture

## Core flow
main.js creates Phaser and the DOM UI.

ClubScene owns the playable club scene and connects:
- IsoGrid for projection and depth
- NavigationGrid for collision and pathfinding
- ClubObjectFactory for renderable furniture placeholders
- GuestActor for customer behavior
- GameStore for cash, XP, level, and selected build item

## Why this fixes the old prototype problems
The previous prototype mixed rendering, movement, UI, progression, and furniture in one large script. In this rebuild, furniture footprints feed navigation, seats contain explicit orientation, and guest states are independent of art assets. New art can be swapped in without rewriting movement or UI.

## Rule for future work
Do not add a furniture asset without its footprint and, if it can be sat on, its seat definitions. Do not add a character animation directly to a scene; register it through the character animation pipeline.
