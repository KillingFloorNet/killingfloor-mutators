/*
В этом мутаторе я вытаскиваю значения стим кача
Так вот если вытащить значение SteamNameStat="Stat46" (в комментариях пишут, что это используется для определения ивента)
То получим для стима значение 2, а для пиратки значение 0 (так как такая переменная никак в Stats.bin не сохраняется)

Чуть позже добавлю в указанный выше мутатор эту проверку, чтобы можно было только стимовцам кач конвертировать в SP

Так же можно было бы использовать значения каких-нибудь ачивок. Наверняка есть ачивки, которые выполнены у всех более менее прокачавшихся (убейте 1000 мутантов, например)
*/

simulated function Tick(float dt)
{
    local PlayerController PC;
    local SteamStatsAndAchievementsBase.SteamStatInt TmpStat;
    PC=Level.GetLocalPlayerController();
    if(PC==none)
        return;
    MySteamStatsAndAchievements.GetStatInt(TmpStat,"Stat46");
    Log("SteamVars.0"@TmpStat.Value);
}
