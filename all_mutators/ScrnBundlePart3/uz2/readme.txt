This uz2 directory must be placed inside KillingFloor directory.
KF SDK needs to be installed (there must be ..\system\ucc.exe).

make_INPUT_uz2.cmd compresses files from "INPUT" directory.
Only Unreal packages are processed.

make_ScrnBundle_uz2 compresses all assets from ScrN Brutal KF Bundle.
The Bundle needs to be already installed.
https://steamcommunity.com/groups/ScrNBalance/discussions/2/483368526570475472/

uz2.cmd compresses a file passed as argument. For example:
uz2.cmd ..\System\ScrnWeaponPack.u

All produced uz2 files are placed into "OUTPUT" directory
