import { COLORS } from "../config/constants.js";

function prism(graphics, grid, object, height, top, sideA, sideB) {
  const x = object.x;
  const y = object.y;
  const w = object.w || 1;
  const h = object.h || 1;
  const topPoints = grid.diamond(x, y, w, h, height);
  const basePoints = grid.diamond(x, y, w, h, 0);

  graphics.fillStyle(top, 1);
  graphics.fillPoints(topPoints, true);
  graphics.fillStyle(sideA, 1);
  graphics.fillPoints([topPoints[1], basePoints[1], basePoints[2], topPoints[2]], true);
  graphics.fillStyle(sideB, 1);
  graphics.fillPoints([topPoints[3], topPoints[2], basePoints[2], basePoints[3]], true);
}

export class ClubObjectFactory {
  constructor(scene, grid) {
    this.scene = scene;
    this.grid = grid;
  }

  create(object) {
    const graphics = this.scene.add.graphics();
    graphics.setDepth(this.grid.depth(object.x + (object.w || 1), object.y + (object.h || 1)));

    if (object.kind === "dance") this.drawDance(graphics, object);
    else if (object.kind === "bar") this.drawBar(graphics, object);
    else if (object.kind === "dj") this.drawDJ(graphics, object);
    else if (object.kind === "table") this.drawTable(graphics, object);
    else if (object.kind === "sofa" || object.kind === "booth") this.drawSeating(graphics, object);
    else this.drawDecor(graphics, object);

    return graphics;
  }

  drawDance(graphics, object) {
    const colors = [0x5d36d8, 0xa638d8, 0x235dd8, 0x18a8c0];
    for (let yy = 0; yy < object.h; yy += 1) {
      for (let xx = 0; xx < object.w; xx += 1) {
        graphics.fillStyle(colors[(xx + yy) % colors.length], 0.82);
        graphics.fillPoints(this.grid.diamond(object.x + xx, object.y + yy, 1, 1, 2), true);
        graphics.lineStyle(1, 0xffffff, 0.1);
        graphics.strokePoints(this.grid.diamond(object.x + xx, object.y + yy, 1, 1, 2), true);
      }
    }
    this.scene.tweens.add({
      targets: graphics,
      alpha: { from: 0.76, to: 1 },
      duration: 900,
      yoyo: true,
      repeat: -1,
      ease: "Sine.InOut"
    });
  }

  drawBar(graphics, object) {
    const top = object.style === "neon" ? 0x7047d4 : object.style === "vip" ? 0x9a4fb7 : 0x514660;
    prism(graphics, this.grid, object, 36, top, 0x29223f, 0x34294a);
    const left = this.grid.toWorld(object.x + 0.45, object.y + 0.12, 43);
    const right = this.grid.toWorld(object.x + object.w - 0.45, object.y + 0.12, 43);
    graphics.lineStyle(4, COLORS.cyan, 0.8);
    graphics.lineBetween(left.x, left.y, right.x, right.y);
  }

  drawDJ(graphics, object) {
    prism(graphics, this.grid, object, 40, 0x4f3b72, 0x211b37, 0x2c2244);
    const center = this.grid.toWorld(object.x + object.w * 0.5, object.y + 0.45, 52);
    graphics.fillStyle(COLORS.pink, 1);
    graphics.fillCircle(center.x - 18, center.y, 8);
    graphics.fillStyle(COLORS.cyan, 1);
    graphics.fillCircle(center.x + 18, center.y, 8);
  }

  drawTable(graphics, object) {
    const center = this.grid.toWorld(object.x + object.w * 0.5, object.y + object.h * 0.5, 20);
    graphics.fillStyle(0x3b3150, 1);
    graphics.fillEllipse(center.x, center.y, 84, 38);
    graphics.lineStyle(3, 0xb98cff, 0.75);
    graphics.strokeEllipse(center.x, center.y, 84, 38);
  }

  drawSeating(graphics, object) {
    const top = object.style === "luxury" ? 0x8045ad : 0x593a83;
    prism(graphics, this.grid, object, 25, top, 0x2d2447, 0x3b2959);
    const back = { ...object, y: object.y - 0.08, h: 0.28 };
    prism(graphics, this.grid, back, 45, 0x7148a1, 0x33244e, 0x432b67);
  }

  drawDecor(graphics, object) {
    const center = this.grid.centerOfCell(object.x, object.y);
    if (object.style === "plant") {
      graphics.fillStyle(0x382b48, 1);
      graphics.fillRect(center.x - 7, center.y - 6, 14, 18);
      graphics.fillStyle(0x49b27d, 1);
      graphics.fillCircle(center.x, center.y - 24, 13);
      return;
    }
    graphics.fillStyle(COLORS.purple, 1);
    graphics.fillCircle(center.x, center.y - 20, 12);
  }
}
