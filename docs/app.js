import {
  astrolabe_version,
  parse_char,
  parse_string,
  parse_range,
  parse_identifier,
  parse_int,
  parse_csv,
  parse_modes_demo,
  error_demo,
  commit_vs_alt,
  pos_track,
} from "./playground.js";

const $ = (sel) => document.querySelector(sel);
const $$ = (sel) => Array.from(document.querySelectorAll(sel));

/* ---------- 输出渲染 ---------- */

function pretty(text) {
  try {
    return JSON.stringify(JSON.parse(text), null, 2);
  } catch {
    return String(text);
  }
}

function isError(text) {
  return typeof text === "string" && text.startsWith('{"ok":false');
}

function showOut(selector, text, ok) {
  const node = $(selector);
  if (!node) return;
  node.textContent = pretty(text);
  node.classList.toggle("ok", ok === true);
  node.classList.toggle("bad", ok === false);
}

const showOk = (selector, text) => showOut(selector, text, true);
const showBad = (selector, text) => showOut(selector, text, false);

function auto(selector, text) {
  (isError(text) ? showBad : showOk)(selector, text);
}

/* ---------- 主题 ---------- */

const THEME_KEY = "astrolabe-mbt-theme";
const themeToggle = $("#theme-toggle");

function applyTheme(theme) {
  document.documentElement.dataset.theme = theme;
  if (themeToggle) {
    themeToggle.textContent = theme === "dark" ? "◐" : "☀";
    themeToggle.setAttribute(
      "aria-label",
      theme === "dark" ? "切换到浅色主题" : "切换到深色主题",
    );
    themeToggle.title = themeToggle.getAttribute("aria-label");
  }
}

if (themeToggle) {
  themeToggle.addEventListener("click", () => {
    const next = document.documentElement.dataset.theme === "dark" ? "light" : "dark";
    applyTheme(next);
    try {
      localStorage.setItem(THEME_KEY, next);
    } catch {
      /* 隐私模式忽略 */
    }
  });
  applyTheme(document.documentElement.dataset.theme === "light" ? "light" : "dark");
}

/* ---------- 窄屏导航（≤960px 汉堡菜单） ---------- */

const navToggle = $("#nav-toggle");
const siteNav = $("#site-nav");

function closeNav() {
  if (!siteNav) return;
  siteNav.classList.remove("open");
  if (navToggle) {
    navToggle.setAttribute("aria-expanded", "false");
    navToggle.setAttribute("aria-label", "打开导航");
    navToggle.title = "打开导航";
  }
}

if (navToggle && siteNav) {
  navToggle.addEventListener("click", () => {
    const open = siteNav.classList.toggle("open");
    navToggle.setAttribute("aria-expanded", open ? "true" : "false");
    navToggle.setAttribute("aria-label", open ? "关闭导航" : "打开导航");
    navToggle.title = navToggle.getAttribute("aria-label");
  });
  siteNav.querySelectorAll("a").forEach((link) => {
    link.addEventListener("click", closeNav);
  });
  document.addEventListener("keydown", (event) => {
    if (event.key === "Escape") closeNav();
  });
  window.addEventListener("resize", () => {
    if (window.innerWidth > 960) closeNav();
  });
}

/* ---------- 演示动作 ---------- */

function runChar() {
  auto("#char-out", parse_char($("#in-char").value, $("#arg-char").value));
}

function runString() {
  auto("#str-out", parse_string($("#in-str").value, $("#arg-str").value));
}

function runRange() {
  auto("#range-out", parse_range($("#in-range").value, $("#lo").value, $("#hi").value));
}

function runIdent() {
  auto("#ident-out", parse_identifier($("#in-ident").value));
}

function runInt() {
  auto("#int-out", parse_int($("#in-int").value));
}

function runCsv() {
  auto("#csv-out", parse_csv($("#in-csv").value));
}

function runModes() {
  auto("#modes-out", parse_modes_demo($("#in-modes").value, $("#arg-modes").value));
}

function runError() {
  // 失败演示：结构化错误（位置 + 期望 + caret 片段）就是本次输出，故用 ok 态渲染。
  const text = error_demo($("#in-err").value, $("#arg-err").value);
  showOk("#err-out", text);
}

function runCommit() {
  auto("#commit-out", commit_vs_alt($("#in-commit").value));
}

function runPos() {
  auto("#pos-out", pos_track($("#in-pos").value));
}

