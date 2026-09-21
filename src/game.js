import { starterObjects } from "./building.js";
import { createCustomers, updateCustomers } from "./characters.js";
import { levelFromXP, progressWithinLevel } from "./progression.js";
import { setupUI, updateHUD } from "./ui.js";

const canvas = document.querySelector("#game-canvas");
const ctx = canvas.getContext("2d", { alpha: false });

const state = {
  cash: 2500,
  xp: 0,
  level: 1,
  progress: {current:0,total:100,ratio:0},
  objects: structuredClone(starterObjects),
  customers: createCustomers(16),
  camera: { x: 0, y: 45, zoom: 1 },
  selectedBuild: null,
  wallStyle: "charcoal",
  time: 0
};

let ui;

function toast(message) {
  const el = document.querySelector("#toast");
  el.textContent = message;
  el.classList.add("show");
  clearTimeout(toast.timer);
  toast.timer = setTimeout(() => el.classList.remove("show"), 1800);
}

function selectBuildItem(item) {
  if (item.kind === "wall") {
    state.wallStyle = item.style;
    toast(`${item.name} applied`);
    return;
  }
  if (item.cost > state.cash) {
    toast("Not enough cash yet");
    return;
  }
  state.selectedBuild = item;
  toast(`${item.name} selected — click the club floor to place`);
}

ui = setupUI(state, { toast, selectBuildItem });

function syncProgress() {
  const oldLevel = state.level;
  state.level = levelFromXP(state.xp);
  state.progress = progressWithinLevel(state.xp, state.level);
  if (state.level !== oldLevel) {
    toast(`Level ${state.level} reached — new designs unlocked`);
    ui.refresh();
  }
  updateHUD(state);
}

function resize() {
  const dpr = Math.min(window.devicePixelRatio || 1, 2);
  const rect = canvas.getBoundingClientRect();
  canvas.width = Math.max(1, Math.floor(rect.width * dpr));
  canvas.height = Math.max(1, Math.floor(rect.height * dpr));
  ctx.setTransform(dpr,0,0,dpr,0,0);
}
window.addEventListener("resize", resize);
resize();
syncProgress();

const TILE_W = 76;
const TILE_H = 38;
const GRID_W = 15;
const GRID_H = 13;

function origin() {
  return {
    x: canvas.clientWidth * .55 + state.camera.x,
    y: 145 + state.camera.y
  };
}

function iso(x,y,z=0) {
  const o = origin();
  return {
    x: o.x + (x - y) * TILE_W * .5 * state.camera.zoom,
    y: o.y + (x + y) * TILE_H * .5 * state.camera.zoom - z * state.camera.zoom
  };
}

function screenToGrid(sx, sy) {
  const o = origin();
  const x = (sx - o.x) / state.camera.zoom;
  const y = (sy - o.y) / state.camera.zoom;
  return {
    x: (y / (TILE_H*.5) + x / (TILE_W*.5)) * .5,
    y: (y / (TILE_H*.5) - x / (TILE_W*.5)) * .5
  };
}

function poly(points, fill, stroke=null, lineWidth=1) {
  ctx.beginPath();
  ctx.moveTo(points[0].x, points[0].y);
  for (let i=1;i<points.length;i++) ctx.lineTo(points[i].x, points[i].y);
  ctx.closePath();
  ctx.fillStyle = fill;
  ctx.fill();
  if (stroke) {
    ctx.strokeStyle = stroke;
    ctx.lineWidth = lineWidth;
    ctx.stroke();
  }
}

function drawBackdrop() {
  const w = canvas.clientWidth;
  const h = canvas.clientHeight;
  const g = ctx.createLinearGradient(0,0,0,h);
  g.addColorStop(0,"#0d0a1d");
  g.addColorStop(.55,"#0a0916");
  g.addColorStop(1,"#060610");
  ctx.fillStyle = g;
  ctx.fillRect(0,0,w,h);

  ctx.globalAlpha = .18;
  for (let i=0;i<7;i++) {
    const x = (i / 6) * w;
    const rg = ctx.createRadialGradient(x,110,0,x,110,190);
    rg.addColorStop(0, i%2 ? "#ff3bbb" : "#6556ff");
    rg.addColorStop(1,"transparent");
    ctx.fillStyle=rg;
    ctx.fillRect(x-220,-30,440,360);
  }
  ctx.globalAlpha=1;
}

function tileColor(x,y) {
  const checker = (x+y)%2===0;
  return checker ? "#1a1830" : "#17152b";
}

