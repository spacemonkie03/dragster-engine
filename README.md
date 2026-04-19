# Dragster engine

Dragster engine is an open-source ETS2 engine-power mod that adds a custom drag-style engine option to supported stock SCS trucks.

## What it includes

- One custom engine accessory named `Dragster engine` for each supported truck family
- Stock ETS2 sound setup for each truck family
- No tire, transmission, or FMOD sound-bank overrides

## Supported truck families

- `daf.xf`
- `daf.xf_euro6`
- `iveco.hiway`
- `iveco.stralis`
- `man.tgx`
- `man.tgx_euro6`
- `mercedes.actros`
- `mercedes.actros2014`
- `renault.magnum`
- `renault.premium`
- `renault.t`
- `scania.r`
- `scania.r_2016`
- `scania.s_2016`
- `scania.streamline`
- `volvo.fh16`
- `volvo.fh16_2012`
- `volvo.fh_2024`

## Build

Build the `.scs` package from the repo contents:

```powershell
powershell -ExecutionPolicy Bypass -File .\validate_mod.ps1
powershell -ExecutionPolicy Bypass -File .\build_mod.ps1
```

The output package is written to `dist\dragster_engine.scs`.

If you want to regenerate the truck definitions from extracted game files, run:

```powershell
powershell -ExecutionPolicy Bypass -File .\generate_all_truck_defs.ps1 -SourceTruckRoots 'C:\path\to\extract1','C:\path\to\extract2'
```

Then rebuild:

```powershell
powershell -ExecutionPolicy Bypass -File .\build_mod.ps1 -RefreshDefinitions
```

## Install

1. Put `dragster_engine.scs` into `C:\Users\<you>\Documents\Euro Truck Simulator 2\mod`
2. Enable `Dragster engine` in the ETS2 Mod Manager
3. Visit service or a dealer upgrade shop and select `Dragster engine`

## CI

GitHub Actions builds the package on:

- every pull request targeting `main`
- every push to `main`

Each workflow run validates the mod files, builds the `.scs`, and uploads the package as an artifact.

## Open source

This project is released under the MIT License. See [LICENSE](LICENSE).

## Community post drafts

Ready-to-post drafts live in:

- [posts/reddit.md](posts/reddit.md)
- [posts/scs_forum.md](posts/scs_forum.md)
