# Character Animation Pipeline

The game logic stays separate from the art. GuestActor owns behavior and state; final sprite sheets only change how each state is rendered.

## Required animation states for the first final guest
- idle
- walk
- dance_a
- sit_down
- seated_idle
- stand_up

## Direction rule
Start with two mirrored isometric facing families instead of drawing every compass direction:
- NE / SE use the normal sprite orientation
- NW / SW use the mirrored sprite orientation

If a later animation needs true four-direction art, the behavior system can map to four sheets without changing navigation.

## Seat contract
Every usable seat must define:
- approach: walkable grid cell where the guest stops before sitting
- position: exact isometric seat anchor
- facing: direction the guest must face when seated

Characters never choose a sitting angle themselves. Furniture owns the seat orientation. This is what prevents backward seating.

## Sprite-sheet recommendation
Use one consistent frame canvas size for a character tier. Export transparent PNG or WebP sprite sheets. Do not bake floor shadows into character art; shadows are rendered separately so they stay aligned during animation.

## Performance target
Prefer short reusable loops and atlases or sprite sheets. Phaser owns character animation and scene rendering. The DOM is reserved for HUD and menu UI.
