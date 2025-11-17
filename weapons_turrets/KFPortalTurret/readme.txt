Portal Turret - небольшая турель из игры Portal, используется в качестве защитного оружия, возможна установка в любое место карты.

Установка безобидной турели:
Custom Shop Mutator:
KFPortalTurret.PTurretPickup
KillingFloor.ini, ServerPackages:
ServerPackage = KFPortalTurret

Для установки злой турели (которая будет атаковать и игроков и мутантов):
Использовать триггер> TurretSpawnPoint, и настроить там все параметры.
Конфигурации находятся в файле KFPortalTurret.ini:
HitDamages = 5 - урон от турели
TurretHealth = 400 - Общее количество жизни турели
bStationaryTurret = False - Включает/выключает возможность мутантам или людям ранить турель