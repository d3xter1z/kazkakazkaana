# DPKT meniu – pakeitimų istorija

Autorius: Dex. Naujausia versija viršuje.

Versijos: 1 – dialogų versija, 2 – mimgui. 2.x.x: vidurinis skaičius keičiasi su didesniais pakeitimais, paskutinis – su smulkiais.

## 2.18.1
- F4 atšaukiamas: paspaudus F4 scriptas iškart atstato SA-MP žymą, tad į klasės pasirinkimą po mirties negrąžina (chate parašoma „F4 atšauktas“). Veikia su SA-MP 0.3.7 R1, R3, R5; Nustatymuose rodoma atpažinta versija.
- Galima išjungti Nustatymuose (Chatas ir serverio langai). Alt+F4 veikia kaip įprastai.

## 2.18.0 – Serverio pranešimai
- Nauja skiltis „Serverio pranešimai“ (Analizės įrankiai): „G kill pranešimai“ (kas ką nužudė lipdamas į tr. priemonę) ir „/kick'ai“ (adminas, žaidėjas, priežastis).
- Pranešimai renkami iš chato tik kol esi ON (su nuleistu žaidimu be Anti-ESC – ne) – tai parašyta raudonai skilties viršuje. Istorija saugoma faile (config\dpkt\serverio_pranesimai.json), lieka perkrovus.
- Paieška pagal nicką, „Tik šiandien“, kopijavimas, istorijos išvalymas. Paspaudus nicką – nukopijuojamas.

## 2.17.1
- Nustatymuose (Išvaizda) – temos: Klasikinė (kaip anksčiau), Mėlyna (pagal nutylėjimą) ir Smaragdinė. Persijungia iškart.
- Smaragdinė: plokščios kortelės be rėmelių, daugiau oro, žaliai mėlynas akcentas. Mėlyna: rėmeliai, apvalesni laukai ir mygtukai, mėlynas akcentas.
- Kairiajame meniu – aukštesni punktai, pažymėtas punktas su akcento spalvos juostele, grupių pavadinimai akcento spalva.
- Skilčių pavadinimai storu šriftu, pavadinimo juostoje šalia – versija, apačioje – akcento spalvos linija.
- Pagrindiniame – /dpversija komandų sąraše.
- Pagrindinis langas nebeslenka horizontaliai laikant Shift ir sukant ratuką.

## 2.17.0 – Versijos pasirinkimas
- Nustatymuose „Versijos pasirinkimas“ (arba komanda /dpversija): galima įdiegti ankstesnę versiją iš GitHub – 27 išlikusios versijos nuo v3.4 iki dabartinės (v3.4–v5.8 – sena numeracija, iki 2.9.0).
- Pasirinkta ne naujausia versija prisegama: automatiniai atnaujinimai jos nebekeičia, kol vėl nepasirenkama naujausia. Įkėlus scriptą chate primenama, kad versija prisegta.
- Į visas archyvines versijas pridėtas /dpversija, tad grįžti galima iš bet kurios. Senesnės versijos gali nepalaikyti versijos parinkimo meniu – jose naudok /dpversija.

## 2.16.1
- Event fonduose „Davei ... €“ parašoma tik įsitikinus, kad serveris neatsakė „Tokios komandos nėra“. Be prieigos prie /mgduoti, /tduoti ar /eduoti rašoma tik „Neturi prieigos prie komandos ...“, o „Duoti pinigų“ lange tai primenama.

## 2.16.0 – Juodieji sąrašai
- Blist skiltyje – sarg.lt juodieji sąrašai (Mafijos/gaujos, Teisėsaugos, Direktorių, Darbų su pakvietimais): nickas, priežastis, nuo, iki, terminas, kas įtraukė. Pirmą kartą atidarius parsiunčiama iš sarg.lt automatiškai, paskui – mygtuku „Atnaujinti iš sarg.lt“. Sąrašas išsaugomas ir lieka perkrovus scriptą.
- Prisijungę ir sąraše esantys žaidėjai rodomi raudonai (su žaliu tašku), antraštėje – kiek tokių yra.
- Paieška pagal nicką ar priežastį, varnelė „Tik prisijungę“. Paspaudus nicką – „Kopijuoti nicką“.
- Prie formos parašoma, jei įvestas žaidėjas jau yra juodajame sąraše (raudonai – jei tame pačiame tipe).
- Jei sarg.lt nepasiekiamas – „Įkelti iš failo“: puslapis išsaugomas naršyklėje (Ctrl+S) kaip moonloader\config\dpkt\juodieji.html.
- „Žaidėjo profilis“ pašalintas (kartu ir jo mygtukai Direktoriuose bei nicko meniu).

