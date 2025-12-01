[Custom Server Details]: https://github.com/InsultingPros/CustomServerDetails

# CustomServerDetails Extension

[![GitHub all releases](https://img.shields.io/github/downloads/InsultingPros/CustomServerDetailsExtension/total)](https://github.com/InsultingPros/CustomServerDetailsExtension/releases)

This is a template-example repo to show how to add your own server details, without recompiling [Custom Server Details].

## Installation

0. Make sure you have installed [Custom Server Details] 1.4.0 or higher. Open your [CustomServerDetails.ini](https://github.com/InsultingPros/CustomServerDetails/blob/main/Configs/CustomServerDetails.ini)'s `[CustomServerDetails.CSDMasterServerUplink]` section:

1. Add your *packageName.className*:

    ```ini
    extendedServerDetailsClassName=CustomServerDetailsExtension.CustomServerDetailsExtension
    ```

2. Add your new variable to `infoBlockKeys`:

    ```ini
    infoBlockKeys=(detail="Difficulty",key="DIFF")
    ```

3. Finally edit the server state (`infoBlockPatterns`) where you want to see your new variable:

    ```ini
    infoBlockPatterns=(state="LOBBY",pattern="^w^[Current state: ^g^LOBBY^w^], Difficulty: %DIFF%")
    ```

## Building

Use [KF Compile Tool](https://github.com/InsultingPros/KFCompileTool) for easy compilation.

```ini
EditPackages=CustomServerDetails
EditPackages=CustomServerDetailsExtension
```
