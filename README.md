# Al-Folio Core

Core runtime/theme gem for al-folio v1.x.

## Responsibilities

- Validate v1 config contract (`al_folio.api_version`, Tailwind and Distill runtime keys)
- Emit migration warnings for legacy Bootstrap-marked content when compat mode is off
- Guard Distill runtime policy (`al_folio.distill.allow_remote_loader`)
- Ship migration manifests consumed by `al_folio_upgrade`

## Migration manifests

Version manifests live under `migrations/` and are packaged with the gem.

## Theme usage

Use the gem as a Jekyll theme in starter sites:

```yaml
theme: al_folio_core
plugins:
  - al_folio_core
```
