export class NavigationGrid {
  constructor(grid) {
    this.grid = grid;
    this.blocked = new Set();
  }

  key(x, y) {
    return String(x) + ":" + String(y);
  }

  rebuild(objects) {
    this.blocked.clear();
    for (const object of objects) {
      if (!object.solid) continue;
      this.blockFootprint(object.x, object.y, object.w || 1, object.h || 1);
    }
  }

  blockFootprint(x, y, w, h) {
    for (let yy = y; yy < y + h; yy += 1) {
      for (let xx = x; xx < x + w; xx += 1) {
        this.blocked.add(this.key(xx, yy));
      }
    }
  }

  isBlocked(x, y) {
    return this.blocked.has(this.key(x, y));
  }

  canPlace(x, y, w, h) {
    if (!this.grid.isInside(x, y, w, h)) return false;
    for (let yy = y; yy < y + h; yy += 1) {
      for (let xx = x; xx < x + w; xx += 1) {
        if (this.isBlocked(xx, yy)) return false;
      }
    }
    return true;
  }

  isWalkable(x, y) {
    return this.grid.isInside(x, y) && !this.isBlocked(x, y);
  }

  findPath(start, goal) {
    const sx = Math.floor(start.x);
    const sy = Math.floor(start.y);
    const gx = Math.floor(goal.x);
    const gy = Math.floor(goal.y);
    const startKey = this.key(sx, sy);
    const goalKey = this.key(gx, gy);

    if (!this.isWalkable(gx, gy)) return [];

    const queue = [{ x: sx, y: sy }];
    const cameFrom = new Map([[startKey, null]]);
    const directions = [
      { x: 1, y: 0 },
      { x: -1, y: 0 },
      { x: 0, y: 1 },
      { x: 0, y: -1 }
    ];

    while (queue.length) {
      const current = queue.shift();
      const currentKey = this.key(current.x, current.y);
      if (currentKey === goalKey) break;

      for (const direction of directions) {
        const next = { x: current.x + direction.x, y: current.y + direction.y };
        const nextKey = this.key(next.x, next.y);
        if (cameFrom.has(nextKey) || !this.isWalkable(next.x, next.y)) continue;
        cameFrom.set(nextKey, current);
        queue.push(next);
      }
    }

    if (!cameFrom.has(goalKey)) return [];

    const path = [];
    let cursor = { x: gx, y: gy };
    while (cursor) {
      path.push({ x: cursor.x + 0.5, y: cursor.y + 0.5 });
      cursor = cameFrom.get(this.key(cursor.x, cursor.y));
    }
    return path.reverse();
  }
}