## 2.15.3
- Nustatymuose mygtukas „Atsisiųsti iš naujo“: parsiunčia GitHub'e esantį scriptą net jei versija ta pati (pvz. kai failas buvo įkeltas rankiniu būdu).

## 2.15.2
- Direktoriuose mygtukas „Paskutinė savaitės suvestinė“: atidaro paskutinę padarytą suvestinę nepaleidžiant patikros iš naujo. Suvestinė išsaugoma faile, tad lieka ir perkrovus scriptą ar žaidimą.
- Paspaudus „Savaitės suvestinė“ pirma atsidaro langas su datomis: iš anksto įrašyta nuo prieš 7 d. iki šiandien, galima pasirinkti bet kokį laikotarpį (daugiausia 31 d.). Raudonai – mažiau nei 7 val. per pasirinktą laikotarpį.
- Suvestinėje direktoriai ir pavaduotojai rodomi atskirai: dvi dalys su antraštėmis (kiek žmonių ir kiek žaidė mažiau nei 7 val.), rūšiavimas veikia kiekvienos dalies viduje. Kopijuojant – ta pati tvarka.
- „Savaitės suvestinė“ nebe (WIP).

## 2.15.1
- Backend changes.

## 2.15.0 – Direktorių suvestinė ir žaidėjo profilis
- Direktoriuose mygtukas „Savaitės suvestinė“: gauna /direkt ir kiekvienam direktoriui bei pavaduotojui patikrina /info už kiekvieną iš paskutinių 7 dienų. Atskirame lange: darbas, pareigos, nickas, minutės kiekvieną dieną ir iš viso; raudonai – mažiau nei 7 val. per 7 dienas. Galima rūšiuoti nuo mažiausiai žaidusių, kopijuoti, paspaudus nicką – „Kopijuoti nicką“.
- Nauja skiltis „Žaidėjo profilis“ (Analizės įrankiai): visa /info informacija, įspėjimų istorija (per jo darbo direktorių) ir užblokavimai (/gautiban nickas, lentelė Data | Admin | Priežastis | Trukmė: „x H“ – laikinas ban x valandų, be trukmės – amžinas (raudonai); serverio langas paslepiamas). Jei nėra prieigos prie įspėjimų ar /gautiban, ta dalis praleidžiama, o likusi informacija vis tiek surenkama. Mygtukai „Kopijuoti nicką“, „Aktyvumas (7d.)“.
- Direktoriuose prie pasirinkto darbo mygtukai „Direktoriaus / Pavaduotojo aktyvumas (7d.)“ ir „Direktoriaus / Pavaduotojo profilis“ – patikra prasideda iškart. Paspaudus nicką kitose lentelėse taip pat atsirado „Aktyvumas (7d.)“ ir „Žaidėjo profilis“.
- Serverio atsakymas „Toks žaidėjas nežaidžia“ atpažįstamas: suvestinėje rodoma „Nežaidžia“ ir likusios dienos nebetikrinamos, profilyje parašoma, aktyvumo patikra nutraukiama.
- Abiem – „Sugeneruoti (Dev)“.
- „Žaidėjo profilis“ ir „Savaitės suvestinė“ pažymėti geltonu (WIP) – gali veikti netinkamai.
- Jei patikra turėtų trukti (ar jau trunka) ilgiau nei 120 s, statuse parašoma „Geriau kavos eik pasiimt... užtruksim...“.
- Greitesnės patikros: serverio atsakymo laukiama 0,5 s (buvo 2 s, seni nustatymai perkeliami), o pauzė tarp komandų skaičiuojama nuo išsiųstos komandos – atsakymo laukimas prie jos nebepridedamas. /info siunčiami kas 0,75 s, o ne kas ~2,75 s. Vėliau atėjęs /info atsakymas dar priimamas iki pauzės pabaigos.

## 2.14.0 – Backend changes
- Backend changes.

## 2.13.1
- Atnaujinimų apsauga: parsiųstas scriptas įdiegiamas tik tada, kai jo versija sutampa su version.json (kitaip atnaujinimas atšaukiamas).

