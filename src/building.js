export const catalog = {
  bars: [
    { id: "starter-bar", name: "Starter Bar", level: 1, cost: 0, icon: "▰", kind: "bar", footprint: [3,1], style: "starter" },
    { id: "neon-bar", name: "Neon Bar", level: 3, cost: 1200, icon: "▰", kind: "bar", footprint: [3,1], style: "neon" },
    { id: "vip-bar", name: "VIP Backlit Bar", level: 7, cost: 4200, icon: "▰", kind: "bar", footprint: [4,1], style: "vip" }
  ],
  seating: [
    { id: "round-table", name: "Round Table Set", level: 1, cost: 300, icon: "◉", kind: "table", footprint: [2,2], style: "starter" },
    { id: "purple-sofa", name: "Purple Lounge Sofa", level: 2, cost: 650, icon: "▱", kind: "sofa", footprint: [2,1], style: "purple" },
    { id: "corner-booth", name: "Corner Booth", level: 5, cost: 1800, icon: "◰", kind: "booth", footprint: [2,2], style: "vip" },
    { id: "velvet-booth", name: "Velvet VIP Booth", level: 9, cost: 5200, icon: "◰", kind: "booth", footprint: [3,2], style: "luxury" }
  ],
  dance: [
    { id: "basic-dance", name: "Basic Dance Floor", level: 1, cost: 500, icon: "◇", kind: "dance", footprint: [3,3], style: "starter" },
    { id: "pulse-floor", name: "Pulse Dance Floor", level: 4, cost: 2100, icon: "◆", kind: "dance", footprint: [4,4], style: "pulse" },
    { id: "prism-floor", name: "Prism Dance Floor", level: 8, cost: 4800, icon: "◆", kind: "dance", footprint: [4,4], style: "prism" }
  ],
  walls: [
    { id: "charcoal-wall", name: "Charcoal Walls", level: 1, cost: 0, icon: "▦", kind: "wall", style: "charcoal" },
    { id: "violet-wall", name: "Violet Accent Walls", level: 4, cost: 1000, icon: "▦", kind: "wall", style: "violet" },
    { id: "lux-wall", name: "Luxury Panel Walls", level: 8, cost: 3500, icon: "▦", kind: "wall", style: "luxury" }
  ],
  decor: [
    { id: "neon-sign", name: "Neon Sign", level: 2, cost: 450, icon: "✧", kind: "decor", footprint: [1,1], style: "neon" },
    { id: "speaker-stack", name: "Speaker Stack", level: 3, cost: 700, icon: "▣", kind: "decor", footprint: [1,1], style: "speaker" },
    { id: "laser-column", name: "Laser Column", level: 6, cost: 2200, icon: "✦", kind: "decor", footprint: [1,1], style: "laser" },
    { id: "champagne-display", name: "Champagne Display", level: 10, cost: 6500, icon: "♢", kind: "decor", footprint: [2,1], style: "luxury" }
  ]
};

export const starterObjects = [
  { id:"dj-1", kind:"dj", x:7, y:2, w:3, h:1, rotation:0, style:"starter" },
  { id:"bar-1", kind:"bar", x:2, y:3, w:3, h:1, rotation:0, style:"starter" },
  { id:"dance-1", kind:"dance", x:6, y:6, w:4, h:4, rotation:0, style:"starter" },
  { id:"table-1", kind:"table", x:2, y:7, w:2, h:2, rotation:0, style:"starter" },
  { id:"sofa-1", kind:"sofa", x:11, y:6, w:2, h:1, rotation:0, style:"purple" },
  { id:"plant-1", kind:"decor", x:12, y:3, w:1, h:1, rotation:0, style:"plant" }
];

export function getCategoryItems(category) {
  return catalog[category] ?? [];
}
