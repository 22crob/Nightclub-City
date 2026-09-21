import * as Phaser from "phaser";
import { BootScene } from "./scenes/BootScene.js";
import { ClubScene } from "./scenes/ClubScene.js";
import { GameUI } from "./ui/GameUI.js";

const config = {
  type: Phaser.AUTO,
  parent: "game-root",
  backgroundColor: "#090815",
  scale: {
    mode: Phaser.Scale.RESIZE,
    autoCenter: Phaser.Scale.CENTER_BOTH,
    width: "100%",
    height: "100%"
  },
  render: {
    antialias: true,
    pixelArt: false,
    roundPixels: false
  },
  fps: {
    target: 60
  },
  scene: [BootScene, ClubScene]
};

new GameUI();
new Phaser.Game(config);
