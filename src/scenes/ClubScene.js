import * as Phaser from "phaser";
import { COLORS } from "../config/constants.js";
import { starterLayout, seats, guestRoute } from "../data/starterLayout.js";
import { gameStore } from "../state/GameStore.js";
import { IsoGrid } from "../systems/IsoGrid.js";
import { NavigationGrid } from "../systems/NavigationGrid.js";
import { ClubObjectFactory } from "../systems/ClubObjectFactory.js";
import { GuestActor } from "../systems/GuestActor.js";

export class ClubScene extends Phaser.Scene {
  constructor() {
    super("ClubScene");
    this.objects = [];
    this.selectedBuild = null;
    this.drag = null;
  }

  create() {
    this.cameras.main.setBackgroundColor(COLORS.background);

    this.grid = new IsoGrid(this);
    this.grid.drawRoom();
    this.navigation = new NavigationGrid(this.grid);
    this.factory = new ClubObjectFactory(this, this.grid);

    this.objects = starterLayout.map((object) => ({ ...object }));
    this.navigation.rebuild(this.objects);
    for (const object of this.objects) this.factory.create(object);

    const seat = seats.find((entry) => entry.id === guestRoute.seatId);
    this.guest = new GuestActor(this, this.grid, this.navigation, guestRoute, seat);

    this.preview = this.add.graphics();
    this.preview.setDepth(99999);
    this.preview.setVisible(false);

    this.configureCamera();
    this.configureBuildEvents();
    this.events.once(Phaser.Scenes.Events.SHUTDOWN, () => this.cleanup());

    window.dispatchEvent(new CustomEvent("nightclub:toast", {
      detail: "Phaser foundation loaded — watch the test guest walk, dance, and sit."
    }));
  }

  cleanup() {
    window.removeEventListener("nightclub:build-selected", this.onBuildSelected);
    window.removeEventListener("nightclub:build-cleared", this.onBuildCleared);
  }

  configureCamera() {
    const camera = this.cameras.main;
    camera.setZoom(0.88);
    camera.centerOn(720, 445);

    this.input.on("pointerdown", (pointer) => {
      this.drag = {
        x: pointer.x,
        y: pointer.y,
        scrollX: camera.scrollX,
        scrollY: camera.scrollY,
        moved: false
      };
    });

    this.input.on("pointermove", (pointer) => {
      this.updateBuildPreview(pointer);
      if (!pointer.isDown || !this.drag) return;
      const dx = pointer.x - this.drag.x;
      const dy = pointer.y - this.drag.y;
      if (Math.hypot(dx, dy) > 4) this.drag.moved = true;
      if (this.selectedBuild) return;
      camera.scrollX = this.drag.scrollX - dx / camera.zoom;
      camera.scrollY = this.drag.scrollY - dy / camera.zoom;
    });

    this.input.on("pointerup", (pointer) => {
      const moved = this.drag && this.drag.moved;
      if (this.selectedBuild && !moved) this.tryPlaceBuild(pointer);
      this.drag = null;
    });

    this.input.on("wheel", (pointer, gameObjects, deltaX, deltaY) => {
      const nextZoom = Phaser.Math.Clamp(camera.zoom - Math.sign(deltaY) * 0.08, 0.62, 1.35);
      camera.setZoom(nextZoom);
    });
  }

  configureBuildEvents() {
    this.onBuildSelected = (event) => {
      this.selectedBuild = event.detail;
      this.preview.setVisible(true);
    };
    this.onBuildCleared = () => {
      this.selectedBuild = null;
      this.preview.clear();
      this.preview.setVisible(false);
    };
    window.addEventListener("nightclub:build-selected", this.onBuildSelected);
    window.addEventListener("nightclub:build-cleared", this.onBuildCleared);
  }

  updateBuildPreview(pointer) {
    if (!this.selectedBuild) return;
    const world = pointer.positionToCamera(this.cameras.main);
    const tile = this.grid.toGrid(world.x, world.y);
    const x = Math.floor(tile.x);
    const y = Math.floor(tile.y);
    const footprint = this.selectedBuild.footprint || [1, 1];
    const w = footprint[0];
    const h = footprint[1];
    const valid = this.selectedBuild.kind === "wall" || this.navigation.canPlace(x, y, w, h);

    this.preview.clear();
    this.preview.fillStyle(valid ? COLORS.cyan : 0xff5c7b, 0.28);
    this.preview.fillPoints(this.grid.diamond(x, y, w, h, 4), true);
    this.preview.lineStyle(2, valid ? COLORS.cyan : 0xff5c7b, 0.9);
    this.preview.strokePoints(this.grid.diamond(x, y, w, h, 4), true);
  }

  tryPlaceBuild(pointer) {
    const item = this.selectedBuild;
    if (!item) return;

    if (item.kind === "wall") {
      window.dispatchEvent(new CustomEvent("nightclub:toast", {
        detail: "Wall themes are wired into the catalog; visual wall swapping is the next art pass."
      }));
      gameStore.clearBuildSelection();
      window.dispatchEvent(new Event("nightclub:build-cleared"));
      return;
    }

    const world = pointer.positionToCamera(this.cameras.main);
    const tile = this.grid.toGrid(world.x, world.y);
    const x = Math.floor(tile.x);
    const y = Math.floor(tile.y);
    const footprint = item.footprint || [1, 1];
    const w = footprint[0];
    const h = footprint[1];

    if (!this.navigation.canPlace(x, y, w, h)) {
      window.dispatchEvent(new CustomEvent("nightclub:toast", { detail: "That space is blocked." }));
      return;
    }

    const reward = Math.max(20, Math.round(item.cost / 12));
    if (!gameStore.purchase(item.cost, reward)) {
      window.dispatchEvent(new CustomEvent("nightclub:toast", { detail: "Not enough cash yet." }));
      return;
    }

    const object = {
      id: item.id + "-" + Date.now(),
      kind: item.kind,
      x,
      y,
      w,
      h,
      style: item.style,
      solid: item.kind !== "dance"
    };
    this.objects.push(object);
    this.factory.create(object);
    if (object.solid) this.navigation.blockFootprint(x, y, w, h);

    gameStore.clearBuildSelection();
    window.dispatchEvent(new Event("nightclub:build-cleared"));
    window.dispatchEvent(new CustomEvent("nightclub:toast", { detail: item.name + " placed." }));
  }

  update(time, delta) {
    if (this.guest) this.guest.update(time, delta);
  }
}
