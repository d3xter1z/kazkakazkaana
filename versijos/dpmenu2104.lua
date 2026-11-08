script_name("DPKT meniu")
script_author("Dex")
script_version("2.10.4")

require "lib.moonloader"
local sampev = require "lib.samp.events"
local imgui  = require "mimgui"
local ffi    = require "ffi"
local new    = imgui.new

---------------------------------------------------------------- SULIETUVINIMAS
function ltu(text)
    local encoding = require 'encoding'
    encoding.default = 'cp1257'
    local u8 = encoding.UTF8
    local ltu = {
        "\xc4\x85", -- ą
        "\xc4\x8d", "\xc4\x99", "\xc4\x97", "\xc4\xaf", "\xc5\xa1", "\xc5\xb3",
        "\xc5\xab", "\xc5\xbe", "\xc4\x84", "\xc4\x8c", "\xc4\x98", "\xc4\x96",
        "\xc4\xae", "\xc5\xa0", "\xc5\xb2", "\xc5\xaa", "\xc5\xbd"
    }
    -- ąčęėįšųūž ĄČĘĖĮŠŲŪŽ
    if string.find(text, "ą") then text = string.gsub(text, "ą", ltu[1]) end
    if string.find(text, "č") then text = string.gsub(text, "č", ltu[2]) end
    if string.find(text, "ę") then text = string.gsub(text, "ę", ltu[3]) end
    if string.find(text, "ė") then text = string.gsub(text, "ė", ltu[4]) end
    if string.find(text, "į") then text = string.gsub(text, "į", ltu[5]) end
    if string.find(text, "š") then text = string.gsub(text, "š", ltu[6]) end
    if string.find(text, "ų") then text = string.gsub(text, "ų", ltu[7]) end
    if string.find(text, "ū") then text = string.gsub(text, "ū", ltu[8]) end
    if string.find(text, "ž") then text = string.gsub(text, "ž", ltu[9]) end
    if string.find(text, "Ą") then text = string.gsub(text, "Ą", ltu[10]) end
    if string.find(text, "Č") then text = string.gsub(text, "Č", ltu[11]) end
    if string.find(text, "Ę") then text = string.gsub(text, "Ę", ltu[12]) end
    if string.find(text, "Ė") then text = string.gsub(text, "Ė", ltu[13]) end
    if string.find(text, "Į") then text = string.gsub(text, "Į", ltu[14]) end
    if string.find(text, "Š") then text = string.gsub(text, "Š", ltu[15]) end
    if string.find(text, "Ų") then text = string.gsub(text, "Ų", ltu[16]) end
    if string.find(text, "Ū") then text = string.gsub(text, "Ū", ltu[17]) end
    if string.find(text, "Ž") then text = string.gsub(text, "Ž", ltu[18]) end
    text = u8:decode(text)
    return text
end

-- cp1257 (žaidimo / serverio tekstas) -> UTF-8 (imgui ir failai): u8(tekstas)
local koduote = require 'encoding'
koduote.default = 'cp1257'
local u8 = koduote.UTF8

---------------------------------------------------------------- NUSTATYMAI
-- Ką rašyti į /blist pirmu argumentu pagal pasirinkimą.
local BLIST_TIPAI = {
    { pavadinimas = "M/G blist",          argumentas = "1" },
    { pavadinimas = "Teisėsaugos blist",  argumentas = "2" },
    { pavadinimas = "Direktorių blist",   argumentas = "3" },
    { pavadinimas = "Visų darbų blist",   argumentas = "4" },
}

-- Direktorių ID (/skirtidir): darbų patikrai ir analizei.
local DIREKTORIU_DARBAI = {
    { pavadinimas = "Policijos",                 id = 1 },
    { pavadinimas = "Ligoninės",                 id = 2 },
    { pavadinimas = "FTB",                       id = 5 },
    { pavadinimas = "Cosa Nostra",               id = 6 },
    { pavadinimas = "Prekeivių",                 id = 8 },
    { pavadinimas = "Immortal",                  id = 12 },
    { pavadinimas = "Mechanikų",                 id = 13 },
    { pavadinimas = "Interpolo",                 id = 14 },
    { pavadinimas = "Apsaugos",                  id = 15 },
    { pavadinimas = "Armijos",                   id = 16 },
    { pavadinimas = "Narkotikų prekeivių",       id = 17 },
    { pavadinimas = "Taksi",                     id = 18 },
    { pavadinimas = "Radijo",                    id = 19 },
    { pavadinimas = "Grove Street",              id = 21 },
    { pavadinimas = "The Ballas",                id = 22 },
    { pavadinimas = "Reporterių",                id = 23 },
    { pavadinimas = "Tolimųjų reisų vairuotojų", id = 24 },
}

-- Darbų ID skirtukui "Pakeisti darbą".
local KEICIAMI_DARBAI = {
    { pavadinimas = "Policininkų",               id = 1 },
    { pavadinimas = "Medikų",                    id = 2 },
    { pavadinimas = "Cosa Nostra mafijos",       id = 6 },
    { pavadinimas = "Tolimųjų reisų vairuotojų", id = 7 },
    { pavadinimas = "FTB",                       id = 9 },
    { pavadinimas = "Mechanikų",                 id = 12 },
    { pavadinimas = "Ginklų prekeivių",          id = 15 },
    { pavadinimas = "Reporterių",                id = 16 },
    { pavadinimas = "Taksi",                     id = 21 },
    { pavadinimas = "Immortal mafijos",          id = 26 },
    { pavadinimas = "Interpolo",                 id = 27 },
    { pavadinimas = "Apsaugos",                  id = 28 },
    { pavadinimas = "Armijos",                   id = 29 },
    { pavadinimas = "Radijos",                   id = 32 },
    { pavadinimas = "SPD",                       id = 33 },
    { pavadinimas = "„Grove Street“ gaujos",     id = 34 },
    { pavadinimas = "„The Ballas“ gaujos",       id = 35 },
}

-- /direkt darbo pavadinimas -> direktoriaus ID (/skirtidir). Raktai be lietuviškų raidžių.
local DIREKT_DARBAI = {
    { raktas = "Polic",    id = 1 },
    { raktas = "Medik",    id = 2 },
    { raktas = "FTB",      id = 5 },
    { raktas = "Cosa",     id = 6 },
    { raktas = "Narkot",   id = 17 }, -- prieš "Prekei", kad nesumaišytų
    { raktas = "Prekei",   id = 8 },
    { raktas = "Immortal", id = 12 },
    { raktas = "Mechan",   id = 13 },
    { raktas = "Interpol", id = 14 },
    { raktas = "Apsaug",   id = 15 },
    { raktas = "Karei",    id = 16 },
    { raktas = "Taks",     id = 18 },
    { raktas = "Radij",    id = 19 },
    { raktas = "Grove",    id = 21 },
    { raktas = "Ballas",   id = 22 },
    { raktas = "Report",   id = 23 },
    { raktas = "Tolim",    id = 24 },
}

-- Komandos. %d / %s pakeičiami ID arba nicku.
-- (vienoje lentelėje: Lua leidžia ne daugiau kaip 200 lokalių kintamųjų)
local KOMANDOS = {
    darboKeitimas        = "/noriudarbo %d",
    direktorius          = "/skirtidir %s %d",    -- nickas, darbo ID (0 = nuimti)
    direktoriusOffline   = "/skirtidiroff %s %d", -- neprisijungusiam: nickas, 0 = nuimti
    pavaduotojoAtemimas  = "/skirtipav %s",       -- pavaduotojo nickas (reikia to darbo direktoriaus)
    info                 = "/info %s %s",         -- nickas, data
    arsutapo             = "/arsutapo %s %s",     -- paskyra 1, paskyra 2
    visidarbuotojaiData  = "/visidarbuotojai %s", -- konkrečiai dienai (data MMMM-MM-DD)
    ispejimai            = "/ispejimai %s",       -- žaidėjo įspėjimų istorija (reikia to darbo direktoriaus)
}

-- Paskyrų sutapimas: per kiek minučių prisijungimas prie kitos paskyros laikomas persijungimu.
local PERSIJUNGIMO_MIN = 15

-- true: /skirtidir <tavo nickas> ..., false: /skirtidir <tavo ID> ...
local NAUDOTI_NICKA = true

-- Pauzė tarp komandų (ms), kad neišmestų už flood.
local PAUZE = 750

local MIN_MENESIU, MAX_MENESIU = 1, 60

-- Kiek laukti serverio atsakymo (sekundėmis).
local LAUKTI_PO_EILUTES = 1.0  -- /visidarbuotojai: kiek laukti po paskutinės eilutės
local LAUKTI_ILGIAUSIAI = 2.0  -- ilgiausiai vienai komandai

local DATOS_FORMATAS = "%Y-%m-%d"   -- 2026-10-29
local MAX_DIENU      = 366          -- daugiausia dienų vienam aktyvumo patikrinimui

local DUOMENU_APLANKAS = getWorkingDirectory() .. "\\config\\dpkt"
-- duomenų failai (vienoje lentelėje: Lua leidžia ne daugiau kaip 200 lokalių kintamųjų)
local FAILAI = {
    darbuotojai = DUOMENU_APLANKAS .. "\\darbuotojai.json",
    fondai      = DUOMENU_APLANKAS .. "\\fondai.json",
    aktyvumas   = DUOMENU_APLANKAS .. "\\aktyvumas.json",
    nustatymai  = DUOMENU_APLANKAS .. "\\nustatymai.json",
    zurnalas    = DUOMENU_APLANKAS .. "\\debug_visidarbuotojai.txt",
    ispejimai   = DUOMENU_APLANKAS .. "\\debug_ispejimai.txt",
}

---------------------------------------------------------------- VARTOTOJO NUSTATYMAI
-- Keičiami lange "Nustatymai", saugomi config\dpkt\nustatymai.json
local NUMATYTI_NUSTATYMAI = {
    dev = false,                 -- Dev režimas: atsitiktiniai duomenys, kol nėra tikrų
    sriftas = 17,                -- šrifto dydis (taikoma perkrovus scriptą)
    langoAlfa = 1.0,             -- lango nepermatomumas (1 = visiškai nepermatomas)
    vaivorykste = false,         -- vaivorykštinė pavadinimo juosta (išjungus - juoda)
    animacija = true,            -- ar vaivorykštė juda
    vaivorykstesGreitis = 0.08,  -- kaip greitai juda
    pauze = 750,                 -- ms tarp komandų
    laukti = 2,                  -- s, kiek laukti serverio atsakymo
    persijungimoMin = 15,        -- min, persijungimo tarp paskyrų riba
    perimtiDirekt = false,       -- /direkt rodyti DPKT meniu lange (išjungus - serverio lentelė)
    perimtiArsutapo = true,      -- /arsutapo rodyti DPKT meniu lange
    perimtiNoriudarbo = false,   -- /noriudarbo be ID atidaro "Pakeisti darbą" (išjungus - serverio komanda)
    slepti = true,               -- slėpti chate eilutes, kurias renka scriptas
    chate = false,               -- pranešimus rodyti ir chate (ne tik skiltyje "Patikros statusas")
    pasveikinimas = true,        -- "DPKT meniu įkeltas" žinutė
    zurnalas = true,             -- /visidarbuotojai rinkimo output į failą (derinimui)
}
local nust = {}
local nustatymaiPakeisti = false

local function pritaikytiNustatymus()
    PAUZE = nust.pauze
    LAUKTI_ILGIAUSIAI = nust.laukti
    PERSIJUNGIMO_MIN = nust.persijungimoMin
end

local function ikeltiNustatymus()
    for k, v in pairs(NUMATYTI_NUSTATYMAI) do nust[k] = v end
    local f = io.open(FAILAI.nustatymai, "r")
    if f then
        local pavyko, d = pcall(decodeJson, f:read("*a"))
        f:close()
        if pavyko and type(d) == "table" then
            for k, v in pairs(d) do
                if NUMATYTI_NUSTATYMAI[k] ~= nil and type(v) == type(NUMATYTI_NUSTATYMAI[k]) then nust[k] = v end
            end
        end
    end
    pritaikytiNustatymus()
end

local function issaugotiNustatymus()
    local config = getWorkingDirectory() .. "\\config"
    if not doesDirectoryExist(config) then createDirectory(config) end
    if not doesDirectoryExist(DUOMENU_APLANKAS) then createDirectory(DUOMENU_APLANKAS) end
    local f = io.open(FAILAI.nustatymai, "w")
    if f then f:write(encodeJson(nust)) f:close() end
end

ikeltiNustatymus()

---------------------------------------------------------------- PAGALBINĖS
local ZALIA   = 0x33AA33
local RAUDONA = 0xFF0000

-- ltu(), bet niekada negrąžina nil
local function saugusLtu(tekstas)
    tekstas = tostring(tekstas or "")
    local pavyko, rezultatas = pcall(ltu, tekstas)
    if pavyko and type(rezultatas) == "string" then return rezultatas end
    return (tekstas:gsub("[\x80-\xFF]+", "?"))
end

-- Visi scripto pranešimai rodomi DPKT meniu skiltyje "Patikros statusas", ne chate
-- (chate lieka tik žinutė įkėlus scriptą; nustatymuose galima įjungti dubliavimą į chatą).
local MAX_STATUSO_IRASU = 300
local statusas = {
    irasai = {},      -- { laikas = "12:34:56", tekstas = "...", tipas = "info" | "klaida" | "ispejimas" | "antraste" }
    patikra = nil,    -- { pavadinimas, pradzia = "12:34:56", t0, busena = "vyksta" | "baigta" | "nutraukta", trukme }
    naujas = nil,     -- paskutinis pranešimas apatinei juostai { tekstas, tipas, t }
    slinkti = false,  -- naujas įrašas: nuslinkti sąrašą į apačią
    perjungti = false -- prasidėjo patikra: atidaryti skiltį "Patikros statusas"
}

