# Killing Floor Mutators Archive

© 2024, [Geekrainian](https://github.com/geekrainian/?utm_source=gitlab&utm_medium=killingfloor&utm_campaign=mutators-archive)

A large collection of Killing Floor (Unreal 2.x) mutators from the internet.

- `/all_mutators`: Mutators with source code
- `/all_mutators_protected`: Mutators (protected)
- `/cached_files`: Random resources from the client cache (2023)
- `/killingfloorsource`: Original Killing Floor Mod source code
- `/udk2004_3369`: UDK 2004 Scripts (3369)
- `/skins`: Player skin mutators
- `/specimens`: Monster mutators
- `/weapons_misc`: Weapon mutators
- `/weapons_turrets`: Turret mutators
- `/mods`: Large or gameplay-changing mutators
- `/sql_unreal`: Examples of Unreal SQL bridge

## VS Code/Cursor IDE Extensions

Choose one of:

- [UCX VsCode Extension - UT99](https://open-vsx.org/extension/peterekepeter/ucx)
  - Code formatting is available. Note that it may not fix all indentation issues.
- [UnrealScript by EliotVU](https://open-vsx.org/extension/EliotVU/uc)
  - Switch to version 0.8.3 (this works well with the Cursor 1.7.28).
  - No code formatting available.

## Experimental

### clang-format

1. Install clang-format globally:

```
npm install -g clang-format
```

2. Open target `.uc` file in editor.

3. Open `Terminal` -> `Run Task` -> `Format UnrealScript File`

### Custom Formatting for UCX VsCode Extension

1. Clone the [UCX repository](https://github.com/peterekepeter/ucx)
2. Modify the formatter source code to remove spaces before parentheses in control statements
3. Build and install the modified extension locally
4. This gives you full control but requires maintenance on updates