## 2.13.0 – Užblokavimai
- Nauja skiltis „Užblokavimai“ (Įrankiai): atidarius automatiškai siunčiamas /bans, serverio langas paslepiamas, rodoma lentelė Žaidėjas | Admin | Data | Priežastis su paieška.
- Paspaudus užblokuotą žaidėją: Kopijuoti nicką arba Atblokuoti (su patvirtinimu, /unban nickas, po to sąrašas atnaujinamas). Paspaudus adminą: Kopijuoti nicką.
- „Sugeneruoti (Dev)“ su atsitiktiniais duomenimis (atblokuojant nieko nesiunčiama).

## 2.12.2
- Aktyvumo stulpelis „Darbas“ prisitaiko prie ilgiausio teksto (nebenusikerpa, pvz. „Tolimųjų reisų vairuotojas | Cosa Nostra“).
- Raudonai pažymima ir diena, kai darbas pasikeitė be „nuo“ datos (pvz. įstojo į mafiją) – su „(pasikeitė)“.
- Darbas ir mafija/gauja rodomi per kablelį (pvz. „Tolimųjų reisų vairuotojas, Cosa Nostra“), kad kopijuojant nesimaišytų su stulpelių skirtuku.
- Iš aktyvumo formos išimtas „Darbas“ pasirinkimas: darbas ir jo rodikliai imami iš /info, direktoriaus užsidėti nebereikia.

## 2.12.1
- Atidarius „Direktoriai“ skiltį /direkt išsiunčiamas automatiškai – nebereikia spausti „Atnaujinti“.

## 2.12.0 – Darbas aktyvume
- Aktyvumo patikra iš /info paima žaidėjo darbą ir nuo kada jame dirba, pvz. „Darbas: Mechanikas nuo 2026-09-26“. Mafijoms ir gaujoms rodomas jų pavadinimas (pvz. „Cosa Nostra“), pravardės ir „Nedirbi“ nuimami.
- Jei per tikrinamą laikotarpį darbas pasikeitė (ar žaidėjas įsidarbino), lentelėje atsiranda stulpelis „Darbas“, o diena, kai įsidarbino, pažymima raudonai su „(įsidarbino)“.
- Iš /info paimami ir darbo rodikliai, kurie eina po žuvų eilutės (pvz. Atvyko, Pardavimai, Atgabenimai, Baudos | Iškvietimai, Žala) – kiekvienam atskiras stulpelis su suma ir vidurkiu. Tam nereikia direktoriaus.
- Darbas ir rodikliai įtraukiami į „Kopijuoti visą lentelę“, Dev režime generuojami ir jie, ir darbo pasikeitimas.

## 2.11.2
- Atnaujinimai iškart po įkėlimo: versija ir failas imami iš paskutinio GitHub commit'o (per GitHub API), o ne iš „main“, kurį GitHub iki ~5 min. rodo seną.

## 2.11.1
- Skiltis „Patikros statusas“ pervadinta į „Statusas“.

## 2.11.0 – Automatiniai atnaujinimai
- Įkėlus scriptą tikrinama GitHub (d3xter1z/kazkakazkaana) ir, jei yra naujesnė versija, ji parsisiunčiama ir įdiegiama automatiškai.
- Parsiųstas failas patikrinamas (ar užsikrauna), senas išsaugomas kaip dpmenu.lua.bak, sugadintas atnaujinimas neįdiegiamas.
- Po atnaujinimo chate ir statuse parašoma, iš kurios į kurią versiją atnaujinta.
- Nustatymuose: „Automatiniai atnaujinimai“ ir „Tikrinti atnaujinimus dabar“.

## 2.10.4
- Fondų išrašuose „JS mafia_blist“ (serverio vidinis įrašas) ir kiti įrašai su tarpais rodomi pilkai ir nepaspaudžiami, jiems pinigų duoti neleidžiama.

## 2.10.3
- Nustatymuose varnelė „/noriudarbo be ID atidaro „Pakeisti darbą““, pagal nutylėjimą išjungta – pirmenybė serverio komandai.

## 2.10.2
- Parašius /noriudarbo (be ID) atsidaro „Pakeisti darbą“. Su ID komanda keliauja serveriui kaip anksčiau.

## 2.10.1
- „Event“ dabar atskira meniu grupė su trimis skiltimis: Mafijų, gaujų fondas, Teisėsaugos fondas, Event fondas. Atidarius skiltį jos fondas užklausiamas automatiškai.

