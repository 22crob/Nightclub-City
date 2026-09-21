import { DEPTH } from "../config/constants.js";

export class GuestActor {
  constructor(scene, grid, navigation, route, seat) {
    this.scene = scene;
    this.grid = grid;
    this.navigation = navigation;
    this.route = route;
    this.seat = seat;
    this.gridPosition = { x: route.entrance.x + 0.5, y: route.entrance.y + 0.5 };
    this.path = [];
    this.pathIndex = 0;
    this.speed = 2.25;
    this.state = "enter";
    this.stateTime = 0;
    this.phase = 0;

    const world = this.grid.toWorld(this.gridPosition.x, this.gridPosition.y);
    this.root = scene.add.container(world.x, world.y);
    this.body = scene.add.container(0, 0);
    this.root.add(this.body);

    this.shadow = scene.add.ellipse(0, 5, 22, 9, 0x000000, 0.25);
    this.leftLeg = scene.add.rectangle(-4, -8, 5, 15, 0xbfc2d4, 1);
    this.rightLeg = scene.add.rectangle(4, -8, 5, 15, 0xbfc2d4, 1);
    this.torso = scene.add.rectangle(0, -25, 17, 22, 0xff62c7, 1);
    this.head = scene.add.ellipse(0, -43, 19, 21, 0xd79a72, 1);
    this.hair = scene.add.ellipse(0, -47, 20, 11, 0x2a1d25, 1);

    this.body.add([this.shadow, this.leftLeg, this.rightLeg, this.torso, this.head, this.hair]);
    this.setStandingPose();
    this.walkTo(route.danceTarget, "dance");
  }

  setStandingPose() {
    this.leftLeg.setPosition(-4, -8).setRotation(0);
    this.rightLeg.setPosition(4, -8).setRotation(0);
    this.torso.setPosition(0, -25).setRotation(0);
    this.head.setPosition(0, -43);
    this.hair.setPosition(0, -47);
    this.body.setPosition(0, 0).setRotation(0).setScale(1, 1);
  }

  setSeatedPose() {
    this.leftLeg.setPosition(-6, -1).setRotation(-0.72);
    this.rightLeg.setPosition(6, -1).setRotation(0.72);
    this.torso.setPosition(0, -20).setRotation(0);
    this.head.setPosition(0, -38);
    this.hair.setPosition(0, -42);
    this.body.setPosition(0, -5);
    this.faceDirection(this.seat.facing);
  }

  faceDirection(direction) {
    if (direction === "NE" || direction === "SE") this.body.setScale(1, 1);
    else this.body.setScale(-1, 1);
  }

  faceMovement(from, to) {
    const a = this.grid.toWorld(from.x, from.y);
    const b = this.grid.toWorld(to.x, to.y);
    this.body.setScale(b.x >= a.x ? 1 : -1, 1);
  }

  walkTo(target, nextState) {
    const path = this.navigation.findPath(this.gridPosition, target);
    this.path = path.length > 1 ? path.slice(1) : [];
    this.pathIndex = 0;
    this.nextState = nextState;
    this.state = "walk";
    this.stateTime = 0;
    this.setStandingPose();
  }

  beginState(state) {
    this.state = state;
    this.stateTime = 0;
    if (state === "dance") this.setStandingPose();
    if (state === "sit") {
      this.gridPosition = { x: this.seat.position.x, y: this.seat.position.y };
      this.setSeatedPose();
      this.updateWorldPosition();
    }
  }

  updateWorldPosition() {
    const world = this.grid.toWorld(this.gridPosition.x, this.gridPosition.y);
    this.root.setPosition(world.x, world.y);
    this.root.setDepth(DEPTH.guestBase + Math.round((this.gridPosition.x + this.gridPosition.y) * 100));
  }

  update(time, delta) {
    const dt = delta / 1000;
    this.stateTime += dt;
    this.phase += dt;

    if (this.state === "walk") this.updateWalk(dt);
    else if (this.state === "dance") this.updateDance();
    else if (this.state === "sit") this.updateSit();

    this.updateWorldPosition();
  }

  updateWalk(dt) {
    const target = this.path[this.pathIndex];
    if (!target) {
      this.beginState(this.nextState);
      return;
    }

    const dx = target.x - this.gridPosition.x;
    const dy = target.y - this.gridPosition.y;
    const distance = Math.hypot(dx, dy);
    if (distance < 0.04) {
      this.gridPosition = { ...target };
      this.pathIndex += 1;
      return;
    }

    this.faceMovement(this.gridPosition, target);
    const step = Math.min(distance, this.speed * dt);
    this.gridPosition.x += (dx / distance) * step;
    this.gridPosition.y += (dy / distance) * step;
    this.body.y = Math.sin(this.phase * 13) * 2.2;
    this.leftLeg.rotation = Math.sin(this.phase * 13) * 0.18;
    this.rightLeg.rotation = -this.leftLeg.rotation;
  }

  updateDance() {
    this.body.y = Math.sin(this.phase * 7.5) * 4;
    this.body.rotation = Math.sin(this.phase * 4) * 0.08;
    this.leftLeg.rotation = Math.sin(this.phase * 6) * 0.22;
    this.rightLeg.rotation = -this.leftLeg.rotation;

    if (this.stateTime > 4.2) {
      this.walkTo(this.seat.approach, "sit");
    }
  }

  updateSit() {
    this.body.y = -5 + Math.sin(this.phase * 2.2) * 0.7;
    if (this.stateTime > 4.5) {
      this.gridPosition = { x: this.seat.approach.x + 0.5, y: this.seat.approach.y + 0.5 };
      this.setStandingPose();
      this.walkTo(this.route.danceTarget, "dance");
    }
  }
}
