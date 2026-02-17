# Changelog

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
