const LEVEL_THRESHOLDS = [0, 100, 240, 420, 650, 940, 1290, 1710, 2210, 2800];

class GameStore {
  constructor() {
    this.cash = 2500;
    this.xp = 0;
    this.level = 1;
    this.selectedBuild = null;
    this.listeners = new Set();
  }

  subscribe(listener) {
    this.listeners.add(listener);
    listener(this.snapshot());
    return () => this.listeners.delete(listener);
  }

  snapshot() {
    const progress = this.getProgress();
    return {
      cash: this.cash,
      xp: this.xp,
      level: this.level,
      selectedBuild: this.selectedBuild,
      progress
    };
  }

  emit() {
    const snapshot = this.snapshot();
    for (const listener of this.listeners) listener(snapshot);
  }

  getProgress() {
    if (this.level >= 10) return { current: 1, total: 1, ratio: 1 };
    const floor = LEVEL_THRESHOLDS[this.level - 1];
    const ceiling = LEVEL_THRESHOLDS[this.level];
    const current = Math.max(0, this.xp - floor);
    const total = Math.max(1, ceiling - floor);
    return { current, total, ratio: Math.min(1, current / total) };
  }

  recalculateLevel() {
    let nextLevel = 1;
    for (let i = 1; i < LEVEL_THRESHOLDS.length; i += 1) {
      if (this.xp >= LEVEL_THRESHOLDS[i]) nextLevel = i + 1;
    }
    this.level = Math.min(10, nextLevel);
  }

  selectBuild(item) {
    this.selectedBuild = item;
    this.emit();
  }

  clearBuildSelection() {
    this.selectedBuild = null;
    this.emit();
  }

  canAfford(cost) {
    return cost <= this.cash;
  }

  purchase(cost, xpReward) {
    if (!this.canAfford(cost)) return false;
    this.cash -= cost;
    this.xp += xpReward;
    this.recalculateLevel();
    this.emit();
    return true;
  }
}

export const gameStore = new GameStore();