## 2.10.0 – Event skiltis
- Event fondai: Mafijų, gaujų (/mgfondas), Teisėsaugos (/tfondas) ir Event (/efondas).
- Atidarius skiltį ar pasirinkus fondą komanda išsiunčiama automatiškai, serverio langas ir chato eilutė paslepiami, duomenys rodomi lentelėje: likutis, įplaukos, išlaidos, Data | Vardas | Suma.
- Paspaudus nicką: Kopijuoti nicką arba Duoti pinigų iš fondo (/mgduoti, /tduoti, /eduoti). Tikrinama, ar fonde pakanka pinigų, po davimo fondas atnaujinamas.
- Paieška pagal nicką ir „Sugeneruoti (Dev)“.

## 2.9.0 – Pakeitimų skiltis
- Nauja skiltis „Pakeitimai“ su visa versijų istorija.
- Versijos pernumeruotos: 1 – dialogų versija, 2 – mimgui. 2.x.x: vidurinis skaičius – didesni pakeitimai, paskutinis – smulkūs.
- Atidarius meniu 1 iš 10 kartų Pagrindiniame vietoj palinkėjimo šypsotis raudonai rašoma „Kas skaitys tas GD“.

## 2.8.3
- Nauji „Pakeisti darbą“ ID (17 darbų): Policininkų 1, Medikų 2, Cosa Nostra 6, Tolimųjų reisų 7, FTB 9, Mechanikų 12, Ginklų prekeivių 15, Reporterių 16, Taksi 21, Immortal 26, Interpolo 27, Apsaugos 28, Armijos 29, Radijos 32, SPD 33, „Grove Street“ 34, „The Ballas“ 35.

## 2.8.2
- Atimant direktoriaus statusą tikrinama, ar jis prisijungęs. Jei ne – naudojama /skirtidiroff <nick> 0.

## 2.8.1
- Darbo analizė atbuline data: neaktyvumas skaičiuojamas nuo pasirinktos datos.
- Jei praeitos dienos sąraše nėra Įspėjimų ar Priimtas stulpelių, rašoma „nėra duomenų“.

## 2.8.0 – Darbo analizė
- Darbų patikroje vienas mygtukas „Tikrinti“ (/dfondas + /visidarbuotojai).
- Po patikros atsidaro langas „Darbo analizė“: fondas, darbuotojai, direktorius ir pavaduotojas, neaktyvūs, su įspėjimais, nauji, daugiausiai dirbę, rodiklių sumos ir vidurkiai, darbuotojų lentelė su nicko meniu.
- Datos pasirinkimas ir „Sugeneruoti (Dev)“.
- Paslėpti /skirtidir atsakymai, ateinantys jau po patikros, ir tuščios eilutės po scripto komandų.

## 2.7.6
- Pridėtas SPD (ID 20) prie „Pakeisti darbą“.

## 2.7.5
- Nauji „Pakeisti darbą“ ID (18 darbų, su abiem Taksi firmomis, Narkotikų prekeiviais, Reporteriais).

## 2.7.4
- Pavaduotojo statusas atimamas per to darbo direktorių (/skirtipav <nick>), po to atnaujinama /direkt.

## 2.7.3
- Įspėjimų istorija pagal tikrą serverio langą: santrauka „įspėtas direktoriaus N kartų“ ir lentelė Data | Priežastis | Davė.

## 2.7.2
- Įspėjimų istorijoje tekstas nebenusikerpa: stulpeliai pagal turinį, langas praplatėja, jei reikia – horizontali slinktis.

## 2.7.1
- Dev režime tikra aktyvumo patikra nebeužgožiama senų atsitiktinių duomenų.

## 2.7.0 – Darbo statistika aktyvume
- Aktyvumo patikra renka ir darbo statistiką kiekvienai dienai (baudos, atvykimai, pagydymai ir t.t.) per /visidarbuotojai <data>.
- Sumos ir vidurkiai, darbas parenkamas automatiškai arba rankiniu būdu.

## 2.6.2
- Direktoriuose: „Kopijuoti direktoriaus nicką“, „Kopijuoti pavaduotojo nicką“.

## 2.6.1
- Mažiausias lango dydis 1300x750 (mažesniame ekrane – visas ekranas).

## 2.6.0 – Nicko meniu ir įspėjimų istorija
- Darbuotojų lentelėje nickai paspaudžiami: Tikrinti žaidėjo aktyvumą, Žaidėjo įspėjimų istorija (/ispejimai per to darbo direktorių, atskirame lange), Kopijuoti nicką.
- Veikia ir su atsitiktiniais duomenimis.

## 2.5.7
- Aktyvumo eilutės kopijuojamos paspaudus, mygtukas „Kopijuoti visą lentelę“.

## 2.5.6
- Su nuimta /arsutapo varnele scriptas komandos neliečia.

