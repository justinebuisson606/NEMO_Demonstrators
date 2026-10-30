console.log("[collapse.js] v4 chargé");

const TITLES = ["running the simulation"];   // débuts de titres à replier (minuscules)
const HEADINGS = "h1,h2,h3,h4,h5,h6";
const levelOf = el => +el.tagName[1];

function labelOf(h) {
  const c = h.cloneNode(true);
  c.querySelectorAll(".headerlink, .anchor-link").forEach(a => a.remove());
  return c.textContent.trim();
}

function collapseSections() {
  try {
    const root = document.querySelector(".md-content__inner") || document.body;
    const all = Array.from(root.querySelectorAll(HEADINGS));
    console.log("[collapse.js] titres trouvés :", all.length);
    let done = 0;

    all.forEach((h, i) => {
      if (h.dataset.folded || h.closest("details")) return;
      const label = labelOf(h);
      if (!TITLES.some(t => label.toLowerCase().startsWith(t))) return;
      h.dataset.folded = "1";

      const level = levelOf(h);
      const next = all.slice(i + 1).find(x => levelOf(x) <= level);
      console.log("[collapse.js] section :", label, "| fin avant :", next ? labelOf(next) : "(fin de page)");

      const range = document.createRange();
      range.setStartBefore(h);
      if (next) range.setEndBefore(next); else range.setEndAfter(root.lastChild);

      const contents = range.extractContents();
      const details = document.createElement("details");
      const summary = document.createElement("summary");
      summary.textContent = label + " (click to expand)";
      details.appendChild(summary);
      details.appendChild(contents);
      range.insertNode(details);
      h.style.display = "none";
      done++;
    });
    console.log("[collapse.js] sections repliées :", done);
  } catch (e) {
    console.error("[collapse.js] erreur :", e);
  }
}

if (typeof document$ !== "undefined") document$.subscribe(collapseSections);
else document.addEventListener("DOMContentLoaded", collapseSections);
window.addEventListener("load", collapseSections);   // filet de sécurité, sans effet si déjà fait
