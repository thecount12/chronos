---
title: "Chronos App: Architecture & Product Roadmap"
date: 2026-11-24
tags:
  - chronos
  - swiftui
  - architecture
  - obsidian
  - productivity
---

# Chronos: Multiplatform Time Architecture & Productivity Plan

**Core Thesis:** *"Everybody that wants to become more efficient begins with a checklist. It's also where efficiency ends. To become efficient, you must keep the wheel moving."* — *How to Beat the Clock* (2020)

Chronos replaces rigid, base-60 task lists with a **concentric visual time instrument** across **Apple Watch, iPhone, and Mac** (prototyped in **Lux / Plan 9**), uniting **Metric Time**, **Cyclical Sprint Arcs**, **Pythagorean Planetary Rulers**, and **zero-lock-in Obsidian Markdown**.

---

## 1. Core System Pillars

### A. Dual Time Overlay (Standard + Metric LMT)
* **Standard Time (`HH:mm:ss`):** Keeps you synced with external appointments and social schedules.
* **Metric Time (`00.00 – 99.99 LMT`):** Divides the 86,400-second day into **100 centidays** (`1 centiday = 14m 24s`, `1 deciday = 2h 24m`), acting as a **0%–100% daily fuel gauge**.

### B. Concentric Cyclical Rings (Outer → Inner)
1. **Outer Ring (Cyan):** **Metric Day (`00–99 LMT`)** with 10 radial deciday markers (`00`–`90`).
2. **Second Ring (Day Planet Color):** **20-Day Sprint (`Day 1–20`)** / **10-Day Dekade (`Day 1–10`)** for short-term execution momentum.
3. **Third Ring (Hour Planet Color):** **100-Day Arc (`Day 1–100`)** for macro seasonal projects and skill-building.
4. **Inner Ring (Solar Gold):** **365-Day Solar Arc (`Day 1–365`)** anchored by default to the user's **Birthday (Solar Return)**, with 1-tap presets for **Jan 1 (Calendar Year)** or **Today (Custom Sprint)**.

### C. Pythagorean Planetary Telemetry
* **Day Ruler & Chaldean Planetary Hour:** Maps each day and sunrise-anchored hour to its **Pythagorean Root (`1, 2, 3, 5, 6, 8, 9`)**, **Planet**, **Archangel**, and **Olympic Spirit**, dynamically tinting the wheel's rings.

### D. Zero-Lock-In Obsidian / Markdown Integration
* No proprietary database for notes.
* **One-Click YAML Frontmatter Copy & Direct `.md` Vault Stamper:** Exports current metric time, sprint/arc counts, and planetary rulers straight into daily Markdown files (`YYYY-MM-DD.md`).

---

## 2. Multiplatform Target Architecture (`thecount12/chronos`)

| Surface | Target | Status & Role |
| :--- | :--- | :--- |
| **Prototypes (`*.lux`)** | Lux VM (9front & POSIX) | **Done:** CLI telemetry (`chronos_state.lux`), anchor calculator (`anchor_calc.lux`), and local SVG web wheel (`lux_chronos_wheel.lux`). |
| **Shared Engine (`ChronosEngine.swift`)** | All Apple Targets | **Done:** Single source of truth for Metric LMT, Solar Return anchor math, cyclical arcs, planetary matrix, and YAML formatting. |
| **Apple Watch App (`ChronosWatch Watch App`)** | `watchOS` | **Done (v1):** 2-page OLED wheel with 10 deciday markers, Digital Crown time-scrubber (`±50 cd`), tap-to-reset, and Page 2 telemetry + Birthday anchor steppers. |
| **Watch Face Complication (`ChronosComplication`)** | `WidgetKit` (`watchOS`) | **Done (v1):** Circular, Corner, and Rectangular complications updating every `1.0 centiday` (`14.4 mins`). |
| **macOS App & Menu Bar (`Chronos`)** | `macOS` | **Done (v1):** Live `MenuBarExtra` readout (`02.45 LMT • ♂`), full concentric wheel window, and direct Obsidian folder `.md` file stamper. |
| **iOS / iPadOS App (`Chronos`)** | `iOS` | **Done (v1):** Full concentric wheel, anchor `DatePicker` + presets (`Birthday`, `Jan 1`, `Today`), and clipboard YAML export. |

---

## 3. Next Milestone Roadmap (Post-v1 Prototype)

1. **App Group Sync (`group.com.wg.local.chronos`):**
   * Share `birthMonth`, `birthDay`, and custom `anchorTimestamp` automatically between iPhone, Apple Watch, and Watch Face Complications (`WidgetCenter.shared.reloadAllTimelines()`).
2. **Interactive Deciday Time-Segmenting (From *How to Beat the Clock*):**
   * Tap any of the **10 deciday segments (`00`–`90`)** on iPhone/Mac to assign a single focus intention for that `2.4-hour` block and append it directly to today's Obsidian note.
3. **Quick Voice / Scribble Capture on Apple Watch:**
   * Add a quick-log button on Page 2 of `ChronosWatch` to dictate a timestamped Markdown bullet (`- **02.45 LMT (00:35)** [♂ 9 / ♄ 8]: ...`) straight into iCloud Drive for Obsidian.
4. **Companion Book (Edition 2.0):**
   * Map each chapter directly to one ring of the Chronos Wheel once the daily personal workflow is battle-tested.