local function statusoIrasas(tekstas, tipas)
    tipas = tipas or "info"
    -- tipas "serveris": serverio atsakymas scripto komandai (paslėptas chate), rodomas tik čia
    local e = { laikas = os.date("%H:%M:%S"), tekstas = tostring(tekstas or ""), tipas = tipas }
    statusas.irasai[#statusas.irasai + 1] = e
    if #statusas.irasai > MAX_STATUSO_IRASU then table.remove(statusas.irasai, 1) end
    statusas.slinkti = true
    if tipas ~= "antraste" and tipas ~= "serveris" then
        statusas.naujas = { tekstas = e.tekstas, tipas = tipas, t = localClock() }
        if nust.chate then
            sampAddChatMessage(saugusLtu("* DPKT meniu - " .. e.tekstas), tipas == "ispejimas" and RAUDONA or ZALIA)
        end
    end
end

local function pranesimas(tekstas) statusoIrasas(tekstas, "info") end
local function klaida(tekstas) statusoIrasas(tekstas, "klaida") end
local function perspejimas()
    statusoIrasas("Rekomenduojama nedaryti jokių veiksmų (teleportų ar pnš.) kol vyksta patikra.", "ispejimas")
end

-- Derinimo žurnalas: kol renkami visų darbų /visidarbuotojai, čia kaupiamas visas
-- serverio output (chatas ir langai) ir scripto komandos. Išsaugoma į failą.
local zurnalas = nil

-- laikas nuo rinkimo pradžios, sekundėmis (tikslumas iki ms)
local function zurnaloLaikas()
    return string.format("+%8.3f s", localClock() - (zurnalas.t0 or 0))
end

-- tekstas: cp1257 iš serverio arba UTF-8 iš scripto (utf8 = true)
local function zurnaloIrasas(tekstas, utf8)
    if not zurnalas then return end
    if not utf8 then
        local pavyko, r = pcall(u8, tostring(tekstas or ""))
        tekstas = pavyko and r or tostring(tekstas)
    end
    zurnalas.eilutes[#zurnalas.eilutes + 1] = "[" .. zurnaloLaikas() .. "] " .. tekstas
end

local function issaugotiZurnala(busenaTekstu)
    if not zurnalas then return end
    local z = zurnalas
    zurnalas = nil
    local config = getWorkingDirectory() .. "\\config"
    if not doesDirectoryExist(config) then createDirectory(config) end
    if not doesDirectoryExist(DUOMENU_APLANKAS) then createDirectory(DUOMENU_APLANKAS) end
    local f = io.open(FAILAI.zurnalas, "w")
    if not f then return end
    f:write("DPKT meniu v" .. tostring(thisScript().version) .. " - /visidarbuotojai derinimo žurnalas\n")
    f:write("Pradėta: " .. z.pradzia .. ", baigta: " .. os.date("%Y-%m-%d %H:%M:%S") .. ", būsena: " .. busenaTekstu .. "\n")
    f:write("Nickas: " .. tostring(z.nickas) .. ", data: " .. tostring(z.data or "-") .. "\n")
    f:write("Formatas: [+sekundės nuo pradžios] > komanda | CHAT [žymė] 0xSPALVA | tekstas | DIALOG ...\n")
    f:write("Žymės: [ATPAŽINTA] eilutė suskaidyta į laukus, [NUKIRPTA] chato eilutė nukirpta, galas imamas iš lango\n")
    f:write(string.rep("=", 70) .. "\n")
    for _, e in ipairs(z.eilutes) do f:write(e, "\n") end
    f:close()
    pranesimas("Derinimo žurnalas: moonloader\\config\\dpkt\\debug_visidarbuotojai.txt")
end

-- Paskutinė scripto išsiųsta komanda: jei serveris atsako "Tokios komandos nėra",
-- žinom, kuriai komandai trūksta prieigos.
local prieiga = { klaida = nil, komanda = nil, laikas = 0 }

-- UTF-8 tekstas -> serveriui (cp1257)
local function siusti(komanda)
    zurnaloIrasas("> " .. komanda, true)
    prieiga.komanda, prieiga.laikas = komanda, localClock()
    sampSendChat(saugusLtu(komanda))
end

local function manoNickas()
    local pavyko, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
    if not pavyko then return nil end
    if NAUDOTI_NICKA then return sampGetPlayerNickname(id) end
    return tostring(id)
end

-- ar žaidėjas su tokiu nicku dabar prisijungęs (tikrinama gyvai, ne pagal /direkt spalvas)
local function arPrisijunges(nickas)
    local mazas = tostring(nickas or ""):lower()
    if mazas == "" then return false end
    local pavyko, manoId = sampGetPlayerIdByCharHandle(PLAYER_PED)
    if pavyko and tostring(sampGetPlayerNickname(manoId)):lower() == mazas then return true end
    for id = 0, sampGetMaxPlayerId(false) do
        if sampIsPlayerConnected(id) and tostring(sampGetPlayerNickname(id)):lower() == mazas then return true end
    end
    return false
end

local function apkarpyti(tekstas)
    return (tekstas or ""):match("^%s*(.-)%s*$")
end

local function nuimtiSpalvas(tekstas)
    return (tostring(tekstas or ""):gsub("{%x%x%x%x%x%x}", ""))
end

local function tekst(reiksme) return reiksme ~= nil and tostring(reiksme) or "?" end

-- 427612456 -> "427.612.456"
local function formatuotiSuma(suma)
    local s = tostring(math.floor(tonumber(suma) or 0))
    local rezultatas = s:reverse():gsub("(%d%d%d)", "%1."):reverse()
    return (rezultatas:gsub("^%.", ""))
end

-- "427.612.456" -> 427612456
local function sumaIsTeksto(tekstas)
    return tonumber((tostring(tekstas or ""):gsub("[%.,]", ""))) or 0
end

-- 12345 -> "+12.345"
local function xpPokytis(skaicius)
    return (skaicius < 0 and "-" or "+") .. formatuotiSuma(math.abs(skaicius))
end

local function minutesTekstu(min)
    return string.format("%d min (%d val. %d min)", min, math.floor(min / 60), min % 60)
end

local function teisingasNickas(nickas)
    return nickas:match("^%u%l%l+_%u%l%l+$") ~= nil
end

-- "2026-10-29" -> laikas (vidurdienis, kad vasaros laikas nesumaišytų dienų)
local function datosLaikas(tekstas)
    local m, men, d = apkarpyti(tekstas):match("^(%d%d%d%d)-(%d%d)-(%d%d)$")
    if not m then return nil end
    m, men, d = tonumber(m), tonumber(men), tonumber(d)
    local laikas = os.time({ year = m, month = men, day = d, hour = 12 })
    local patikra = os.date("*t", laikas)
    if patikra.year ~= m or patikra.month ~= men or patikra.day ~= d then return nil end
    return laikas
end

local function darbasPagalId(id)
    for _, d in ipairs(DIREKTORIU_DARBAI) do
        if d.id == id then return d end
    end
    return nil
end

local function skaitytiJson(kelias)
    local f = io.open(kelias, "r")
    if not f then return nil end
    local pavyko, duomenys = pcall(decodeJson, f:read("*a"))
    f:close()
    if pavyko and type(duomenys) == "table" then return duomenys end
    return nil
end

local function rasytiJson(kelias, duomenys)
    local config = getWorkingDirectory() .. "\\config"
    if not doesDirectoryExist(config) then createDirectory(config) end
    if not doesDirectoryExist(DUOMENU_APLANKAS) then createDirectory(DUOMENU_APLANKAS) end
    local f = io.open(kelias, "w")
    if not f then return false end
    f:write(encodeJson(duomenys))
    f:close()
    return true
end

---------------------------------------------------------------- BŪSENA
local uzimtas = false
-- vykstančio veiksmo eiga, rodoma lange
local eiga = { tekstas = nil, dabar = 0, viso = 0 }

-- rodytiStatusa: atidaryti skiltį "Patikros statusas" (ilgoms patikroms)
local function pradetiEiga(tekstas, viso, rodytiStatusa)
    eiga.tekstas, eiga.dabar, eiga.viso = tekstas, 0, viso
    statusas.patikra = { pavadinimas = tekstas, pradzia = os.date("%H:%M:%S"), t0 = localClock(), busena = "vyksta" }
    statusoIrasas(tekstas, "antraste")
    if rodytiStatusa then statusas.perjungti = true end
end

-- busena: "baigta" (numatyta) arba "nutraukta"
local function baigtiEiga(busena)
    eiga.tekstas, eiga.dabar, eiga.viso = nil, 0, 0
    local p = statusas.patikra
    if p and p.busena == "vyksta" then
        p.busena = busena or "baigta"
        p.trukme = localClock() - p.t0
    end
end

-- Duomenys atmintyje (kad nereiktų kas kadrą skaityti failų)
local duomenys = {
    darbuotojai = nil, -- { darbai = {...}, surinkta = "..." | nil, atsitiktiniai = true }
    fondai = nil,      -- { darbai = {...}, surinkta = "..." | nil, atsitiktiniai = true }
    aktyvumas = nil,   -- { antraste, rezultatas, tikrinta }
    direkt = nil,      -- { eilutes = {...}, onlineDir, onlinePav, gauta }
}

---------------------------------------------------------------- ATSITIKTINIAI DUOMENYS
-- Naudojami tik tol, kol paspaudi "Atnaujinti informaciją".
local VARDAI = {
    "Jonas", "Tomas", "Lukas", "Mantas", "Paulius", "Rokas", "Dovydas", "Matas",
    "Karolis", "Domas", "Ignas", "Arnas", "Deividas", "Gytis", "Edvinas", "Justas",
}
local PAVARDES = {
    "Petraitis", "Kazlauskas", "Jankauskas", "Butkus", "Paulauskas", "Urbonas",
    "Navickas", "Rimkus", "Silver", "Adams", "Bayern", "Capela", "Vendetta", "Huawei",
    "Rule", "Shot",
}

local function atsitiktinis(sarasas) return sarasas[math.random(#sarasas)] end

-- Kiekvieno darbo /visidarbuotojai stulpeliai (pagal tikrą serverio output'ą)
local STD = { "Priimtas", "Rangas", "Įspėjimai" }
local function stulpeliai(...)
    local r = { ... }
    for _, x in ipairs(STD) do r[#r + 1] = x end
    return r
end
local MAFIJOS_STULPELIAI = { "Šiandien.", "Žala", "Rangas" }
local DARBU_STULPELIAI = {
    [1]  = stulpeliai("Šiandien", "Baudos", "Atvykimai"),            -- Policija
    [2]  = stulpeliai("Šiandien", "Iškvietimai", "Pagydymai"),       -- Ligoninė
    [5]  = stulpeliai("Šiandien", "Baudos"),                         -- FTB
    [6]  = MAFIJOS_STULPELIAI,                                       -- Cosa Nostra
    [8]  = stulpeliai("Šiandien", "Iškvietimai", "Pardavimai"),      -- Prekeiviai
    [12] = MAFIJOS_STULPELIAI,                                       -- Immortal
    [13] = stulpeliai("Šiandien", "Iškvietimai", "Atgabenimai"),     -- Mechanikai
    [14] = stulpeliai("Šiandien", "Baudos"),                         -- Interpolas
    [15] = stulpeliai("Šiandien", "Iškvietimai"),                    -- Apsauga
    [18] = stulpeliai("Šiandien", "Iškvietimai", "Atvežimai"),       -- Taksi
    [21] = MAFIJOS_STULPELIAI,                                       -- Grove Street
    [22] = MAFIJOS_STULPELIAI,                                       -- The Ballas
    [23] = stulpeliai("Pražaidė", "Eteryje", "Iškvietimai"),         -- Reporteriai
    [24] = stulpeliai("Šiandien", "Kroviniai"),                      -- Tolimųjų reisų
}
local NUMATYTI_STULPELIAI = stulpeliai("Šiandien", "Iškvietimai")  -- Armija, Narkotikai, Radijas
local SLAPTOSIOS_POLICIJOS_STULPELIAI = stulpeliai("Šiandien")

local function atsitiktineReiksme(laukas, dabar)
    if laukas == "Šiandien" then return math.random(0, 180) .. "min" end
    if laukas == "Šiandien." then return math.random(0, 180) .. "min." end
    if laukas == "Priimtas" then return os.date("%Y-%m-%d", dabar - math.random(7, 1500) * 86400) end
    if laukas == "Rangas" then return tostring(math.random(1, 11)) end
    if laukas == "Įspėjimai" then return tostring(math.random() < 0.8 and 0 or math.random(1, 3)) end
    if laukas == "Pražaidė" then return tostring(math.random(0, 120)) end
    if laukas == "Žala" then return tostring(math.random() < 0.7 and 0 or math.random(1, 50000)) end
    return tostring(math.random() < 0.5 and 0 or math.random(1, 15))   -- iškvietimai, baudos, pagydymai ir t.t.
end

-- Praeitos dienos formatas (/visidarbuotojai <data>): be Priimtas/Rangas/Įspėjimai, su "D. p.",
-- "Šiandien" turi du skaičius ("431 / 203 min"), FTB turi Ž/H/K, mafijos tik laiką ir žalą.
local function praeitos(...)
    local r = { ... }
    r[#r + 1] = "D. p."
    return r
end
local MAFIJOS_PRAEITOS = { "Šiandien1", "Žala" }
local DARBU_PRAEITOS = {
    [1]  = praeitos("Šiandien2", "Baudos", "Atvykimai"),
    [2]  = praeitos("Šiandien2", "Iškvietimai", "Pagydymai"),
    [5]  = praeitos("Šiandien2", "Baudos", "Ž", "H", "K"),
    [6]  = MAFIJOS_PRAEITOS,
    [8]  = praeitos("Šiandien2", "Iškvietimai", "Pardavimai"),
    [12] = MAFIJOS_PRAEITOS,
    [13] = praeitos("Šiandien2", "Iškvietimai", "Atgabenimai"),
    [14] = praeitos("Šiandien2", "Baudos"),
    [15] = praeitos("Šiandien2", "Iškvietimai"),
    [18] = praeitos("Šiandien2", "Iškvietimai", "Atvežimai"),
    [21] = MAFIJOS_PRAEITOS,
    [22] = MAFIJOS_PRAEITOS,
    [23] = praeitos("Pražaidė2", "Eteryje", "Iškvietimai"),
    [24] = praeitos("Šiandien2", "Kroviniai"),
}
local NUMATYTI_PRAEITOS = praeitos("Šiandien2", "Iškvietimai")
local SLAPTOSIOS_POLICIJOS_PRAEITOS = { "Šiandien1", "D. p." }

local function atsitiktineIstorine(laukas, kontekstas)
    if laukas == "Šiandien2" or laukas == "Pražaidė2" then
        local viso = math.random() < 0.4 and 0 or math.random(1, 700)
        local darbe = math.random(0, viso)
        kontekstas.darbe = darbe
        return viso .. " / " .. darbe .. " min"
    end
    if laukas == "Šiandien1" then return math.random(0, 800) .. " min" end
    if laukas == "D. p." then
        local darbe = kontekstas.darbe or 0
        return darbe > 0 and (formatuotiSuma(math.random(1, 500) * 1000 * math.random(1, 10)) .. "€") or "0€"
    end
    if laukas == "Ž" or laukas == "H" or laukas == "K" then return tostring(math.random() < 0.7 and 0 or math.random(1, 5)) end
    return nil
end

local function atsitiktiniaiDarbuotojai(darboId, praeita)
    local sarasas, panaudoti, dabar = {}, {}, os.time()
    local function sukurti(kiek, laukai, skyrius)
        local grupe = {}
        for _ = 1, kiek do
            local nickas = atsitiktinis(VARDAI) .. "_" .. atsitiktinis(PAVARDES)
            if not panaudoti[nickas] then
                panaudoti[nickas] = true
                local d = { nickas = nickas, skyrius = skyrius, laukai = {},
                            prisijunge = os.date("%Y-%m-%d %H:%M", dabar - math.random(0, 3 * 86400)) }
                local kontekstas = {}
                for _, laukas in ipairs(laukai) do
                    -- "Šiandien." (mafijos), "Šiandien1/2", "Pražaidė2" rodomi be priesagos
                    local pav = laukas:match("^(.-)[12]$") or (laukas == "Šiandien." and "Šiandien") or laukas
                    local reiksme = praeita and atsitiktineIstorine(laukas, kontekstas) or nil
                    d.laukai[#d.laukai + 1] = { pav, reiksme or atsitiktineReiksme(laukas, dabar) }
                end
                d.rikiavimas = kontekstas.darbe or 0
                grupe[#grupe + 1] = d
            end
        end
        if praeita then
            -- praeitos dienos sąrašas serveryje surikiuotas pagal laiką darbe
            table.sort(grupe, function(a, b) return a.rikiavimas > b.rikiavimas end)
        else
            table.sort(grupe, function(a, b) return a.nickas < b.nickas end)
        end
        for i, d in ipairs(grupe) do d.nr = i; sarasas[#sarasas + 1] = d end
    end

    local laukai = praeita and (DARBU_PRAEITOS[darboId] or NUMATYTI_PRAEITOS)
                       or (DARBU_STULPELIAI[darboId] or NUMATYTI_STULPELIAI)
    local mafija = laukai == MAFIJOS_STULPELIAI or laukai == MAFIJOS_PRAEITOS
    sukurti(mafija and math.random(1, 4) or math.random(3, 14), laukai, nil)
    if #sarasas > 0 and math.random() < 0.8 then sarasas[math.random(#sarasas)].pareigos = "dir" end
    if #sarasas > 1 and math.random() < 0.6 then
        local kandidatas = sarasas[math.random(#sarasas)]
        if not kandidatas.pareigos then kandidatas.pareigos = "pav" end
    end
    if darboId == 1 then
        sukurti(math.random(1, 3), praeita and SLAPTOSIOS_POLICIJOS_PRAEITOS or SLAPTOSIOS_POLICIJOS_STULPELIAI,
            not praeita and "Slaptoji policija" or nil)
    end
    return sarasas
end

-- data: nil = šiandien, kitaip praeitos dienos formatas
local function atsitiktiniaiDarbuotojuDuomenys(data)
    local siandien = os.date("%Y-%m-%d")
    local praeita = data ~= nil and data ~= siandien
    local r = { darbai = {}, atsitiktiniai = true, data = data or siandien }
    for _, d in ipairs(DIREKTORIU_DARBAI) do
        r.darbai[#r.darbai + 1] = { pavadinimas = d.pavadinimas, id = d.id, eilutes = atsitiktiniaiDarbuotojai(d.id, praeita) }
    end
    return r
end

local function atsitiktiniaiFondai()
    local r = { darbai = {}, atsitiktiniai = true }
    for _, d in ipairs(DIREKTORIU_DARBAI) do
        r.darbai[#r.darbai + 1] = {
            pavadinimas = d.pavadinimas, id = d.id,
            suma = math.random(1000, 999999) * 1000 + math.random(0, 999),
        }
    end
    return r
end

-- Įkelia tik tikrus (surinktus) duomenis. Atsitiktiniai niekada nesaugomi į failus.
local function ikeltiDuomenis()
    local d = skaitytiJson(FAILAI.darbuotojai)
    duomenys.darbuotojai = (d and type(d.darbai) == "table" and d.surinkta and not d.atsitiktiniai) and d or nil

    local f = skaitytiJson(FAILAI.fondai)
    duomenys.fondai = (f and type(f.darbai) == "table" and f.surinkta and not f.atsitiktiniai) and f or nil

    local a = skaitytiJson(FAILAI.aktyvumas)
    if a and type(a.rezultatas) == "table" and type(a.rezultatas.dienos) == "table"
        and #a.rezultatas.dienos > 0 and not a.atsitiktiniai then
        duomenys.aktyvumas = a
    end
end

-- Kai tikrų duomenų nėra ir Dev režimas išjungtas: visi darbai su nuliais
local function tusciDarbuotojai()
    local r = { darbai = {}, tusti = true }
    for _, d in ipairs(DIREKTORIU_DARBAI) do
        r.darbai[#r.darbai + 1] = { pavadinimas = d.pavadinimas, id = d.id, eilutes = {} }
    end
    return r
end

local function tusciFondai()
    local r = { darbai = {}, tusti = true }
    for _, d in ipairs(DIREKTORIU_DARBAI) do
        r.darbai[#r.darbai + 1] = { pavadinimas = d.pavadinimas, id = d.id, suma = 0 }
    end
    return r
end

---------------------------------------------------------------- SERVERIO ATSAKYMŲ ATPAŽINIMAS
-- /visidarbuotojai: kiekvienas darbas turi savo stulpelius, pvz.
--   1. Vardas_Pavarde Prisijungė 2026-10-30 14:14 | Šiandien 0min | Baudos 0 | Priimtas 2026-10-27 | Rangas (11) | Įspėjimai 0
--   1. Vardas_Pavarde Prisijungė 2026-10-30 12:38 | Šiandien 0min. | Žala 0 | Rangas (1)
-- Todėl eilutė skaidoma bendrai: "Pavadinimas reikšmė" tarp "|".
-- SA-MP chato eilutė nukerpama ties 144 simboliais, todėl galas papildomas iš lango "Darbuotojai".
local PRISIJUNGE = ltu("Prisijungė")
local CHATO_RIBA = 143

-- Vieno "|" segmento skaidymas į laukus. Formatai, kuriuos serveris naudoja:
--   "Šiandien 0min", "Baudos 3", "Rangas (11)", "Priimtas 2026-10-27"
--   praeitos dienos:  "Šiandien 431 203min" (du skaičiai), "D. p. 1.504.000€", "D. p. €"
--   FTB:              "Ž: 0 H: 0 K: 0" (keli laukai viename segmente)
local REIKSMES_PRADZIA = "[%d%(\128%-]"   -- skaičius, "(", € (cp1257 0x80) arba "-"

local function segmentoLaukai(seg)
    -- keli "X: reikšmė" viename segmente
    local poros = {}
    for pav, reiksme in seg:gmatch("([^%s:]+):%s*([^%s]+)") do poros[#poros + 1] = { pav, reiksme } end
    if #poros >= 2 then return poros end

    local pav, reiksme = seg:match("^(.-)%s+(" .. REIKSMES_PRADZIA .. ".*)$")
    if not pav or pav == "" then return nil end
    if pav == "Rangas" then reiksme = reiksme:gsub("[()]", "") end
    -- "431 203min" -> "431 / 203 min" (praeitos dienos: du laikai)
    local a1, a2, galas = reiksme:match("^(%d+)%s+(%d+)%s*(min%.?)$")
    if a1 then reiksme = a1 .. " / " .. a2 .. " " .. galas end
    if reiksme == "\128" then reiksme = "0\128" end
    return { { pav, reiksme } }
end

-- isLango = true: eilutė iš serverio lango, ji niekada nebūna nukirpta
local function atpazintiDarbuotoja(tekstas, isLango)
    local t = nuimtiSpalvas(tekstas)
    local nr, nickas, likutis = t:match("^%s*(%d+)%.%s+(%S+)%s+" .. PRISIJUNGE .. "%s+(.*)$")
    if not nr then return nil end

    local segmentai = {}
    for seg in (likutis .. "|"):gmatch("(.-)|") do segmentai[#segmentai + 1] = apkarpyti(seg) end
    local d = { nr = tonumber(nr), nickas = u8(nickas), prisijunge = u8(segmentai[1] or ""), laukai = {} }

    for i = 2, #segmentai do
        local seg = segmentai[i]
        local paskutinis = (i == #segmentai)
        if paskutinis and not isLango and #tostring(tekstas) >= CHATO_RIBA then
            d.nukirpta = true          -- paskutinis laukas gali būti nukirptas, imsim iš lango
        else
            local laukai = segmentoLaukai(seg)
            if laukai then
                for _, l in ipairs(laukai) do d.laukai[#d.laukai + 1] = { u8(l[1]), u8(l[2]) } end
            elseif seg ~= "" then
                d.nukirpta = true
            end
        end
    end
    return d
end

-- Lango "Darbuotojai" eilutės: "1. Vardas_Pavarde 2026-10-30 14:14|0min|0/0|2026-10-27|(11)|0"
-- Iš jų imam tai, kas chate galėjo būti nukirpta: priėmimo datą, rangą ir įspėjimus.
-- Eilutė be numerio (pvz. "Slaptoji policija") yra poskyrio pavadinimas.
local function atpazintiDarbuotojuLanga(tekstas)
    local r = { pagalNicka = {}, tvarka = {} }
    local skyrius = nil
    for eilute in (tostring(tekstas) .. "\n"):gmatch("(.-)\n") do
        local t = apkarpyti(nuimtiSpalvas(eilute))
        local nr, nickas, prisijunge = t:match("^(%d+)%.%s+(%S+)%s+(%d%d%d%d%-%d%d%-%d%d %d%d:%d%d)")
        if nr then
            local laukai = {}
            for laukas in (t .. "|"):gmatch("(.-)|") do laukai[#laukai + 1] = laukas end
            local datos = {}
            for data in t:gmatch("%d%d%d%d%-%d%d%-%d%d") do datos[#datos + 1] = data end
            local rangas
            for x in t:gmatch("%((%d+)%)") do rangas = x end
            local e = {
                nr = tonumber(nr), nickas = u8(nickas), prisijunge = prisijunge, skyrius = skyrius,
                priimtas = #datos >= 2 and datos[#datos] or nil,
                rangas = rangas,
                ispejimai = (laukai[#laukai] or ""):match("^%s*(%d+)%s*$"),
            }
            r.pagalNicka[e.nickas] = e
            r.tvarka[#r.tvarka + 1] = e
        elseif t ~= "" then
            skyrius = u8(t)
        end
    end
    return r
end

local function turiLauka(d, pavadinimas)
    for _, l in ipairs(d.laukai) do if l[1] == pavadinimas then return true end end
    return false
end

-- Sujungia chato eilutes su lango duomenimis: poskyriai, nukirpti laukai, trūkstami darbuotojai.
local function sujungtiDarbuotojus(eilutes, langoTekstas)
    if not langoTekstas then return eilutes end

    -- Praeitos dienos langas turi tas pačias pilnas eilutes kaip chatas (su "Prisijungė"),
    -- tik nenukirptas, todėl tada imam viską iš lango.
    if tostring(langoTekstas):find(PRISIJUNGE, 1, true) then
        local isLango, skyrius = {}, nil
        for eilute in (tostring(langoTekstas) .. "\n"):gmatch("(.-)\n") do
            local d = atpazintiDarbuotoja(eilute, true)
            if d then
                d.skyrius = skyrius
                isLango[#isLango + 1] = d
            else
                local t = apkarpyti(nuimtiSpalvas(eilute))
                if t ~= "" then skyrius = u8(t) end
            end
        end
        if #isLango > 0 then return isLango end
    end

    local langas = atpazintiDarbuotojuLanga(langoTekstas)

    -- visi stulpeliai, kurie šiame darbe pasitaiko pilnose eilutėse
    local visiLaukai = {}
    for _, d in ipairs(eilutes) do
        for _, l in ipairs(d.laukai) do visiLaukai[l[1]] = true end
    end
    local papildomi = {
        { "Priimtas", "priimtas" }, { "Rangas", "rangas" }, { "Įspėjimai", "ispejimai" },
    }

    local yra = {}
    for _, d in ipairs(eilutes) do
        yra[d.nickas] = true
        local l = langas.pagalNicka[d.nickas]
        if l then
            d.skyrius = l.skyrius
            if d.nukirpta then
                for _, p in ipairs(papildomi) do
                    if l[p[2]] and not turiLauka(d, p[1]) and (visiLaukai[p[1]] or p[1] ~= "Priimtas") then
                        d.laukai[#d.laukai + 1] = { p[1], l[p[2]] }
                    end
                end
            end
        end
    end
    -- darbuotojai, kurių chate nebuvo (pvz. eilutė dingo), pridedami iš lango
    for _, l in ipairs(langas.tvarka) do
        if not yra[l.nickas] then
            local d = { nr = l.nr, nickas = l.nickas, prisijunge = l.prisijunge, skyrius = l.skyrius,
                        laukai = {}, isLango = true }
            for _, p in ipairs(papildomi) do
                if l[p[2]] then d.laukai[#d.laukai + 1] = { p[1], l[p[2]] } end
            end
            eilutes[#eilutes + 1] = d
        end
    end
    return eilutes
end

-- *** Darbo fonde yra 427.612.456 €
local function atpazintiFonda(tekstas)
    return nuimtiSpalvas(tekstas):match("Darbo fonde yra%s+([%d%.,]+)")
end

-- /info: Žaidė Šiandien: 105min | Pravažiavo Šiandien: 0.35km | Patirtis: 4.505.940XP |
--        Šiandien pagavo žuvų už: 0€ | Nėra informacijos
local MINUCIU_SABLONAS  = ltu("Šiandien") .. ":?%s*(%d+)%s*min"
local KM_SABLONAS       = ltu("Šiandien") .. ":?%s*(%d+[%.,]?%d*)%s*km"
local PATIRTIS_SABLONAS = "Patirtis:?%s*([%d%.,]+)%s*XP"
local ZUVU_SABLONAS     = ltu("pagavo žuvų už") .. ":?%s*([%d%.,]+)"
local NERA_INFORMACIJOS = ltu("Nėra informacijos")

local function atpazintiInfo(tekstas)
    local t = nuimtiSpalvas(tekstas)
    local r = {}
    local min = t:match(MINUCIU_SABLONAS)
    if min then r.minutes = tonumber(min) end
    local km = t:match(KM_SABLONAS)
    if km then r.km = tonumber((km:gsub(",", "."))) end
    r.xp = t:match(PATIRTIS_SABLONAS)
    local zuvys = t:match(ZUVU_SABLONAS)
    if zuvys then r.zuvys = sumaIsTeksto(zuvys) end
    if t:find(NERA_INFORMACIJOS, 1, true) then
        r.minutes = r.minutes or 0
        r.km = r.km or 0
        r.zuvys = r.zuvys or 0
    end
    if r.minutes or r.km or r.xp or r.zuvys then return r end
    return nil
end

-- /direkt langelis "{00FF00}Jack_Slider" -> "Jack_Slider", true (žalias = online)
local function vardasIrBusena(langelis)
    langelis = langelis or ""
    local spalva = langelis:match("{(%x%x%x%x%x%x)}")
    local vardas = apkarpyti(nuimtiSpalvas(langelis))
    if vardas == "" or vardas == "-" then return nil, false end
    local online = false
    if spalva then
        local r, g = tonumber(spalva:sub(1, 2), 16), tonumber(spalva:sub(3, 4), 16)
        online = g > 0x80 and r < 0x80
    end
    return vardas, online
end

local function direktoriausId(darboTekstas)
    for _, d in ipairs(DIREKT_DARBAI) do
        if darboTekstas:find(d.raktas, 1, true) then return d.id end
    end
    return nil
end

local function atpazintiDirekt(tekstas)
    local eilutes = {}
    for eilute in (tekstas .. "\n"):gmatch("(.-)\n") do eilutes[#eilutes + 1] = eilute end
    if #eilutes < 2 or not eilutes[1]:find("Direktorius", 1, true) then return nil end

    local r = { eilutes = {}, onlineDir = 0, onlinePav = 0, gauta = os.date("%Y-%m-%d %H:%M") }
    for i = 2, #eilutes do
        local langeliai = {}
        for langelis in (eilutes[i] .. "\t"):gmatch("(.-)\t") do langeliai[#langeliai + 1] = langelis end
        local darbas = apkarpyti(nuimtiSpalvas(langeliai[1] or ""))
        if darbas ~= "" then
            local pavadinimas = darbas:match("^(.-)%s*%(") or darbas
            local dir, dirOnline = vardasIrBusena(langeliai[2])
            local pav, pavOnline = vardasIrBusena(langeliai[3])
            if dirOnline then r.onlineDir = r.onlineDir + 1 end
            if pavOnline then r.onlinePav = r.onlinePav + 1 end
            r.eilutes[#r.eilutes + 1] = {
                pavadinimas = u8(pavadinimas), visas = u8(darbas), id = direktoriausId(darbas),
                direktorius = dir, direktoriusOnline = dirOnline,
                pavaduotojas = pav, pavaduotojasOnline = pavOnline,
            }
        end
    end
    return r
end

-- /arsutapo lentelė (cp1257). Antraštė: "Vardas_A ir Vardas_B prisijungimai".
-- Eilutės: paskyros vardas atskiroje eilutėje, po jo "data \t IP numeris \t SAMP ID raidė".
-- Vienodas IP skaičius = tas pats IP, vienoda SAMP ID raidė = tas pats kompiuteris.
local DATA_LAIKAS = "^(%d%d%d%d)%-(%d%d)%-(%d%d) (%d%d):(%d%d):(%d%d)$"

local function laikasIsTeksto(t)
    local y, mo, d, h, mi, se = (t or ""):match(DATA_LAIKAS)
    if not y then return nil end
    return os.time({ year = tonumber(y), month = tonumber(mo), day = tonumber(d),
                     hour = tonumber(h), min = tonumber(mi), sec = tonumber(se) })
end

local function atpazintiSutapima(antraste, tekstas)
    local a = apkarpyti(nuimtiSpalvas(antraste))
    if not a:find("prisijungimai", 1, true) then return nil end
    local eilutes = {}
    for eilute in (tekstas .. "\n"):gmatch("(.-)\n") do eilutes[#eilutes + 1] = eilute end
    if #eilutes < 2 or not eilutes[1]:find("SAMP ID", 1, true) then return nil end

    local r = { paskyros = {}, irasai = {}, antraste = u8(a), gauta = os.date("%Y-%m-%d %H:%M") }
    local dabartine
    for i = 2, #eilutes do
        local langeliai = {}
        for langelis in (eilutes[i] .. "\t"):gmatch("(.-)\t") do
            langeliai[#langeliai + 1] = apkarpyti(nuimtiSpalvas(langelis))
        end
        local pirmas = langeliai[1] or ""
        local laikas = laikasIsTeksto(pirmas)
        if laikas then
            if dabartine then
                r.irasai[#r.irasai + 1] = { paskyra = dabartine, data = pirmas, laikas = laikas,
                    ip = u8(langeliai[2] or "?"), samp = u8(langeliai[3] or "?") }
            end
        elseif pirmas ~= "" then
            dabartine = u8(pirmas)
            r.paskyros[#r.paskyros + 1] = dabartine
        end
    end
    if #r.paskyros == 0 then return nil end
    return r
end

local function analizuotiSutapima(r)
    local info = {}
    for _, p in ipairs(r.paskyros) do
        info[p] = { kiek = 0, ip = {}, ipSar = {}, samp = {}, sampSar = {} }
    end
    for _, e in ipairs(r.irasai) do
        local x = info[e.paskyra]
        x.kiek = x.kiek + 1
        if not x.ip[e.ip] then x.ip[e.ip] = 0; x.ipSar[#x.ipSar + 1] = e.ip end
        x.ip[e.ip] = x.ip[e.ip] + 1
        if not x.samp[e.samp] then x.samp[e.samp] = 0; x.sampSar[#x.sampSar + 1] = e.samp end
        x.samp[e.samp] = x.samp[e.samp] + 1
        if not x.pirmas or e.laikas < x.pirmas.laikas then x.pirmas = e end
        if not x.paskutinis or e.laikas > x.paskutinis.laikas then x.paskutinis = e end
    end
    for _, x in pairs(info) do
        table.sort(x.ipSar, function(a, b) return (tonumber(a) or 1e9) < (tonumber(b) or 1e9) end)
        table.sort(x.sampSar)
    end

    local bendriIp, bendriSamp, bendrasIp, bendrasSamp = {}, {}, {}, {}
    if #r.paskyros >= 2 then
        local a, b = info[r.paskyros[1]], info[r.paskyros[2]]
        for _, ip in ipairs(a.ipSar) do if b.ip[ip] then bendriIp[#bendriIp + 1] = ip; bendrasIp[ip] = true end end
        for _, sp in ipairs(a.sampSar) do if b.samp[sp] then bendriSamp[#bendriSamp + 1] = sp; bendrasSamp[sp] = true end end
    end

    -- visi prisijungimai pagal laiką ir persijungimai tarp paskyrų
    local visi = {}
    for _, e in ipairs(r.irasai) do visi[#visi + 1] = e end
    table.sort(visi, function(a, b) return a.laikas < b.laikas end)
    local persijungimai = {}
    for i = 2, #visi do
        local is, i2 = visi[i - 1], visi[i]
        if is.paskyra ~= i2.paskyra and i2.laikas - is.laikas <= PERSIJUNGIMO_MIN * 60 then
            table.insert(persijungimai, 1, { is = is, i = i2, min = math.floor((i2.laikas - is.laikas) / 60) })
        end
    end
    local laikoEile = {}
    for i = #visi, 1, -1 do laikoEile[#laikoEile + 1] = visi[i] end

    return { info = info, bendriIp = bendriIp, bendriSamp = bendriSamp, bendrasIp = bendrasIp,
             bendrasSamp = bendrasSamp, persijungimai = persijungimai, laikoEile = laikoEile }
end

-- Dev režimui: atsitiktinis /arsutapo pavyzdys.
-- scenarijus: "sutampa" (tas pats SAMP ID), "ip" (tik bendras IP),
--             "nesutampa" (nieko bendro), "ip_keitimas" (tas pats SAMP ID, kiekvienąkart kitas IP),
--             nil = atsitiktinai vienas iš jų
local SUTAPIMO_SCENARIJAI = { "sutampa", "ip", "nesutampa", "ip_keitimas" }

local function atsitiktinisSutapimas(scenarijus)
    scenarijus = scenarijus or SUTAPIMO_SCENARIJAI[math.random(#SUTAPIMO_SCENARIJAI)]
    local vardai = { "Jonas", "Tomas", "Lukas", "Mantas", "Rokas", "Matas", "Domas", "Gytis" }
    local pavardes = { "Petraitis", "Butkus", "Urbonas", "Rimkus", "Navickas", "Adams", "Shot", "Rule" }
    local a = vardai[math.random(#vardai)] .. "_" .. pavardes[math.random(#pavardes)]
    local b
    repeat b = vardai[math.random(#vardai)] .. "_" .. pavardes[math.random(#pavardes)] until b ~= a

    local r = { paskyros = { a, b }, irasai = {}, antraste = a .. " ir " .. b .. " prisijungimai",
                gauta = os.date("%Y-%m-%d %H:%M"), atsitiktiniai = true, scenarijus = scenarijus }
    local function irasas(paskyra, laikas, ip, samp)
        r.irasai[#r.irasai + 1] = { paskyra = paskyra, laikas = laikas,
            data = os.date("%Y-%m-%d %H:%M:%S", laikas), ip = tostring(ip), samp = samp }
    end

    local sampA = "A"
    local sampB = (scenarijus == "sutampa" or scenarijus == "ip_keitimas") and "A" or "B"
    local pradzia = os.time() - 60 * 86400

    if scenarijus == "nesutampa" then
        -- dvi nepriklausomos paskyros: skirtingi IP, skirtingi kompiuteriai, atsitiktiniai laikai
        local laikas, ip = pradzia, 0
        for _ = 1, math.random(10, 18) do
            laikas = laikas + math.random(3, 80) * 3600
            if math.random() < 0.3 then ip = math.random(0, 5) end
            irasas(a, laikas, ip, sampA)
        end
        laikas, ip = pradzia + math.random(1, 48) * 3600, 20
        for _ = 1, math.random(8, 15) do
            laikas = laikas + math.random(5, 90) * 3600
            if math.random() < 0.3 then ip = math.random(20, 25) end
            irasas(b, laikas, ip, sampB)
        end
    else
        -- pirma paskyra žaidžia, kartais po kelių minučių persijungia į antrą
        local laikas, ip = pradzia, 0
        local ipNumeriai = { 0, 1, 2, 6, 8, 17 }
        local kitasIp = 30
        for _ = 1, math.random(14, 22) do
            laikas = laikas + math.random(3, 60) * 3600
            if scenarijus == "ip_keitimas" then
                ip = kitasIp; kitasIp = kitasIp + 1      -- kiekvieną kartą naujas IP
            elseif math.random() < 0.3 then
                ip = ipNumeriai[math.random(#ipNumeriai)]
            end
            irasas(a, laikas, ip, sampA)
            if math.random() < 0.35 then
                local ipB = ip
                if scenarijus == "ip_keitimas" then ipB = kitasIp; kitasIp = kitasIp + 1 end
                irasas(b, laikas + math.random(1, 10) * 60, ipB, sampB)
            end
        end
        local turiB = false
        for _, e in ipairs(r.irasai) do if e.paskyra == b then turiB = true end end
        if not turiB then irasas(b, laikas + 300, scenarijus == "ip_keitimas" and kitasIp or ip, sampB) end
    end

    r.analize = analizuotiSutapima(r)
    return r
end

-- Dev režimui: atsitiktinė aktyvumo patikra (7 dienos)
local function atsitiktinisAktyvumas(nickas, nuo, iki, darbas)
    nickas = nickas or (VARDAI[math.random(#VARDAI)] .. "_" .. PAVARDES[math.random(#PAVARDES)])
    local dienu = 7
    if nuo and iki then dienu = math.max(2, math.floor((iki - nuo) / 86400 + 0.5) + 1) end
    nuo = nuo or (os.time() - dienu * 86400)
    local r = { dienos = {}, visoMin = 0, visoKm = 0, visoZuvys = 0, neatsake = 0 }
    local xp = math.random(1000000, 5000000)
    for i = 0, dienu - 1 do
        local min = math.random() < 0.15 and 0 or math.random(20, 600)
        local km = min > 0 and math.random(0, 3000) / 10 or 0
        local zuvys = (min > 0 and math.random() < 0.3) and math.random(1, 50) * 50 or 0
        xp = xp + min * math.random(20, 40)
        local d = { data = os.date(DATOS_FORMATAS, nuo + i * 86400), minutes = min, km = km,
                    zuvys = zuvys, xp = formatuotiSuma(xp) }
        if darbas then
            d.darbas = {}
            for _, laukas in ipairs(DARBU_STULPELIAI[darbas.id] or NUMATYTI_STULPELIAI) do
                if laukas ~= "Priimtas" and laukas ~= "Rangas" and laukas ~= "Įspėjimai" then
                    d.darbas[#d.darbas + 1] = { laukas, min > 0 and atsitiktineReiksme(laukas, os.time()) or
                        (laukas:find("Šiandien", 1, true) and "0min" or "0") }
                end
            end
        end
        r.dienos[#r.dienos + 1] = d
        r.visoMin, r.visoKm, r.visoZuvys = r.visoMin + min, r.visoKm + km, r.visoZuvys + zuvys
    end
    r.darbas = darbas and darbas.pavadinimas or nil
    r.xpPirma, r.xpPaskutine = r.dienos[1].xp, r.dienos[dienu].xp
    r.xpPokytis = sumaIsTeksto(r.xpPaskutine) - sumaIsTeksto(r.xpPirma)
    r.xpVidurkis = math.floor(r.xpPokytis / (dienu - 1) + 0.5)
    return {
        antraste = string.format("%s %s - %s", nickas, r.dienos[1].data, r.dienos[dienu].data),
        rezultatas = r, tikrinta = os.date("%Y-%m-%d %H:%M"), atsitiktiniai = true,
    }
end

-- Dev režimui: atsitiktinė /direkt lentelė
local function atsitiktiniaiDirektoriai()
    local r = { eilutes = {}, onlineDir = 0, onlinePav = 0, gauta = os.date("%Y-%m-%d %H:%M"), atsitiktiniai = true }
    local function nickas() return VARDAI[math.random(#VARDAI)] .. "_" .. PAVARDES[math.random(#PAVARDES)] end
    for _, d in ipairs(DIREKTORIU_DARBAI) do
        local e = { pavadinimas = d.pavadinimas, id = d.id,
                    visas = string.format("%s (Nuo %s XP)", d.pavadinimas, formatuotiSuma(math.random(2, 70) * 1000)) }
        if math.random() < 0.6 then e.direktorius, e.direktoriusOnline = nickas(), math.random() < 0.3 end
        if math.random() < 0.5 then e.pavaduotojas, e.pavaduotojasOnline = nickas(), math.random() < 0.3 end
        if e.direktoriusOnline then r.onlineDir = r.onlineDir + 1 end
        if e.pavaduotojasOnline then r.onlinePav = r.onlinePav + 1 end
        r.eilutes[#r.eilutes + 1] = e
    end
    return r
end

-- Ką rodyti lange: tikri duomenys, Dev režime atsitiktiniai, kitaip tušti (nuliai)
local atsitiktiniai = {}
local tusti = {}
local GENERATORIAI = {
    darbuotojai = atsitiktiniaiDarbuotojuDuomenys, fondai = atsitiktiniaiFondai,
    aktyvumas = atsitiktinisAktyvumas, direkt = atsitiktiniaiDirektoriai, sutapimas = atsitiktinisSutapimas,
}
local TUSCIU_KURIMAS = { darbuotojai = tusciDarbuotojai, fondai = tusciFondai }

local function rodomi(rusis)
    -- Dev režime rankiniu būdu sugeneruoti duomenys rodomi vietoj tikrų
    if nust.dev and atsitiktiniai[rusis .. "Pirmenybe"] and atsitiktiniai[rusis] then return atsitiktiniai[rusis] end
    if duomenys[rusis] then return duomenys[rusis] end
    if nust.dev then
        if not atsitiktiniai[rusis] then atsitiktiniai[rusis] = GENERATORIAI[rusis]() end
        return atsitiktiniai[rusis]
    end
    if TUSCIU_KURIMAS[rusis] then
        if not tusti[rusis] then tusti[rusis] = TUSCIU_KURIMAS[rusis]() end
        return tusti[rusis]
    end
    return nil
end

---------------------------------------------------------------- RINKIMO BŪSENA (hookams)
local rinkimas = {
    darbuotojai = nil,  -- { eilutes = {}, paskutine = laikas } kol renkama
    fondas = nil,       -- { suma = "..." } kol laukiama
    info = nil,         -- { minutes, km, xp, zuvys } kol laukiama
    direkt = nil,       -- { gauta = true } kol laukiama /direkt lentelės (prieš renkant darbuotojus)
    ispejimai = nil,    -- { eilutes = {}, paskutine, langas = { stilius, antraste, tekstas } } kol laukiama /ispejimai
    efondas = nil,      -- { id = "mg" | "t" | "e" } kol laukiama /mgfondas, /tfondas ar /efondas lango
}

local TOKIOS_KOMANDOS_NERA = ltu("Tokios komandos nėra")

function sampev.onServerMessage(spalva, tekstas)
    if zurnalas then
        local zyme = ""
        local d = atpazintiDarbuotoja(tekstas)
        if d then zyme = d.nukirpta and " [NUKIRPTA]" or " [ATPAŽINTA]" end
        zurnaloIrasas(string.format("CHAT%s 0x%08X | %s", zyme, (tonumber(spalva) or 0) % 0x100000000, tostring(tekstas)))
    end

    -- serverio atsakymai į scripto /skirtidir ir /skirtipav (paskyrimas, nuėmimas) slepiami
    -- chate ir rodomi skiltyje "Patikros statusas". Tikrinam tik ~2 s po scripto komandos, kad
    -- nepaslėptume kitų žinučių. (Nebetikrinam "uzimtas": paskutinis /skirtidir 0 išsiunčiamas
    -- jau pačioje pabaigoje, o atsakymas ateina, kai patikra jau baigta.)
    if nust.slepti and prieiga.komanda and localClock() - prieiga.laikas < 2
            and apkarpyti(nuimtiSpalvas(tekstas)) == "" then
        return false   -- tuščia eilutė po scripto komandos
    end
    if nust.slepti and prieiga.komanda and localClock() - prieiga.laikas < 2
            and (prieiga.komanda:find(KOMANDOS.direktorius:match("^(/%S+)"), 1, true) == 1
              or prieiga.komanda:find(KOMANDOS.pavaduotojoAtemimas:match("^(/%S+)"), 1, true) == 1) then
        local svarus = nuimtiSpalvas(tekstas)
        local mazos = svarus:lower()
        if mazos:find("direktori", 1, true) or mazos:find("diektori", 1, true) or mazos:find("pareig", 1, true)
                or mazos:find("pavaduotoj", 1, true) then
            local pavyko, r = pcall(u8, svarus)
            statusoIrasas(pavyko and r or svarus, "serveris")
            return false
        end
    end

    -- scripto komandai serveris atsakė "Tokios komandos nėra" = nėra prieigos
    if prieiga.komanda and localClock() - prieiga.laikas < 3
            and nuimtiSpalvas(tekstas):find(TOKIOS_KOMANDOS_NERA, 1, true) then
        local komanda = prieiga.komanda:match("^(/%S+)") or prieiga.komanda
        prieiga.klaida, prieiga.komanda = komanda, nil
        statusoIrasas("Neturi prieigos prie komandos " .. komanda .. ".", "ispejimas")
        return false
    end

    -- /mgfondas, /tfondas, /efondas: chate ateina "... fonde: 96.020.000€" - pasiimam likutį ir slepiam
    if rinkimas.efondas then
        local likutis = nuimtiSpalvas(tekstas):match("fonde:%s*([%d%.,]+)")
        if likutis then
            rinkimas.efondas.likutis = sumaIsTeksto(likutis)
            if nust.slepti then return false end
            return
        end
    end

    -- /ispejimai atsakymas chate: renkam visas eilutes, kol neateina langas
    if rinkimas.ispejimai and not rinkimas.ispejimai.langas then
        local r = rinkimas.ispejimai
        r.eilutes[#r.eilutes + 1] = tekstas
        r.paskutine = localClock()
        if nust.slepti then return false end
        return
    end

    if rinkimas.darbuotojai then
        local d = atpazintiDarbuotoja(tekstas)
        if d then
            local r = rinkimas.darbuotojai
            r.eilutes[#r.eilutes + 1] = d
            r.paskutine = localClock()
            if nust.slepti then return false end
            return
        end
    end
    if rinkimas.fondas then
        local suma = atpazintiFonda(tekstas)
        if suma then
            rinkimas.fondas.suma = suma
            if nust.slepti then return false end
            return
        end
    end
    if rinkimas.info then
        local r = atpazintiInfo(tekstas)
        if r then
            for k, v in pairs(r) do rinkimas.info[k] = v end
            if nust.slepti then return false end
            return
        end
    end
end

-- atidaroma (apibrėžta žemiau, UI skyriuje)
local atidarytiMeniu

function sampev.onShowDialog(id, stilius, antraste, mygtukas1, mygtukas2, tekstas)
    if zurnalas then
        zurnaloIrasas(string.format("DIALOG id=%s stilius=%s mygtukai=[%s|%s] antraštė: %s",
            tostring(id), tostring(stilius), tostring(mygtukas1), tostring(mygtukas2), tostring(antraste)))
        zurnalas.eilutes[#zurnalas.eilutes + 1] = "    --- lango tekstas ---"
        for eilute in (tostring(tekstas) .. "\n"):gmatch("(.-)\n") do
            local pavyko, r = pcall(u8, eilute)
            zurnalas.eilutes[#zurnalas.eilutes + 1] = "    " .. (pavyko and r or eilute)
        end
        zurnalas.eilutes[#zurnalas.eilutes + 1] = "    --- lango pabaiga ---"
    end

    -- ar langą užklausė pats scriptas (mygtukas DPKT meniu) - tada visada rodom meniu lange
    local function isScripto(komanda)
        return prieiga.komanda ~= nil and prieiga.komanda:find(komanda, 1, true) == 1
            and localClock() - prieiga.laikas < LAUKTI_ILGIAUSIAI + 1
    end

    -- /mgfondas, /tfondas, /efondas langas: "Data | Vardas | Suma", antraštėje likutis
    if rinkimas.efondas and not rinkimas.efondas.langas
            and (tostring(antraste):find("fonde", 1, true) or tostring(tekstas):find("Vardas", 1, true)) then
        rinkimas.efondas.langas = { antraste = antraste, tekstas = tekstas }
        lua_thread.create(function() wait(0) sampSendDialogResponse(id, 0, 0, "") end)
        return false
    end

    -- /ispejimai atsakymas lange: pasiimam ir neberodom (rodom savo lange)
    if rinkimas.ispejimai and not rinkimas.ispejimai.langas then
        rinkimas.ispejimai.langas = { stilius = stilius, antraste = antraste, tekstas = tekstas }
        lua_thread.create(function() wait(0) sampSendDialogResponse(id, 0, 0, "") end)
        return false
    end

    -- /direkt: vietoj serverio lango rodom savo
    if stilius == 5 and tostring(antraste):find("Direktoriai", 1, true) then
        local r = atpazintiDirekt(tekstas)
        if r then
            duomenys.direkt = r
            -- rinkimo metu: lentelė reikalinga tik direktoriams pažymėti, langą paslepiam
            if rinkimas.direkt then
                rinkimas.direkt.gauta = true
                lua_thread.create(function() wait(0) sampSendDialogResponse(id, 0, 0, "") end)
                return false
            end
            if nust.perimtiDirekt or isScripto("/direkt") then
                atidarytiMeniu("direktoriai")
                -- uždarom serverio langą, kad serveris nemanytų, jog jis vis dar atidarytas
                lua_thread.create(function() wait(0) sampSendDialogResponse(id, 0, 0, "") end)
                return false
            end
            return
        end
    end

    -- /arsutapo: vietoj serverio lango rodom savo
    if stilius == 5 then
        local r = atpazintiSutapima(antraste, tekstas)
        if r then
            r.analize = analizuotiSutapima(r)
            duomenys.sutapimas = r
            if nust.perimtiArsutapo or isScripto("/arsutapo") then
                atidarytiMeniu("sutapimas")
                lua_thread.create(function() wait(0) sampSendDialogResponse(id, 0, 0, "") end)
                return false
            end
            return
        end
    end

    -- /visidarbuotojai langas rinkimo metu: pasiimam tekstą ir neberodom
    if rinkimas.darbuotojai and (tostring(antraste):find("Darbuotojai", 1, true)
            or tostring(antraste):match("^%s*%d%d%d%d%-%d%d%-%d%d%s*$")
            or tostring(tekstas):find(PRISIJUNGE, 1, true)) then
        rinkimas.darbuotojai.langas = tekstas
        if nust.slepti then
            lua_thread.create(function() wait(0) sampSendDialogResponse(id, 0, 0, "") end)
            return false
        end
        return
    end

    -- /info atsakymas lange
    if rinkimas.info then
        local r = atpazintiInfo(tekstas)
        if r and r.minutes then
            for k, v in pairs(r) do rinkimas.info[k] = v end
            return false
        end
    end
end

---------------------------------------------------------------- VEIKSMAI
-- Nutraukia patikrą, kai trūksta prieigos. Jei direktorius jau buvo uždėtas, jį nuima.
local function nutrauktiPatikra(as)
    rinkimas.darbuotojai, rinkimas.fondas, rinkimas.info, rinkimas.ispejimai = nil, nil, nil, nil
    local dirKomanda = KOMANDOS.direktorius:match("^(/%S+)")
    if as and prieiga.klaida ~= dirKomanda then
        siusti(string.format(KOMANDOS.direktorius, as, 0))
        pranesimas("Nuimiau direktorių.")
    end
    klaida("Patikra nutraukta.")
    issaugotiZurnala("nutraukta (" .. tostring(prieiga.klaida) .. ")")
    uzimtas = false
    baigtiEiga("nutraukta")
end

-- užsideda direktorių, išsiunčia komandą, nusiima
-- tikslas: tekstas pranešimui ("patikrinti /dfondas" ir pan.); kaiBaigta: veiksmas sėkmingai pabaigus
local function vykdytiDirektoriausSeka(darbas, komanda, tikslas, kaiBaigta)
    if uzimtas then klaida("Palauk, kol baigsis ankstesnis veiksmas.") return end
    local as = manoNickas()
    if not as then klaida("Nepavyko gauti tavo ID.") return end
    uzimtas = true
    pradetiEiga(string.format("%s: %s", darbas.pavadinimas, komanda), 3)
    prieiga.klaida = nil
    lua_thread.create(function()
        siusti(string.format(KOMANDOS.direktorius, as, 0))
        pranesimas("Nuimiau esamą direktorių, jei toks buvo.")
        wait(PAUZE)
        if prieiga.klaida then return nutrauktiPatikra(as) end
        eiga.dabar = 1
        siusti(string.format(KOMANDOS.direktorius, as, darbas.id))
        pranesimas(string.format("Skyrei sau %s direktorių %s.", darbas.pavadinimas, tikslas or ("patikrinti " .. komanda)))
        wait(PAUZE)
        if prieiga.klaida then return nutrauktiPatikra(as) end
        eiga.dabar = 2
        siusti(komanda)
        wait(PAUZE)
        if prieiga.klaida then return nutrauktiPatikra(as) end
        siusti(string.format(KOMANDOS.direktorius, as, 0))
        pranesimas("Nuimiau direktorių.")
        uzimtas = false
        baigtiEiga()
        if kaiBaigta then kaiBaigta() end
    end)
end

-- Žaidėjo įspėjimų istorija: užsideda darbo direktorių, /ispejimai nickas, nusiima.
-- Rezultatas rodomas atskirame lange (ispejimai.langas).
local ispejimai = { langas = nil }

ispejimai.PRIEZASTYS = {
    "Blogas pardavimas", "Nedalyvavimas veikloje", "Nepagarba kolegoms", "Atrankos trukdymas",
    "Trukdymas dirbti", "Nepagarba bendradarbiams", "Bloga kaina", "Nepaimti iškvietimai per 30sec",
    "Nesurinkti iškvietimai/pardavimai", "Konfliktai į /r",
}

-- Dev režimui: atsitiktinė įspėjimų istorija (kaip tikras serverio langas)
function ispejimai.atsitiktine(nickas)
    local t = { antrastes = { "Data", "Priežastis", "Davė" }, eilutes = {}, stulpeliu = 3 }
    local kiek = math.random(0, 3)
    t.santrauka = { string.format("%s įspėtas direktoriaus %d kartų", nickas, kiek) }
    t.ispetas = kiek
    local laikas = os.time()
    for _ = 1, math.random(0, 14) do
        laikas = laikas - math.random(1, 90) * 86400 - math.random(0, 86399)
        local nuo = math.random(3)
        t.eilutes[#t.eilutes + 1] = {
            os.date("%Y-%m-%d %H:%M:%S", laikas), ispejimai.PRIEZASTYS[math.random(#ispejimai.PRIEZASTYS)],
            nuo == 1 and "Direktorius" or (nuo == 2 and "Pavaduotojas" or "-"),
        }
    end
    return t
end

-- Serverio langas "Įspėjimai":
--   Chrome_Incognito įspėtas direktoriaus 0 kartų
--   Paskutiniai darbo įspėjimai:
--   [2025-10-15 21:11:40] Nedalyvavimas veikloje (nuo dir.)
--   [2022-01-31 21:17:09] Bloga Kaina(01-31 - 20:19:34) (nuo pav.)
-- Grąžina lentelę Data | Priežastis | Davė arba nil, jei formatas kitoks.
function ispejimai.atpazintiLanga(tekstas)
    local t = { antrastes = { "Data", "Priežastis", "Davė" }, eilutes = {}, stulpeliu = 3, santrauka = {} }
    local rasta = false
    for eilute in (tostring(tekstas or "") .. "\n"):gmatch("(.-)\n") do
        local e = apkarpyti(nuimtiSpalvas(eilute))
        local data, priezastis = e:match("^%[(%d%d%d%d%-%d%d%-%d%d %d%d:%d%d:?%d?%d?)%]%s*(.-)$")
        if data then
            rasta = true
            local dave = "-"
            local be, kas = priezastis:match("^(.-)%s*%(nuo%s+(%a+)%.?%)%s*$")
            if be then
                priezastis = be
                kas = kas:lower()
                if kas:find("^dir") then dave = "Direktorius"
                elseif kas:find("^pav") then dave = "Pavaduotojas"
                else dave = u8(kas) end
            end
            t.eilutes[#t.eilutes + 1] = { data, u8(priezastis), dave }
        elseif e ~= "" and not e:find("^Paskutiniai") then
            local kartu = e:match("(%d+)%s+kart")
            if kartu then t.ispetas = tonumber(kartu) end
            t.santrauka[#t.santrauka + 1] = u8(e)
        end
    end
    -- be "[data]" eilučių ir su stulpeliais (\t) - kitoks langas, jį atpažins bendras būdas
    if not rasta and (#t.santrauka == 0 or tostring(tekstas):find("\t", 1, true)) then return nil end
    return t
end

-- serverio atsakymas -> lentelė (UTF-8). Lange: stulpeliai pagal \t, stilius 5 = pirma eilutė antraštės.
-- Chate: kiekviena eilutė atskirai.
function ispejimai.lentele(r)
    local t = { antrastes = nil, eilutes = {}, stulpeliu = 1 }
    local function langeliai(eilute)
        local sar = {}
        for x in (eilute .. "\t"):gmatch("(.-)\t") do
            local pavyko, u = pcall(u8, apkarpyti(nuimtiSpalvas(x)))
            sar[#sar + 1] = pavyko and u or x
        end
        while #sar > 0 and sar[#sar] == "" do sar[#sar] = nil end
        return sar
    end
    if r.langas then
        local tikras = ispejimai.atpazintiLanga(r.langas.tekstas)
        if tikras then return tikras end
        local eilutes = {}
        for e in (tostring(r.langas.tekstas or "") .. "\n"):gmatch("(.-)\n") do
            if apkarpyti(nuimtiSpalvas(e)) ~= "" then eilutes[#eilutes + 1] = e end
        end
        local pradzia = 1
        if r.langas.stilius == 5 and #eilutes > 0 then
            t.antrastes = langeliai(eilutes[1])
            pradzia = 2
        end
        for i = pradzia, #eilutes do
            local l = langeliai(eilutes[i])
            if #l > 0 then t.eilutes[#t.eilutes + 1] = l end
        end
        local pavyko, u = pcall(u8, apkarpyti(nuimtiSpalvas(tostring(r.langas.antraste or ""))))
        t.pavadinimas = pavyko and u or nil
    else
        for _, e in ipairs(r.eilutes) do t.eilutes[#t.eilutes + 1] = langeliai(e) end
    end
    t.stulpeliu = t.antrastes and #t.antrastes or 1
    for _, l in ipairs(t.eilutes) do t.stulpeliu = math.max(t.stulpeliu, #l) end
    return t
end

-- neapdorotas serverio atsakymas į failą, kad būtų galima patobulinti atpažinimą
function ispejimai.issaugotiDerinima(nickas, darbas, r)
    if not nust.zurnalas then return end
    local f = io.open(FAILAI.ispejimai, "w")
    if not f then return end
    local function utf(x) local pavyko, u = pcall(u8, tostring(x or "")) return pavyko and u or tostring(x) end
    f:write("DPKT meniu v" .. tostring(thisScript().version) .. " - /ispejimai derinimo žurnalas\n")
    f:write("Laikas: " .. os.date("%Y-%m-%d %H:%M:%S") .. ", nickas: " .. nickas .. ", darbas: " .. darbas .. "\n")
    f:write(string.rep("=", 70) .. "\n")
    for _, e in ipairs(r.eilutes) do f:write("CHAT | " .. utf(e) .. "\n") end
    if r.langas then
        f:write(string.format("DIALOG stilius=%s antraštė: %s\n", tostring(r.langas.stilius), utf(r.langas.antraste)))
        for e in (tostring(r.langas.tekstas) .. "\n"):gmatch("(.-)\n") do f:write("    " .. utf(e) .. "\n") end
    end
    if not r.langas and #r.eilutes == 0 then f:write("(serveris neatsakė)\n") end
    f:close()
end

-- darbas: { pavadinimas, id }; atsitiktinai = Dev režimo atsitiktiniai duomenys (be serverio)
function ispejimai.tikrinti(nickas, darbas, atsitiktinai)
    local L = { nickas = nickas, darbas = darbas.pavadinimas, busena = "vyksta", atidarytas = new.bool(true),
                fokusas = true, atsitiktiniai = atsitiktinai }
    if atsitiktinai then
        L.lentele, L.busena, L.gauta = ispejimai.atsitiktine(nickas), "gauta", os.date("%Y-%m-%d %H:%M")
        ispejimai.langas = L
        return
    end
    if uzimtas then klaida("Palauk, kol baigsis ankstesnis veiksmas.") return end
    local as = manoNickas()
    if not as then klaida("Nepavyko gauti tavo ID.") return end
    ispejimai.langas = L
    uzimtas = true
    pradetiEiga(string.format("Įspėjimų istorija: %s (%s)", nickas, darbas.pavadinimas), 3)
    prieiga.klaida = nil
    lua_thread.create(function()
        local function nutraukti()
            L.busena = "nutraukta"
            return nutrauktiPatikra(as)
        end
        siusti(string.format(KOMANDOS.direktorius, as, 0))
        pranesimas("Nuimiau esamą direktorių, jei toks buvo.")
        wait(PAUZE)
        if prieiga.klaida then return nutraukti() end
        eiga.dabar = 1
        siusti(string.format(KOMANDOS.direktorius, as, darbas.id))
        pranesimas(string.format("Skyrei sau %s direktorių patikrinti %s įspėjimus.", darbas.pavadinimas, nickas))
        wait(PAUZE)
        if prieiga.klaida then return nutraukti() end
        eiga.dabar = 2

        local pradzia = localClock()
        rinkimas.ispejimai = { eilutes = {}, paskutine = pradzia }
        siusti(string.format(KOMANDOS.ispejimai, nickas))
        while true do
            wait(100)
            local r, dabar = rinkimas.ispejimai, localClock()
            if not r or r.langas or prieiga.klaida or (#r.eilutes > 0 and dabar - r.paskutine >= LAUKTI_PO_EILUTES)
                    or dabar - pradzia >= LAUKTI_ILGIAUSIAI then
                break
            end
        end
        if prieiga.klaida then return nutraukti() end
        local r = rinkimas.ispejimai or { eilutes = {} }
        rinkimas.ispejimai = nil
        ispejimai.issaugotiDerinima(nickas, darbas.pavadinimas, r)
        if r.langas or #r.eilutes > 0 then
            L.lentele, L.busena = ispejimai.lentele(r), "gauta"
        else
            L.busena = "neatsake"
            klaida("Negautas atsakymas į /ispejimai.")
        end
        L.gauta = os.date("%Y-%m-%d %H:%M")

        siusti(string.format(KOMANDOS.direktorius, as, 0))
        pranesimas("Nuimiau direktorių.")
        uzimtas = false
        baigtiEiga()
    end)
end

-- Darbo analizė: užsideda darbo direktorių, /dfondas + /visidarbuotojai, nusiima,
-- tada atidaro langą su to darbo analize (darboAnalize.langas).
local darboAnalize = { langas = nil }

-- pažymi direktorių ir pavaduotoją pagal paskutinę /direkt lentelę
function darboAnalize.pazymetiPareigas(eilutes, darboId)
    if not duomenys.direkt then return end
    for _, d in ipairs(duomenys.direkt.eilutes or {}) do
        if d.id == darboId then
            for _, e in ipairs(eilutes) do
                if d.direktorius and e.nickas == d.direktorius then e.pareigos = "dir"
                elseif d.pavaduotojas and e.nickas == d.pavaduotojas then e.pareigos = "pav" end
            end
        end
    end
end

-- naujai surinkta informacija papildo išsaugotus Darbuotojų ir Fondų duomenis
function darboAnalize.atnaujintiIssaugotus(darbas, eilutes, fondas, data)
    local laikas = os.date("%Y-%m-%d %H:%M")
    local d = duomenys.darbuotojai
    if d and d.data == (data or os.date(DATOS_FORMATAS)) then
        for _, x in ipairs(d.darbai or {}) do
            if x.id == darbas.id then x.eilutes, x.surinkta = eilutes, laikas end
        end
        rasytiJson(FAILAI.darbuotojai, d)
    end
    local f = duomenys.fondai
    if f and fondas then
        for _, x in ipairs(f.darbai or {}) do
            if x.id == darbas.id then x.suma = fondas end
        end
        rasytiJson(FAILAI.fondai, f)
    end
end

-- Dev režimui: atsitiktinė analizė be serverio (data: nil = šiandien)
function darboAnalize.atsitiktine(darbas, data)
    darboAnalize.langas = {
        darbas = darbas.pavadinimas, id = darbas.id, busena = "gauta", atidarytas = new.bool(true), fokusas = true,
        atsitiktiniai = true, gauta = os.date("%Y-%m-%d %H:%M"), data = data or os.date(DATOS_FORMATAS),
        fondas = math.random(1000, 999999) * 1000 + math.random(0, 999),
        eilutes = atsitiktiniaiDarbuotojai(darbas.id, data ~= nil),
    }
end

-- data: nil = šiandien, kitaip /visidarbuotojai <data> (fondas visada dabartinis)
function darboAnalize.tikrinti(darbas, data)
    if uzimtas then klaida("Palauk, kol baigsis ankstesnis veiksmas.") return end
    local as = manoNickas()
    if not as then klaida("Nepavyko gauti tavo ID.") return end
    uzimtas = true
    pradetiEiga(darbas.pavadinimas .. ": darbo analizė", 4, true)
    prieiga.klaida = nil
    lua_thread.create(function()
        siusti(string.format(KOMANDOS.direktorius, as, 0))
        pranesimas("Nuimiau esamą direktorių, jei toks buvo.")
        wait(PAUZE)
        if prieiga.klaida then return nutrauktiPatikra(as) end
        eiga.dabar = 1
        siusti(string.format(KOMANDOS.direktorius, as, darbas.id))
        pranesimas(string.format("Skyrei sau %s direktorių darbo analizei (/dfondas ir /visidarbuotojai%s).",
            darbas.pavadinimas, data and (" " .. data) or ""))
        wait(PAUZE)
        if prieiga.klaida then return nutrauktiPatikra(as) end

        -- fondas
        eiga.dabar = 2
        rinkimas.fondas = {}
        local pradzia = localClock()
        siusti("/dfondas")
        while not rinkimas.fondas.suma and localClock() - pradzia < LAUKTI_ILGIAUSIAI and not prieiga.klaida do
            wait(100)
        end
        if prieiga.klaida then return nutrauktiPatikra(as) end
        local fondas = rinkimas.fondas.suma and sumaIsTeksto(rinkimas.fondas.suma) or nil
        rinkimas.fondas = nil
        if not fondas then klaida("Negautas atsakymas į /dfondas.") end
        wait(PAUZE)

        -- darbuotojai
        eiga.dabar = 3
        pradzia = localClock()
        rinkimas.darbuotojai = { eilutes = {}, paskutine = pradzia }
        siusti(data and string.format(KOMANDOS.visidarbuotojaiData, data) or "/visidarbuotojai")
        while true do
            wait(100)
            local r, dabar = rinkimas.darbuotojai, localClock()
            if r.langas or (#r.eilutes > 0 and dabar - r.paskutine >= LAUKTI_PO_EILUTES)
                or dabar - pradzia >= LAUKTI_ILGIAUSIAI or prieiga.klaida then
                break
            end
        end
        if prieiga.klaida then return nutrauktiPatikra(as) end
        local eilutes = sujungtiDarbuotojus(rinkimas.darbuotojai.eilutes, rinkimas.darbuotojai.langas)
        rinkimas.darbuotojai = nil
        darboAnalize.pazymetiPareigas(eilutes, darbas.id)

        siusti(string.format(KOMANDOS.direktorius, as, 0))
        pranesimas("Nuimiau direktorių.")
        darboAnalize.atnaujintiIssaugotus(darbas, eilutes, fondas, data)
        pranesimas(string.format("%s darbo analizė baigta: %d darbuotojų.", darbas.pavadinimas, #eilutes))
        darboAnalize.langas = {
            darbas = darbas.pavadinimas, id = darbas.id, busena = "gauta", atidarytas = new.bool(true),
            fokusas = true, gauta = os.date("%Y-%m-%d %H:%M"), fondas = fondas, eilutes = eilutes,
            data = data or os.date(DATOS_FORMATAS),
        }
        uzimtas = false
        baigtiEiga()
    end)
end

-- Event skiltis: mafijų/gaujų, teisėsaugos ir event fondai (/mgfondas, /tfondas, /efondas)
-- ir pinigų davimas iš jų (/mgduoti, /tduoti, /eduoti).
local eventFondai = {
    SARASAS = {
        { id = "mg", pavadinimas = "Mafijų, gaujų", komanda = "/mgfondas", duoti = "/mgduoti %s %d" },
        { id = "t",  pavadinimas = "Teisėsaugos",   komanda = "/tfondas",  duoti = "/tduoti %s %d" },
        { id = "e",  pavadinimas = "Event",         komanda = "/efondas",  duoti = "/eduoti %s %d" },
    },
    -- serverio vidiniai įrašai (ne žaidėjai) - jų pasirinkti neleidžiam
    SISTEMINIAI = { ["js mafia_blist"] = true },
    aktyvus = "mg",
    duomenys = {},     -- [id] = { likutis, irasai = { { data, vardas, suma } }, gauta, atsitiktiniai }
    kraunama = nil,    -- id, kol laukiama serverio atsakymo
    klaida = {},       -- [id] = tekstas
    matomas = false,   -- ar skiltis rodoma (kad atidarius užklausa būtų siunčiama tik vieną kartą)
    paieska = new.char[32](),
    nickas = new.char[32](),
    suma = new.char[24](),
}

-- ar įrašo "Vardas" yra žaidėjas: ne vidinis serverio įrašas ir be tarpų (nickai tarpų neturi)
function eventFondai.zaidejas(vardas)
    vardas = tostring(vardas or "")
    return vardas ~= "" and not vardas:find("%s") and not eventFondai.SISTEMINIAI[vardas:lower()]
end

function eventFondai.pagalId(id)
    for _, f in ipairs(eventFondai.SARASAS) do if f.id == id then return f end end
end

-- lango tekstas (cp1257) -> įrašai: "2026-10-24 19:07:42 \t Steel_Ghost \t {FF0000}-800.000.000"
function eventFondai.atpazinti(antraste, tekstas)
    local r = { irasai = {}, gauta = os.date("%Y-%m-%d %H:%M") }
    local likutis = nuimtiSpalvas(tostring(antraste or "")):match("fonde:%s*([%d%.,]+)")
    if likutis then r.likutis = sumaIsTeksto(likutis) end
    for eilute in (tostring(tekstas or "") .. "\n"):gmatch("(.-)\n") do
        local l = {}
        for x in (eilute .. "\t"):gmatch("(.-)\t") do l[#l + 1] = apkarpyti(nuimtiSpalvas(x)) end
        if l[1] and l[1]:match("^%d%d%d%d%-%d%d%-%d%d") and l[3] then
            local neig = l[3]:find("^%-") ~= nil
            local suma = sumaIsTeksto((l[3]:gsub("[^%d]", "")))
            r.irasai[#r.irasai + 1] = { data = l[1], vardas = u8(l[2] or ""), suma = neig and -suma or suma }
        end
    end
    return r
end

-- Dev režimui
function eventFondai.atsitiktiniai(id)
    local r = { irasai = {}, gauta = os.date("%Y-%m-%d %H:%M"), atsitiktiniai = true,
                likutis = id == "mg" and 0 or math.random(1, 9999) * 10000 }
    local laikas = os.time()
    for _ = 1, math.random(12, 25) do
        laikas = laikas - math.random(600, 6 * 86400)
        local suma
        if id == "t" and math.random() < 0.8 then suma = 5000000
        elseif math.random() < 0.25 then suma = math.random(1, 100) * 10000
        else suma = -math.random(1, 200) * 500000 end
        local vardas = VARDAI[math.random(#VARDAI)] .. "_" .. PAVARDES[math.random(#PAVARDES)]
        if id == "mg" and math.random() < 0.15 then vardas = "JS mafia_blist" end
        r.irasai[#r.irasai + 1] = { data = os.date("%Y-%m-%d %H:%M:%S", laikas), vardas = vardas, suma = suma }
    end
    return r
end

-- išsiunčia /mgfondas (ar kt.) ir laukia lango; chato eilutė ir langas paslepiami
function eventFondai.atnaujinti(id)
    local f = eventFondai.pagalId(id)
    if not f then return end
    if uzimtas or rinkimas.efondas then klaida("Palauk, kol baigsis ankstesnis veiksmas.") return end
    eventFondai.kraunama, eventFondai.klaida[id] = id, nil
    prieiga.klaida = nil
    rinkimas.efondas = { id = id }
    siusti(f.komanda)
    lua_thread.create(function()
        local pradzia = localClock()
        while rinkimas.efondas and not rinkimas.efondas.langas and not prieiga.klaida
                and localClock() - pradzia < LAUKTI_ILGIAUSIAI do
            wait(100)
        end
        local r = rinkimas.efondas
        rinkimas.efondas, eventFondai.kraunama = nil, nil
        if prieiga.klaida then
            eventFondai.klaida[id] = "Neturi prieigos prie " .. f.komanda .. "."
        elseif r and r.langas then
            local d = eventFondai.atpazinti(r.langas.antraste, r.langas.tekstas)
            d.likutis = d.likutis or r.likutis
            eventFondai.duomenys[id] = d
        else
            eventFondai.klaida[id] = "Negautas atsakymas į " .. f.komanda .. "."
            klaida(eventFondai.klaida[id])
        end
    end)
end

-- /mgduoti nickas suma (ar kt.), tada fondas atnaujinamas
function eventFondai.duoti(id, nickas, suma)
    local f = eventFondai.pagalId(id)
    local d = eventFondai.duomenys[id]
    local komanda = string.format(f.duoti, nickas, suma)
    if d and d.atsitiktiniai then
        pranesimas(string.format("Dev režimas: būtų išsiųsta %s (atsitiktiniai duomenys, nieko nesiųsta).", komanda))
        return
    end
    if uzimtas or rinkimas.efondas then klaida("Palauk, kol baigsis ankstesnis veiksmas.") return end
    siusti(komanda)
    pranesimas(string.format("Davei %s € iš %s fondo žaidėjui %s (%s).", formatuotiSuma(suma), f.pavadinimas, nickas, komanda))
    lua_thread.create(function()
        wait(PAUZE)
        if not prieiga.klaida then eventFondai.atnaujinti(id) end
    end)
end

local function rinktiDarbuotojus(data)
    if uzimtas then klaida("Palauk, kol baigsis ankstesnis veiksmas.") return end
    local as = manoNickas()
    if not as then klaida("Nepavyko gauti tavo ID.") return end
    uzimtas = true
    pradetiEiga(data and ("Renkami darbuotojai už " .. data) or "Renkami darbuotojai", #DIREKTORIU_DARBAI, true)
    prieiga.klaida = nil
    if nust.zurnalas then
        zurnalas = { pradzia = os.date("%Y-%m-%d %H:%M:%S"), t0 = localClock(), nickas = as, eilutes = {},
                     data = data or "šiandien" }
    end
    lua_thread.create(function()
        local rezultatas = { darbai = {} }
        perspejimas()
        siusti(string.format(KOMANDOS.direktorius, as, 0))
        pranesimas("Nuimiau esamą direktorių, jei toks buvo.")
        wait(PAUZE)
        if prieiga.klaida then return nutrauktiPatikra(as) end

        -- /direkt: kas kurio darbo direktorius ir pavaduotojas, kad juos pažymėtume
        eiga.tekstas = "Gaunama /direkt lentelė"
        rinkimas.direkt = {}
        local direktPradzia = localClock()
        siusti("/direkt")
        while not rinkimas.direkt.gauta and localClock() - direktPradzia < LAUKTI_ILGIAUSIAI and not prieiga.klaida do
            wait(100)
        end
        local direktGauta = rinkimas.direkt.gauta
        rinkimas.direkt = nil
        if prieiga.klaida == "/direkt" then
            prieiga.klaida = nil          -- be /direkt renkam toliau, tik nepažymim direktorių
        elseif prieiga.klaida then
            return nutrauktiPatikra(as)
        end
        local pareigos = {}
        if direktGauta and duomenys.direkt then
            for _, e in ipairs(duomenys.direkt.eilutes) do
                if e.id then pareigos[e.id] = { dir = e.direktorius, pav = e.pavaduotojas } end
            end
        else
            klaida("Nepavyko gauti /direkt lentelės, direktoriai ir pavaduotojai nebus pažymėti.")
        end
        wait(PAUZE)

        for i, darbas in ipairs(DIREKTORIU_DARBAI) do
            eiga.dabar = i - 1
            eiga.tekstas = "Renkami darbuotojai: " .. darbas.pavadinimas
            if zurnalas then
                zurnalas.eilutes[#zurnalas.eilutes + 1] = ""
                zurnalas.eilutes[#zurnalas.eilutes + 1] = string.format("========== %d/%d  %s (direktoriaus ID %d) ==========",
                    i, #DIREKTORIU_DARBAI, darbas.pavadinimas, darbas.id)
            end
            siusti(string.format(KOMANDOS.direktorius, as, darbas.id))
            pranesimas(string.format("Skyrei sau %s direktorių patikrinti /visidarbuotojai%s (%d/%d).",
                darbas.pavadinimas, data and (" " .. data) or "", i, #DIREKTORIU_DARBAI))
            wait(PAUZE)
            if prieiga.klaida then return nutrauktiPatikra(as) end

            local pradzia = localClock()
            rinkimas.darbuotojai = { eilutes = {}, paskutine = pradzia }
            siusti(data and string.format(KOMANDOS.visidarbuotojaiData, data) or "/visidarbuotojai")
            while true do
                wait(100)
                local r, dabar = rinkimas.darbuotojai, localClock()
                -- langas "Darbuotojai" ateina po visų chato eilučių, tad tai pabaigos ženklas
                if r.langas or (#r.eilutes > 0 and dabar - r.paskutine >= LAUKTI_PO_EILUTES)
                    or dabar - pradzia >= LAUKTI_ILGIAUSIAI or prieiga.klaida then
                    break
                end
            end
            if prieiga.klaida then return nutrauktiPatikra(as) end
            local eilutes = sujungtiDarbuotojus(rinkimas.darbuotojai.eilutes, rinkimas.darbuotojai.langas)
            local p = pareigos[darbas.id]
            if p then
                for _, e in ipairs(eilutes) do
                    if p.dir and e.nickas == p.dir then e.pareigos = "dir"
                    elseif p.pav and e.nickas == p.pav then e.pareigos = "pav" end
                end
            end
            rezultatas.darbai[#rezultatas.darbai + 1] = {
                pavadinimas = darbas.pavadinimas, id = darbas.id,
                eilutes = eilutes, surinkta = os.date("%Y-%m-%d %H:%M"),
            }
            if zurnalas then
                local pilnos, nukirptos, isLango = 0, 0, 0
                for _, e in ipairs(eilutes) do
                    if e.isLango then isLango = isLango + 1
                    elseif e.nukirpta then nukirptos = nukirptos + 1
                    else pilnos = pilnos + 1 end
                end
                zurnalas.eilutes[#zurnalas.eilutes + 1] = string.format(
                    "---------- Rezultatas: %d pilnos, %d nukirptos (papildyta iš lango), %d tik iš lango, langas: %s ----------",
                    pilnos, nukirptos, isLango, rinkimas.darbuotojai.langas and "gautas" or "negautas")
            end
            rinkimas.darbuotojai = nil
        end

        siusti(string.format(KOMANDOS.direktorius, as, 0))
        pranesimas("Nuimiau direktorių.")
        rezultatas.surinkta = os.date("%Y-%m-%d %H:%M")
        rezultatas.data = data or os.date(DATOS_FORMATAS)
        duomenys.darbuotojai = rezultatas
        atsitiktiniai.darbuotojaiPirmenybe = nil
        if rasytiJson(FAILAI.darbuotojai, rezultatas) then
            pranesimas("Darbuotojų informacija išsaugota.")
        else
            klaida("Nepavyko išsaugoti informacijos į diską.")
        end
        issaugotiZurnala("baigta")
        uzimtas = false
        baigtiEiga()
    end)
end

local function rinktiFondus()
    if uzimtas then klaida("Palauk, kol baigsis ankstesnis veiksmas.") return end
    local as = manoNickas()
    if not as then klaida("Nepavyko gauti tavo ID.") return end
    uzimtas = true
    pradetiEiga("Renkami fondai", #DIREKTORIU_DARBAI, true)
    prieiga.klaida = nil
    lua_thread.create(function()
        local rezultatas = { darbai = {} }
        perspejimas()
        siusti(string.format(KOMANDOS.direktorius, as, 0))
        pranesimas("Nuimiau esamą direktorių, jei toks buvo.")
        wait(PAUZE)
        if prieiga.klaida then return nutrauktiPatikra(as) end

        for i, darbas in ipairs(DIREKTORIU_DARBAI) do
            eiga.dabar = i - 1
            eiga.tekstas = "Renkami fondai: " .. darbas.pavadinimas
            siusti(string.format(KOMANDOS.direktorius, as, darbas.id))
            pranesimas(string.format("Skyrei sau %s direktorių patikrinti /dfondas (%d/%d).",
                darbas.pavadinimas, i, #DIREKTORIU_DARBAI))
            wait(PAUZE)
            if prieiga.klaida then return nutrauktiPatikra(as) end

            rinkimas.fondas = {}
            local pradzia = localClock()
            siusti("/dfondas")
            while not rinkimas.fondas.suma and localClock() - pradzia < LAUKTI_ILGIAUSIAI and not prieiga.klaida do
                wait(100)
            end
            if prieiga.klaida then return nutrauktiPatikra(as) end
            local irasas = { pavadinimas = darbas.pavadinimas, id = darbas.id }
            irasas.suma = rinkimas.fondas.suma and sumaIsTeksto(rinkimas.fondas.suma) or 0
            rezultatas.darbai[#rezultatas.darbai + 1] = irasas
            rinkimas.fondas = nil
            wait(PAUZE)
        end

        siusti(string.format(KOMANDOS.direktorius, as, 0))
        pranesimas("Nuimiau direktorių.")
        rezultatas.surinkta = os.date("%Y-%m-%d %H:%M")
        duomenys.fondai = rezultatas
        if rasytiJson(FAILAI.fondai, rezultatas) then
            pranesimas("Darbų fondų informacija išsaugota.")
        else
            klaida("Nepavyko išsaugoti informacijos į diską.")
        end
        uzimtas = false
        baigtiEiga()
    end)
end

-- Darbo statistika aktyvumui: kiek ko žaidėjas surinko darbe kiekvieną dieną
-- (baudos, atvykimai, pagydymai ir t.t.) iš /visidarbuotojai <data>.
local darboStatistika = {
    -- šių laukų aktyvumo lentelėje nerodom (ne dienos statistika)
    NERODYTI = { ["Priimtas"] = true, ["Rangas"] = true, ["Įspėjimai"] = true },
    talpykla = { nickas = nil, saltinis = nil, darbas = nil },
}

-- darbas, kuriame žaidėjas yra pagal surinktus Darbuotojų duomenis (Dev režime ir atsitiktinius)
function darboStatistika.rasti(nickas)
    local saltinis = duomenys.darbuotojai or (nust.dev and atsitiktiniai.darbuotojai) or nil
    local t = darboStatistika.talpykla
    if t.nickas == nickas and t.saltinis == saltinis then return t.darbas end
    local rastas = nil
    if saltinis and nickas ~= "" then
        local mazas = nickas:lower()
        for _, d in ipairs(saltinis.darbai or {}) do
            for _, e in ipairs(d.eilutes or {}) do
                if e.nickas and e.nickas:lower() == mazas then rastas = darbasPagalId(d.id) break end
            end
            if rastas then break end
        end
    end
    t.nickas, t.saltinis, t.darbas = nickas, saltinis, rastas
    return rastas
end

-- darbuotojo eilutės laukai be Priimtas/Rangas/Įspėjimai
function darboStatistika.laukai(e)
    local r = {}
    for _, l in ipairs(e.laukai or {}) do
        if not darboStatistika.NERODYTI[l[1]] then r[#r + 1] = { l[1], l[2] } end
    end
    return r
end

-- visų dienų laukų pavadinimai pagal pirmą pasirodymą
function darboStatistika.stulpeliai(r)
    local sar, yra = {}, {}
    for _, d in ipairs(r.dienos or {}) do
        for _, l in ipairs(d.darbas or {}) do
            if not yra[l[1]] then yra[l[1]] = true; sar[#sar + 1] = l[1] end
        end
    end
    return sar
end

-- reikšmių suma (ar vidurkis): skaičiai sudedami pagal vietą, pvz. "113min" + "20min" = "133min",
-- "431 / 203 min" + "10 / 5 min" = "441 / 208 min". Kitokio formato reikšmės praleidžiamos.
function darboStatistika.sumuoti(reiksmes, dalinti)
    local sumos, sablonas, kiek = {}, nil, nil
    for _, v in ipairs(reiksmes) do
        local sk = {}
        local s = tostring(v):gsub("%d[%d%.]*", function(x) sk[#sk + 1] = sumaIsTeksto(x) return "\1" end)
        if #sk > 0 then
            if not sablonas then sablonas, kiek = s, #sk end
            if #sk == kiek then for i = 1, kiek do sumos[i] = (sumos[i] or 0) + sk[i] end end
        end
    end
    if not sablonas then return "-" end
    local i = 0
    return (sablonas:gsub("\1", function()
        i = i + 1
        local x = sumos[i] or 0
        if dalinti then x = math.floor(x / dalinti + 0.5) end
        return formatuotiSuma(x)
    end))
end

-- darbas: { pavadinimas, id } arba nil (be darbo statistikos)
local function tikrintiAktyvuma(nickas, nuo, iki, darbas)
    if uzimtas then klaida("Palauk, kol baigsis ankstesnis veiksmas.") return end
    local as = nil
    if darbas then
        as = manoNickas()
        if not as then
            klaida("Nepavyko gauti tavo ID, darbo statistika nebus renkama.")
            darbas = nil
        end
    end
    local dienu = math.floor((iki - nuo) / 86400 + 0.5) + 1
    local nuoTekstu, ikiTekstu = os.date(DATOS_FORMATAS, nuo), os.date(DATOS_FORMATAS, iki)
    uzimtas = true
    pradetiEiga(string.format("Tikrinamas %s aktyvumas", nickas), dienu, true)
    prieiga.klaida = nil
    lua_thread.create(function()
        local sekundziu = math.ceil(dienu * 0.3 + (dienu - 1) * PAUZE / 1000)
        if darbas then sekundziu = sekundziu + math.ceil(dienu * (0.3 + PAUZE / 1000) + 3 * PAUZE / 1000) end
        pranesimas(string.format("Tikrinu %s aktyvumą nuo %s iki %s (%d d.).",
            nickas, nuoTekstu, ikiTekstu, dienu))
        if darbas then
            pranesimas(string.format("Renku ir %s darbo statistiką (/visidarbuotojai kiekvienai dienai).", darbas.pavadinimas))
        end
        pranesimas(string.format("Patikra truks apie ~%d s.", sekundziu))
        perspejimas()

        -- darbo statistikai reikia to darbo direktoriaus
        if darbas then
            siusti(string.format(KOMANDOS.direktorius, as, 0))
            pranesimas("Nuimiau esamą direktorių, jei toks buvo.")
            wait(PAUZE)
            if prieiga.klaida then return nutrauktiPatikra(as) end
            siusti(string.format(KOMANDOS.direktorius, as, darbas.id))
            pranesimas(string.format("Skyrei sau %s direktorių darbo statistikai.", darbas.pavadinimas))
            wait(PAUZE)
            if prieiga.klaida then return nutrauktiPatikra(as) end
        end

        local r = { dienos = {}, visoMin = 0, visoKm = 0, visoZuvys = 0, neatsake = 0,
                    darbas = darbas and darbas.pavadinimas or nil }
        for i = 0, dienu - 1 do
            eiga.dabar = i
            local data = os.date(DATOS_FORMATAS, nuo + i * 86400)
            rinkimas.info = {}
            local pradzia = localClock()
            siusti(string.format(KOMANDOS.info, nickas, data))
            while not rinkimas.info.minutes and localClock() - pradzia < LAUKTI_ILGIAUSIAI and not prieiga.klaida do
                wait(100)
            end
            if prieiga.klaida then return nutrauktiPatikra(as) end
            -- chate kitos eilutės gali ateiti kiek vėliau
            if rinkimas.info.minutes then
                local terminas = localClock() + 0.3
                while localClock() < terminas and (not rinkimas.info.km or not rinkimas.info.xp
                        or not rinkimas.info.zuvys) do
                    wait(50)
                end
            end
            local info = rinkimas.info
            rinkimas.info = nil

            local diena = { data = data, minutes = info.minutes, km = info.km, xp = info.xp, zuvys = info.zuvys }
            r.dienos[#r.dienos + 1] = diena

            -- tos dienos darbo statistika
            if darbas then
                wait(PAUZE)
                local dPradzia = localClock()
                rinkimas.darbuotojai = { eilutes = {}, paskutine = dPradzia }
                siusti(string.format(KOMANDOS.visidarbuotojaiData, data))
                while true do
                    wait(100)
                    local rd, dabar = rinkimas.darbuotojai, localClock()
                    if rd.langas or (#rd.eilutes > 0 and dabar - rd.paskutine >= LAUKTI_PO_EILUTES)
                        or dabar - dPradzia >= LAUKTI_ILGIAUSIAI or prieiga.klaida then
                        break
                    end
                end
                if prieiga.klaida then return nutrauktiPatikra(as) end
                local visi = sujungtiDarbuotojus(rinkimas.darbuotojai.eilutes, rinkimas.darbuotojai.langas)
                rinkimas.darbuotojai = nil
                local mazas = nickas:lower()
                diena.darbas = {}
                diena.darbeNerastas = true
                for _, e in ipairs(visi) do
                    if e.nickas and e.nickas:lower() == mazas then
                        diena.darbas, diena.darbeNerastas = darboStatistika.laukai(e), nil
                        break
                    end
                end
            end
            if diena.minutes then
                r.visoMin = r.visoMin + diena.minutes
                r.visoKm = r.visoKm + (diena.km or 0)
                r.visoZuvys = r.visoZuvys + (diena.zuvys or 0)
            else
                r.neatsake = r.neatsake + 1
            end
            if i < dienu - 1 then wait(PAUZE) end
        end

        -- patirtis serveryje yra bendra sukaupta
        r.xpPirma = r.dienos[1].xp
        r.xpPaskutine = r.dienos[#r.dienos].xp
        if r.xpPirma and r.xpPaskutine then
            r.xpPokytis = sumaIsTeksto(r.xpPaskutine) - sumaIsTeksto(r.xpPirma)
            if dienu > 1 then r.xpVidurkis = math.floor(r.xpPokytis / (dienu - 1) + 0.5) end
        end

        if darbas then
            siusti(string.format(KOMANDOS.direktorius, as, 0))
            pranesimas("Nuimiau direktorių.")
        end

        atsitiktiniai.aktyvumasPirmenybe = nil   -- tikri duomenys svarbesni už sugeneruotus (Dev)
        duomenys.aktyvumas = {
            antraste = string.format("%s %s - %s", nickas, nuoTekstu, ikiTekstu),
            rezultatas = r, tikrinta = os.date("%Y-%m-%d %H:%M"),
        }
        rasytiJson(FAILAI.aktyvumas, duomenys.aktyvumas)

        pranesimas("Patikra baigta.")
        if r.neatsake > 0 then
            klaida(string.format("%d d. negautas atsakymas į /info, jos įskaičiuotos kaip 0.", r.neatsake))
        end
        uzimtas = false
        baigtiEiga()
        atidarytiMeniu("aktyvumas")
    end)
end

---------------------------------------------------------------- UI: BŪSENA
local ui = {
    atidarytas = new.bool(false),
    skirtukas = "pagrindinis",

    -- blist
    blistTipas = 1,
    blistNickas = new.char[64](),
    blistMenesiai = new.int(12),
    blistPriezastis = new.char[256](),
    blistKlaida = nil,

    -- aktyvumas
    aktNickas = new.char[64](),
    aktDarbas = 0,     -- darbo statistika: 0 = automatiškai, -1 = nerinkti, kitaip darbo (direktoriaus) ID
    aktNuo = new.char[16](),
    aktIki = new.char[16](),
    aktKlaida = nil,

    -- darbuotojai
    paieska = new.char[64](),
    darbData = new.char[16](),
    analizesData = new.char[16](),   -- Darbų patikra: /visidarbuotojai data (tuščia = šiandien)
    darbKlaida = nil,
    zaidejuPaieska = new.char[64](),

    -- paskyrų sutapimas
    sut1 = new.char[64](),
    sut2 = new.char[64](),
    sutKlaida = nil,

    -- direktoriai
    direktPasirinkta = nil,

    -- patvirtinimo langas
    patvirtinimas = nil,      -- { klausimas, veiksmas }
    atidarytiPatvirtinima = false,
}

local function irasyti(buferis, tekstas)
    ffi.copy(buferis, tostring(tekstas or ""))
end

local function skaityti(buferis)
    return apkarpyti(ffi.string(buferis))
end

local SKIRTUKAI = {
    { id = "pagrindinis", pavadinimas = "Pagrindinis" },
    { id = "statusas",    pavadinimas = "Patikros statusas", dinaminis = true },
    { grupe = "Įrankiai" },
    { id = "darbai",      pavadinimas = "Darbų patikra" },
    { id = "keisti",      pavadinimas = "Pakeisti darbą" },
    { id = "blist",       pavadinimas = "Blist" },
    { id = "direktoriai", pavadinimas = "Direktoriai" },
    { grupe = "Analizės įrankiai" },
    { id = "darbuotojai", pavadinimas = "Darbuotojai" },
    { id = "fondai",      pavadinimas = "Darbų fondai" },
    { id = "aktyvumas",   pavadinimas = "Aktyvumas" },
    { id = "sutapimas",   pavadinimas = "Paskyrų sutapimas" },
    { grupe = "Event" },
    { id = "ef_mg",       pavadinimas = "Mafijų, gaujų fondas" },
    { id = "ef_t",        pavadinimas = "Teisėsaugos fondas" },
    { id = "ef_e",        pavadinimas = "Event fondas" },
    { grupe = "Kita" },
    { id = "nustatymai",  pavadinimas = "Nustatymai" },
    { id = "pakeitimai",  pavadinimas = "Pakeitimai" },
}

atidarytiMeniu = function(skirtukas)
    -- kiekvieną kartą atidarius: 1 iš 10, kad Pagrindiniame bus "Kas skaitys tas GD"
    if not ui.atidarytas[0] then
        ui.gd = math.random(10) == 1
        eventFondai.matomas = false   -- Event skiltyje fondas vėl atnaujinamas
    end
    if skirtukas then
        ui.skirtukas = skirtukas
        statusas.perjungti = false   -- aiškiai nurodytas skirtukas svarbesnis už "Patikros statusas"
    end
    ui.atidarytas[0] = true
end

-- /arsutapo be dviejų paskyrų: serveris atsako "Tokios komandos nėra", todėl tokios
-- komandos neišsiunčiam, o atidarom Paskyrų sutapimo skiltį (su vienu nicku - jį įrašom).
-- Su dviem paskyromis komanda keliauja serveriui, o jo langą perima onShowDialog.
-- Veikia tik su įjungtu nustatymu "Rodyti /arsutapo DPKT meniu lange".
function sampev.onSendCommand(komanda)
    local pavadinimas, argumentai = tostring(komanda or ""):match("^/(%S+)%s*(.-)%s*$")
    -- /noriudarbo be ID atidaro "Pakeisti darbą" (su ID - keliauja serveriui, kaip ir scripto mygtukai)
    if nust.perimtiNoriudarbo and pavadinimas
            and pavadinimas:lower() == KOMANDOS.darboKeitimas:match("^/(%S+)"):lower() and argumentai == "" then
        atidarytiMeniu("keisti")
        return false
    end
    if not nust.perimtiArsutapo then return end   -- išjungta: viskas eina serveriui
    if not pavadinimas or pavadinimas:lower() ~= "arsutapo" then return end
    local zodziai = {}
    for z in argumentai:gmatch("%S+") do zodziai[#zodziai + 1] = z end
    if #zodziai >= 2 then return end
    if zodziai[1] then
        local nickas = u8(zodziai[1])
        if skaityti(ui.sut1) == "" or skaityti(ui.sut1) == nickas then irasyti(ui.sut1, nickas)
        else irasyti(ui.sut2, nickas) end
    end
    ui.sutKlaida = nil
    atidarytiMeniu("sutapimas")
    return false
end

local function paklausti(klausimas, veiksmas)
    ui.patvirtinimas = { klausimas = klausimas, veiksmas = veiksmas }
    ui.atidarytiPatvirtinima = true
end

---------------------------------------------------------------- UI: PAGALBINĖS
local SPALVA_ZALIA   = imgui.ImVec4(0.30, 0.85, 0.30, 1.00)
local SPALVA_RAUDONA = imgui.ImVec4(1.00, 0.30, 0.30, 1.00)
local SPALVA_GELTONA = imgui.ImVec4(1.00, 0.82, 0.30, 1.00)

local function langoAlfa()
    imgui.GetStyle().Colors[imgui.Col.WindowBg] = imgui.ImVec4(0, 0, 0, nust.langoAlfa)
end

local function duomenuBusena(d)
    if d.surinkta then
        imgui.TextDisabled((("Duomenys surinkti: " .. d.surinkta):gsub("%%", "%%%%")))
    elseif d.atsitiktiniai then
        imgui.TextColored(SPALVA_GELTONA, "Dev režimas: rodomi atsitiktiniai duomenys.")
    else
        imgui.TextColored(SPALVA_GELTONA, "Informacija dar nesurinkta. Spausk \"Atnaujinti informaciją\".")
    end
end

-- tekstas be printf formatavimo (kad "%" nesugadintų)
local function T(tekstas, spalva)
    tekstas = tostring(tekstas or "")
    if spalva then
        imgui.TextColored(spalva, (tekstas:gsub("%%", "%%%%")))
    else
        imgui.TextUnformatted(tekstas)
    end
end

local function TPilkas(tekstas)
    imgui.TextDisabled((tostring(tekstas or ""):gsub("%%", "%%%%")))
end

local function spalvotasMygtukas(tekstas, spalva, dydis)
    imgui.PushStyleColor(imgui.Col.Button, spalva)
    imgui.PushStyleColor(imgui.Col.ButtonHovered,
        imgui.ImVec4(math.min(spalva.x + 0.1, 1), math.min(spalva.y + 0.1, 1), math.min(spalva.z + 0.1, 1), 1))
    imgui.PushStyleColor(imgui.Col.ButtonActive, spalva)
    local paspausta = imgui.Button(tekstas, dydis or imgui.ImVec2(0, 0))
    imgui.PopStyleColor(3)
    return paspausta
end

local MYGTUKAS_ZALIAS   = imgui.ImVec4(0.15, 0.55, 0.15, 1.00)
local MYGTUKAS_RAUDONAS = imgui.ImVec4(0.65, 0.12, 0.12, 1.00)

local function plotis() return imgui.GetContentRegionAvail().x end

-- Lentelės stulpeliai be tempiamų ribų. imgui leidžia tempti tik stulpelius su rėmeliais,
-- o mūsų pločiai nustatomi kas kadrą, todėl tempiant lentelė "subyrėdavo".
-- Stulpeliai kuriami be rėmelių, o skiriamąsias linijas piešiam patys.
local lentelesLinijos = nil
local function lentelesStulpeliai(kiek, id, linijos)
    imgui.Columns(kiek, id, false)
    if linijos and kiek > 1 then
        lentelesLinijos = { kiek = kiek, y = imgui.GetCursorScreenPos().y }
    else
        lentelesLinijos = nil
    end
end

local function stulpeliuPabaiga()
    local l = lentelesLinijos
    lentelesLinijos = nil
    if l then
        local wp, ws = imgui.GetWindowPos(), imgui.GetWindowSize()
        local y2 = imgui.GetCursorScreenPos().y - imgui.GetStyle().ItemSpacing.y
        if y2 > l.y then
            local dl = imgui.GetWindowDrawList()
            local spalva = imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.Separator])
            dl:PushClipRect(wp, imgui.ImVec2(wp.x + ws.x, wp.y + ws.y), false)
            for n = 1, l.kiek - 1 do
                local x = math.floor(wp.x + imgui.GetColumnOffset(n)) + 0.5
                dl:AddLine(imgui.ImVec2(x, l.y), imgui.ImVec2(x, y2), spalva)
            end
            dl:PopClipRect()
        end
    end
    imgui.Columns(1)
end

-- pirmojo stulpelio plotis pagal ilgiausią tekstą
local function stulpelioPlotis(sarasas, min)
    local w = min or 0
    for _, k in ipairs(sarasas) do w = math.max(w, imgui.CalcTextSize(k[1]).x) end
    return w + 20
end

local function eigosJuosta()
    if not eiga.tekstas then return false end
    local dalis = eiga.viso > 0 and (eiga.dabar / eiga.viso) or 0
    imgui.ProgressBar(dalis, imgui.ImVec2(-1, 0),
        string.format("%s (%d/%d)", eiga.tekstas, eiga.dabar, eiga.viso))
    return true
end

-- tekstas į iškarpinę (imgui tikisi UTF-8, Windows'e išlieka lietuviškos raidės ir €)
local kopijavimas = { raktas = nil, t = -10 }

function kopijavimas.kopijuoti(tekstas, raktas)
    if imgui.SetClipboardText then
        imgui.SetClipboardText(tekstas)
    elseif setClipboardText then
        setClipboardText(saugusLtu(tekstas))
    end
    kopijavimas.raktas, kopijavimas.t = raktas, localClock()
end

-- užuomina po pele: "Spausk, kad nukopijuotum" arba "Nukopijuota!"
function kopijavimas.uzuomina(raktas)
    if not imgui.IsItemHovered() then return end
    if kopijavimas.raktas == raktas and localClock() - kopijavimas.t < 1.5 then
        imgui.SetTooltip("Nukopijuota!")
    else
        imgui.SetTooltip("Spausk, kad nukopijuotum eilutę")
    end
end

---------------------------------------------------------------- PAKEITIMAI
-- Po kiekvieno atnaujinimo čia pridedamas naujas įrašas (ir pakeičiamas script_version).
-- Versijų istorija (naujausia viršuje). Rodoma skiltyje „Pakeitimai“.
local PAKEITIMAI = {
    { versija = "2.10.4", pakeitimai = {
        "Fondų išrašuose „JS mafia_blist“ (serverio vidinis įrašas) ir kiti įrašai su tarpais rodomi pilkai ir nepaspaudžiami, jiems pinigų duoti neleidžiama.",
    } },
    { versija = "2.10.3", pakeitimai = {
        "Nustatymuose varnelė „/noriudarbo be ID atidaro „Pakeisti darbą““, pagal nutylėjimą išjungta – pirmenybė serverio komandai.",
    } },
    { versija = "2.10.2", pakeitimai = {
        "Parašius /noriudarbo (be ID) atsidaro „Pakeisti darbą“. Su ID komanda keliauja serveriui kaip anksčiau.",
    } },
    { versija = "2.10.1", pakeitimai = {
        "„Event“ dabar atskira meniu grupė su trimis skiltimis: Mafijų, gaujų fondas, Teisėsaugos fondas, Event fondas. Atidarius skiltį jos fondas užklausiamas automatiškai.",
    } },
    { versija = "2.10.0", pavadinimas = "Event skiltis", pakeitimai = {
        "Event fondai: Mafijų, gaujų (/mgfondas), Teisėsaugos (/tfondas) ir Event (/efondas).",
        "Atidarius skiltį ar pasirinkus fondą komanda išsiunčiama automatiškai, serverio langas ir chato eilutė paslepiami, duomenys rodomi lentelėje: likutis, įplaukos, išlaidos, Data | Vardas | Suma.",
        "Paspaudus nicką: Kopijuoti nicką arba Duoti pinigų iš fondo (/mgduoti, /tduoti, /eduoti). Tikrinama, ar fonde pakanka pinigų, po davimo fondas atnaujinamas.",
        "Paieška pagal nicką ir „Sugeneruoti (Dev)“.",
    } },
    { versija = "2.9.0", pavadinimas = "Pakeitimų skiltis", pakeitimai = {
        "Nauja skiltis „Pakeitimai“ su visa versijų istorija.",
        "Versijos pernumeruotos: 1 – dialogų versija, 2 – mimgui. 2.x.x: vidurinis skaičius – didesni pakeitimai, paskutinis – smulkūs.",
        "Atidarius meniu 1 iš 10 kartų Pagrindiniame vietoj palinkėjimo šypsotis raudonai rašoma „Kas skaitys tas GD“.",
    } },
    { versija = "2.8.3", pakeitimai = {
        "Nauji „Pakeisti darbą“ ID (17 darbų): Policininkų 1, Medikų 2, Cosa Nostra 6, Tolimųjų reisų 7, FTB 9, Mechanikų 12, Ginklų prekeivių 15, Reporterių 16, Taksi 21, Immortal 26, Interpolo 27, Apsaugos 28, Armijos 29, Radijos 32, SPD 33, „Grove Street“ 34, „The Ballas“ 35.",
    } },
    { versija = "2.8.2", pakeitimai = {
        "Atimant direktoriaus statusą tikrinama, ar jis prisijungęs. Jei ne – naudojama /skirtidiroff <nick> 0.",
    } },
    { versija = "2.8.1", pakeitimai = {
        "Darbo analizė atbuline data: neaktyvumas skaičiuojamas nuo pasirinktos datos.",
        "Jei praeitos dienos sąraše nėra Įspėjimų ar Priimtas stulpelių, rašoma „nėra duomenų“.",
    } },
    { versija = "2.8.0", pavadinimas = "Darbo analizė", pakeitimai = {
        "Darbų patikroje vienas mygtukas „Tikrinti“ (/dfondas + /visidarbuotojai).",
        "Po patikros atsidaro langas „Darbo analizė“: fondas, darbuotojai, direktorius ir pavaduotojas, neaktyvūs, su įspėjimais, nauji, daugiausiai dirbę, rodiklių sumos ir vidurkiai, darbuotojų lentelė su nicko meniu.",
        "Datos pasirinkimas ir „Sugeneruoti (Dev)“.",
        "Paslėpti /skirtidir atsakymai, ateinantys jau po patikros, ir tuščios eilutės po scripto komandų.",
    } },
    { versija = "2.7.6", pakeitimai = {
        "Pridėtas SPD (ID 20) prie „Pakeisti darbą“.",
    } },
    { versija = "2.7.5", pakeitimai = {
        "Nauji „Pakeisti darbą“ ID (18 darbų, su abiem Taksi firmomis, Narkotikų prekeiviais, Reporteriais).",
    } },
    { versija = "2.7.4", pakeitimai = {
        "Pavaduotojo statusas atimamas per to darbo direktorių (/skirtipav <nick>), po to atnaujinama /direkt.",
    } },
    { versija = "2.7.3", pakeitimai = {
        "Įspėjimų istorija pagal tikrą serverio langą: santrauka „įspėtas direktoriaus N kartų“ ir lentelė Data | Priežastis | Davė.",
    } },
    { versija = "2.7.2", pakeitimai = {
        "Įspėjimų istorijoje tekstas nebenusikerpa: stulpeliai pagal turinį, langas praplatėja, jei reikia – horizontali slinktis.",
    } },
    { versija = "2.7.1", pakeitimai = {
        "Dev režime tikra aktyvumo patikra nebeužgožiama senų atsitiktinių duomenų.",
    } },
    { versija = "2.7.0", pavadinimas = "Darbo statistika aktyvume", pakeitimai = {
        "Aktyvumo patikra renka ir darbo statistiką kiekvienai dienai (baudos, atvykimai, pagydymai ir t.t.) per /visidarbuotojai <data>.",
        "Sumos ir vidurkiai, darbas parenkamas automatiškai arba rankiniu būdu.",
    } },
    { versija = "2.6.2", pakeitimai = {
        "Direktoriuose: „Kopijuoti direktoriaus nicką“, „Kopijuoti pavaduotojo nicką“.",
    } },
    { versija = "2.6.1", pakeitimai = {
        "Mažiausias lango dydis 1300x750 (mažesniame ekrane – visas ekranas).",
    } },
    { versija = "2.6.0", pavadinimas = "Nicko meniu ir įspėjimų istorija", pakeitimai = {
        "Darbuotojų lentelėje nickai paspaudžiami: Tikrinti žaidėjo aktyvumą, Žaidėjo įspėjimų istorija (/ispejimai per to darbo direktorių, atskirame lange), Kopijuoti nicką.",
        "Veikia ir su atsitiktiniais duomenimis.",
    } },
    { versija = "2.5.7", pakeitimai = {
        "Aktyvumo eilutės kopijuojamos paspaudus, mygtukas „Kopijuoti visą lentelę“.",
    } },
    { versija = "2.5.6", pakeitimai = {
        "Su nuimta /arsutapo varnele scriptas komandos neliečia.",
    } },
    { versija = "2.5.5", pakeitimai = {
        "/arsutapo be paskyrų atidaro Paskyrų sutapimo skiltį, su vienu nicku jį įrašo į laukelį.",
    } },
    { versija = "2.5.4", pakeitimai = {
        "Serverio atsakymo laukimas pagal nutylėjimą 2 s.",
    } },
    { versija = "2.5.3", pakeitimai = {
        "/direkt ir /arsutapo nustatymai atskirti: /direkt pagal nutylėjimą rodo serverio lentelę, mygtukai meniu visada atnaujina meniu.",
    } },
    { versija = "2.5.2", pakeitimai = {
        "Lentelės nebesubyra tempiant stulpelių ribas.",
        "Pagrindiniame puslapyje tekstas nebenusikerpa, nicko stulpelis prisitaiko prie ilgiausio nicko.",
    } },
    { versija = "2.5.1", pakeitimai = {
        "Patikros metu serverio atsakymai į /skirtidir slepiami chate ir rodomi statuse.",
    } },
    { versija = "2.5.0", pavadinimas = "Patikros statusas", pakeitimai = {
        "Visos scripto žinutės perkeltos iš chato į skiltį „Patikros statusas“: eiga, trukmė, likęs laikas, perspėjimai ir visi pranešimai su laiku.",
        "Chate liko tik įkėlimo žinutė, naujausias pranešimas kelias sekundes rodomas lango apačioje.",
        "Nustatymas „Pranešimus rodyti ir chate“.",
    } },
    { versija = "2.4.2", pakeitimai = {
        "Ryškesnės linijos, rėmeliai aplink laukus ir mygtukus, šviesesni pažymėjimai.",
    } },
    { versija = "2.4.1", pakeitimai = {
        "Vaivorykštinė juosta pagal nutylėjimą išjungta, vietoj jos juoda pavadinimo juosta.",
    } },
    { versija = "2.4.0", pavadinimas = "Direktorių žymės", pakeitimai = {
        "Prieš renkant darbuotojus paimama /direkt lentelė: direktorius pažymimas (dir), pavaduotojas (pav).",
        "Išimtas „Nr.“ stulpelis.",
    } },
    { versija = "2.3.2", pakeitimai = {
        "Atsitiktiniai duomenys atnaujinti: kiekvieno darbo stulpeliai, praeitos dienos formatas.",
        "Dev režime galima generuoti duomenis ir atbuline data.",
    } },
    { versija = "2.3.1", pakeitimai = {
        "Pataisytas praeitos dienos formatas („Šiandien 431 203min“, „D. p. …€“, lango antraštė – data).",
    } },
    { versija = "2.3.0", pavadinimas = "Darbuotojai pagal datą", pakeitimai = {
        "/visidarbuotojai pagal datą: datos laukas su „Šiandien“ / „Vakar“.",
        "Jei fondo nepavyko gauti, rašomas 0.",
    } },
    { versija = "2.2.1", pakeitimai = {
        "Perrašytas /visidarbuotojai atpažinimas pagal tikrą serverio output'ą: kiekvieno darbo stulpeliai, nukirptos chato eilutės papildomos iš lango, poskyriai.",
    } },
    { versija = "2.2.0", pavadinimas = "Nustatymai ir Dev režimas", pakeitimai = {
        "Skiltis „Nustatymai“ su Dev režimu, nustatymai išsaugomi nustatymai.json.",
        "Persijungimai rodomi tik tada, kai yra bendras IP arba SAMP ID, Dev sutapimo scenarijų mygtukai.",
        "Failas pervadintas į dpmenu.lua, autorius Dex.",
        "„Tokios komandos nėra“ – rašoma „Neturi prieigos prie komandos X“, patikra nutraukiama, direktorius nuimamas.",
        "Derinimo žurnalas debug_visidarbuotojai.txt.",
    } },
    { versija = "2.1.0", pavadinimas = "Paskyrų sutapimas", pakeitimai = {
        "Nauja skiltis „Paskyrų sutapimas“ (/arsutapo): bendri IP, bendras SAMP ID, persijungimai tarp paskyrų ir spalvota išvada.",
    } },
    { versija = "2.0.0", pavadinimas = "Perrašyta ant mimgui", pakeitimai = {
        "Vietoj dialogų – vienas mimgui langas su skirtukais, juodas nepermatomas dizainas, apačioje „Made by Dex, with love, mua :3“.",
        "Išimta „Mafijos/Gaujos“ skiltis, pridėtas „Pagrindinis“ puslapis.",
        "Aktyvume prisijungusių žaidėjų sąrašas.",
    } },
    { versija = "1.x", pavadinimas = "Dialogų versija", pakeitimai = {
        "Pirmoji versija buvo ant SA-MP dialogų (pradžioje vadinosi „mgdpkt“).",
        "Mafijų ir gaujų užšaldymas, darbo /dfondas ir /visidarbuotojai per /skirtidir, /blist (tipai 1–4, 1–60 mėn.) su nicko patikra.",
        "Pervadinta į DPKT meniu, komanda /dp, „Pakeisti darbą“ (/noriudarbo).",
        "Visų darbų /visidarbuotojai ir /dfondas su išsaugojimu diske.",
        "Aktyvumas per /info kiekvienai dienai, trumposios komandos /aktyvumas, /vdd, /vdf.",
        "/direkt valdymas: direktoriai, pavaduotojai, jų aktyvumas ir statuso atėmimas.",
    } },
}

---------------------------------------------------------------- UI: SKIRTUKAI
local PAGRINDINIO_KOMANDOS = {
    { "/dp",        "Atidaro DPKT meniu" },
    { "/aktyvumas", "Atidaro aktyvumo patikrą" },
    { "/vdd",       "Atidaro visų darbų darbuotojus" },
    { "/vdf",       "Atidaro visų darbų fondus" },
    { "/noriudarbo", "Serverio komanda: jei įjungta nustatymuose, be ID atidaro „Pakeisti darbą“" },
    { "/direkt",    "Serverio komanda: jei įjungta nustatymuose, vietoj serverio lentelės atidaro Direktorių skiltį" },
    { "/arsutapo",  "Be paskyrų atidaro Paskyrų sutapimo skiltį. Su dviem paskyromis - serverio komanda, rezultatas rodomas meniu (jei įjungta nustatymuose)" },
}

local PAGRINDINIO_SKILTYS = {
    { "Darbų patikra",  "Užsideda tau darbo direktorių, patikrina /dfondas ir /visidarbuotojai, nusiima ir parodo darbo analizę." },
    { "Pakeisti darbą", "Pakeičia tavo darbą per /noriudarbo." },
    { "Blist",          "Įtraukia žaidėją į juodąjį sąrašą: tipas, nickas, mėnesiai (1-60), priežastis." },
    { "Direktoriai",    "Rodo visus direktorius ir pavaduotojus, kas prisijungę. Paspaudus ant darbo: "
                        .. "fondas, darbuotojai, aktyvumas, statuso atėmimas." },
    { "Darbuotojai",    "Surenka visų darbų /visidarbuotojai ir išsaugo. Yra paieška pagal nicką." },
    { "Darbų fondai",   "Surenka visų darbų /dfondas ir išsaugo, rodo bendrą sumą." },
    { "Aktyvumas",      "Per /info patikrina žaidėjo žaidimo laiką, ridą, žuvis ir patirtį kiekvienai dienai, "
                        .. "suskaičiuoja sumas ir vidurkius. Paskutinė patikra išsaugoma." },
    { "Paskyrų sutapimas", "Per /arsutapo palygina dvi paskyras: bendri IP, bendras SAMP ID (tas pats "
                        .. "kompiuteris), persijungimai tarp paskyrų ir aiški išvada." },
    { "Nustatymai",     "Dev režimas (atsitiktiniai duomenys testavimui), pauzės, chato ir lango nustatymai." },
    { "Event",          "Mafijų, gaujų (/mgfondas), Teisėsaugos (/tfondas) ir Event (/efondas) fondai: išrašai ir pinigų davimas." },
    { "Pakeitimai",     "Visų versijų pakeitimų istorija." },
}

local function rodytiPagrindini()
    T("DPKT meniu v" .. thisScript().version)
    TPilkas("Administravimo įrankiai darbams, direktoriams ir žaidėjų aktyvumui tikrinti.")
    imgui.Separator()
    imgui.Spacing()

    T("Komandos")
    imgui.Columns(2, "##pagr_komandos", false)
    imgui.SetColumnWidth(0, stulpelioPlotis(PAGRINDINIO_KOMANDOS, 100))
    for _, k in ipairs(PAGRINDINIO_KOMANDOS) do
        T(k[1], SPALVA_ZALIA) imgui.NextColumn()
        T(k[2]) imgui.NextColumn()
    end
    imgui.Columns(1)
    imgui.Spacing()
    imgui.Separator()
    imgui.Spacing()

    T("Ką daro scriptas")
    imgui.Columns(2, "##pagr_skiltys", false)
    imgui.SetColumnWidth(0, stulpelioPlotis(PAGRINDINIO_SKILTYS, 100))
    for _, k in ipairs(PAGRINDINIO_SKILTYS) do
        T(k[1], SPALVA_ZALIA) imgui.NextColumn()
        imgui.TextWrapped((k[2]:gsub("%%", "%%%%"))) imgui.NextColumn()
    end
    imgui.Columns(1)
    imgui.Spacing()
    TPilkas("Kol vyksta patikra, geriau nedaryti jokių veiksmų (teleportų ar pnš.).")
    TPilkas("Duomenys saugomi aplanke moonloader\\config\\dpkt.")

    imgui.Spacing()
    imgui.Separator()
    imgui.Spacing()
    local linkejimas = ui.gd and "Kas skaitys tas GD"
        or "Sėkmingo administravimo, kantrybės su žaidėjais ir nepamiršk šypsotis :)"
    imgui.SetCursorPosX(math.max(0, (imgui.GetWindowWidth() - imgui.CalcTextSize(linkejimas).x) / 2))
    T(linkejimas, ui.gd and SPALVA_RAUDONA or SPALVA_ZALIA)
end

local function rodytiDarbuPatikra()
    T("Darbų patikra")
    TPilkas("Užsideda tau darbo direktorių, patikrina /dfondas ir /visidarbuotojai, nusiima ir atidaro darbo analizę.")
    imgui.Separator()
    -- data /visidarbuotojai (fondas visada dabartinis)
    T("Data:")
    imgui.SameLine()
    imgui.PushItemWidth(110)
    imgui.InputText("##analizes_data", ui.analizesData, ffi.sizeof(ui.analizesData))
    imgui.PopItemWidth()
    imgui.SameLine()
    if imgui.SmallButton("Šiandien##analizes_data") then irasyti(ui.analizesData, "") ui.analizesKlaida = nil end
    imgui.SameLine()
    if imgui.SmallButton("Vakar##analizes_data") then
        irasyti(ui.analizesData, os.date(DATOS_FORMATAS, os.time() - 86400))
        ui.analizesKlaida = nil
    end
    imgui.SameLine()
    TPilkas(skaityti(ui.analizesData) == "" and "(tuščia = šiandien; fondas visada dabartinis)" or "(fondas visada dabartinis)")
    if ui.analizesKlaida then T(ui.analizesKlaida, SPALVA_RAUDONA) end
    -- grąžina true ir datą (nil = šiandien) arba false
    local function pasirinktaData()
        local tekstas = skaityti(ui.analizesData)
        if tekstas == "" then ui.analizesKlaida = nil return true, nil end
        local laikas = datosLaikas(tekstas)
        if not laikas then
            ui.analizesKlaida = "Netinkama data. Formatas MMMM-MM-DD arba palik tuščią (šiandien)."
            return false
        elseif laikas > os.time() then
            ui.analizesKlaida = "Data negali būti ateityje."
            return false
        end
        ui.analizesKlaida = nil
        local data = os.date(DATOS_FORMATAS, laikas)
        return true, data ~= os.date(DATOS_FORMATAS) and data or nil
    end
    imgui.Separator()
    eigosJuosta()
    imgui.Columns(3, "##darbu_patikra", false)
    imgui.SetColumnWidth(0, 260)
    imgui.SetColumnWidth(1, 70)
    for _, darbas in ipairs(DIREKTORIU_DARBAI) do
        T(darbas.pavadinimas)
        imgui.NextColumn()
        TPilkas("ID: " .. darbas.id)
        imgui.NextColumn()
        if imgui.SmallButton("Tikrinti##t" .. darbas.id) then
            local tinka, data = pasirinktaData()
            if tinka then darboAnalize.tikrinti(darbas, data) end
        end
        if nust.dev then
            imgui.SameLine()
            if imgui.SmallButton("Sugeneruoti (Dev)##ta" .. darbas.id) then
                local tinka, data = pasirinktaData()
                if tinka then darboAnalize.atsitiktine(darbas, data) end
            end
        end
        imgui.NextColumn()
    end
    imgui.Columns(1)
end

local function rodytiDarboKeitima()
    T("Pakeisti darbą")
    TPilkas("Išsiunčia " .. KOMANDOS.darboKeitimas:gsub("%%d", "<ID>"))
    imgui.Separator()
    imgui.Columns(3, "##keisti", false)
    imgui.SetColumnWidth(0, 260)
    imgui.SetColumnWidth(1, 70)
    for _, darbas in ipairs(KEICIAMI_DARBAI) do
        T(darbas.pavadinimas)
        imgui.NextColumn()
        TPilkas("ID: " .. darbas.id)
        imgui.NextColumn()
        if imgui.SmallButton("Pakeisti##k" .. darbas.id) then
            siusti(string.format(KOMANDOS.darboKeitimas, darbas.id))
            pranesimas(string.format("Pakeitei darbą: %s.", darbas.pavadinimas))
        end
        imgui.NextColumn()
    end
    imgui.Columns(1)
end

local function rodytiBlist()
    T("Blist")
    imgui.Separator()
    imgui.Spacing()

    T("Tipas")
    for i, tipas in ipairs(BLIST_TIPAI) do
        if imgui.Selectable(string.format("%s (%s)##bt%d", tipas.pavadinimas, tipas.argumentas, i),
                ui.blistTipas == i, 0, imgui.ImVec2(260, 0)) then
            ui.blistTipas = i
        end
    end
    imgui.Spacing()

    imgui.PushItemWidth(260)
    T("Nickas (Vardas_Pavarde)")
    imgui.InputText("##blist_nickas", ui.blistNickas, ffi.sizeof(ui.blistNickas))
    T("Mėnesiai")
    imgui.SliderInt("##blist_men", ui.blistMenesiai, MIN_MENESIU, MAX_MENESIU)
    imgui.PopItemWidth()
    T("Priežastis")
    imgui.PushItemWidth(math.min(plotis(), 500))
    imgui.InputText("##blist_priezastis", ui.blistPriezastis, ffi.sizeof(ui.blistPriezastis))
    imgui.PopItemWidth()

    local tipas = BLIST_TIPAI[ui.blistTipas]
    local nickas, priezastis = skaityti(ui.blistNickas), skaityti(ui.blistPriezastis)
    local menesiai = math.max(MIN_MENESIU, math.min(MAX_MENESIU, ui.blistMenesiai[0]))
    local komanda = string.format("/blist %s %s %d %s", tipas.argumentas,
        nickas ~= "" and nickas or "<nickas>", menesiai, priezastis ~= "" and priezastis or "<priežastis>")

    imgui.Spacing()
    TPilkas("Bus išsiųsta: " .. komanda)
    if ui.blistKlaida then T(ui.blistKlaida, SPALVA_RAUDONA) end
    imgui.Spacing()

    if imgui.Button("Siųsti", imgui.ImVec2(160, 30)) then
        if not teisingasNickas(nickas) then
            ui.blistKlaida = "Netinkamas nickas. Formatas Vardas_Pavarde: abi dalys bent 3 raidžių, "
                .. "pirma didžioji, kitos mažosios, be skaičių."
        elseif priezastis == "" then
            ui.blistKlaida = "Priežastis negali būti tuščia."
        else
            ui.blistKlaida = nil
            siusti(komanda)
            pranesimas(komanda)
            irasyti(ui.blistNickas, "")
            irasyti(ui.blistPriezastis, "")
        end
    end
end

local function pradetiAktyvumoPatikra()
    local nickas = skaityti(ui.aktNickas)
    local nuo, iki = datosLaikas(skaityti(ui.aktNuo)), datosLaikas(skaityti(ui.aktIki))
    if not teisingasNickas(nickas) then
        ui.aktKlaida = "Netinkamas nickas. Formatas Vardas_Pavarde."
    elseif not nuo then
        ui.aktKlaida = "Netinkama pradžios data. Formatas MMMM-MM-DD."
    elseif not iki then
        ui.aktKlaida = "Netinkama pabaigos data. Formatas MMMM-MM-DD."
    elseif nuo > os.time() then
        ui.aktKlaida = "Pradžios data negali būti ateityje."
    elseif iki < nuo then
        ui.aktKlaida = "Pabaigos data negali būti ankstesnė už pradžios."
    elseif (iki - nuo) / 86400 + 1 > MAX_DIENU then
        ui.aktKlaida = string.format("Daugiausia %d dienų vienu kartu.", MAX_DIENU)
    else
        ui.aktKlaida = nil
        local darbas = nil
        if ui.aktDarbas > 0 then darbas = darbasPagalId(ui.aktDarbas)
        elseif ui.aktDarbas == 0 then darbas = darboStatistika.rasti(nickas) end
        tikrintiAktyvuma(nickas, nuo, iki, darbas)
    end
end

-- atidaro aktyvumo skirtuką su įrašytu nicku (iš Direktorių)
local function aktyvumasNickui(nickas)
    irasyti(ui.aktNickas, nickas)
    ui.aktKlaida = nil
    atidarytiMeniu("aktyvumas")
end

local function rodytiDirektorius()
    T("Direktoriai")
    imgui.SameLine()
    if imgui.SmallButton("Atnaujinti (/direkt)") then siusti("/direkt") end
    imgui.Separator()
    eigosJuosta()

    local d = rodomi("direkt")
    if not d then
        imgui.Spacing()
        TPilkas("Informacijos dar nėra. Parašyk /direkt arba spausk \"Atnaujinti (/direkt)\".")
        return
    end
    TPilkas("Gauta: " .. d.gauta)
    if d.atsitiktiniai then T("Dev režimas: rodomi atsitiktiniai duomenys.", SPALVA_GELTONA) end

    -- lentelė: visi darbai iš eilės, be atskiros slinkties
    lentelesStulpeliai(3, "##direkt", true)
    imgui.SetColumnWidth(0, 330)
    imgui.SetColumnWidth(1, 210)
    TPilkas("Darbas") imgui.NextColumn()
    TPilkas("Direktorius") imgui.NextColumn()
    TPilkas("Pavaduotojas") imgui.NextColumn()
    imgui.Separator()
    for i, e in ipairs(d.eilutes) do
        if imgui.Selectable(e.visas .. "##dir" .. i, ui.direktPasirinkta == i,
                imgui.SelectableFlags.SpanAllColumns) then
            ui.direktPasirinkta = i
        end
        imgui.NextColumn()
        if e.direktorius then T(e.direktorius, e.direktoriusOnline and SPALVA_ZALIA or SPALVA_RAUDONA) end
        imgui.NextColumn()
        if e.pavaduotojas then T(e.pavaduotojas, e.pavaduotojasOnline and SPALVA_ZALIA or SPALVA_RAUDONA) end
        imgui.NextColumn()
    end
    stulpeliuPabaiga()
    imgui.Separator()

    T(string.format("Šiuo metu prisijungusių direktorių: %d, pavaduotojų: %d", d.onlineDir, d.onlinePav))
    imgui.Separator()

    -- pasirinkto darbo valdymas
    local e = ui.direktPasirinkta and d.eilutes[ui.direktPasirinkta]
    if not e then
        TPilkas("Pasirink darbą lentelėje.")
        return
    end
    T("Darbas: " .. e.pavadinimas)
    T("Direktorius: " .. (e.direktorius or "nėra"))
    T("Pavaduotojas: " .. (e.pavaduotojas or "nėra"))
    imgui.Spacing()

    local darbas = e.id and darbasPagalId(e.id)
    local w = 230
    if imgui.Button("Tikrinti darbo /dfondas", imgui.ImVec2(w, 0)) then
        if darbas then vykdytiDirektoriausSeka(darbas, "/dfondas") else klaida("Nežinomas šio darbo direktoriaus ID.") end
    end
    imgui.SameLine()
    if imgui.Button("Tikrinti darbo /visidarbuotojai", imgui.ImVec2(w, 0)) then
        if darbas then vykdytiDirektoriausSeka(darbas, "/visidarbuotojai") else klaida("Nežinomas šio darbo direktoriaus ID.") end
    end

    if imgui.Button("Tikrinti direktoriaus aktyvumą", imgui.ImVec2(w, 0)) then
        if e.direktorius then aktyvumasNickui(e.direktorius) else klaida("Šis darbas neturi direktoriaus.") end
    end
    imgui.SameLine()
    if imgui.Button("Tikrinti pavaduotojo aktyvumą", imgui.ImVec2(w, 0)) then
        if e.pavaduotojas then aktyvumasNickui(e.pavaduotojas) else klaida("Šis darbas neturi pavaduotojo.") end
    end

    -- nicko kopijavimas (mygtuko užrašas trumpam pasikeičia į "Nukopijuota!")
    local function kopijavimoMygtukas(tekstas, raktas, nickas, kaiNera)
        local ka = kopijavimas.raktas == raktas and localClock() - kopijavimas.t < 1.5
        if imgui.Button((ka and "Nukopijuota!" or tekstas) .. "##" .. raktas, imgui.ImVec2(w, 0)) then
            if nickas then kopijavimas.kopijuoti(nickas, raktas) else klaida(kaiNera) end
        end
    end
    kopijavimoMygtukas("Kopijuoti direktoriaus nicką", "dir_nickas", e.direktorius, "Šis darbas neturi direktoriaus.")
    imgui.SameLine()
    kopijavimoMygtukas("Kopijuoti pavaduotojo nicką", "pav_nickas", e.pavaduotojas, "Šis darbas neturi pavaduotojo.")

    if spalvotasMygtukas("Atimti direktoriaus statusą", MYGTUKAS_RAUDONAS, imgui.ImVec2(w, 0)) then
        if not e.direktorius then
            klaida("Šis darbas neturi direktoriaus.")
        else
            local vardas, pav = e.direktorius, e.pavadinimas
            local online = arPrisijunges(vardas)
            paklausti(string.format("Ar tikrai nori atimti %s direktoriaus statusą (%s)?\n%s", vardas, pav,
                online and "Žaidėjas prisijungęs." or "Žaidėjas neprisijungęs, bus naudojama /skirtidiroff."), function()
                -- tikrinam dar kartą: per tą laiką galėjo prisijungti ar atsijungti
                if arPrisijunges(vardas) then
                    siusti(string.format(KOMANDOS.direktorius, vardas, 0))
                    pranesimas(string.format("Atėmei %s direktoriaus statusą (%s).", vardas, pav))
                else
                    siusti(string.format(KOMANDOS.direktoriusOffline, vardas, 0))
                    pranesimas(string.format("Atėmei %s direktoriaus statusą (%s), žaidėjas neprisijungęs.", vardas, pav))
                end
                siusti("/direkt")   -- atnaujinam Direktorių lentelę
            end)
        end
    end
    imgui.SameLine()
    if spalvotasMygtukas("Atimti pavaduotojo statusą", MYGTUKAS_RAUDONAS, imgui.ImVec2(w, 0)) then
        if not e.pavaduotojas then
            klaida("Šis darbas neturi pavaduotojo.")
        else
            local vardas, pav = e.pavaduotojas, e.pavadinimas
            if not darbas then
                klaida("Nežinomas šio darbo direktoriaus ID, pavaduotojo statuso atimti negaliu.")
            else
                paklausti(string.format("Ar tikrai nori atimti %s pavaduotojo statusą (%s)?", vardas, pav), function()
                    -- /skirtipav veikia tik to darbo direktoriui: užsidedam, atimam, nusiimam
                    vykdytiDirektoriausSeka(darbas, string.format(KOMANDOS.pavaduotojoAtemimas, vardas),
                        "atimti " .. vardas .. " pavaduotojo statusą", function()
                            pranesimas(string.format("Atėmei %s pavaduotojo statusą (%s).", vardas, pav))
                            siusti("/direkt")   -- atnaujinam Direktorių lentelę
                        end)
                end)
            end
        end
    end
end

-- seni failai (prieš 3.0) turėjo fiksuotus laukus: paverčiam į bendrą formatą
local function darbuotojoLaukai(e)
    if e.laukai then return e.laukai end
    local l = {}
    for _, p in ipairs({ { "Šiandien", e.siandien }, { "Iškvietimai", e.iskvietimai }, { "Priimtas", e.priimtas },
                         { "Rangas", e.rangas }, { "Įspėjimai", e.ispejimai } }) do
        if p[2] then l[#l + 1] = p end
    end
    e.laukai = l
    return l
end

-- šio darbo stulpeliai: visi laukai pagal pirmą pasirodymą
local function darboStulpeliai(eilutes)
    local sarasas, yra = {}, {}
    for _, e in ipairs(eilutes) do
        for _, l in ipairs(darbuotojoLaukai(e)) do
            if not yra[l[1]] then yra[l[1]] = true; sarasas[#sarasas + 1] = l[1] end
        end
    end
    return sarasas
end

local function rodytiDarbuotojus()
    T("Visų darbų darbuotojai")
    imgui.SameLine()
    -- grąžina true ir datą (nil = šiandien) arba false, jei data netinkama
    local function pasirinktaData()
        local tekstas = skaityti(ui.darbData)
        if tekstas == "" then ui.darbKlaida = nil return true, nil end
        local laikas = datosLaikas(tekstas)
        if not laikas then
            ui.darbKlaida = "Netinkama data. Formatas MMMM-MM-DD arba palik tuščią (šiandien)."
            return false
        elseif laikas > os.time() then
            ui.darbKlaida = "Data negali būti ateityje."
            return false
        end
        ui.darbKlaida = nil
        local data = os.date(DATOS_FORMATAS, laikas)
        return true, data ~= os.date(DATOS_FORMATAS) and data or nil
    end

    if spalvotasMygtukas("Atnaujinti informaciją##darbuotojai", MYGTUKAS_ZALIAS) then
        local tinka, data = pasirinktaData()
        if tinka then rinktiDarbuotojus(data) end
    end
    if nust.dev then
        imgui.SameLine()
        if imgui.Button("Sugeneruoti (Dev)##darbuotojai") then
            local tinka, data = pasirinktaData()
            if tinka then
                atsitiktiniai.darbuotojai = atsitiktiniaiDarbuotojuDuomenys(data)
                atsitiktiniai.darbuotojaiPirmenybe = true
            end
        end
    end
    imgui.SameLine()
    T("Data:")
    imgui.SameLine()
    imgui.PushItemWidth(110)
    imgui.InputText("##darb_data", ui.darbData, ffi.sizeof(ui.darbData))
    imgui.PopItemWidth()
    imgui.SameLine()
    if imgui.SmallButton("Šiandien##darb_data") then irasyti(ui.darbData, "") end
    imgui.SameLine()
    if imgui.SmallButton("Vakar##darb_data") then irasyti(ui.darbData, os.date(DATOS_FORMATAS, os.time() - 86400)) end
    imgui.SameLine()
    TPilkas(skaityti(ui.darbData) == "" and "(tuščia = šiandien)" or "")
    imgui.Separator()
    if ui.darbKlaida then T(ui.darbKlaida, SPALVA_RAUDONA) end
    eigosJuosta()

    local d = rodomi("darbuotojai")
    if not d then return end
    duomenuBusena(d)
    if d.data then
        T("Duomenys už: " .. d.data .. (d.data == os.date(DATOS_FORMATAS) and " (šiandien)" or ""), SPALVA_ZALIA)
    end

    imgui.PushItemWidth(220)
    imgui.InputText("Ieškoti nicko##paieska", ui.paieska, ffi.sizeof(ui.paieska))
    imgui.PopItemWidth()
    local paieska = skaityti(ui.paieska):lower()

    imgui.BeginChild("##darbuotojai", imgui.ImVec2(0, 0), false)
    for di, darbas in ipairs(d.darbai) do
        local eilutes = {}
        for _, e in ipairs(darbas.eilutes or {}) do
            local vardas = (e.nickas or e.visa or ""):lower()
            if paieska == "" or vardas:find(paieska, 1, true) then eilutes[#eilutes + 1] = e end
        end
        if paieska == "" or #eilutes > 0 then
            if paieska ~= "" and imgui.SetNextItemOpen then imgui.SetNextItemOpen(true) end
            local antraste = string.format("%s (%d)##darbas%d", tekst(darbas.pavadinimas), #eilutes, di)
            if imgui.CollapsingHeader(antraste) then
                if darbas.surinkta then TPilkas("Surinkta: " .. darbas.surinkta) end
                if #eilutes == 0 then
                    TPilkas("Darbuotojų nerasta.")
                else
                    local laukai = darboStulpeliai(eilutes)
                    local kiek = 2 + #laukai
                    local id = "##dc" .. di
                    local nickoPlotis = 140
                    for _, e in ipairs(eilutes) do
                        if not e.visa then
                            local w = imgui.CalcTextSize(tekst(e.nickas)).x
                            if e.pareigos then w = w + 4 + imgui.CalcTextSize("(" .. e.pareigos .. ")").x end
                            nickoPlotis = math.max(nickoPlotis, w + 20)
                        end
                    end
                    local function antrastes()
                        lentelesStulpeliai(kiek, id, true)
                        imgui.SetColumnWidth(0, nickoPlotis)
                        imgui.SetColumnWidth(1, 135)
                        TPilkas("Nickas") imgui.NextColumn()
                        TPilkas("Prisijungė") imgui.NextColumn()
                        for _, st in ipairs(laukai) do TPilkas(st) imgui.NextColumn() end
                        imgui.Separator()
                    end
                    antrastes()
                    local skyrius = nil
                    for _, e in ipairs(eilutes) do
                        -- poskyris (pvz. "Slaptoji policija")
                        if e.skyrius ~= skyrius then
                            skyrius = e.skyrius
                            stulpeliuPabaiga()
                            imgui.Spacing()
                            T(skyrius or darbas.pavadinimas, SPALVA_ZALIA)
                            antrastes()
                        end
                        if e.visa then
                            T(e.visa) imgui.NextColumn()
                            for _ = 2, kiek do imgui.NextColumn() end
                        else
                            local reiksmes = {}
                            for _, l in ipairs(darbuotojoLaukai(e)) do reiksmes[l[1]] = l[2] end
                            local nickas = tekst(e.nickas)
                            local dydis = imgui.CalcTextSize(nickas)
                            if imgui.Selectable(nickas .. "##nk" .. di .. "_" .. tostring(e), false, 0, imgui.ImVec2(dydis.x, 0)) then
                                ui.nickMeniu = { nickas = e.nickas, darbas = { pavadinimas = darbas.pavadinimas, id = darbas.id },
                                                 atsitiktiniai = d.atsitiktiniai }
                                ui.atidarytiNickMeniu = true
                            end
                            if imgui.IsItemHovered() then imgui.SetTooltip("Spausk: aktyvumas, įspėjimų istorija") end
                            if e.pareigos then
                                imgui.SameLine(0, 4)
                                T("(" .. e.pareigos .. ")", e.pareigos == "dir" and SPALVA_GELTONA or SPALVA_ZALIA)
                            end
                            imgui.NextColumn()
                            T(tekst(e.prisijunge)) imgui.NextColumn()
                            for _, st in ipairs(laukai) do
                                if reiksmes[st] then T(reiksmes[st]) else TPilkas("-") end
                                imgui.NextColumn()
                            end
                        end
                    end
                    stulpeliuPabaiga()
                end
                imgui.Spacing()
            end
        end
    end
    imgui.EndChild()
end

local function rodytiFondus()
    T("Visų darbų fondai")
    imgui.SameLine()
    if spalvotasMygtukas("Atnaujinti informaciją##fondai", MYGTUKAS_ZALIAS) then rinktiFondus() end
    imgui.Separator()
    eigosJuosta()

    local d = rodomi("fondai")
    if not d then return end
    duomenuBusena(d)

    imgui.BeginChild("##fondai", imgui.ImVec2(0, 0), false)
    lentelesStulpeliai(2, "##fondai_lentele", true)
    imgui.SetColumnWidth(0, 300)
    TPilkas("Darbas") imgui.NextColumn()
    TPilkas("Fondas") imgui.NextColumn()
    imgui.Separator()
    local viso = 0
    for _, darbas in ipairs(d.darbai) do
        T(string.format("%s (ID: %d)", tekst(darbas.pavadinimas), darbas.id or 0))
        imgui.NextColumn()
        viso = viso + (darbas.suma or 0)
        T(formatuotiSuma(darbas.suma or 0) .. " €")
        imgui.NextColumn()
    end
    imgui.Separator()
    T("Iš viso") imgui.NextColumn()
    T(formatuotiSuma(viso) .. " €") imgui.NextColumn()
    stulpeliuPabaiga()
    imgui.EndChild()
end

local AKTYVUMO_STULPELIAI = {
    { "Data", 110 }, { "Žaidė", 210 }, { "Pravažiavo", 120 }, { "Žuvys", 120 }, { "Patirtis", 0 },
}

-- viena lentelės eilutė; paspaudus bet kur ant eilutės, ji nukopijuojama
local function aktyvumoEilute(reiksmes, raktas)
    local paspausta = imgui.Selectable(tostring(reiksmes[1]) .. "##akt_" .. raktas,
        kopijavimas.raktas == raktas and localClock() - kopijavimas.t < 1.5, imgui.SelectableFlags.SpanAllColumns)
    kopijavimas.uzuomina(raktas)
    if paspausta then kopijavimas.kopijuoti(table.concat(reiksmes, " | "), raktas) end
    imgui.NextColumn()
    for i = 2, #reiksmes do
        T(reiksmes[i])
        imgui.NextColumn()
    end
end

-- prisijungusių žaidėjų sąrašas (atnaujinamas kas sekundę, ne kas kadrą)
local zaidejai = { sarasas = {}, atnaujinta = -10 }

local function prisijungeZaidejai()
    if os.clock() - zaidejai.atnaujinta < 1 then return zaidejai.sarasas end
    local sarasas = {}
    local pavyko, manoId = sampGetPlayerIdByCharHandle(PLAYER_PED)
    if pavyko then
        sarasas[#sarasas + 1] = { id = manoId, nickas = u8(sampGetPlayerNickname(manoId)) }
    end
    for id = 0, sampGetMaxPlayerId(false) do
        if sampIsPlayerConnected(id) and id ~= manoId then
            sarasas[#sarasas + 1] = { id = id, nickas = u8(sampGetPlayerNickname(id)) }
        end
    end
    table.sort(sarasas, function(a, b) return a.nickas:lower() < b.nickas:lower() end)
    zaidejai.sarasas, zaidejai.atnaujinta = sarasas, os.clock()
    return sarasas
end

local function rodytiZaidejuSarasa(aukstis, pasirinktas, kaiPasirinkta)
    local sarasas = prisijungeZaidejai()
    T(string.format("Prisijungę žaidėjai (%d)", #sarasas))
    imgui.PushItemWidth(-1)
    imgui.InputText("##zaideju_paieska", ui.zaidejuPaieska, ffi.sizeof(ui.zaidejuPaieska))
    imgui.PopItemWidth()
    if imgui.IsItemHovered() and skaityti(ui.zaidejuPaieska) == "" then
        imgui.SetTooltip("Ieškoti pagal nicką arba ID")
    end
    local paieska = skaityti(ui.zaidejuPaieska):lower()

    imgui.BeginChild("##zaideju_sarasas", imgui.ImVec2(0, aukstis), true)
    for _, z in ipairs(sarasas) do
        if paieska == "" or z.nickas:lower():find(paieska, 1, true) or tostring(z.id) == paieska then
            if imgui.Selectable(string.format("%s [%d]##z%d", z.nickas, z.id, z.id), z.nickas == pasirinktas) then
                kaiPasirinkta(z.nickas)
            end
        end
    end
    imgui.EndChild()
end

local function rodytiAktyvuma()
    T("Aktyvumas")
    TPilkas("/info <nickas> <data> kiekvienai dienai. Žaidėją gali pasirinkti iš sąrašo dešinėje.")
    imgui.Separator()

    -- kairėje forma, dešinėje prisijungusių žaidėjų sąrašas
    imgui.BeginGroup()
    imgui.PushItemWidth(200)
    T("Nickas") imgui.SameLine(110)
    imgui.InputText("##akt_nickas", ui.aktNickas, ffi.sizeof(ui.aktNickas))
    T("Nuo") imgui.SameLine(110)
    imgui.InputText("##akt_nuo", ui.aktNuo, ffi.sizeof(ui.aktNuo))
    T("Iki") imgui.SameLine(110)
    imgui.InputText("##akt_iki", ui.aktIki, ffi.sizeof(ui.aktIki))
    T("Darbas") imgui.SameLine(110)
    local rastas = darboStatistika.rasti(skaityti(ui.aktNickas))
    local perziura
    if ui.aktDarbas == -1 then perziura = "Nerinkti"
    elseif ui.aktDarbas > 0 then perziura = (darbasPagalId(ui.aktDarbas) or {}).pavadinimas or "?"
    else perziura = "Automatiškai" .. (rastas and (" (" .. rastas.pavadinimas .. ")") or "") end
    if imgui.BeginCombo("##akt_darbas", perziura) then
        if imgui.Selectable("Automatiškai##akt_d_auto", ui.aktDarbas == 0) then ui.aktDarbas = 0 end
        if imgui.Selectable("Nerinkti darbo statistikos##akt_d_ne", ui.aktDarbas == -1) then ui.aktDarbas = -1 end
        imgui.Separator()
        for _, dd in ipairs(DIREKTORIU_DARBAI) do
            if imgui.Selectable(dd.pavadinimas .. "##akt_d" .. dd.id, ui.aktDarbas == dd.id) then ui.aktDarbas = dd.id end
        end
        imgui.EndCombo()
    end
    if imgui.IsItemHovered() then
        imgui.SetTooltip("Kiek ko žaidėjas surinko darbe kiekvieną dieną (/visidarbuotojai, reikia to darbo direktoriaus)")
    end
    imgui.PopItemWidth()
    if ui.aktDarbas == 0 and not rastas and skaityti(ui.aktNickas) ~= "" then
        TPilkas("Darbas nerastas Darbuotojų duomenyse, darbo statistika nebus renkama.")
    end
    if ui.aktKlaida then T(ui.aktKlaida, SPALVA_RAUDONA) end
    if imgui.Button("Tikrinti", imgui.ImVec2(160, 28)) then pradetiAktyvumoPatikra() end
    imgui.EndGroup()

    imgui.SameLine(0, 30)
    imgui.BeginGroup()
    imgui.BeginChild("##zaideju_blokas", imgui.ImVec2(math.min(plotis(), 380), 210), false)
    rodytiZaidejuSarasa(0, skaityti(ui.aktNickas), function(nickas)
        irasyti(ui.aktNickas, nickas)
        ui.aktKlaida = nil
    end)
    imgui.EndChild()
    imgui.EndGroup()

    imgui.Spacing()
    eigosJuosta()
    imgui.Separator()

    local a = rodomi("aktyvumas")
    if not a then
        TPilkas("Aktyvumas dar netikrintas.")
        return
    end
    local r = a.rezultatas
    -- eilutės (tos pačios rodomos lentelėje ir kopijuojamos); gale - darbo statistikos stulpeliai
    local darboSt = darboStatistika.stulpeliai(r)
    local function darboReiksmes(d)
        local pagal = {}
        for _, l in ipairs(d.darbas or {}) do pagal[l[1]] = l[2] end
        local sar = {}
        for _, st in ipairs(darboSt) do sar[#sar + 1] = pagal[st] or "-" end
        return sar, pagal
    end
    local dienuEilutes = {}
    for _, d in ipairs(r.dienos) do
        local e
        if d.minutes then
            e = { d.data, d.minutes .. " min", string.format("%.2f km", d.km or 0),
                  formatuotiSuma(d.zuvys or 0) .. " €", d.xp and (d.xp .. " XP") or "-" }
        else
            e = { d.data, "Negautas atsakymas", "-", "-", "-" }
        end
        for _, v in ipairs((darboReiksmes(d))) do e[#e + 1] = v end
        dienuEilutes[#dienuEilutes + 1] = e
    end
    local dienu = math.max(1, #r.dienos)
    local sumuEilutes = {
        { "Iš viso", minutesTekstu(r.visoMin), string.format("%.2f km", r.visoKm),
          formatuotiSuma(r.visoZuvys or 0) .. " €", r.xpPokytis and (xpPokytis(r.xpPokytis) .. " XP") or "-" },
        { "Vidurkis", minutesTekstu(math.floor(r.visoMin / dienu + 0.5)),
          string.format("%.2f km", r.visoKm / dienu),
          formatuotiSuma(math.floor((r.visoZuvys or 0) / dienu + 0.5)) .. " €",
          r.xpVidurkis and (xpPokytis(r.xpVidurkis) .. " XP") or "-" },
    }
    for _, st in ipairs(darboSt) do
        local reiksmes = {}
        for _, d in ipairs(r.dienos) do
            local _, pagal = darboReiksmes(d)
            if pagal[st] then reiksmes[#reiksmes + 1] = pagal[st] end
        end
        sumuEilutes[1][#sumuEilutes[1] + 1] = darboStatistika.sumuoti(reiksmes)
        sumuEilutes[2][#sumuEilutes[2] + 1] = darboStatistika.sumuoti(reiksmes, dienu)
    end
    local stulpeliuPav = {}
    for _, st in ipairs(AKTYVUMO_STULPELIAI) do stulpeliuPav[#stulpeliuPav + 1] = st[1] end
    for _, st in ipairs(darboSt) do stulpeliuPav[#stulpeliuPav + 1] = st end
    local xpPirma = "Patirtis pirmą dieną: " .. (r.xpPirma and (r.xpPirma .. " XP") or "nėra informacijos")
    local xpPaskutine = "Patirtis paskutinę dieną: " .. (r.xpPaskutine and (r.xpPaskutine .. " XP") or "nėra informacijos")

    T("Paskutinė patikra: " .. tekst(a.antraste))
    if a.atsitiktiniai then T("Dev režimas: rodomi atsitiktiniai duomenys.", SPALVA_GELTONA) end
    TPilkas("Tikrinta: " .. tekst(a.tikrinta))
    imgui.SameLine()
    if imgui.SmallButton("Kopijuoti visą lentelę##akt") then
        local tekstas = { "Aktyvumas: " .. tekst(a.antraste) .. (r.darbas and (", darbas: " .. r.darbas) or ""),
                          table.concat(stulpeliuPav, " | ") }
        for _, e in ipairs(dienuEilutes) do tekstas[#tekstas + 1] = table.concat(e, " | ") end
        for _, e in ipairs(sumuEilutes) do tekstas[#tekstas + 1] = table.concat(e, " | ") end
        tekstas[#tekstas + 1] = xpPirma
        tekstas[#tekstas + 1] = xpPaskutine
        kopijavimas.kopijuoti(table.concat(tekstas, "\r\n"), "visa")
    end
    if kopijavimas.raktas == "visa" and localClock() - kopijavimas.t < 1.5 then
        imgui.SameLine()
        T("Nukopijuota!", SPALVA_ZALIA)
    elseif imgui.IsItemHovered() then
        imgui.SetTooltip("Arba spausk ant bet kurios eilutės, kad nukopijuotum tik ją")
    end

    if r.darbas then
        T("Darbo statistika: " .. r.darbas, SPALVA_ZALIA)
        local nerasta = 0
        for _, d in ipairs(r.dienos) do if d.darbeNerastas then nerasta = nerasta + 1 end end
        if nerasta > 0 then
            imgui.SameLine()
            TPilkas(string.format("(%d d. žaidėjas nerastas darbo sąraše)", nerasta))
        end
    end

    imgui.BeginChild("##aktyvumas", imgui.ImVec2(0, 0), false)
    lentelesStulpeliai(#stulpeliuPav, "##akt_lentele" .. #darboSt, true)
    for i, pav in ipairs(stulpeliuPav) do
        local st = AKTYVUMO_STULPELIAI[i]
        if st then
            local plotisSt = st[2] > 0 and st[2] or (#darboSt > 0 and 150 or 0)
            if plotisSt > 0 then imgui.SetColumnWidth(i - 1, plotisSt) end
        end
        TPilkas(pav)
        imgui.NextColumn()
    end
    imgui.Separator()

    for i, e in ipairs(dienuEilutes) do aktyvumoEilute(e, "d" .. i) end
    imgui.Separator()
    for i, e in ipairs(sumuEilutes) do aktyvumoEilute(e, "s" .. i) end
    stulpeliuPabaiga()

    imgui.Spacing()
    for i, eil in ipairs({ xpPirma, xpPaskutine }) do
        if imgui.Selectable(eil .. "##akt_xp" .. i, kopijavimas.raktas == "xp" .. i and localClock() - kopijavimas.t < 1.5) then
            kopijavimas.kopijuoti(eil, "xp" .. i)
        end
        kopijavimas.uzuomina("xp" .. i)
    end
    if r.neatsake and r.neatsake > 0 then
        TPilkas(string.format("Negautas atsakymas: %d d. (skaičiuota kaip 0)", r.neatsake))
    end
    imgui.EndChild()
end

local PASKYROS_SPALVOS = { imgui.ImVec4(0.45, 0.75, 1.00, 1.00), imgui.ImVec4(1.00, 0.68, 0.30, 1.00) }

local function paskyrosSpalva(r, vardas)
    for i, p in ipairs(r.paskyros) do
        if p == vardas then return PASKYROS_SPALVOS[i] end
    end
    return nil
end

local function ipSarasas(sarasas)
    local dalys = {}
    for i, ip in ipairs(sarasas) do dalys[i] = "#" .. ip end
    return table.concat(dalys, ", ")
end

local function pradetiSutapimoPatikra()
    local a, b = skaityti(ui.sut1), skaityti(ui.sut2)
    if a == "" or b == "" then
        ui.sutKlaida = "Įvesk abi paskyras."
    elseif a:find("%s") or b:find("%s") then
        ui.sutKlaida = "Nickai negali turėti tarpų."
    elseif a:lower() == b:lower() then
        ui.sutKlaida = "Paskyros turi būti skirtingos."
    else
        ui.sutKlaida = nil
        siusti(string.format(KOMANDOS.arsutapo, a, b))
    end
end

-- išvadų langelis su spalvotu fonu
local function isvada(eilutes, spalva)
    local h = #eilutes * imgui.GetTextLineHeightWithSpacing() + 14
    imgui.PushStyleColor(imgui.Col.ChildBg, imgui.ImVec4(spalva.x * 0.18, spalva.y * 0.18, spalva.z * 0.18, 1))
    imgui.PushStyleColor(imgui.Col.Border, spalva)
    imgui.BeginChild("##sut_isvada", imgui.ImVec2(0, h), true, imgui.WindowFlags.NoScrollbar)
    for i, e in ipairs(eilutes) do T(e, i == 1 and spalva or nil) end
    imgui.EndChild()
    imgui.PopStyleColor(2)
end

local function rodytiSutapima()
    T("Paskyrų sutapimas")
    TPilkas("/arsutapo: ar dvi paskyros jungėsi iš to paties IP arba kompiuterio (SAMP ID).")
    imgui.Separator()

    -- forma + prisijungę žaidėjai
    imgui.BeginGroup()
    imgui.PushItemWidth(200)
    T("Paskyra 1") imgui.SameLine(110)
    imgui.InputText("##sut1", ui.sut1, ffi.sizeof(ui.sut1))
    T("Paskyra 2") imgui.SameLine(110)
    imgui.InputText("##sut2", ui.sut2, ffi.sizeof(ui.sut2))
    imgui.PopItemWidth()
    if ui.sutKlaida then T(ui.sutKlaida, SPALVA_RAUDONA) end
    if imgui.Button("Tikrinti", imgui.ImVec2(160, 28)) then pradetiSutapimoPatikra() end
    TPilkas("Arba chate: /arsutapo Nick_1 Nick_2")
    imgui.EndGroup()

    imgui.SameLine(0, 30)
    imgui.BeginGroup()
    imgui.BeginChild("##sut_zaidejai", imgui.ImVec2(math.min(plotis(), 380), 180), false)
    rodytiZaidejuSarasa(0, nil, function(nickas)
        -- užpildo pirmą tuščią laukelį, kitaip pakeičia antrą paskyrą
        if skaityti(ui.sut1) == "" then irasyti(ui.sut1, nickas) else irasyti(ui.sut2, nickas) end
        ui.sutKlaida = nil
    end)
    imgui.EndChild()
    imgui.EndGroup()
    imgui.Spacing()
    imgui.Separator()

    -- Dev režime: pasirinkti, kokį pavyzdį rodyti
    if nust.dev then
        TPilkas("Dev režimas: pavyzdys")
        local mygtukai = {
            { "Sutapimas", "sutampa" }, { "Nesutapimas", "nesutampa" },
            { "Tik bendras IP", "ip" }, { "Keičia IP, tas pats SAMP ID", "ip_keitimas" },
            { "Atsitiktinis", nil },
        }
        for i, m in ipairs(mygtukai) do
            if i > 1 then imgui.SameLine() end
            if imgui.Button(m[1] .. "##dev_sut" .. i) then
                duomenys.sutapimas = nil
                atsitiktiniai.sutapimas = atsitiktinisSutapimas(m[2])
            end
        end
        imgui.Separator()
    end

    local r = rodomi("sutapimas")
    if not r then
        TPilkas("Patikrinimo dar nėra.")
        return
    end
    local a = r.analize

    imgui.BeginChild("##sut_rezultatas", imgui.ImVec2(0, 0), false)
    T(r.antraste)
    imgui.SameLine()
    TPilkas("·  gauta " .. r.gauta)
    if r.atsitiktiniai then
        T("Dev režimas: rodomi atsitiktiniai duomenys. Patikrink paskyras arba parašyk /arsutapo.", SPALVA_GELTONA)
    end
    imgui.Spacing()

    -- persijungimai rodomi tik tada, kai paskyros turi bendrą IP ar SAMP ID
    local yraSasaja = #a.bendriSamp > 0 or #a.bendriIp > 0

    -- išvada
    local eilutes, spalva = {}, SPALVA_ZALIA
    if #a.bendriSamp > 0 then
        spalva = SPALVA_RAUDONA
        eilutes[#eilutes + 1] = "PASKYROS SUTAMPA: abi naudojo tą patį kompiuterį (SAMP ID "
            .. table.concat(a.bendriSamp, ", ") .. ")."
        if #a.bendriIp > 0 then
            eilutes[#eilutes + 1] = "Bendri IP: " .. ipSarasas(a.bendriIp) .. "."
        else
            eilutes[#eilutes + 1] = "IP skirtingi, bet tai nieko nekeičia: SAMP ID vienodas."
        end
    elseif #a.bendriIp > 0 then
        spalva = SPALVA_GELTONA
        eilutes[#eilutes + 1] = "Bendras IP (" .. ipSarasas(a.bendriIp) .. "), bet SAMP ID skirtingi."
        eilutes[#eilutes + 1] = "Gali būti tas pats žmogus kitu kompiuteriu arba bendras tinklas (šeima, kompiuterių klasė)."
    else
        eilutes[#eilutes + 1] = "Bendrų IP ir SAMP ID nerasta."
    end
    for _, p in ipairs(r.paskyros) do
        local x = a.info[p]
        if #x.ipSar > 1 and #x.sampSar == 1 then
            eilutes[#eilutes + 1] = string.format("%s naudojo %d skirtingus IP, bet SAMP ID visada tas pats (%s).",
                p, #x.ipSar, x.sampSar[1])
        end
    end
    if yraSasaja and #a.persijungimai > 0 then
        eilutes[#eilutes + 1] = string.format("Persijungė tarp paskyrų per %d min.: %d kartų.",
            PERSIJUNGIMO_MIN, #a.persijungimai)
    end
    isvada(eilutes, spalva)
    imgui.Spacing()

    -- paskyrų suvestinė
    lentelesStulpeliai(math.max(1, math.min(2, #r.paskyros)), "##sut_paskyros", true)
    for i, p in ipairs(r.paskyros) do
        if i > 2 then break end
        local x = a.info[p]
        T(p, PASKYROS_SPALVOS[i])
        TPilkas("Prisijungimų:") imgui.SameLine() T(tostring(x.kiek))
        TPilkas("Paskutinis:") imgui.SameLine() T(x.paskutinis and x.paskutinis.data or "-")
        TPilkas("Pirmas sąraše:") imgui.SameLine() T(x.pirmas and x.pirmas.data or "-")
        TPilkas("SAMP ID:") imgui.SameLine()
        T(table.concat(x.sampSar, ", "), #a.bendriSamp > 0 and SPALVA_RAUDONA or nil)
        TPilkas(string.format("Skirtingų IP: %d", #x.ipSar))
        imgui.TextWrapped((ipSarasas(x.ipSar):gsub("%%", "%%%%")))
        imgui.NextColumn()
    end
    stulpeliuPabaiga()
    imgui.Separator()

    -- persijungimai
    if yraSasaja and #a.persijungimai > 0 then
        T(string.format("Persijungimai tarp paskyrų (per %d min.)", PERSIJUNGIMO_MIN))
        imgui.Columns(4, "##sut_persij", false)
        imgui.SetColumnWidth(0, 190)
        imgui.SetColumnWidth(1, 190)
        imgui.SetColumnWidth(2, 190)
        TPilkas("Atsijungė / buvo") imgui.NextColumn()
        TPilkas("Prisijungė prie") imgui.NextColumn()
        TPilkas("Laikas") imgui.NextColumn()
        TPilkas("Po") imgui.NextColumn()
        for _, pj in ipairs(a.persijungimai) do
            T(pj.is.paskyra, paskyrosSpalva(r, pj.is.paskyra)) imgui.NextColumn()
            T(pj.i.paskyra, paskyrosSpalva(r, pj.i.paskyra)) imgui.NextColumn()
            T(pj.i.data) imgui.NextColumn()
            T(pj.min .. " min") imgui.NextColumn()
        end
        imgui.Columns(1)
        imgui.Separator()
    end

    -- visi prisijungimai
    if imgui.CollapsingHeader(string.format("Visi prisijungimai (%d)##sut_visi", #a.laikoEile)) then
        TPilkas("Geltonas IP ir raudonas SAMP ID reiškia, kad jie sutampa su kita paskyra.")
        lentelesStulpeliai(4, "##sut_visi_lentele", true)
        imgui.SetColumnWidth(0, 190)
        imgui.SetColumnWidth(1, 190)
        imgui.SetColumnWidth(2, 100)
        TPilkas("Data") imgui.NextColumn()
        TPilkas("Paskyra") imgui.NextColumn()
        TPilkas("IP") imgui.NextColumn()
        TPilkas("SAMP ID") imgui.NextColumn()
        imgui.Separator()
        for _, e in ipairs(a.laikoEile) do
            T(e.data) imgui.NextColumn()
            T(e.paskyra, paskyrosSpalva(r, e.paskyra)) imgui.NextColumn()
            T("#" .. e.ip, a.bendrasIp[e.ip] and SPALVA_GELTONA or nil) imgui.NextColumn()
            T(e.samp, a.bendrasSamp[e.samp] and SPALVA_RAUDONA or nil) imgui.NextColumn()
        end
        stulpeliuPabaiga()
    end
    imgui.EndChild()
end

---------------------------------------------------------------- UI: NUSTATYMAI
local nustUI = nil

local function nustatymuRodikliai()
    if nustUI then return nustUI end
    nustUI = {}
    for k, v in pairs(nust) do
        if type(v) == "boolean" then nustUI[k] = new.bool(v)
        elseif k == "langoAlfa" or k == "vaivorykstesGreitis" then nustUI[k] = new.float(v)
        else nustUI[k] = new.int(v) end
    end
    return nustUI
end

local function pakeista()
    nustatymaiPakeisti = true
    pritaikytiNustatymus()
end

local function zymimasis(raktas, tekstas, paaiskinimas)
    local r = nustatymuRodikliai()
    if imgui.Checkbox(tekstas .. "##n_" .. raktas, r[raktas]) then
        nust[raktas] = r[raktas][0]
        pakeista()
    end
    if paaiskinimas then
        imgui.SameLine()
        TPilkas("(" .. paaiskinimas .. ")")
    end
end

local function slankiklisInt(raktas, tekstas, min, max, formatas)
    local r = nustatymuRodikliai()
    imgui.PushItemWidth(260)
    if imgui.SliderInt(tekstas .. "##n_" .. raktas, r[raktas], min, max, formatas) then
        nust[raktas] = math.max(min, math.min(max, r[raktas][0]))
        pakeista()
    end
    imgui.PopItemWidth()
end

local function slankiklisFloat(raktas, tekstas, min, max, formatas)
    local r = nustatymuRodikliai()
    imgui.PushItemWidth(260)
    if imgui.SliderFloat(tekstas .. "##n_" .. raktas, r[raktas], min, max, formatas) then
        nust[raktas] = math.max(min, math.min(max, r[raktas][0]))
        pakeista()
        if raktas == "langoAlfa" then langoAlfa() end
    end
    imgui.PopItemWidth()
end

local function skyrius(pavadinimas)
    imgui.Spacing()
    T(pavadinimas, SPALVA_ZALIA)
    imgui.Separator()
end

local function rodytiNustatymus()
    T("Nustatymai")
    TPilkas("Pakeitimai išsaugomi automatiškai (config\\dpkt\\nustatymai.json).")
    imgui.Separator()

    skyrius("Duomenys")
    zymimasis("dev", "Dev režimas", "atsitiktiniai duomenys, kol nėra tikrų")
    zymimasis("zurnalas", "Derinimo žurnalas", "visas /visidarbuotojai output į debug_visidarbuotojai.txt")
    TPilkas("Be Dev režimo rodomi tik tikri duomenys. Jei jų nėra, prie darbų rodomi nuliai.")
    if nust.dev then
        if imgui.Button("Sugeneruoti naujus atsitiktinius duomenis") then atsitiktiniai = {} end
    end
    if spalvotasMygtukas("Ištrinti surinktus duomenis", MYGTUKAS_RAUDONAS) then
        paklausti("Ar tikrai nori ištrinti visus surinktus duomenis (darbuotojai, fondai, aktyvumas)?", function()
            os.remove(FAILAI.darbuotojai)
            os.remove(FAILAI.fondai)
            os.remove(FAILAI.aktyvumas)
            duomenys.darbuotojai, duomenys.fondai, duomenys.aktyvumas = nil, nil, nil
            duomenys.direkt, duomenys.sutapimas = nil, nil
            pranesimas("Surinkti duomenys ištrinti.")
        end)
    end

    skyrius("Chatas ir serverio langai")
    zymimasis("perimtiDirekt", "Rodyti /direkt DPKT meniu lange", "kai rašai komandą pats; mygtukas meniu visada atnaujina meniu")
    zymimasis("perimtiArsutapo", "Rodyti /arsutapo DPKT meniu lange", "vietoj serverio lango")
    zymimasis("perimtiNoriudarbo", "/noriudarbo be ID atidaro „Pakeisti darbą“", "vietoj serverio komandos")
    zymimasis("slepti", "Slėpti chate eilutes, kurias renka scriptas", "/visidarbuotojai, /dfondas, /info, /skirtidir atsakymai patikros metu")
    zymimasis("chate", "Pranešimus rodyti ir chate", "ne tik skiltyje Patikros statusas")
    zymimasis("pasveikinimas", "Rodyti žinutę įkėlus scriptą")

    skyrius("Patikros")
    slankiklisInt("pauze", "Pauzė tarp komandų", 300, 3000, "%d ms")
    TPilkas("Jei serveris išmeta už flood, padidink pauzę.")
    slankiklisInt("laukti", "Kiek laukti serverio atsakymo", 2, 15, "%d s")
    slankiklisInt("persijungimoMin", "Persijungimo tarp paskyrų riba", 1, 120, "%d min")

    skyrius("Išvaizda")
    slankiklisInt("sriftas", "Šrifto dydis", 12, 24, "%d")
    imgui.SameLine()
    if imgui.SmallButton("Perkrauti scriptą") then
        issaugotiNustatymus()
        thisScript():reload()
    end
    TPilkas("Šrifto dydis pritaikomas perkrovus scriptą.")
    slankiklisFloat("langoAlfa", "Lango nepermatomumas", 0.5, 1.0, "%.2f")
    zymimasis("vaivorykste", "Vaivorykštinė pavadinimo juosta")
    if nust.vaivorykste then
        zymimasis("animacija", "Vaivorykštė juda")
        if nust.animacija then slankiklisFloat("vaivorykstesGreitis", "Judėjimo greitis", 0.01, 0.5, "%.2f") end
    end

    imgui.Spacing()
    imgui.Separator()
    if imgui.Button("Atkurti numatytus nustatymus") then
        for k, v in pairs(NUMATYTI_NUSTATYMAI) do nust[k] = v end
        nustUI = nil
        langoAlfa()
        pakeista()
    end
end

---------------------------------------------------------------- UI: PATIKROS STATUSAS
local STATUSO_SPALVOS = {
    info = SPALVA_ZALIA,
    klaida = SPALVA_ZALIA,
    serveris = imgui.ImVec4(0.62, 0.80, 1.00, 1.00),
    ispejimas = SPALVA_RAUDONA,
}

local function trukmesTekstas(sek)
    sek = math.max(0, math.floor(sek + 0.5))
    if sek < 60 then return sek .. " s" end
    return string.format("%d min %02d s", math.floor(sek / 60), sek % 60)
end

local function rodytiStatusa()
    T("Patikros statusas")
    TPilkas("Čia rodoma viskas, ką scriptas daro ir ką praneša.")
    imgui.Separator()

    local p = statusas.patikra
    if p then
        local vyksta = p.busena == "vyksta"
        local trukme = vyksta and (localClock() - p.t0) or (p.trukme or 0)
        T(p.pavadinimas)
        imgui.SameLine()
        if vyksta then T("- vyksta", SPALVA_ZALIA)
        elseif p.busena == "nutraukta" then T("- nutraukta", SPALVA_RAUDONA)
        else T("- baigta", SPALVA_ZALIA) end
        local eilute = "Pradėta: " .. p.pradzia .. "   Trukmė: " .. trukmesTekstas(trukme)
        if vyksta and eiga.viso > 0 and eiga.dabar > 0 then
            local liko = trukme / eiga.dabar * (eiga.viso - eiga.dabar)
            eilute = eilute .. "   Liko apie ~" .. trukmesTekstas(liko)
        end
        TPilkas(eilute)
        if vyksta then
            eigosJuosta()
            T("Rekomenduojama nedaryti jokių veiksmų (teleportų ar pnš.) kol vyksta patikra.", SPALVA_RAUDONA)
        end
        imgui.Separator()
    end

    T(string.format("Įrašai (%d)", #statusas.irasai))
    if not uzimtas and #statusas.irasai > 0 then
        imgui.SameLine()
        if imgui.SmallButton("Išvalyti##statusas") then
            statusas.irasai, statusas.patikra, statusas.naujas = {}, nil, nil
        end
    end

    imgui.BeginChild("##statuso_irasai", imgui.ImVec2(0, 0), true)
    imgui.PushTextWrapPos(0)
    for i, e in ipairs(statusas.irasai) do
        if e.tipas == "antraste" then
            if i > 1 then imgui.Spacing() end
            TPilkas(e.laikas)
            imgui.SameLine()
            T(e.tekstas)
            imgui.Separator()
        else
            TPilkas(e.laikas)
            imgui.SameLine()
            T(e.tekstas, STATUSO_SPALVOS[e.tipas] or SPALVA_ZALIA)
        end
    end
    imgui.PopTextWrapPos()
    if statusas.slinkti then
        imgui.SetScrollHereY(1.0)
        statusas.slinkti = false
    end
    imgui.EndChild()
end

local function rodytiStatusoPunkta()
    return uzimtas or statusas.patikra ~= nil or #statusas.irasai > 0
end

local TURINYS = {
    statusas = rodytiStatusa,
    pagrindinis = rodytiPagrindini,
    darbai = rodytiDarbuPatikra,
    keisti = rodytiDarboKeitima,
    blist = rodytiBlist,
    direktoriai = rodytiDirektorius,
    darbuotojai = rodytiDarbuotojus,
    fondai = rodytiFondus,
    aktyvumas = rodytiAktyvuma,
    sutapimas = rodytiSutapima,
    nustatymai = rodytiNustatymus,
}

local titulinisSriftas = nil   -- storas, didesnis šriftas pavadinimo juostai

-- Event grupės skiltys (Mafijų, gaujų / Teisėsaugos / Event fondas): išrašas, nicko meniu
-- (kopijuoti, duoti pinigų). Atidarius skiltį fondas užklausiamas automatiškai.
function eventFondai.rodyti(id)
    local E = eventFondai
    if E.matomas ~= id then
        E.matomas, E.aktyvus = id, id
        E.atnaujinti(id)
    end
    local f = E.pagalId(id)
    local d = E.duomenys[f.id]
    T(f.pavadinimas .. " fondas")
    TPilkas(f.komanda .. ". Paspaudus nicką: kopijuoti nicką arba duoti pinigų iš fondo (" .. f.duoti:match("^(/%S+)") .. ").")
    imgui.Separator()

    if imgui.SmallButton("Atnaujinti##ef_atn") then E.atnaujinti(f.id) end
    imgui.SameLine()
    if imgui.SmallButton("Duoti pinigų...##ef_duoti") then
        irasyti(E.nickas, "") irasyti(E.suma, "")
        E.duotiKlaida, E.atidarytiDuoti = nil, true
    end
    if nust.dev then
        imgui.SameLine()
        if imgui.SmallButton("Sugeneruoti (Dev)##ef_dev") then E.duomenys[f.id] = E.atsitiktiniai(f.id) end
    end
    imgui.SameLine()
    imgui.PushItemWidth(180)
    imgui.InputText("Ieškoti nicko##ef_paieska", E.paieska, ffi.sizeof(E.paieska))
    imgui.PopItemWidth()

    if E.kraunama == f.id then TPilkas("Laukiama serverio atsakymo (" .. f.komanda .. ")...") end
    if E.klaida[f.id] then T(E.klaida[f.id], SPALVA_RAUDONA) end
    imgui.Separator()
    if not d then
        if E.kraunama ~= f.id then TPilkas("Duomenų dar nėra. Spausk \"Atnaujinti\".") end
        return
    end

    if titulinisSriftas then imgui.PushFont(titulinisSriftas) end
    T(f.pavadinimas .. " fonde: " .. (d.likutis and (formatuotiSuma(d.likutis) .. " €") or "?"), SPALVA_ZALIA)
    if titulinisSriftas then imgui.PopFont() end
    local iplaukos, islaidos = 0, 0
    for _, e in ipairs(d.irasai) do
        if e.suma >= 0 then iplaukos = iplaukos + e.suma else islaidos = islaidos - e.suma end
    end
    TPilkas(string.format("Gauta: %s   Įrašų: %d   Įplaukos: +%s €   Išlaidos: -%s €", tekst(d.gauta), #d.irasai,
        formatuotiSuma(iplaukos), formatuotiSuma(islaidos)))
    if d.atsitiktiniai then T("Dev režimas: rodomi atsitiktiniai duomenys.", SPALVA_GELTONA) end

    local paieska = skaityti(E.paieska):lower()
    imgui.BeginChild("##ef_lentele", imgui.ImVec2(0, 0), false)
    lentelesStulpeliai(3, "##ef_st", true)
    imgui.SetColumnWidth(0, 190)
    imgui.SetColumnWidth(1, 230)
    TPilkas("Data") imgui.NextColumn()
    TPilkas("Vardas") imgui.NextColumn()
    TPilkas("Suma") imgui.NextColumn()
    imgui.Separator()
    for i, e in ipairs(d.irasai) do
        if paieska == "" or e.vardas:lower():find(paieska, 1, true) then
            T(e.data) imgui.NextColumn()
            if E.zaidejas(e.vardas) then
                local dydis = imgui.CalcTextSize(e.vardas)
                if imgui.Selectable(e.vardas .. "##ef_n" .. i, false, 0, imgui.ImVec2(dydis.x, 0)) then
                    E.meniu = { nickas = e.vardas, fondas = f.id }
                    E.atidarytiMeniu = true
                end
                if imgui.IsItemHovered() then imgui.SetTooltip("Spausk: kopijuoti nicką, duoti pinigų") end
            else
                TPilkas(e.vardas)
                if imgui.IsItemHovered() then imgui.SetTooltip("Serverio vidinis įrašas, ne žaidėjas") end
            end
            imgui.NextColumn()
            T((e.suma >= 0 and "+" or "-") .. formatuotiSuma(math.abs(e.suma)) .. " €",
                e.suma >= 0 and SPALVA_ZALIA or SPALVA_RAUDONA)
            imgui.NextColumn()
        end
    end
    stulpeliuPabaiga()
    imgui.EndChild()
end

TURINYS.ef_mg = function() eventFondai.rodyti("mg") end
TURINYS.ef_t  = function() eventFondai.rodyti("t") end
TURINYS.ef_e  = function() eventFondai.rodyti("e") end

-- Event: nicko meniu ir "Duoti pinigų" langas (piešiami pagrindinio lango lygyje)
function eventFondai.langai()
    local E = eventFondai
    if E.atidarytiMeniu then
        imgui.OpenPopup("##ef_nick_meniu")
        E.atidarytiMeniu = false
    end
    if imgui.BeginPopup("##ef_nick_meniu") then
        local m = E.meniu
        if m then
            T(m.nickas)
            TPilkas(E.pagalId(m.fondas).pavadinimas .. " fondas")
            imgui.Separator()
            if imgui.Button("Kopijuoti nicką", imgui.ImVec2(240, 0)) then
                imgui.CloseCurrentPopup()
                kopijavimas.kopijuoti(m.nickas, "ef_nickas")
            end
            if imgui.Button("Duoti pinigų iš fondo", imgui.ImVec2(240, 0)) then
                imgui.CloseCurrentPopup()
                irasyti(E.nickas, m.nickas) irasyti(E.suma, "")
                E.duotiKlaida, E.atidarytiDuoti = nil, true
            end
        end
        imgui.EndPopup()
    end

    if E.atidarytiDuoti then
        imgui.OpenPopup("Duoti pinigų##dpkt_ef")
        E.atidarytiDuoti = false
    end
    if imgui.BeginPopupModal("Duoti pinigų##dpkt_ef", nil, imgui.WindowFlags.AlwaysAutoResize) then
        local f = E.pagalId(E.aktyvus)
        local d = E.duomenys[f.id]
        T("Duoti pinigų iš " .. f.pavadinimas .. " fondo (" .. f.duoti:match("^(/%S+)") .. ")")
        TPilkas("Fonde: " .. ((d and d.likutis) and (formatuotiSuma(d.likutis) .. " €") or "nežinoma"))
        imgui.PushItemWidth(220)
        T("Nickas") imgui.SameLine(90)
        imgui.InputText("##ef_d_nick", E.nickas, ffi.sizeof(E.nickas))
        T("Suma") imgui.SameLine(90)
        imgui.InputText("##ef_d_suma", E.suma, ffi.sizeof(E.suma))
        imgui.PopItemWidth()
        local suma = tonumber((skaityti(E.suma):gsub("[%s%.,€]", ""))) or 0
        if suma > 0 then TPilkas("= " .. formatuotiSuma(suma) .. " €") end
        if E.duotiKlaida then T(E.duotiKlaida, SPALVA_RAUDONA) end
        imgui.Spacing()
        if spalvotasMygtukas("Duoti", MYGTUKAS_ZALIAS, imgui.ImVec2(120, 0)) then
            local nickas = skaityti(E.nickas)
            if nickas == "" or nickas:find("%s") then
                E.duotiKlaida = "Įrašyk nicką (be tarpų)."
            elseif not E.zaidejas(nickas) then
                E.duotiKlaida = "Tai serverio vidinis įrašas, ne žaidėjas."
            elseif suma <= 0 or suma ~= math.floor(suma) then
                E.duotiKlaida = "Įrašyk teigiamą sveiką sumą."
            elseif d and d.likutis and not d.atsitiktiniai and suma > d.likutis then
                E.duotiKlaida = "Fonde nepakanka pinigų."
            else
                E.duoti(f.id, nickas, suma)
                imgui.CloseCurrentPopup()
            end
        end
        imgui.SameLine()
        if imgui.Button("Atšaukti", imgui.ImVec2(120, 0)) then imgui.CloseCurrentPopup() end
        imgui.EndPopup()
    end
end

-- skiltis "Pakeitimai": didesni atnaujinimai (2.X.0) ryškiai, smulkūs (2.x.X) pilkai
TURINYS.pakeitimai = function()
    T("Pakeitimai")
    TPilkas("Dabartinė versija: v" .. tostring(thisScript().version) .. ". Naujausi pakeitimai viršuje.")
    imgui.Separator()
    imgui.BeginChild("##pakeitimai", imgui.ImVec2(0, 0), false)
    for i, v in ipairs(PAKEITIMAI) do
        if i == 1 and imgui.SetNextItemOpen then imgui.SetNextItemOpen(true, imgui.Cond.Once) end
        local antraste = "v" .. v.versija .. (v.pavadinimas and ("  –  " .. v.pavadinimas) or "") .. "##pk" .. i
        local smulkus = not v.pavadinimas
        if smulkus then imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.65, 0.65, 0.65, 1)) end
        local atidaryta = imgui.CollapsingHeader(antraste)
        if smulkus then imgui.PopStyleColor() end
        if atidaryta then
            imgui.PushTextWrapPos(0)
            for _, e in ipairs(v.pakeitimai) do T("•  " .. e) end
            imgui.PopTextWrapPos()
            imgui.Spacing()
        end
    end
    imgui.EndChild()
end

---------------------------------------------------------------- UI: LANGAS
-- Lietuviškos raidės (Latin Extended-A), kabutės „“ ir €
local LT_SIMBOLIAI = ffi.new("ImWchar[9]", 0x0020, 0x00FF, 0x0100, 0x017F, 0x2010, 0x205E, 0x20AC, 0x20AC, 0)

---------------------------------------------------------------- UI: JUODA TEMA + VAIVORYKŠTĖ
local function juodaTema()
    local st = imgui.GetStyle()
    local c, k = st.Colors, imgui.Col
    -- rėmeliai aplink laukus, mygtukus ir blokus, kad aiškiau matytųsi ribos
    st.WindowBorderSize = 1
    st.ChildBorderSize  = 1
    st.FrameBorderSize  = 1
    st.PopupBorderSize  = 1
    local function v4(r, g, b, a) return imgui.ImVec4(r, g, b, a or 1) end
    c[k.WindowBg]             = v4(0, 0, 0)
    c[k.ChildBg]              = v4(0, 0, 0, 0)
    c[k.PopupBg]              = v4(0.02, 0.02, 0.02)
    c[k.Border]               = v4(0.33, 0.33, 0.33)
    c[k.TitleBg]              = v4(0, 0, 0)
    c[k.TitleBgActive]        = v4(0.06, 0.06, 0.06)
    c[k.TitleBgCollapsed]     = v4(0, 0, 0)
    c[k.BorderShadow]         = v4(0, 0, 0, 0)
    c[k.FrameBg]              = v4(0.12, 0.12, 0.12)
    c[k.FrameBgHovered]       = v4(0.18, 0.18, 0.18)
    c[k.FrameBgActive]        = v4(0.23, 0.23, 0.23)
    c[k.Button]               = v4(0.16, 0.16, 0.16)
    c[k.ButtonHovered]        = v4(0.24, 0.24, 0.24)
    c[k.ButtonActive]         = v4(0.30, 0.30, 0.30)
    c[k.Header]               = v4(0.20, 0.20, 0.20)
    c[k.HeaderHovered]        = v4(0.26, 0.26, 0.26)
    c[k.HeaderActive]         = v4(0.31, 0.31, 0.31)
    c[k.Separator]            = v4(0.33, 0.33, 0.33)
    c[k.SeparatorHovered]     = v4(0.45, 0.45, 0.45)
    c[k.SeparatorActive]      = v4(0.55, 0.55, 0.55)
    c[k.ScrollbarBg]          = v4(0, 0, 0, 0)
    c[k.ScrollbarGrab]        = v4(0.30, 0.30, 0.30)
    c[k.ScrollbarGrabHovered] = v4(0.38, 0.38, 0.38)
    c[k.ScrollbarGrabActive]  = v4(0.46, 0.46, 0.46)
    c[k.SliderGrab]           = v4(0.55, 0.55, 0.55)
    c[k.SliderGrabActive]     = v4(0.75, 0.75, 0.75)
    c[k.CheckMark]            = v4(0.85, 0.85, 0.85)
    c[k.ResizeGrip]           = v4(0, 0, 0, 0)
    c[k.ResizeGripHovered]    = v4(0.30, 0.30, 0.30)
    c[k.ResizeGripActive]     = v4(0.45, 0.45, 0.45)
    c[k.PlotHistogram]        = v4(0.30, 0.85, 0.30)
    c[k.TextSelectedBg]       = v4(0.30, 0.30, 0.30)
    c[k.ModalWindowDimBg]     = v4(0, 0, 0, 0.6)
end

-- HSV (0-1) -> RGB
local function hsv(h, s, v)
    h = (h % 1) * 6
    local i = math.floor(h)
    local f = h - i
    local p, q, t = v * (1 - s), v * (1 - s * f), v * (1 - s * (1 - f))
    if i == 0 then return v, t, p elseif i == 1 then return q, v, p
    elseif i == 2 then return p, v, t elseif i == 3 then return p, q, v
    elseif i == 4 then return t, p, v end
    return v, p, q
end

local function vaivorykstesSpalva(h)
    local r, g, b = hsv(h, 0.75, 1)
    return imgui.ColorConvertFloat4ToU32(imgui.ImVec4(r, g, b, 1))
end

local SRIFTO_DYDIS = nust.sriftas  -- pagrindinio šrifto dydis (Nustatymai)
local TITULO_AUKSTIS = 36

-- pavadinimo juosta: juoda arba vaivorykštinė (judanti); grąžina true, jei paspausta "X"
local function pavadinimoJuosta(pavadinimas)
    local p = imgui.GetWindowPos()
    local w = imgui.GetWindowWidth()
    local dl = imgui.GetWindowDrawList()
    dl:PushClipRect(p, imgui.ImVec2(p.x + w, p.y + TITULO_AUKSTIS), false)

    if not nust.vaivorykste then
        dl:AddRectFilled(p, imgui.ImVec2(p.x + w, p.y + TITULO_AUKSTIS), 0xFF000000)
        dl:AddLine(imgui.ImVec2(p.x, p.y + TITULO_AUKSTIS - 1), imgui.ImVec2(p.x + w, p.y + TITULO_AUKSTIS - 1), 0xFF545454)
        if titulinisSriftas then imgui.PushFont(titulinisSriftas) end
        local dydis = imgui.CalcTextSize(pavadinimas)
        dl:AddText(imgui.ImVec2(p.x + 14, p.y + (TITULO_AUKSTIS - dydis.y) / 2), 0xFFFFFFFF, pavadinimas)
        if titulinisSriftas then imgui.PopFont() end
        dl:PopClipRect()
        imgui.SetCursorPos(imgui.ImVec2(w - 36, 4))
        imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.14, 0.14, 0.14, 1))
        imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.22, 0.22, 0.22, 1))
        imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.30, 0.30, 0.30, 1))
        local uzdaryti = imgui.Button("X##uzdaryti", imgui.ImVec2(28, TITULO_AUKSTIS - 8))
        imgui.PopStyleColor(3)
        imgui.SetCursorPos(imgui.ImVec2(imgui.GetStyle().WindowPadding.x, TITULO_AUKSTIS + 8))
        return uzdaryti
    end

    local dalys = 24
    local poslinkis = nust.animacija and os.clock() * nust.vaivorykstesGreitis or 0
    for i = 0, dalys - 1 do
        local x0 = p.x + w * i / dalys
        local x1 = p.x + w * (i + 1) / dalys + 1
        local c0 = vaivorykstesSpalva(poslinkis + i / dalys)
        local c1 = vaivorykstesSpalva(poslinkis + (i + 1) / dalys)
        dl:AddRectFilledMultiColor(imgui.ImVec2(x0, p.y), imgui.ImVec2(x1, p.y + TITULO_AUKSTIS), c0, c1, c1, c0)
    end
    -- švelnus patamsinimas apačioje, kad tekstas geriau matytųsi
    dl:AddRectFilledMultiColor(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + w, p.y + TITULO_AUKSTIS),
        0x00000000, 0x00000000, 0x59000000, 0x59000000)

    -- pavadinimas: tamsus fonas po tekstu + kontūras, kad matytųsi ant bet kurios spalvos
    if titulinisSriftas then imgui.PushFont(titulinisSriftas) end
    local dydis = imgui.CalcTextSize(pavadinimas)
    local tx, ty = p.x + 18, p.y + (TITULO_AUKSTIS - dydis.y) / 2
    dl:AddRectFilled(imgui.ImVec2(tx - 10, p.y + 5), imgui.ImVec2(tx + dydis.x + 10, p.y + TITULO_AUKSTIS - 5),
        0xB4000000, 8)
    for _, d in ipairs({ { -1, 0 }, { 1, 0 }, { 0, -1 }, { 0, 1 }, { 1, 1 } }) do
        dl:AddText(imgui.ImVec2(tx + d[1], ty + d[2]), 0xFF000000, pavadinimas)
    end
    dl:AddText(imgui.ImVec2(tx, ty), 0xFFFFFFFF, pavadinimas)
    if titulinisSriftas then imgui.PopFont() end
    dl:PopClipRect()

    -- uždarymo mygtukas
    imgui.SetCursorPos(imgui.ImVec2(w - 36, 4))
    imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0, 0, 0, 0.35))
    imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0, 0, 0, 0.6))
    imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0, 0, 0, 0.8))
    local uzdaryti = imgui.Button("X##uzdaryti", imgui.ImVec2(28, TITULO_AUKSTIS - 8))
    imgui.PopStyleColor(3)

    imgui.SetCursorPos(imgui.ImVec2(imgui.GetStyle().WindowPadding.x, TITULO_AUKSTIS + 8))
    return uzdaryti
end

imgui.OnInitialize(function()
    local io = imgui.GetIO()
    io.IniFilename = nil
    local aplankas = getFolderPath(0x14)
    local sriftas, storas = aplankas .. "\\arial.ttf", aplankas .. "\\arialbd.ttf"
    if doesFileExist(sriftas) then
        if not doesFileExist(storas) then storas = sriftas end
        io.Fonts:Clear()
        io.Fonts:AddFontFromFileTTF(sriftas, SRIFTO_DYDIS, nil, LT_SIMBOLIAI)
        titulinisSriftas = io.Fonts:AddFontFromFileTTF(storas, SRIFTO_DYDIS + 3, nil, LT_SIMBOLIAI)
    end
    imgui.StyleColorsDark()
    juodaTema()
    langoAlfa()
end)

-- veiksmai su darbuotoju (iškylantis meniu paspaudus nicką): aktyvumas, įspėjimai, nicko kopijavimas
local function nickoVeiksmai(nm)
    if not nm then return end
    T(nm.nickas)
    TPilkas(nm.darbas.pavadinimas)
    imgui.Separator()
    if imgui.Button("Tikrinti žaidėjo aktyvumą", imgui.ImVec2(260, 0)) then
        imgui.CloseCurrentPopup()
        ui.aktDarbas = nm.darbas.id
        if nm.atsitiktiniai then
            local nuo, iki = datosLaikas(skaityti(ui.aktNuo)), datosLaikas(skaityti(ui.aktIki))
            if not (nuo and iki and iki >= nuo) then nuo, iki = nil, nil end
            atsitiktiniai.aktyvumas = atsitiktinisAktyvumas(nm.nickas, nuo, iki, nm.darbas)
            atsitiktiniai.aktyvumasPirmenybe = true
            aktyvumasNickui(nm.nickas)
        else
            aktyvumasNickui(nm.nickas)
            pradetiAktyvumoPatikra()
        end
    end
    if imgui.Button("Žaidėjo įspėjimų istorija", imgui.ImVec2(260, 0)) then
        imgui.CloseCurrentPopup()
        ispejimai.tikrinti(nm.nickas, nm.darbas, nm.atsitiktiniai)
    end
    if imgui.Button("Kopijuoti nicką", imgui.ImVec2(260, 0)) then
        imgui.CloseCurrentPopup()
        kopijavimas.kopijuoti(nm.nickas, "nickas")
    end
end

imgui.OnFrame(function() return ui.atidarytas[0] end, function()
    local sx, sy = getScreenResolution()
    imgui.SetNextWindowPos(imgui.ImVec2(sx / 2, sy / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    -- mažiausias dydis 1300x750 (mažesniame ekrane - visas ekranas), kad langas nesusitrauktų
    local minW, minH = math.min(1300, sx - 20), math.min(750, sy - 20)
    imgui.SetNextWindowSizeConstraints(imgui.ImVec2(minW, minH), imgui.ImVec2(math.max(minW, sx), math.max(minH, sy)))
    imgui.SetNextWindowSize(imgui.ImVec2(minW, minH), imgui.Cond.FirstUseEver)
    imgui.Begin("DPKT meniu", ui.atidarytas, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoTitleBar)
    if pavadinimoJuosta("DPKT meniu") then ui.atidarytas[0] = false end

    -- prasidėjo patikra: rodom jos statusą
    if statusas.perjungti then
        statusas.perjungti = false
        ui.skirtukas = "statusas"
    end
    if ui.skirtukas == "statusas" and not rodytiStatusoPunkta() then ui.skirtukas = "pagrindinis" end
    if not tostring(ui.skirtukas):find("^ef_") then eventFondai.matomas = false end

    -- kairysis meniu
    local apaciosAukstis = imgui.GetTextLineHeightWithSpacing() + 10
    imgui.BeginChild("##meniu", imgui.ImVec2(190, -apaciosAukstis), true)
    for _, s in ipairs(SKIRTUKAI) do
        if s.grupe then
            imgui.Spacing()
            TPilkas(s.grupe)
            imgui.Separator()
        elseif s.id == "statusas" then
            if rodytiStatusoPunkta() then
                local pav = s.pavadinimas
                local p = statusas.patikra
                local spalva = nil
                if uzimtas then
                    if eiga.viso > 0 then pav = string.format("%s (%d/%d)", pav, eiga.dabar, eiga.viso) end
                    spalva = SPALVA_ZALIA
                elseif p and p.busena == "nutraukta" then
                    spalva = SPALVA_RAUDONA
                end
                if spalva then imgui.PushStyleColor(imgui.Col.Text, spalva) end
                if imgui.Selectable(pav .. "##sk_" .. s.id, ui.skirtukas == s.id) then ui.skirtukas = s.id end
                if spalva then imgui.PopStyleColor() end
            end
        elseif imgui.Selectable(s.pavadinimas .. "##sk_" .. s.id, ui.skirtukas == s.id) then
            ui.skirtukas = s.id
        end
    end
    imgui.EndChild()

    imgui.SameLine()

    -- turinys
    imgui.BeginChild("##turinys", imgui.ImVec2(0, -apaciosAukstis), true)
    local rodyti = TURINYS[ui.skirtukas]
    if rodyti then rodyti() end
    imgui.EndChild()

    -- apatinė juosta: kelias sekundes rodo naujausią pranešimą (paspaudus - Patikros statusas)
    imgui.Separator()
    local n = statusas.naujas
    if n and ui.skirtukas ~= "statusas" and localClock() - n.t < 8 then
        local tekstas = "* " .. n.tekstas
        imgui.SetCursorPosX(math.max(8, (imgui.GetWindowWidth() - imgui.CalcTextSize(tekstas).x) / 2))
        T(tekstas, STATUSO_SPALVOS[n.tipas] or SPALVA_ZALIA)
        if imgui.IsItemHovered() then imgui.SetTooltip("Spausk, kad atidarytum Patikros statusą") end
        if imgui.IsItemClicked() then ui.skirtukas = "statusas" end
    else
        local paraso = "Made by Dex, with love, mua :3"
        imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(paraso).x) / 2)
        TPilkas(paraso)
    end

    -- veiksmai su darbuotoju (paspaudus nicką Darbuotojų lentelėje)
    if ui.atidarytiNickMeniu then
        imgui.OpenPopup("##nick_meniu")
        ui.atidarytiNickMeniu = false
    end
    if imgui.BeginPopup("##nick_meniu") then
        nickoVeiksmai(ui.nickMeniu)
        imgui.EndPopup()
    end

    eventFondai.langai()

    -- patvirtinimo langas
    if ui.atidarytiPatvirtinima then
        imgui.OpenPopup("Patvirtinimas##dpkt")
        ui.atidarytiPatvirtinima = false
    end
    if imgui.BeginPopupModal("Patvirtinimas##dpkt", nil, imgui.WindowFlags.AlwaysAutoResize) then
        T(ui.patvirtinimas and ui.patvirtinimas.klausimas or "")
        imgui.Spacing()
        if spalvotasMygtukas("Taip", MYGTUKAS_RAUDONAS, imgui.ImVec2(120, 0)) then
            if ui.patvirtinimas then ui.patvirtinimas.veiksmas() end
            ui.patvirtinimas = nil
            imgui.CloseCurrentPopup()
        end
        imgui.SameLine()
        if imgui.Button("Ne", imgui.ImVec2(120, 0)) then
            ui.patvirtinimas = nil
            imgui.CloseCurrentPopup()
        end
        imgui.EndPopup()
    end

    imgui.End()
end)

---------------------------------------------------------------- ĮSPĖJIMŲ LANGAS
imgui.OnFrame(function() return ispejimai.langas ~= nil and ispejimai.langas.atidarytas[0] end, function()
    local L = ispejimai.langas
    local sx, sy = getScreenResolution()
    local t = L.lentele
    -- stulpelių pločiai pagal ilgiausią tekstą, kad niekas nenusikirptų
    if t and t.stulpeliu > 1 and not t.plociai then
        t.plociai, t.viso = {}, 0
        for i = 1, t.stulpeliu do
            local w = t.antrastes and imgui.CalcTextSize(t.antrastes[i] or "").x or 0
            for _, l in ipairs(t.eilutes) do w = math.max(w, imgui.CalcTextSize(l[i] or "").x) end
            t.plociai[i] = math.floor(w + 24)
            t.viso = t.viso + t.plociai[i]
        end
    end
    imgui.SetNextWindowPos(imgui.ImVec2(sx / 2, sy / 2), imgui.Cond.Appearing, imgui.ImVec2(0.5, 0.5))
    imgui.SetNextWindowSizeConstraints(imgui.ImVec2(math.min(600, sx - 20), math.min(300, sy - 20)), imgui.ImVec2(sx, sy))
    if t and t.viso and not L.dydisPritaikytas then
        -- atidarant langas praplatinamas tiek, kad lentelė tilptų (bet ne daugiau nei ekranas)
        L.dydisPritaikytas = true
        imgui.SetNextWindowSize(imgui.ImVec2(math.min(math.max(780, t.viso + 40), sx - 40), math.min(440, sy - 60)), imgui.Cond.Always)
    else
        imgui.SetNextWindowSize(imgui.ImVec2(math.min(780, sx - 40), math.min(440, sy - 60)), imgui.Cond.FirstUseEver)
    end
    if L.fokusas then
        imgui.SetNextWindowFocus()
        L.fokusas = false
    end
    imgui.Begin("Įspėjimų istorija: " .. L.nickas .. "###dpkt_ispejimai", L.atidarytas, imgui.WindowFlags.NoCollapse)
    if titulinisSriftas then imgui.PushFont(titulinisSriftas) end
    T(L.nickas)
    if titulinisSriftas then imgui.PopFont() end
    TPilkas(L.darbas .. (L.gauta and ("   Gauta: " .. L.gauta) or ""))
    if L.atsitiktiniai then T("Dev režimas: rodomi atsitiktiniai duomenys.", SPALVA_GELTONA) end
    imgui.Separator()

    if L.busena == "vyksta" then
        eigosJuosta()
        TPilkas("Laukiama serverio atsakymo...")
    elseif L.busena == "nutraukta" then
        T("Patikra nutraukta (žr. Patikros statusas).", SPALVA_RAUDONA)
    elseif L.busena == "neatsake" then
        T("Serveris neatsakė į /ispejimai.", SPALVA_RAUDONA)
    end
    if t and t.santrauka and L.busena == "gauta" then
        for _, e in ipairs(t.santrauka) do
            T(e, (t.ispetas and t.ispetas > 0) and SPALVA_GELTONA or SPALVA_ZALIA)
        end
        imgui.Spacing()
    end
    if L.busena ~= "gauta" then
        -- nieko daugiau
    elseif t and #t.eilutes == 0 then
        T("Įspėjimų nėra.", SPALVA_ZALIA)
    elseif t then
        T(string.format("Įrašų: %d", #t.eilutes))
        imgui.SameLine()
        if imgui.SmallButton("Kopijuoti##isp") then
            local eil = {}
            if t.antrastes then eil[#eil + 1] = table.concat(t.antrastes, " | ") end
            for _, l in ipairs(t.eilutes) do eil[#eil + 1] = table.concat(l, " | ") end
            local virsus = L.nickas .. " (" .. L.darbas .. ") įspėjimai"
            if t.santrauka and #t.santrauka > 0 then virsus = virsus .. "\r\n" .. table.concat(t.santrauka, "\r\n") end
            kopijavimas.kopijuoti(virsus .. "\r\n" .. table.concat(eil, "\r\n"), "ispejimai")
        end
        if kopijavimas.raktas == "ispejimai" and localClock() - kopijavimas.t < 1.5 then
            imgui.SameLine()
            T("Nukopijuota!", SPALVA_ZALIA)
        end
        -- per siaurame lange - horizontali slinktis, o ne nukirptas tekstas
        local platus = t.viso and t.viso > imgui.GetContentRegionAvail().x
        if platus then imgui.SetNextWindowContentSize(imgui.ImVec2(t.viso, 0)) end
        imgui.BeginChild("##isp_lentele", imgui.ImVec2(0, 0), false, platus and imgui.WindowFlags.HorizontalScrollbar or 0)
        if t.stulpeliu > 1 then
            lentelesStulpeliai(t.stulpeliu, "##isp_st", true)
            if t.plociai and not platus then
                -- likusią vietą atiduodam paskutiniam stulpeliui
                for i = 1, t.stulpeliu - 1 do imgui.SetColumnWidth(i - 1, t.plociai[i]) end
            elseif t.plociai then
                for i = 1, t.stulpeliu do imgui.SetColumnWidth(i - 1, t.plociai[i]) end
            end
            if t.antrastes then
                for i = 1, t.stulpeliu do TPilkas(t.antrastes[i] or "") imgui.NextColumn() end
                imgui.Separator()
            end
            for _, l in ipairs(t.eilutes) do
                for i = 1, t.stulpeliu do T(l[i] or "") imgui.NextColumn() end
            end
            stulpeliuPabaiga()
        else
            imgui.PushTextWrapPos(0)
            for _, l in ipairs(t.eilutes) do T(l[1] or "") end
            imgui.PopTextWrapPos()
        end
        imgui.EndChild()
    end
    imgui.End()
end)

---------------------------------------------------------------- DARBO ANALIZĖS LANGAS
-- kiek dienų nuo datos tekste iki bazinės datos (numatyta - šiandien)
local function dienuNuo(tekstas, bazine)
    local data = tostring(tekstas or ""):match("^(%d%d%d%d%-%d%d%-%d%d)")
    local laikas = data and datosLaikas(data)
    local iki = datosLaikas(bazine or os.date(DATOS_FORMATAS))
    if not laikas or not iki then return nil end
    return math.floor((iki - laikas) / 86400 + 0.5)
end

function darboAnalize.skaiciuoti(L)
    local A = { viso = #L.eilutes, siandien = 0, neaktyvus = {}, suIspejimais = {}, nauji = {},
                rodikliai = {}, top = {}, dir = nil, pav = nil }
    local siandien = L.data or os.date(DATOS_FORMATAS)
    for _, e in ipairs(L.eilutes) do
        if not e.visa then
            if tostring(e.prisijunge or ""):sub(1, 10) == siandien then A.siandien = A.siandien + 1 end
            local d = dienuNuo(e.prisijunge, siandien)
            if d and d >= 7 then A.neaktyvus[#A.neaktyvus + 1] = string.format("%s (%d d.)", tekst(e.nickas), d) end
            for _, l in ipairs(darbuotojoLaukai(e)) do
                if l[1] == "Įspėjimai" then A.yraIspejimu = true end
                if l[1] == "Priimtas" then A.yraPriimtas = true end
                if l[1] == "Įspėjimai" and (tonumber(l[2]) or 0) > 0 then
                    A.suIspejimais[#A.suIspejimais + 1] = string.format("%s (%s)", tekst(e.nickas), l[2])
                elseif l[1] == "Priimtas" then
                    local pd = dienuNuo(l[2], siandien)
                    if pd and pd <= 14 then A.nauji[#A.nauji + 1] = tekst(e.nickas) end
                end
            end
            if e.pareigos == "dir" then A.dir = e.nickas elseif e.pareigos == "pav" then A.pav = e.nickas end
        end
    end
    -- rodikliai: kiekvieno stulpelio suma ir vidurkis vienam darbuotojui
    local stulpeliai = {}
    for _, st in ipairs(darboStulpeliai(L.eilutes)) do
        if not darboStatistika.NERODYTI[st] then stulpeliai[#stulpeliai + 1] = st end
    end
    for _, st in ipairs(stulpeliai) do
        local reiksmes = {}
        for _, e in ipairs(L.eilutes) do
            for _, l in ipairs(darbuotojoLaukai(e)) do if l[1] == st then reiksmes[#reiksmes + 1] = l[2] end end
        end
        A.rodikliai[#A.rodikliai + 1] = { st, darboStatistika.sumuoti(reiksmes),
            darboStatistika.sumuoti(reiksmes, math.max(1, #reiksmes)) }
    end
    -- daugiausiai dirbę pagal pirmą stulpelį (dažniausiai "Šiandien")
    if stulpeliai[1] then
        local sar = {}
        for _, e in ipairs(L.eilutes) do
            for _, l in ipairs(darbuotojoLaukai(e)) do
                if l[1] == stulpeliai[1] then
                    sar[#sar + 1] = { nickas = tekst(e.nickas), reiksme = l[2],
                                      sk = sumaIsTeksto(tostring(l[2]):match("%d[%d%.]*") or "0") }
                end
            end
        end
        table.sort(sar, function(a, b) return a.sk > b.sk end)
        for i = 1, math.min(3, #sar) do if sar[i].sk > 0 then A.top[#A.top + 1] = sar[i] end end
        A.topStulpelis = stulpeliai[1]
    end
    return A
end

imgui.OnFrame(function() return darboAnalize.langas ~= nil and darboAnalize.langas.atidarytas[0] end, function()
    local L = darboAnalize.langas
    if not L.analize then L.analize = darboAnalize.skaiciuoti(L) end
    local A = L.analize
    local sx, sy = getScreenResolution()
    imgui.SetNextWindowPos(imgui.ImVec2(sx / 2, sy / 2), imgui.Cond.Appearing, imgui.ImVec2(0.5, 0.5))
    imgui.SetNextWindowSizeConstraints(imgui.ImVec2(math.min(700, sx - 20), math.min(420, sy - 20)), imgui.ImVec2(sx, sy))
    imgui.SetNextWindowSize(imgui.ImVec2(math.min(1000, sx - 40), math.min(680, sy - 60)), imgui.Cond.FirstUseEver)
    if L.fokusas then
        imgui.SetNextWindowFocus()
        L.fokusas = false
    end
    imgui.Begin("Darbo analizė: " .. L.darbas .. "###dpkt_analize", L.atidarytas, imgui.WindowFlags.NoCollapse)
    if titulinisSriftas then imgui.PushFont(titulinisSriftas) end
    T(L.darbas)
    if titulinisSriftas then imgui.PopFont() end
    local siandien = L.data == os.date(DATOS_FORMATAS)
    TPilkas("Duomenys už: " .. tekst(L.data) .. (siandien and " (šiandien)" or "") .. "   Patikrinta: " .. tekst(L.gauta))
    if L.atsitiktiniai then T("Dev režimas: rodomi atsitiktiniai duomenys.", SPALVA_GELTONA) end
    imgui.Separator()

    imgui.BeginChild("##analize_turinys", imgui.ImVec2(0, 0), false)
    -- santrauka
    local function eilute(pav, reiksme, spalva)
        TPilkas(pav) imgui.NextColumn()
        imgui.PushTextWrapPos(0)
        T(reiksme, spalva)
        imgui.PopTextWrapPos()
        imgui.NextColumn()
    end
    imgui.Columns(2, "##analize_santrauka", false)
    imgui.SetColumnWidth(0, 230)
    eilute("Darbo fondas", L.fondas and (formatuotiSuma(L.fondas) .. " €" .. (siandien and "" or " (dabartinis)")) or "negautas",
        L.fondas and SPALVA_ZALIA or SPALVA_RAUDONA)
    eilute("Darbuotojų", tostring(A.viso))
    eilute("Direktorius", A.dir or "-")
    eilute("Pavaduotojas", A.pav or "-")
    eilute(siandien and "Prisijungę šiandien" or "Prisijungę tą dieną", tostring(A.siandien))
    local NERA_DUOMENU = "nėra duomenų (šios dienos sąraše tokio stulpelio nėra)"
    eilute(siandien and "Neprisijungę 7+ d." or "Neprisijungę 7+ d. iki tos dienos",
        #A.neaktyvus == 0 and "nėra" or (#A.neaktyvus .. ": " .. table.concat(A.neaktyvus, ", ")),
        #A.neaktyvus > 0 and SPALVA_RAUDONA or nil)
    if A.yraIspejimu then
        eilute("Su įspėjimais", #A.suIspejimais == 0 and "nėra" or (#A.suIspejimais .. ": " .. table.concat(A.suIspejimais, ", ")),
            #A.suIspejimais > 0 and SPALVA_GELTONA or nil)
    else
        eilute("Su įspėjimais", NERA_DUOMENU, SPALVA_GELTONA)
    end
    if A.yraPriimtas then
        eilute("Nauji (priimti per 14 d.)", #A.nauji == 0 and "nėra" or (#A.nauji .. ": " .. table.concat(A.nauji, ", ")))
    else
        eilute("Nauji (priimti per 14 d.)", NERA_DUOMENU, SPALVA_GELTONA)
    end
    if #A.top > 0 then
        local t = {}
        for i, x in ipairs(A.top) do t[#t + 1] = string.format("%d. %s (%s)", i, x.nickas, x.reiksme) end
        eilute("Daugiausiai (" .. tekst(A.topStulpelis) .. ")", table.concat(t, "   "), SPALVA_ZALIA)
    end
    imgui.Columns(1)

    -- rodikliai
    if #A.rodikliai > 0 then
        imgui.Spacing()
        T("Darbo rodikliai")
        lentelesStulpeliai(3, "##analize_rodikliai", true)
        imgui.SetColumnWidth(0, 230)
        imgui.SetColumnWidth(1, 200)
        TPilkas("Rodiklis") imgui.NextColumn()
        TPilkas("Iš viso") imgui.NextColumn()
        TPilkas("Vidurkis darbuotojui") imgui.NextColumn()
        imgui.Separator()
        for _, r in ipairs(A.rodikliai) do
            T(r[1]) imgui.NextColumn()
            T(r[2]) imgui.NextColumn()
            T(r[3]) imgui.NextColumn()
        end
        stulpeliuPabaiga()
    end

    -- darbuotojai
    imgui.Spacing()
    T(string.format("Darbuotojai (%d)", A.viso))
    if A.viso == 0 then
        TPilkas("Darbuotojų nerasta.")
    else
        local laukai = darboStulpeliai(L.eilutes)
        local kiek = 2 + #laukai
        local nickoPlotis = 140
        for _, e in ipairs(L.eilutes) do
            if not e.visa then
                local w = imgui.CalcTextSize(tekst(e.nickas)).x
                if e.pareigos then w = w + 4 + imgui.CalcTextSize("(" .. e.pareigos .. ")").x end
                nickoPlotis = math.max(nickoPlotis, w + 20)
            end
        end
        lentelesStulpeliai(kiek, "##analize_darbuotojai", true)
        imgui.SetColumnWidth(0, nickoPlotis)
        imgui.SetColumnWidth(1, 135)
        TPilkas("Nickas") imgui.NextColumn()
        TPilkas("Prisijungė") imgui.NextColumn()
        for _, st in ipairs(laukai) do TPilkas(st) imgui.NextColumn() end
        imgui.Separator()
        for i, e in ipairs(L.eilutes) do
            if e.visa then
                T(e.visa) imgui.NextColumn()
                for _ = 2, kiek do imgui.NextColumn() end
            else
                local nickas = tekst(e.nickas)
                local dydis = imgui.CalcTextSize(nickas)
                if imgui.Selectable(nickas .. "##an_nk" .. i, false, 0, imgui.ImVec2(dydis.x, 0)) then
                    darboAnalize.nickMeniu = { nickas = e.nickas, darbas = { pavadinimas = L.darbas, id = L.id },
                                               atsitiktiniai = L.atsitiktiniai }
                    darboAnalize.atidarytiNickMeniu = true
                end
                if imgui.IsItemHovered() then imgui.SetTooltip("Spausk: aktyvumas, įspėjimų istorija") end
                if e.pareigos then
                    imgui.SameLine(0, 4)
                    T("(" .. e.pareigos .. ")", e.pareigos == "dir" and SPALVA_GELTONA or SPALVA_ZALIA)
                end
                imgui.NextColumn()
                local d = dienuNuo(e.prisijunge, L.data)
                T(tekst(e.prisijunge), (tostring(e.prisijunge or ""):sub(1, 10) == L.data) and SPALVA_ZALIA
                    or ((d and d >= 7) and SPALVA_RAUDONA or nil))
                imgui.NextColumn()
                local reiksmes = {}
                for _, l in ipairs(darbuotojoLaukai(e)) do reiksmes[l[1]] = l[2] end
                for _, st in ipairs(laukai) do
                    if reiksmes[st] then T(reiksmes[st]) else TPilkas("-") end
                    imgui.NextColumn()
                end
            end
        end
        stulpeliuPabaiga()
    end
    imgui.EndChild()

    -- nicko meniu (tas pats kaip Darbuotojų lentelėje)
    if darboAnalize.atidarytiNickMeniu then
        imgui.OpenPopup("##analize_nick")
        darboAnalize.atidarytiNickMeniu = false
    end
    if imgui.BeginPopup("##analize_nick") then
        nickoVeiksmai(darboAnalize.nickMeniu)
        imgui.EndPopup()
    end
    imgui.End()
end)

---------------------------------------------------------------- MAIN
function main()
    if not isSampLoaded() or not isSampfuncsLoaded() then return end
    while not isSampAvailable() do wait(100) end

    math.randomseed(os.time())
    ikeltiDuomenis()
    irasyti(ui.aktNuo, os.date(DATOS_FORMATAS, os.time() - 7 * 86400))
    irasyti(ui.aktIki, os.date(DATOS_FORMATAS))

    sampRegisterChatCommand("dp", function() atidarytiMeniu() end)
    sampRegisterChatCommand("aktyvumas", function() atidarytiMeniu("aktyvumas") end)
    sampRegisterChatCommand("vdd", function() atidarytiMeniu("darbuotojai") end)
    sampRegisterChatCommand("vdf", function() atidarytiMeniu("fondai") end)

    if nust.pasveikinimas then
        sampAddChatMessage(saugusLtu("* DPKT meniu įkeltas. Naudok /dp ir nepamiršk šypsotis :)"), ZALIA)
    end

    -- nustatymai išsaugomi ne dažniau nei kas sekundę (kad slankikliai nerašytų failo kas kadrą)
    while true do
        wait(1000)
        if nustatymaiPakeisti then
            nustatymaiPakeisti = false
            issaugotiNustatymus()
        end
    end
end

-- >>> DPKT versijos pasirinkimas
--------------------------------------------------------------------------------
-- Versijos pasirinkimas iš GitHub (/dpversija). Savarankiškas blokas: toks pat pridėtas
-- ir prie archyvinių versijų (versijos/dpmenuXYZ.lua), kad iš bet kurios būtų galima grįžti.
-- Pasirinkus ne naujausią versiją ji "prisegama" (config\dpkt\prisegta_versija.txt) ir
-- automatiniai atnaujinimai jos nebekeičia, kol nepasirenkama naujausia.
--------------------------------------------------------------------------------
do (function()
    local imgui = require "mimgui"
    local koduote = require "encoding"
    koduote.default = "CP1257"
    local utf8 = koduote.UTF8
    local REPO = "https://raw.githubusercontent.com/d3xter1z/kazkakazkaana/main/"
    local APLANKAS = getWorkingDirectory() .. "\\config\\dpkt"
    local PRISEGTA = APLANKAS .. "\\prisegta_versija.txt"
    local ATNAUJINTA = APLANKAS .. "\\atnaujinta.txt"
    local V = { langas = imgui.new.bool(false), sarasas = nil, pasirinkta = 1, busena = nil, vyksta = false, klausti = false }

    local function skaityti(kelias)
        local f = io.open(kelias, "rb")
        if not f then return nil end
        local t = f:read("*a")
        f:close()
        return t
    end
    local function rasyti(kelias, tekstas)
        if not doesDirectoryExist(APLANKAS) then createDirectory(APLANKAS) end
        local f = io.open(kelias, "wb")
        if not f then return false end
        f:write(tekstas)
        f:close()
        return true
    end
    local function chat(tekstas)
        local ok, t = pcall(function() return utf8:decode(tekstas) end)
        sampAddChatMessage(ok and t or tekstas, 0x33AA33)
    end
    local function dabartine() return tostring(thisScript().version) end

    -- prisegta tik tada, kai prisegta būtent ši versija (įkėlus kitą failą ranka - nebegalioja)
    local prisegta = (skaityti(PRISEGTA) or ""):match("^%s*(.-)%s*$")
    if prisegta ~= "" and prisegta == dabartine() then
        DPKT_PRISEGTA = prisegta
    else
        DPKT_PRISEGTA = nil
        if prisegta ~= "" then os.remove(PRISEGTA) end
    end

    local function parsisiusti(url, kelias)
        os.remove(kelias)
        local baigta = false
        local statusai = require("moonloader").download_status
        downloadUrlToFile(url .. "?t=" .. os.time(), kelias, function(_, status)
            if status == statusai.STATUS_ENDDOWNLOADDATA then baigta = true end
        end)
        local pradzia = os.clock()
        while not baigta and os.clock() - pradzia < 20 do wait(100) end
        wait(200)
        return baigta and doesFileExist(kelias)
    end

    local function gautiSarasa()
        if V.vyksta then return end
        V.vyksta, V.busena = true, "Gaunamas versijų sąrašas..."
        lua_thread.create(function()
            local tmp = APLANKAS .. "\\versijos_tmp.json"
            if not doesDirectoryExist(APLANKAS) then createDirectory(APLANKAS) end
            local ok = parsisiusti(REPO .. "versijos.json", tmp)
            local d = ok and decodeJson(skaityti(tmp) or "")
            os.remove(tmp)
            V.vyksta = false
            if type(d) == "table" and type(d.versijos) == "table" and #d.versijos > 0 then
                V.sarasas, V.busena = d.versijos, nil
                V.pasirinkta = 1
                for i, v in ipairs(d.versijos) do if v.versija == dabartine() then V.pasirinkta = i end end
            else
                V.busena = "Nepavyko gauti versijų sąrašo iš GitHub."
            end
        end)
    end

    local function idiegti(v, naujausia)
        if V.vyksta then return end
        V.vyksta, V.busena = true, "Siunčiama v" .. v.versija .. "..."
        lua_thread.create(function()
            local kelias = thisScript().path
            local tmp = kelias .. ".pasirinkta"
            if not parsisiusti(REPO .. v.failas, tmp) then
                V.vyksta, V.busena = false, "Nepavyko parsisiųsti v" .. v.versija .. "."
                return
            end
            local turinys = skaityti(tmp) or ""
            local failoVersija = turinys:match('script_version%("([^"]+)"%)')
            if #turinys < 10000 or not loadfile(tmp) or failoVersija ~= v.versija then
                os.remove(tmp)
                V.vyksta, V.busena = false, "Parsiųstas failas sugadintas ar ne tos versijos, nieko nekeičiu."
                return
            end
            os.remove(kelias .. ".bak")
            os.rename(kelias, kelias .. ".bak")
            if not os.rename(tmp, kelias) then
                os.rename(kelias .. ".bak", kelias)
                V.vyksta, V.busena = false, "Nepavyko pakeisti scripto failo."
                return
            end
            if naujausia then os.remove(PRISEGTA) else rasyti(PRISEGTA, v.versija) end
            rasyti(ATNAUJINTA, dabartine())
            chat("* DPKT meniu - įdiegta v" .. v.versija .. (naujausia and "" or " (prisegta, automatiniai atnaujinimai išjungti)")
                .. ", perkraunama...")
            wait(500)
            thisScript():reload()
        end)
    end

    function DPKT_VERSIJOS_ATIDARYTI()
        V.langas[0] = true
        V.klausti = false
        if not V.sarasas then gautiSarasa() end
    end

    imgui.OnFrame(function() return V.langas[0] end, function()
        imgui.SetNextWindowSize(imgui.ImVec2(520, 470), imgui.Cond.FirstUseEver)
        imgui.Begin("DPKT versijos pasirinkimas##dpkt_versijos", V.langas)
        imgui.Text("Dabartinė versija: v" .. dabartine() .. (DPKT_PRISEGTA and " (prisegta)" or ""))
        imgui.TextColored(imgui.ImVec4(1.00, 0.80, 0.20, 1.00),
            "Senesnės versijos gali nepalaikyti versijos parinkimo.")
        imgui.TextDisabled("Iš GitHub archyvo įdiegtose versijose jis visada yra per /dpversija.")
        imgui.TextDisabled("Pasirinkus ne naujausią versiją automatiniai atnaujinimai išjungiami,")
        imgui.TextDisabled("kol vėl nepasirinksi naujausios.")
        imgui.Separator()
        if V.busena then imgui.Text(V.busena) end
        if V.sarasas then
            imgui.BeginChild("##dpkt_versiju_sarasas", imgui.ImVec2(0, -60), true)
            for i, v in ipairs(V.sarasas) do
                local zyme = "v" .. tostring(v.versija)
                if i == 1 then zyme = zyme .. "  (naujausia)" end
                if v.versija == dabartine() then zyme = zyme .. "  - dabar" end
                if v.pastaba and v.pastaba ~= "" then zyme = zyme .. "  - " .. v.pastaba end
                if imgui.Selectable(zyme .. "##dpkt_v" .. i, V.pasirinkta == i) then
                    V.pasirinkta, V.klausti = i, false
                end
            end
            imgui.EndChild()
            local v = V.sarasas[V.pasirinkta]
            if v and not V.klausti then
                if imgui.Button("Įdiegti v" .. tostring(v.versija), imgui.ImVec2(200, 0)) and not V.vyksta then V.klausti = true end
                imgui.SameLine()
                if imgui.Button("Atnaujinti sąrašą", imgui.ImVec2(150, 0)) then gautiSarasa() end
            elseif v then
                imgui.Text("Įdiegti v" .. tostring(v.versija) .. "? Scriptas persikraus.")
                if imgui.Button("Taip", imgui.ImVec2(100, 0)) then
                    V.klausti = false
                    idiegti(v, V.pasirinkta == 1)
                end
                imgui.SameLine()
                if imgui.Button("Ne", imgui.ImVec2(100, 0)) then V.klausti = false end
            end
        elseif not V.vyksta then
            if imgui.Button("Gauti versijų sąrašą", imgui.ImVec2(200, 0)) then gautiSarasa() end
        end
        imgui.End()
    end)

    -- /dpversija užregistruojama, kai SA-MP pasiruošęs (scripto main lieka toks pat)
    local senasMain = main
    function main()
        lua_thread.create(function()
            while not isSampAvailable() do wait(100) end
            sampRegisterChatCommand("dpversija", DPKT_VERSIJOS_ATIDARYTI)
            if DPKT_PRISEGTA then
                wait(3000)
                chat("* DPKT meniu - versija v" .. DPKT_PRISEGTA .. " prisegta, automatiniai atnaujinimai išjungti. Pakeisti: /dpversija")
            end
        end)
        return senasMain()
    end
end)() end
-- <<< DPKT versijos pasirinkimas
