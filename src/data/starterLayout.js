export const starterLayout = Object.freeze([
  { id: "dj-1", kind: "dj", x: 7, y: 2, w: 3, h: 1, style: "starter", solid: true },
  { id: "bar-1", kind: "bar", x: 2, y: 3, w: 3, h: 1, style: "starter", solid: true },
  { id: "dance-1", kind: "dance", x: 6, y: 6, w: 4, h: 4, style: "starter", solid: false },
  { id: "table-1", kind: "table", x: 2, y: 7, w: 2, h: 2, style: "starter", solid: true },
  { id: "sofa-1", kind: "sofa", x: 11, y: 6, w: 2, h: 1, style: "purple", solid: true },
  { id: "plant-1", kind: "decor", x: 12, y: 3, w: 1, h: 1, style: "plant", solid: true }
]);

export const seats = Object.freeze([
  {
    id: "sofa-1-seat-a",
    objectId: "sofa-1",
    approach: { x: 11, y: 7 },
    position: { x: 11.4, y: 6.55 },
    facing: "NE"
  },
  {
    id: "sofa-1-seat-b",
    objectId: "sofa-1",
    approach: { x: 12, y: 7 },
    position: { x: 12.05, y: 6.55 },
    facing: "NE"
  }
]);

export const guestRoute = Object.freeze({
  entrance: { x: 14, y: 11 },
  danceTarget: { x: 8, y: 8 },
  seatId: "sofa-1-seat-a"
});
