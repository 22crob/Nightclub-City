import { getCatalogItems } from "../data/catalog.js";
import { gameStore } from "../state/GameStore.js";

export class GameUI {
  constructor() {
    this.drawer = document.querySelector("#design-drawer");
    this.designButton = document.querySelector("#design-button");
    this.closeButton = document.querySelector("#close-design");
    this.itemsRoot = document.querySelector("#design-items");
    this.categories = Array.from(document.querySelectorAll(".category"));
    this.navButtons = Array.from(document.querySelectorAll(".nav-button"));
    this.toastElement = document.querySelector("#toast");
    this.currentCategory = "bars";
    this.toastTimer = null;

    this.bindEvents();
    this.unsubscribe = gameStore.subscribe((state) => this.render(state));
  }

  bindEvents() {
    this.designButton.addEventListener("click", () => this.setDrawer(!this.drawer.classList.contains("open")));
    this.closeButton.addEventListener("click", () => this.setDrawer(false));

    this.categories.forEach((button) => {
      button.addEventListener("click", () => {
        this.currentCategory = button.dataset.category;
        this.render(gameStore.snapshot());
      });
    });

    this.navButtons.forEach((button) => {
      button.addEventListener("click", () => {
        this.navButtons.forEach((item) => item.classList.remove("active"));
        button.classList.add("active");
        if (button.dataset.panel !== "design") this.setDrawer(false);
      });
    });

    window.addEventListener("nightclub:toast", (event) => this.toast(event.detail));
    window.addEventListener("nightclub:build-cleared", () => this.render(gameStore.snapshot()));
  }

  setDrawer(open) {
    this.drawer.classList.toggle("open", open);
    this.drawer.setAttribute("aria-hidden", String(!open));
    this.designButton.classList.toggle("active", open);
  }

  render(state) {
    document.querySelector("#level-value").textContent = String(state.level);
    document.querySelector("#cash-value").textContent = "$" + Math.floor(state.cash).toLocaleString();
    document.querySelector("#xp-fill").style.width = String(state.progress.ratio * 100) + "%";
    document.querySelector("#xp-value").textContent = state.level >= 10
      ? "MAX"
      : Math.floor(state.progress.current) + " / " + state.progress.total;

    this.categories.forEach((button) => {
      button.classList.toggle("active", button.dataset.category === this.currentCategory);
    });

    this.renderItems(state);
  }

  renderItems(state) {
    this.itemsRoot.innerHTML = "";
    for (const item of getCatalogItems(this.currentCategory)) {
      const locked = item.level > state.level;
      const selected = state.selectedBuild && state.selectedBuild.id === item.id;
      const card = document.createElement("button");
      card.className = "item-card" + (locked ? " locked" : "") + (selected ? " selected" : "");
      card.innerHTML =
        '<div class="item-thumb">' + item.icon + '</div>' +
        '<strong>' + item.name + '</strong>' +
        '<div class="item-meta"><span>Lv. ' + item.level + '</span><span>' +
        (item.cost ? "$" + item.cost.toLocaleString() : "Owned") + '</span></div>' +
        (locked ? '<span class="lock-badge">LEVEL ' + item.level + '</span>' : "");

      card.addEventListener("click", () => {
        if (locked) {
          this.toast("Unlocks at level " + item.level + ".");
          return;
        }
        if (!gameStore.canAfford(item.cost)) {
          this.toast("Not enough cash yet.");
          return;
        }
        gameStore.selectBuild(item);
        window.dispatchEvent(new CustomEvent("nightclub:build-selected", { detail: item }));
        this.toast(item.name + " selected — click the club floor to place it.");
      });
      this.itemsRoot.appendChild(card);
    }
  }

  toast(message) {
    this.toastElement.textContent = message;
    this.toastElement.classList.add("show");
    window.clearTimeout(this.toastTimer);
    this.toastTimer = window.setTimeout(() => this.toastElement.classList.remove("show"), 2200);
  }
}
