# Al-Folio Core

Core runtime/theme gem for al-folio v1.x.

## Responsibilities

- Validate v1 config contract (`al_folio.api_version`, Tailwind and Distill runtime keys)
- Emit migration warnings for legacy Bootstrap-marked content when compat mode is off
- Provide shared theme layout/includes/runtime for starter sites
- Delegate CV and Distill rendering to `al_folio_cv` and `al_folio_distill`
- Delegate cookie consent runtime to `al_cookie`
- Delegate icon runtime to `al_icons`
- Delegate search runtime payload to `al_search`
- Provide built-in utility tags/filters (`details`, `file_exists`, `hideCustomBibtex`, `remove_accents`)
- Ship migration manifests consumed by `al_folio_upgrade`
- Exclude legacy Bootstrap/MDB and plugin-owned duplicate runtime assets

## Migration manifests

Version manifests live under `migrations/` and are packaged with the gem.

## Theme usage

Use the gem as a Jekyll theme in starter sites:

```yaml
theme: al_folio_core
plugins:
  - al_folio_core
```