function drawRoom() {
  for (let y=0;y<GRID_H;y++) {
    for (let x=0;x<GRID_W;x++) {
      const a=iso(x,y), b=iso(x+1,y), c=iso(x+1,y+1), d=iso(x,y+1);
      poly([a,b,c,d], tileColor(x,y), "rgba(125,108,180,.09)", .7);
    }
  }

  const wallA = state.wallStyle === "violet" ? "#3b2555" : state.wallStyle === "luxury" ? "#292536" : "#202031";
  const wallB = state.wallStyle === "violet" ? "#251b40" : state.wallStyle === "luxury" ? "#1a1922" : "#171724";
  const h = 120;
  const p00=iso(0,0), p10=iso(GRID_W,0), p01=iso(0,GRID_H);
  poly([p00,p10,{x:p10.x,y:p10.y-h},{x:p00.x,y:p00.y-h}], wallA);
  poly([p00,p01,{x:p01.x,y:p01.y-h},{x:p00.x,y:p00.y-h}], wallB);

  ctx.globalAlpha=.5;
  for (let x=1;x<GRID_W;x+=3) {
    const p=iso(x,0);
    const q={x:p.x,y:p.y-h};
    ctx.strokeStyle="#8b65ff";
    ctx.lineWidth=2;
    ctx.beginPath(); ctx.moveTo(p.x,p.y-5); ctx.lineTo(q.x,q.y+8); ctx.stroke();
  }
  ctx.globalAlpha=1;
}

function drawBlock(x,y,w,h,height,top,sideA,sideB) {
  const a=iso(x,y,height), b=iso(x+w,y,height), c=iso(x+w,y+h,height), d=iso(x,y+h,height);
  const ab=iso(x,y,0), bb=iso(x+w,y,0), cb=iso(x+w,y+h,0), db=iso(x,y+h,0);
  poly([a,b,c,d],top);
  poly([b,bb,cb,c],sideA);
  poly([d,c,cb,db],sideB);
}

function drawDance(o) {
  for(let yy=0;yy<o.h;yy++) for(let xx=0;xx<o.w;xx++) {
    const n=(xx+yy+Math.floor(state.time*2))%4;
    const colors=["#5d36d8","#a638d8","#235dd8","#18a8c0"];
    const a=iso(o.x+xx,o.y+yy,2),b=iso(o.x+xx+1,o.y+yy,2),c=iso(o.x+xx+1,o.y+yy+1,2),d=iso(o.x+xx,o.y+yy+1,2);
    ctx.globalAlpha=.72;
    poly([a,b,c,d],colors[n],"rgba(255,255,255,.12)",.6);
  }
  ctx.globalAlpha=1;
}

function drawObject(o) {
  if(o.kind==="dance") return drawDance(o);
  if(o.kind==="bar") {
    drawBlock(o.x,o.y,o.w,o.h,33,o.style==="neon"?"#7349da":"#50465f","#2a2340","#332849");
    const p=iso(o.x+o.w*.5,o.y+.2,42);
    ctx.fillStyle="#5df3ff"; ctx.globalAlpha=.7; ctx.fillRect(p.x-24,p.y-3,48,3); ctx.globalAlpha=1;
  } else if(o.kind==="dj") {
    drawBlock(o.x,o.y,o.w,o.h,36,"#4e3a70","#221c38","#2b2243");
    const p=iso(o.x+o.w*.5,o.y+.45,49);
    ctx.fillStyle="#ff55cf"; ctx.beginPath(); ctx.arc(p.x-14,p.y,7,0,Math.PI*2); ctx.fill();
    ctx.fillStyle="#58e7ff"; ctx.beginPath(); ctx.arc(p.x+14,p.y,7,0,Math.PI*2); ctx.fill();
  } else if(o.kind==="table") {
    const p=iso(o.x+1,o.y+1,14);
    ctx.fillStyle="#3b3150"; ctx.beginPath(); ctx.ellipse(p.x,p.y,38*state.camera.zoom,19*state.camera.zoom,0,0,Math.PI*2); ctx.fill();
    ctx.strokeStyle="#b98cff"; ctx.lineWidth=2; ctx.stroke();
  } else if(o.kind==="sofa" || o.kind==="booth") {
    drawBlock(o.x,o.y,o.w,o.h,24,o.style==="luxury"?"#8045ad":"#593a83","#2d2447","#3b2959");
    drawBlock(o.x,o.y-.08,o.w,.28,42,"#7148a1","#33244e","#432b67");
  } else {
    const p=iso(o.x+.5,o.y+.5,0);
    ctx.fillStyle=o.style==="plant"?"#44a879":"#8c5cff";
    ctx.beginPath(); ctx.arc(p.x,p.y-18,12,0,Math.PI*2);ctx.fill();
    ctx.fillStyle="#362a47";ctx.fillRect(p.x-6,p.y-7,12,16);
  }
}

