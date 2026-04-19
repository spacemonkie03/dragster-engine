# Contributing

Pull requests are welcome.

## Before opening a PR

1. Run `powershell -ExecutionPolicy Bypass -File .\validate_mod.ps1`
2. Run `powershell -ExecutionPolicy Bypass -File .\build_mod.ps1 -SkipInstallCopy`
3. If you changed generated truck definitions, explain where the source defs came from

## Scope

- Keep the mod engine-only unless the change is clearly documented
- Prefer stock sound references for each truck family
- Do not add paid or closed-source dependencies
