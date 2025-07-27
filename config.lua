Config = {}

Config.Locale = 'pl'

-- Przedmioty
Config.ToolItem = "pila_do_metalu"
Config.RewardItem = "katalizator"

-- Ryzyko i Czas
Config.PoliceAlertChance = 25
Config.Cooldown = 60 -- czas w sekundach po probie kradziezy (sukcesie lub porazce)

-- Paser (Fence)
Config.Fence = {
    coords = vector3(484.5, -1308.2, 29.2),
    ped = "s_m_y_dealer_01",
    price = { min = 250, max = 500 }
}

-- NOWA SEKCJA MINIGRY
Config.Minigame = {
    enabled = true,
    requiredHits = 5, -- ile razy trzeba trafic
    duration = 15000, -- calkowity czas na wykonanie minigry (w milisekundach)
    successZoneWidth = 12, -- szerokosc strefy sukcesu w %
    markerSpeed = 1.5 -- predkosc znacznika (im nizsza wartosc, tym szybciej)
}