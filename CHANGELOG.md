# Changelog

## 1.0.6 - 2026-02-18

- Removed unnecessary navbar menu cross-axis alignment to keep the theme toggle vertically aligned with adjacent controls.
- Updated Tocbot sidebar styling to a Tocbot-native single-rail hierarchy (with al-folio colors) and removed custom per-link ridge markers.

## 1.0.5 - 2026-02-18

- Restored right-aligned desktop navbar menu layout with explicit core-owned alignment classes.
- Matched inline code typography more closely to legacy sizing/weight while preserving code-block styling.
- Normalized related-post recommendation links to regular font weight.
- Fixed Tocbot sidebar visual clashes by removing competing custom rails and scoping active/hover indicators cleanly.

## 1.0.4 - 2026-02-17

- Fixed related-posts HTML structure to render valid list markup.
- Restored sidebar TOC behavior and styling via Tocbot runtime integration.
- Added Tailwind-first vanilla table engine for `pretty_table` pages when Bootstrap compatibility is disabled.
- Replaced remaining jQuery-dependent runtime scripts (masonry, jupyter link handling) with vanilla JS.
- Improved project hover lift, teaching calendar toggle UX, and schedule/table styling parity.

## 1.0.3 - 2026-02-17

- Restricted gem packaging to tracked runtime files to prevent accidental inclusion of local/untracked artifacts.

## 1.0.2 - 2026-02-17

- Extracted icon runtime ownership from core into plugin include wrappers.
- Removed duplicated search runtime payload ownership from core (`assets/js/search/**`).
- Switched back-to-top runtime to pinned CDN contract and fixed script load ordering.
- Replaced opaque `tabs.min.js` with provenance-tracked `tabs.js`.

## 1.0.1 - 2026-02-16

- Fixed cache-bust asset lookup to resolve plugin assets from both Bundler git paths (`bundler/gems/*`) and RubyGems install paths (`gems/*`).
- Added runtime guard coverage for RubyGems-installed plugin asset resolution.

## 1.1.0 - 2026-02-10

- Delegated CV and Distill rendering to `al_folio_cv` and `al_folio_distill`.
- Removed CV/Distill templates and distill runtime assets from core ownership.
- Merged `al_utils` tags/filters into core (`details`, `file_exists`, `hideCustomBibtex`, `remove_accents`).

## 1.0.0 - 2026-02-08

- Initial release.
- Added v1 API contract checks and legacy content migration warnings.