function drawCharacter(c) {
  const bounce = c.state==="dance" ? Math.sin(c.phase)*3 : Math.sin(c.phase)*1.2;
  const p=iso(c.x,c.y,0);
  const s=state.camera.zoom;
  ctx.save();
  ctx.translate(p.x,p.y+bounce);
  ctx.scale(s,s);
  ctx.fillStyle="rgba(0,0,0,.22)";
  ctx.beginPath();ctx.ellipse(0,4,10,4,0,0,Math.PI*2);ctx.fill();
  ctx.fillStyle=c.top;ctx.beginPath();ctx.roundRect(-6,-24,12,17,5);ctx.fill();
  ctx.fillStyle=c.skin;ctx.beginPath();ctx.arc(0,-32,8,0,Math.PI*2);ctx.fill();
  ctx.fillStyle=c.hair;ctx.beginPath();ctx.arc(0,-35,8,Math.PI,Math.PI*2);ctx.lineTo(8,-32);ctx.lineTo(-8,-32);ctx.fill();
  ctx.strokeStyle="#c8bfd6";ctx.lineWidth=2.2;ctx.beginPath();ctx.moveTo(-3,-7);ctx.lineTo(-4,2);ctx.moveTo(3,-7);ctx.lineTo(4,2);ctx.stroke();
  ctx.restore();
}

function drawSelectedPreview() {
  const item=state.selectedBuild;
  if(!item || !pointer.inside) return;
  const g=screenToGrid(pointer.x,pointer.y);
  const x=Math.floor(g.x), y=Math.floor(g.y);
  if(x<0||y<0||x>=GRID_W||y>=GRID_H) return;
  const [w,h]=item.footprint ?? [1,1];
  const a=iso(x,y,3),b=iso(x+w,y,3),c=iso(x+w,y+h,3),d=iso(x,y+h,3);
  ctx.globalAlpha=.45;
  poly([a,b,c,d],"#52e7ff","#fff",1);
  ctx.globalAlpha=1;
}

function render() {
  drawBackdrop();
  ctx.save();
  ctx.translate(0,0);
  drawRoom();
  const drawables = [...state.objects].sort((a,b)=>(a.x+a.y)-(b.x+b.y));
  for(const o of drawables) drawObject(o);
  [...state.customers].sort((a,b)=>(a.x+a.y)-(b.x+b.y)).forEach(drawCharacter);
  drawSelectedPreview();
  ctx.restore();
}

const pointer={x:0,y:0,inside:false,drag:false,lastX:0,lastY:0,moved:false};

canvas.addEventListener("pointerdown",e=>{
  pointer.drag=true; pointer.lastX=e.clientX; pointer.lastY=e.clientY; pointer.moved=false;
  canvas.setPointerCapture(e.pointerId);
});
canvas.addEventListener("pointermove",e=>{
  const rect=canvas.getBoundingClientRect();
  pointer.x=e.clientX-rect.left; pointer.y=e.clientY-rect.top; pointer.inside=true;
  if(pointer.drag){
    const dx=e.clientX-pointer.lastX, dy=e.clientY-pointer.lastY;
    if(Math.hypot(dx,dy)>2) pointer.moved=true;
    if(!state.selectedBuild || pointer.moved){
      state.camera.x+=dx; state.camera.y+=dy;
      pointer.lastX=e.clientX; pointer.lastY=e.clientY;
    }
  }
});
canvas.addEventListener("pointerup",e=>{
  if(state.selectedBuild && !pointer.moved){
    const rect=canvas.getBoundingClientRect();
    const g=screenToGrid(e.clientX-rect.left,e.clientY-rect.top);
    const x=Math.floor(g.x), y=Math.floor(g.y);
    const item=state.selectedBuild;
    const [w,h]=item.footprint ?? [1,1];
    if(x>=0&&y>=0&&x+w<=GRID_W&&y+h<=GRID_H){
      state.objects.push({id:item.id+"-"+Date.now(),kind:item.kind,x,y,w,h,rotation:0,style:item.style});
      state.cash-=item.cost;
      state.xp+=Math.max(20,Math.round(item.cost/12));
      state.selectedBuild=null;
      syncProgress();
      toast(`${item.name} placed`);
    } else toast("Place it inside the club floor");
  }
  pointer.drag=false;
});
canvas.addEventListener("pointerleave",()=>{pointer.inside=false;pointer.drag=false;});
canvas.addEventListener("wheel",e=>{
  e.preventDefault();
  const dir=Math.sign(e.deltaY);
  state.camera.zoom=Math.max(.62,Math.min(1.5,state.camera.zoom-dir*.08));
},{passive:false});

let last=performance.now();
function loop(now){
  const dt=Math.min(.033,(now-last)/1000);
  last=now;
  state.time+=dt;
  updateCustomers(state.customers,dt);
  render();
  requestAnimationFrame(loop);
}
requestAnimationFrame(loop);
