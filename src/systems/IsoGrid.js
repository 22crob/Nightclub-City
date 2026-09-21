import { CLUB, COLORS, DEPTH } from "../config/constants.js";

export class IsoGrid {
  constructor(scene) {
    this.scene = scene;
    this.width = CLUB.gridWidth;
    this.height = CLUB.gridHeight;
    this.tileWidth = CLUB.tileWidth;
    this.tileHeight = CLUB.tileHeight;
    this.originX = CLUB.originX;
    this.originY = CLUB.originY;
  }

  toWorld(x, y, z = 0) {
    return {
      x: this.originX + (x - y) * this.tileWidth * 0.5,
      y: this.originY + (x + y) * this.tileHeight * 0.5 - z
    };
  }

  toGrid(worldX, worldY) {
    const x = worldX - this.originX;
    const y = worldY - this.originY;
    return {
      x: (y / (this.tileHeight * 0.5) + x / (this.tileWidth * 0.5)) * 0.5,
      y: (y / (this.tileHeight * 0.5) - x / (this.tileWidth * 0.5)) * 0.5
    };
  }

  centerOfCell(x, y) {
    return this.toWorld(x + 0.5, y + 0.5, 0);
  }

  depth(x, y, offset = 0) {
    return DEPTH.objectBase + Math.round((x + y) * 100) + offset;
  }

  isInside(x, y, w = 1, h = 1) {
    return x >= 0 && y >= 0 && x + w <= this.width && y + h <= this.height;
  }

  diamond(x, y, w = 1, h = 1, z = 0) {
    return [
      this.toWorld(x, y, z),
      this.toWorld(x + w, y, z),
      this.toWorld(x + w, y + h, z),
      this.toWorld(x, y + h, z)
    ];
  }

  drawRoom() {
    const floor = this.scene.add.graphics();
    floor.setDepth(DEPTH.floor);

    for (let y = 0; y < this.height; y += 1) {
      for (let x = 0; x < this.width; x += 1) {
        const points = this.diamond(x, y);
        floor.fillStyle((x + y) % 2 === 0 ? COLORS.floorA : COLORS.floorB, 1);
        floor.fillPoints(points, true);
        floor.lineStyle(1, COLORS.grid, 0.32);
        floor.strokePoints(points, true);
      }
    }

    const wallHeight = 132;
    const wall = this.scene.add.graphics();
    wall.setDepth(DEPTH.floor - 1);
    const corner = this.toWorld(0, 0);
    const right = this.toWorld(this.width, 0);
    const left = this.toWorld(0, this.height);

    wall.fillStyle(COLORS.wallRight, 1);
    wall.fillPoints([
      corner,
      right,
      { x: right.x, y: right.y - wallHeight },
      { x: corner.x, y: corner.y - wallHeight }
    ], true);

    wall.fillStyle(COLORS.wallLeft, 1);
    wall.fillPoints([
      corner,
      left,
      { x: left.x, y: left.y - wallHeight },
      { x: corner.x, y: corner.y - wallHeight }
    ], true);

    wall.lineStyle(2, COLORS.purple, 0.35);
    for (let x = 1; x < this.width; x += 3) {
      const p = this.toWorld(x, 0);
      wall.lineBetween(p.x, p.y - 8, p.x, p.y - wallHeight + 10);
    }

    return { floor, wall };
  }
}
