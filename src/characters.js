const skinTones = ["#f1c7a5","#d79a72","#b97350","#8d563b","#6a3e2c"];
const tops = ["#ff62c7","#7c63ff","#58ddff","#f4f0ff","#ffb24a","#69e7ad"];
const hairs = ["#191622","#3b241a","#6e4629","#d6b06b","#d9d9e2"];

function seeded(i, mod) { return Math.abs(Math.sin(i * 91.733) * 9999) % mod; }

export function createCustomers(count = 14) {
  return Array.from({length:count}, (_,i) => ({
    id: `guest-${i}`,
    x: 4 + (seeded(i+1, 8)),
    y: 5 + (seeded(i+2, 5)),
    targetX: 5 + seeded(i+4, 7),
    targetY: 5 + seeded(i+5, 5),
    speed: .45 + seeded(i+7, .22),
    phase: seeded(i+8, Math.PI * 2),
    skin: skinTones[i % skinTones.length],
    top: tops[(i * 3) % tops.length],
    hair: hairs[(i * 2 + 1) % hairs.length],
    state: i % 4 === 0 ? "dance" : "walk"
  }));
}

export function updateCustomers(customers, dt) {
  for (const c of customers) {
    c.phase += dt * (c.state === "dance" ? 5 : 2.2);
    const dx = c.targetX - c.x;
    const dy = c.targetY - c.y;
    const dist = Math.hypot(dx, dy);
    if (dist < .2) {
      c.targetX = 4.5 + Math.random() * 7;
      c.targetY = 5 + Math.random() * 5;
      c.state = Math.random() < .38 ? "dance" : "walk";
    } else if (c.state !== "dance") {
      const step = Math.min(dist, c.speed * dt);
      c.x += dx / dist * step;
      c.y += dy / dist * step;
    } else if (Math.random() < dt * .25) {
      c.state = "walk";
    }
  }
}