## 2.5.5
- /arsutapo be paskyrų atidaro Paskyrų sutapimo skiltį, su vienu nicku jį įrašo į laukelį.

## 2.5.4
- Serverio atsakymo laukimas pagal nutylėjimą 2 s.

## 2.5.3
- /direkt ir /arsutapo nustatymai atskirti: /direkt pagal nutylėjimą rodo serverio lentelę, mygtukai meniu visada atnaujina meniu.

## 2.5.2
- Lentelės nebesubyra tempiant stulpelių ribas.
- Pagrindiniame puslapyje tekstas nebenusikerpa, nicko stulpelis prisitaiko prie ilgiausio nicko.

## 2.5.1
- Patikros metu serverio atsakymai į /skirtidir slepiami chate ir rodomi statuse.

## 2.5.0 – Patikros statusas
- Visos scripto žinutės perkeltos iš chato į skiltį „Patikros statusas“: eiga, trukmė, likęs laikas, perspėjimai ir visi pranešimai su laiku.
- Chate liko tik įkėlimo žinutė, naujausias pranešimas kelias sekundes rodomas lango apačioje.
- Nustatymas „Pranešimus rodyti ir chate“.

## 2.4.2
- Ryškesnės linijos, rėmeliai aplink laukus ir mygtukus, šviesesni pažymėjimai.

## 2.4.1
- Vaivorykštinė juosta pagal nutylėjimą išjungta, vietoj jos juoda pavadinimo juosta.

## 2.4.0 – Direktorių žymės
- Prieš renkant darbuotojus paimama /direkt lentelė: direktorius pažymimas (dir), pavaduotojas (pav).
- Išimtas „Nr.“ stulpelis.

## 2.3.2
- Atsitiktiniai duomenys atnaujinti: kiekvieno darbo stulpeliai, praeitos dienos formatas.
- Dev režime galima generuoti duomenis ir atbuline data.

## 2.3.1
- Pataisytas praeitos dienos formatas („Šiandien 431 203min“, „D. p. …€“, lango antraštė – data).

## 2.3.0 – Darbuotojai pagal datą
- /visidarbuotojai pagal datą: datos laukas su „Šiandien“ / „Vakar“.
- Jei fondo nepavyko gauti, rašomas 0.

## 2.2.1
- Perrašytas /visidarbuotojai atpažinimas pagal tikrą serverio output'ą: kiekvieno darbo stulpeliai, nukirptos chato eilutės papildomos iš lango, poskyriai.

## 2.2.0 – Nustatymai ir Dev režimas
- Skiltis „Nustatymai“ su Dev režimu, nustatymai išsaugomi nustatymai.json.
- Persijungimai rodomi tik tada, kai yra bendras IP arba SAMP ID, Dev sutapimo scenarijų mygtukai.
- Failas pervadintas į dpmenu.lua, autorius Dex.
- „Tokios komandos nėra“ – rašoma „Neturi prieigos prie komandos X“, patikra nutraukiama, direktorius nuimamas.
- Derinimo žurnalas debug_visidarbuotojai.txt.

## 2.1.0 – Paskyrų sutapimas
- Nauja skiltis „Paskyrų sutapimas“ (/arsutapo): bendri IP, bendras SAMP ID, persijungimai tarp paskyrų ir spalvota išvada.

## 2.0.0 – Perrašyta ant mimgui
- Vietoj dialogų – vienas mimgui langas su skirtukais, juodas nepermatomas dizainas, apačioje „Made by Dex, with love, mua :3“.
- Išimta „Mafijos/Gaujos“ skiltis, pridėtas „Pagrindinis“ puslapis.
- Aktyvume prisijungusių žaidėjų sąrašas.

## 1.x – Dialogų versija
- Pirmoji versija buvo ant SA-MP dialogų (pradžioje vadinosi „mgdpkt“).
- Mafijų ir gaujų užšaldymas, darbo /dfondas ir /visidarbuotojai per /skirtidir, /blist (tipai 1–4, 1–60 mėn.) su nicko patikra.
- Pervadinta į DPKT meniu, komanda /dp, „Pakeisti darbą“ (/noriudarbo).
- Visų darbų /visidarbuotojai ir /dfondas su išsaugojimu diske.
- Aktyvumas per /info kiekvienai dienai, trumposios komandos /aktyvumas, /vdd, /vdf.
- /direkt valdymas: direktoriai, pavaduotojai, jų aktyvumas ir statuso atėmimas.
