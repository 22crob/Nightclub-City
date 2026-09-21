export function easeOutCubic(t) {
  return 1 - Math.pow(1 - t, 3);
}

export function pulse(time, speed = 1, min = 0, max = 1) {
  const n = (Math.sin(time * speed) + 1) * .5;
  return min + (max - min) * n;
}
