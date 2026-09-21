import { getCategoryItems } from "./building.js";

export function setupUI(state, actions) {
  const drawer = document.querySelector("#design-drawer");
  const designButton = document.querySelector("#design-button");
  const closeButton = document.querySelector("#close-design");
  const categories = [...document.querySelectorAll(".category")];
  const itemsRoot = document.querySelector("#design-items");
  const navButtons = [...document.querySelectorAll(".nav-button")];

  const setDrawer = open => {
    drawer.classList.toggle("open", open);
    drawer.setAttribute("aria-hidden", String(!open));
    designButton.classList.toggle("active", open);
  };

  designButton.addEventListener("click", () => setDrawer(!drawer.classList.contains("open")));
  closeButton.addEventListener("click", () => setDrawer(false));

  navButtons.forEach(btn => {
    btn.addEventListener("click", () => {
      navButtons.forEach(b => b.classList.remove("active"));
      btn.classList.add("active");
      if (btn.dataset.panel !== "design") setDrawer(false);
    });
  });

  function renderCategory(category) {
    categories.forEach(c => c.classList.toggle("active", c.dataset.category === category));
    itemsRoot.innerHTML = "";
    for (const item of getCategoryItems(category)) {
      const locked = item.level > state.level;
      const card = document.createElement("button");
      card.className = `item-card${locked ? " locked" : ""}`;
      card.innerHTML = `
        <div class="item-thumb">${item.icon}</div>
        <strong>${item.name}</strong>
        <div class="item-meta"><span>Lv. ${item.level}</span><span>${item.cost ? "$" + item.cost.toLocaleString() : "Owned"}</span></div>
        ${locked ? `<span class="lock-badge">LEVEL ${item.level}</span>` : ""}
      `;
      card.addEventListener("click", () => {
        if (locked) return actions.toast(`Unlocks at level ${item.level}`);
        actions.selectBuildItem(item);
      });
      itemsRoot.appendChild(card);
    }
  }

  categories.forEach(c => c.addEventListener("click", () => renderCategory(c.dataset.category)));
  renderCategory("bars");

  return {
    refresh() {
      renderCategory(document.querySelector(".category.active")?.dataset.category ?? "bars");
    },
    setDrawer
  };
}

export function updateHUD(state) {
  document.querySelector("#level-value").textContent = state.level;
  document.querySelector("#cash-value").textContent = "$" + Math.floor(state.cash).toLocaleString();
  document.querySelector("#xp-value").textContent = state.level >= 10
    ? "MAX"
    : `${Math.floor(state.progress.current)} / ${state.progress.total}`;
  document.querySelector("#xp-fill").style.width = `${state.progress.ratio * 100}%`;
}
