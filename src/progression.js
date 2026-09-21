export const levelThresholds = [0,100,240,420,650,940,1290,1710,2210,2800];

export function xpForLevel(level) {
  return levelThresholds[Math.max(0, Math.min(level - 1, levelThresholds.length - 1))] ?? 0;
}

export function nextLevelXP(level) {
  return levelThresholds[level] ?? levelThresholds[levelThresholds.length - 1];
}

export function levelFromXP(xp) {
  let level = 1;
  for (let i = 1; i < levelThresholds.length; i++) {
    if (xp >= levelThresholds[i]) level = i + 1;
  }
  return Math.min(level, 10);
}

export function progressWithinLevel(xp, level) {
  if (level >= 10) return { current: 1, total: 1, ratio: 1 };
  const floor = xpForLevel(level);
  const ceil = nextLevelXP(level);
  const current = Math.max(0, xp - floor);
  const total = Math.max(1, ceil - floor);
  return { current, total, ratio: Math.min(1, current / total) };
}