function runHero() {
  const text = error_demo("abd", "abc");
  let data = null;
  try {
    data = JSON.parse(text);
  } catch {
    data = null;
  }
  if (!data || !data.pos) {
    $("#hero-format").textContent = text;
    $("#hero-status").textContent = "演示失败";
    return;
  }
  $("#hero-line").textContent = String(data.pos.line);
  $("#hero-column").textContent = String(data.pos.column);
  $("#hero-offset").textContent = String(data.pos.offset);
  $("#hero-format").textContent = data.format;
  $("#hero-status").textContent = "错误上下文演示（输入 abd，期望 abc）";
}

const ACTIONS = {
  char: runChar,
  string: runString,
  range: runRange,
  ident: runIdent,
  int: runInt,
  csv: runCsv,
  modes: runModes,
  error: runError,
  commit: runCommit,
  pos: runPos,
};

$$("button[data-run]").forEach((button) => {
  button.addEventListener("click", () => {
    const action = ACTIONS[button.dataset.run];
    if (action) action();
  });
});

const PRESETS = {
  "range-bad": {
    fields: [
      ["#lo", "z"],
      ["#hi", "a"],
    ],
    action: "range",
  },
  "commit-ab": {
    fields: [["#in-commit", "ab"]],
    action: "commit",
  },
};

$$("button[data-preset]").forEach((button) => {
  button.addEventListener("click", () => {
    const preset = PRESETS[button.dataset.preset];
    if (!preset) return;
    preset.fields.forEach(([selector, value]) => {
      const node = $(selector);
      if (node) node.value = value;
    });
    const run = ACTIONS[preset.action];
    if (run) run();
  });
});

const ENTER_ACTIONS = [
  ["#in-char", "char"],
  ["#arg-char", "char"],
  ["#in-str", "string"],
  ["#arg-str", "string"],
  ["#in-range", "range"],
  ["#in-ident", "ident"],
  ["#in-int", "int"],
  ["#in-csv", "csv"],
  ["#in-modes", "modes"],
  ["#arg-modes", "modes"],
  ["#in-err", "error"],
  ["#arg-err", "error"],
  ["#in-commit", "commit"],
];

ENTER_ACTIONS.forEach(([selector, action]) => {
  const field = $(selector);
  if (!field) return;
  field.addEventListener("keydown", (event) => {
    if (event.key !== "Enter") return;
    event.preventDefault();
    const button = $(`button[data-run="${action}"]`);
    if (button) button.click();
  });
});

/* ---------- 复制 ---------- */

async function copyText(text) {
  if (navigator.clipboard && window.isSecureContext) {
    await navigator.clipboard.writeText(text);
    return;
  }
  const area = document.createElement("textarea");
  area.value = text;
  area.setAttribute("readonly", "");
  area.style.position = "fixed";
  area.style.opacity = "0";
  document.body.appendChild(area);
  area.select();
  document.execCommand("copy");
  document.body.removeChild(area);
}

$$("[data-copy-target]").forEach((button) => {
  button.addEventListener("click", async () => {
    const target = document.getElementById(button.dataset.copyTarget);
    if (!target) return;
    const original = button.textContent;
    try {
      await copyText(target.textContent.trim());
      button.textContent = "已复制";
    } catch {
      button.textContent = "复制失败";
    }
    setTimeout(() => {
      button.textContent = original;
    }, 1400);
  });
});

/* ---------- 导航高亮 ---------- */

const navLinks = $$(".nav a");
const sections = navLinks
  .map((link) => document.querySelector(link.getAttribute("href")))
  .filter(Boolean);

if ("IntersectionObserver" in window && sections.length > 0) {
  const observer = new IntersectionObserver(
    (entries) => {
      entries.forEach((entry) => {
        if (!entry.isIntersecting) return;
        navLinks.forEach((link) => {
          link.classList.toggle(
            "active",
            link.getAttribute("href") === `#${entry.target.id}`,
          );
        });
      });
    },
    { rootMargin: "-45% 0px -50% 0px", threshold: 0 },
  );
  sections.forEach((section) => observer.observe(section));
}

/* ---------- 初始化 ---------- */

// 版本导出用于契约验证（与 moon.mod 同步；页面徽章为静态文本）。
astrolabe_version();
runHero();
runChar();
runString();
runRange();
runIdent();
runInt();
runCsv();
runModes();
runError();
runCommit();
runPos();