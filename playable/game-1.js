"use strict";
const $=s=>document.querySelector(s), $$=s=>[...document.querySelectorAll(s)];
const canvas=$("#game"),ctx=canvas.getContext("2d");
const TILE_W=76,TILE_H=38,GRID_W=15,GRID_H=13,NIGHT_LENGTH=120,MAX_GUESTS=26;
const COLORS={bg:"#070610",floorA:"#181526",floorB:"#13111f",grid:"rgba(91,83,130,.3)",pink:"#ff4ecb",purple:"#8c5cff",cyan:"#52e7ff",green:"#62e3a6",gold:"#ffca67",red:"#ff667f"};
const thresholds=[0,140,360,680,1100,1650,2350,3250,4400,5850];
const catalog={
 bars:[
  {id:"starter-bar",name:"Starter Bar",level:1,cost:450,icon:"▰",kind:"bar",fp:[2,1],style:"starter",vibe:8,cap:4},
  {id:"neon-bar",name:"Neon Rail Bar",level:3,cost:1350,icon:"▰",kind:"bar",fp:[3,1],style:"neon",vibe:18,cap:7},
  {id:"lounge-bar",name:"Lounge Cocktail Bar",level:5,cost:2750,icon:"▰",kind:"bar",fp:[3,2],style:"lounge",vibe:32,cap:10},
  {id:"glow-bar",name:"Premium Glow Bar",level:8,cost:5600,icon:"▰",kind:"bar",fp:[4,2],style:"glow",vibe:55,cap:14},
  {id:"vip-bar",name:"VIP Signature Bar",level:10,cost:9200,icon:"▰",kind:"bar",fp:[4,2],style:"vip",vibe:82,cap:18}],
 seating:[
  {id:"round-table",name:"Round Table Set",level:1,cost:350,icon:"◉",kind:"table",fp:[2,2],style:"starter",vibe:6,cap:4},
  {id:"purple-sofa",name:"Purple Lounge Sofa",level:2,cost:700,icon:"▱",kind:"sofa",fp:[2,1],style:"purple",vibe:12,cap:3},
  {id:"blue-sofa",name:"Electric Blue Sofa",level:4,cost:1250,icon:"▱",kind:"sofa",fp:[2,1],style:"blue",vibe:20,cap:3},
  {id:"corner-booth",name:"Corner Booth",level:6,cost:2450,icon:"◰",kind:"booth",fp:[2,2],style:"vip",vibe:34,cap:6},
  {id:"velvet-booth",name:"Velvet VIP Booth",level:9,cost:5200,icon:"◰",kind:"booth",fp:[3,2],style:"luxury",vibe:62,cap:8}],
 dance:[
  {id:"basic-dance",name:"Basic Dance Floor",level:1,cost:550,icon:"◇",kind:"dance",fp:[3,3],style:"starter",vibe:8,cap:8},
  {id:"pulse-floor",name:"Pulse Dance Floor",level:4,cost:2200,icon:"◆",kind:"dance",fp:[4,4],style:"pulse",vibe:26,cap:14},
  {id:"laser-floor",name:"Laser Grid Floor",level:6,cost:3600,icon:"◆",kind:"dance",fp:[4,4],style:"laser",vibe:40,cap:16},
  {id:"prism-floor",name:"Prism Dance Floor",level:9,cost:6500,icon:"◆",kind:"dance",fp:[5,4],style:"prism",vibe:70,cap:22}],
 walls:[
  {id:"charcoal-wall",name:"Charcoal Walls",level:1,cost:0,icon:"▦",kind:"wall",fp:[1,1],style:"charcoal",vibe:0,cap:0},
  {id:"violet-wall",name:"Violet Accent Walls",level:3,cost:850,icon:"▦",kind:"wall",fp:[1,1],style:"violet",vibe:12,cap:0},
  {id:"midnight-wall",name:"Midnight Blue Walls",level:5,cost:1600,icon:"▦",kind:"wall",fp:[1,1],style:"midnight",vibe:22,cap:0},
  {id:"lux-wall",name:"Luxury Panel Walls",level:8,cost:3500,icon:"▦",kind:"wall",fp:[1,1],style:"luxury",vibe:42,cap:0}],
 decor:[
  {id:"neon-sign",name:"Neon Club Sign",level:2,cost:450,icon:"✧",kind:"decor",fp:[1,1],style:"neon",vibe:10,cap:0},
  {id:"speaker-stack",name:"Speaker Stack",level:3,cost:750,icon:"▣",kind:"decor",fp:[1,1],style:"speaker",vibe:14,cap:0},
  {id:"palm-planter",name:"Night Palm",level:4,cost:900,icon:"♧",kind:"decor",fp:[1,1],style:"plant",vibe:14,cap:0},
  {id:"laser-column",name:"Laser Column",level:6,cost:2200,icon:"✦",kind:"decor",fp:[1,1],style:"laser",vibe:28,cap:0},
  {id:"champagne-display",name:"Champagne Display",level:10,cost:6500,icon:"♢",kind:"decor",fp:[2,1],style:"luxury",vibe:60,cap:0}]
};
const starter=[
 {id:"dj-1",kind:"dj",x:6,y:1,w:3,h:2,style:"starter",solid:true,vibe:18,cap:0},
 {id:"bar-1",catalogId:"starter-bar",kind:"bar",x:2,y:3,w:2,h:1,style:"starter",solid:true,vibe:8,cap:4},
 {id:"dance-1",catalogId:"basic-dance",kind:"dance",x:6,y:6,w:3,h:3,style:"starter",solid:false,vibe:8,cap:8},
 {id:"table-1",catalogId:"round-table",kind:"table",x:2,y:7,w:2,h:2,style:"starter",solid:true,vibe:6,cap:4},
 {id:"sofa-1",catalogId:"purple-sofa",kind:"sofa",x:11,y:6,w:2,h:1,style:"purple",solid:true,vibe:12,cap:3},
 {id:"plant-1",catalogId:"palm-planter",kind:"decor",x:12,y:3,w:1,h:1,style:"plant",solid:true,vibe:10,cap:0}
];
const goalDefs=[
 {id:"first-night",name:"Run your first night",reward:500,test:s=>s.night>1},
 {id:"serve-10",name:"Serve 10 guests",reward:750,test:s=>s.guestsServed>=10},
 {id:"earn-1500",name:"Earn $1,500 from guests",reward:900,test:s=>s.totalEarned>=1500},
 {id:"level-3",name:"Reach Level 3",reward:1200,test:s=>s.level>=3},
 {id:"rep-30",name:"Reach 30 reputation",reward:1600,test:s=>s.rep>=30}
];
const saveKey="nightclub-city-standalone-v1",layoutKey="nightclub-city-standalone-layout-v1";
let state={cash:4500,xp:0,level:1,rep:8,rating:3,guestsServed:0,totalEarned:0,night:1,open:false,nightIncome:0,nightGuests:0,wall:"charcoal",claimed:[]};
let objects=starter.map(o=>({...o})),guests=[],selected=null,category="bars",bulldoze=false,hoverTile=null,nightLeft=NIGHT_LENGTH,spawnClock=0,lastTime=performance.now(),toastTimer=0,reportOpen=false;
let view={panX:0,panY:55,zoom:.86,drag:null};
const entrance={x:14.5,y:11.5};
function load(){try{const s=JSON.parse(localStorage.getItem(saveKey)||"null");if(s)state={...state,...s,open:false,nightIncome:0,nightGuests:0};const l=JSON.parse(localStorage.getItem(layoutKey)||"null");if(Array.isArray(l)&&l.length)objects=l}catch(e){}recalcLevel();recalcRating()}
function save(){try{localStorage.setItem(saveKey,JSON.stringify({...state,open:false,nightIncome:0,nightGuests:0}));localStorage.setItem(layoutKey,JSON.stringify(objects))}catch(e){}}
function recalcLevel(){let n=1;for(let i=1;i<thresholds.length;i++)if(state.xp>=thresholds[i])n=i+1;state.level=Math.min(10,n)}
function progress(){if(state.level>=10)return{cur:1,total:1,ratio:1};const floor=thresholds[state.level-1],ceil=thresholds[state.level],cur=Math.max(0,state.xp-floor),total=Math.max(1,ceil-floor);return{cur,total,ratio:Math.min(1,cur/total)}}
function recalcRating(){const vibe=objects.reduce((a,o)=>a+(o.vibe||0),0),cap=objects.reduce((a,o)=>a+(o.cap||0),0),types=new Set(objects.map(o=>o.kind)).size,theme=state.wall==="charcoal"?0:.2;state.rating=Math.min(5,2.2+Math.min(1.45,vibe/140)+Math.min(.75,cap/42)+types*.07+theme);renderHUD()}
function purchase(cost,xp=0,vibe=0){if(state.cash<cost)return false;state.cash-=cost;state.xp+=xp;state.rep=Math.min(100,state.rep+vibe*.08);recalcLevel();save();renderAll();return true}
function earn(amount,xp=2){amount=Math.max(0,Math.round(amount));state.cash+=amount;state.totalEarned+=amount;state.nightIncome+=amount;state.xp+=xp;recalcLevel();save();renderHUD();renderGoals()}
function recordGuest(h){state.guestsServed++;state.nightGuests++;state.rep=Math.max(0,Math.min(100,state.rep+(h-.52)*.7));save();renderHUD();renderGoals()}
