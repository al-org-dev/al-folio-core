const ninjaKeys = document.querySelector("ninja-keys");

const currentTheme =
  typeof window.determineComputedTheme === "function"
    ? window.determineComputedTheme()
    : document.documentElement.dataset.theme || "light";

if (ninjaKeys) {
  if (currentTheme === "dark") {
    ninjaKeys.classList.add("dark");
  } else {
    ninjaKeys.classList.remove("dark");
  }
}

window.openSearchModal = () => {
  const navbarNav = document.getElementById("navbarNav");
  const navbarToggle = document.querySelector("[data-nav-toggle]");

  if (navbarNav && navbarNav.classList.contains("show")) {
    navbarNav.classList.remove("show");
    navbarToggle?.classList.add("collapsed");
    navbarToggle?.setAttribute("aria-expanded", "false");
  }

  ninjaKeys?.open();
};
