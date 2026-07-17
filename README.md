[README.md](https://github.com/user-attachments/files/30037799/README.md)
<a name="top"></a>

**🇬🇧 English | [🇩🇪 Deutsch](#deutsch)**

---

# Master Roller Shutter Control (Home Assistant Blueprint)

A comprehensive blueprint for fully automated control of individual roller shutters in Home Assistant – with sun-position shading, extreme-heat protection, ventilation and walkthrough logic, plus presence and holiday awareness.

> **Note:** One automation is created per shutter from the blueprint. That way each room can have its own facade orientation, temperature thresholds and positions.

## Import

[![Open your Home Assistant instance and show the blueprint import dialog.](https://my.home-assistant.io/badges/blueprint_import.svg)](https://my.home-assistant.io/redirect/blueprint_import/?blueprint_url=https%3A%2F%2Fraw.githubusercontent.com%2Falexsilbernagel%2Fha-rolladensteuerung%2Fmain%2Fblueprints%2Fmaster_rolladensteuerung.yaml)

Or manually: **Settings → Automations & Scenes → Blueprints → Import Blueprint** and paste this URL:

```
https://raw.githubusercontent.com/alexsilbernagel/ha-rolladensteuerung/main/blueprints/master_rolladensteuerung.yaml
```

## What the blueprint does

It combines six jobs that would otherwise require separate automations:

- **Morning opening** – based on time, sunrise, presence, weekday, public holiday and house mode.
- **Sun-position shading** – the shutter only lowers when the sun actually hits *this* facade (azimuth window per orientation), it is bright enough (PV power or lux) *and* the temperature justifies it.
- **Extreme-heat protection** – at very high indoor *and* outdoor temperature the shutter moves to a separate, further-closed position. With hysteresis to prevent flapping.
- **Ventilation position** – a tilted window keeps the shutter at a defined minimum height.
- **Walkthrough / cross-ventilation logic** – a fully opened window/patio door raises the shutter, even at night, before opening time and out of a manually closed state.
- **Evening closing** – after sunset with an adjustable offset, taking open windows into account.

Decisions always follow a fixed **priority chain**: safety beats comfort, comfort beats energy.

| Prio | Branch | Effect |
|---|---|---|
| 0 | Fire alarm | holds still (`stop`) so an external escape-route automation is not overwritten |
| 1a | Walkthrough | window fully open → fully up; only walkthrough position while shading is active |
| 1b | Ventilation | tilted window → minimum height |
| 2 | Evening check | push notification if a window is still fully open at night |
| 3 | Closing | night → close (only down to ventilation height if tilted) |
| 4a | Extreme-heat protection | indoor + outdoor very hot → far-closed position |
| 4b | Shading | sun on facade + heat + brightness → shading position |
| 4c | Raising | no sun protection needed → fully up |

## Requirements

**Mandatory**

- A shutter (`cover`) with position support (`set_cover_position` + `current_position` attribute). Pure open/close motors do **not** work.
- The standard `sun.sun` integration
- A weather entity (`weather.*`)
- Indoor and outdoor temperature sensors (`device_class: temperature`)
- An `input_select` as house mode (options: `Zuhause`, `Abwesend`, `Urlaub`)
- An `input_boolean` as fire-alarm status

**Optional**

- Window sensors (tilt and/or fully open)
- Presence sensors
- PV power sensor and/or illuminance sensor (`device_class: illuminance`)
- Trend sensor for anticipatory shading
- Workday sensor for holiday detection
- Timer for notification pause
- Notify service (a notify group is recommended)

Setup details for all helpers and template sensors are in the [full documentation](docs/Documentation_EN.pdf).

## Quick start

1. Import the blueprint via the button above.
2. Create the required helpers (house mode, fire-alarm boolean – see docs).
3. Create the first automation from the blueprint and fill in all inputs for **one** shutter.
4. Observe for a sunny day or two and adjust the thresholds.
5. Only once one shutter runs cleanly, transfer the settings to the rest.

### Recommendations by orientation

| Facade | Shading morning / afternoon | Note |
|---|---|---|
| East | 20–30 % / 30 % | Early low sun; in shade during the afternoon |
| South | 50–65 % / 30–65 % | Roof overhang often helps |
| West | 60 % / 40 % | **Further closed in the afternoon** – reversing this is the most common misconfiguration |
| North | – | Shading usually unnecessary, rest still useful |

## Important notes

- **Temperature thresholds** should be at least 2 K apart (e.g. 20 °C / 22.5 °C), otherwise the shutter flaps.
- **`hitze_alarm` is OR-linked:** a very low outdoor threshold makes the indoor temperature practically irrelevant. Choose deliberately.
- **The fire-alarm boolean is not reset by the blueprint.** That belongs in a separate, acknowledged reset automation – an example is in the documentation. While the boolean is `on`, all shutter automations are suspended.
- **Choose positions at least 10 % apart** so the manual-override detection can tell them apart.

## Documentation

The full documentation (operating principle, all inputs, helper and template setup, window sensors, fire-alarm coupling, troubleshooting) is available as a PDF: [English](docs/Documentation_EN.pdf) · [Deutsch](docs/Dokumentation_DE.pdf).

## Changelog
**V85** – Fix: the PV trigger was a `state` trigger with `for: 2min` and practically never fired on a continuously changing power sensor, because the `for` window restarted on every value change – so shading never reacted to PV power directly, only on the periodic net. Now a `numeric_state` trigger (`above`/`below` `pv_schwelle`, each `for: 2min`), which debounces correctly. Change: safety net (`time_pattern`) tightened from `/15` to `/5` minutes so the fine reopening edge at `pv_schwelle − 500` / `lux_schwelle − 5000` is caught within 5 instead of 15 minutes. `mode: restart` and the position guards still prevent redundant travel.

**V84** – New: fully opened window raises the shutter completely when no sun-position mode is active (also at night, before opening time, from a manually closed state); only walkthrough position while shading is active. Fix: variable order – `sonne_auf_f` is now defined before `hitze_extrem`. New: workday sensor input for holiday detection. New: helper variables to disentangle the brightness logic.

**V83** – Extreme-heat protection with a separate position and hysteresis over indoor and outdoor temperature.

**V82** – Anti-flapping: debounced PV trigger, `mode: restart`, 15-minute safety net.

## Contributing

Found a bug or have an idea? Feel free to open an [issue](../../issues) or a pull request.

## License

Released under the [MIT License](LICENSE). Use at your own risk – test the fire-alarm coupling once in full before productive use.

<br>

---

<a name="deutsch"></a>

**[🇬🇧 English](#top) | 🇩🇪 Deutsch**

---

# Master-Rolladensteuerung (Home Assistant Blueprint)

Ein umfassender Blueprint zur vollautomatischen Steuerung einzelner Rollos in Home Assistant – mit Sonnenstandsbeschattung, Extrem-Hitzeschutz, Lüftungs- und Durchgangslogik, Präsenz- und Feiertagserkennung.

> **Hinweis:** Für jedes Rollo wird eine eigene Automatisierung aus dem Blueprint erzeugt. So kann jeder Raum eigene Himmelsrichtungen, Temperaturschwellen und Positionen bekommen.

## Import

[![Open your Home Assistant instance and show the blueprint import dialog.](https://my.home-assistant.io/badges/blueprint_import.svg)](https://my.home-assistant.io/redirect/blueprint_import/?blueprint_url=https%3A%2F%2Fraw.githubusercontent.com%2Falexsilbernagel%2Fha-rolladensteuerung%2Fmain%2Fblueprints%2Fmaster_rolladensteuerung.yaml)

Alternativ manuell: **Einstellungen → Automatisierungen & Szenen → Blueprints → Blueprint importieren** und diese URL einfügen:

```
https://raw.githubusercontent.com/alexsilbernagel/ha-rolladensteuerung/main/blueprints/master_rolladensteuerung.yaml
```

## Was der Blueprint macht

Er vereint sechs Aufgaben, die man sonst in einzelnen Automatisierungen bauen müsste:

- **Morgendliches Öffnen** – abhängig von Uhrzeit, Sonnenaufgang, Präsenz, Wochentag, Feiertag und Hausmodus.
- **Sonnenstandsbeschattung** – das Rollo fährt nur herunter, wenn die Sonne tatsächlich auf *diese* Fassade scheint (Azimut-Fenster je Himmelsrichtung), es hell genug ist (PV-Leistung oder Lux) *und* die Temperatur das rechtfertigt.
- **Extrem-Hitzeschutz** – bei sehr hoher Innen- *und* Außentemperatur fährt das Rollo auf eine separate, weiter geschlossene Position. Mit Hysterese gegen Pendeln.
- **Lüftungsposition** – gekipptes Fenster hält das Rollo auf einer definierten Mindesthöhe.
- **Durchgangs- und Querlüftungslogik** – ganz geöffnetes Fenster / Terrassentür fährt das Rollo hoch, auch nachts, vor der Öffnungszeit und aus manuell geschlossenem Zustand.
- **Abendliches Schließen** – nach Sonnenuntergang mit einstellbarem Versatz, unter Berücksichtigung offener Fenster.

Die Entscheidung fällt immer über eine feste **Prioritätenkette**: Sicherheit schlägt Komfort, Komfort schlägt Energie.

| Prio | Zweig | Wirkung |
|---|---|---|
| 0 | Brandalarm | hält still (`stop`), damit eine externe Fluchtweg-Automatisierung nicht überschrieben wird |
| 1a | Durchgang / Querlüften | Fenster ganz offen → ganz auf, bei aktiver Beschattung nur Durchgangsposition |
| 1b | Lüftung | gekipptes Fenster → Mindesthöhe |
| 2 | Abend-Check | Push, falls ein Fenster nachts noch ganz offen steht |
| 3 | Schließen | Nacht → schließen (bei Kipp nur bis Lüftungsposition) |
| 4a | Extrem-Hitzeschutz | Innen + Außen sehr heiß → weit geschlossene Position |
| 4b | Beschattung | Sonne auf Fassade + Hitze + Helligkeit → Beschattungsposition |
| 4c | Auffahren | kein Sonnenschutz nötig → ganz auf |

## Voraussetzungen

**Pflicht**

- Ein Rollo (`cover`) mit Positionsunterstützung (`set_cover_position` + Attribut `current_position`). Reine Auf/Zu-Antriebe funktionieren **nicht**.
- Standard-Integration `sun.sun`
- Eine Wetterentität (`weather.*`)
- Raum- und Außentemperatursensor (`device_class: temperature`)
- `input_select` als Hausmodus (Optionen: `Zuhause`, `Abwesend`, `Urlaub`)
- `input_boolean` als Brandalarm-Status

**Optional**

- Fenstersensoren (Kipp und/oder ganz offen)
- Präsenzmelder
- PV-Leistungssensor und/oder Helligkeitssensor (`device_class: illuminance`)
- Trend-Sensor für vorausschauende Beschattung
- Workday-Sensor für Feiertagserkennung
- Timer für Benachrichtigungspause
- Notify-Dienst (empfohlen: eine Notify-Gruppe)

Details zur Einrichtung aller Helfer und Template-Sensoren stehen in der [ausführlichen Dokumentation](docs/Dokumentation_DE.pdf).

## Schnellstart

1. Blueprint über den Button oben importieren.
2. Benötigte Helfer anlegen (Hausmodus, Brandalarm-Boolean – siehe Doku).
3. Erste Automatisierung aus dem Blueprint erstellen, alle Inputs für **ein** Rollo ausfüllen.
4. Ein bis zwei sonnige Tage beobachten und die Schwellen justieren.
5. Erst wenn ein Rollo sauber läuft, die Einstellungen auf die übrigen Rollos übertragen.

### Einstellempfehlungen nach Himmelsrichtung

| Fassade | Beschattung vormittags / nachmittags | Hinweis |
|---|---|---|
| Ost | 20–30 % / 30 % | Frühe flache Sonne; nachmittags im Schatten |
| Süd | 50–65 % / 30–65 % | Dachüberstand hilft oft mit |
| West | 60 % / 40 % | **Nachmittags weiter zu** – häufigste Fehlkonfiguration ist die umgekehrte Reihenfolge |
| Nord | – | Beschattung meist überflüssig, Rest trotzdem nützlich |

## Wichtige Hinweise

- **Temperaturschwellen** sollten mindestens 2 K auseinanderliegen (z. B. 20 °C / 22,5 °C), sonst pendelt das Rollo.
- **`hitze_alarm` ist ODER-verknüpft:** eine sehr niedrig gesetzte Außenschwelle macht die Innentemperatur praktisch wirkungslos. Bewusst wählen.
- **Der Brandalarm-Boolean wird vom Blueprint nicht zurückgesetzt.** Das gehört in eine eigene, quittierte Reset-Automatisierung – ein Beispiel steht in der Dokumentation. Solange der Boolean `on` ist, sind alle Rollo-Automatisierungen stillgelegt.
- **Positionen mit mindestens 10 % Abstand** wählen, damit die Override-Erkennung sie unterscheiden kann.

## Dokumentation

Die vollständige Dokumentation (Funktionsprinzip, alle Inputs, Helfer- und Template-Anleitung, Fenstersensorik, Brandalarm-Kopplung, Fehlersuche) liegt als PDF vor: [Deutsch](docs/Dokumentation_DE.pdf) · [English](docs/Documentation_EN.pdf).

## Changelog
**V85** – Fix: Der PV-Trigger war als `state` mit `for: 2min` definiert und feuerte bei einem sich ständig ändernden Watt-Sensor praktisch nie, da das `for`-Fenster bei jeder Wertänderung neu startete – die Beschattung reagierte dadurch nie direkt auf die PV-Leistung, sondern nur im Zufallstakt. Jetzt `numeric_state` (`above`/`below` `pv_schwelle`, je `for: 2min`), was korrekt entprellt. Änderung: Sicherheitsnetz (`time_pattern`) von `/15` auf `/5` Minuten verkürzt, damit die Öffnungs-Feinkante bei `pv_schwelle − 500` bzw. `lux_schwelle − 5000` binnen maximal 5 statt 15 Minuten erkannt wird. `mode: restart` und die Positions-Guards verhindern weiterhin Mehrfachfahrten.

**V84** – Neu: Ganz geöffnetes Fenster fährt das Rollo ganz auf, wenn kein Sonnenstands-Modus aktiv ist (auch nachts, vor der Öffnungszeit und aus manuell geschlossenem Zustand); bei aktiver Beschattung weiterhin nur bis zur Durchgangsposition. Fix: Variablenreihenfolge – `sonne_auf_f` wird jetzt vor `hitze_extrem` definiert. Neu: Workday-Sensor als Input für Feiertagserkennung. Neu: Hilfsvariablen zur Entzerrung der Helligkeitslogik.

**V83** – Extrem-Hitzeschutz mit separater Position und Hysterese über Innen- und Außentemperatur.

**V82** – Anti-Flapping: PV-Trigger mit Entprellung, `mode: restart`, 15-Minuten-Sicherheitsnetz.

## Mitmachen

Fehler gefunden oder eine Idee? Gerne ein [Issue](../../issues) eröffnen oder einen Pull Request stellen.

## Lizenz

Veröffentlicht unter der [MIT-Lizenz](LICENSE). Nutzung auf eigene Verantwortung – insbesondere die Brandalarm-Kopplung vor dem Produktivbetrieb einmal vollständig durchtesten.

[⬆ nach oben / back to top](#top)
