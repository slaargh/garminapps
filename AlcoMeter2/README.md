# AlcoMeter

A Garmin Connect IQ widget for the Fenix 8 that estimates your blood alcohol level (‰) while you drink beer. It shows when you will be sober again and keeps a 13-month drinking history.

> **Estimate only. Not for deciding whether you can drive.** The numbers come from a simple formula, not from a measurement. Food, health, medication and individual metabolism all change real blood alcohol a lot.

## Features

### Main screen
- **Current level** in ‰. The number is green below 0.20 ‰, yellow below the 0.5 ‰ drink-driving limit and red above it.
- **Beer count** for the current session.
- **Curve graph** from the first beer until sober. The past part is dimmed, a white line marks *now*, and a dashed red line marks the 0.5 ‰ limit. If you are over the limit, a dot shows the time you drop below it.
- **Sober at** a clock time ("Sober 02:40, in 3h 15m"), or "Sober now".

### Buttons

| Input | Action |
|---|---|
| START | Add a beer |
| UP / swipe down | Beer list |
| MENU (long-press UP) | Beer list |
| DOWN / swipe up | Stats |
| BACK | Back / exit |

Tapping the screen does **not** add a beer, so you can't log one by accident.

### Beer list
- **+ Add beer**, showing the grams of alcohol per beer at your current settings.
- Every beer in the session, newest first, with the time it was logged. Select one to delete it (asks you to confirm).
- **Clear all** removes the whole session (asks you to confirm).

### Sessions
- When you add a beer after you are already sober, the previous session is closed and a new one starts.
- Beers older than 24 h are dropped automatically.
- Each beer saves its grams of alcohol when it is logged, so changing the beer settings later only affects new beers.

### Stats (13 months of history)
- **Month list:** the last 13 months, newest first, with the beer count and the highest ‰ of each month.
- **Week chart:** select a month to see a bar chart with one bar per week (Monday–Sunday). UP/DOWN moves between weeks, and the selected week's dates, beers and highest ‰ show above the bars.
- Only a daily summary is stored (beer count and highest ‰). A session counts on the day of its first beer, so a Friday night that runs past midnight counts as Friday.
- Deleting a beer or using Clear all also updates the stats for the current session.

### Glance
In the widget glance loop, the glance shows the current level and the time you will be sober.

### How the estimate works
The widget uses the Widmark formula with instant absorption:

- Each beer raises the level by *grams of alcohol ÷ (body weight × r)* at the moment you log it. r is 0.68 for men and 0.55 for women.
- The level then falls in a straight line at the burn-off rate (0.15 ‰/h by default) until it reaches zero.
- Body weight and sex come from your Garmin user profile. If the profile doesn't have them, the fallback values from the settings are used.

### Settings
You can change these in Garmin Connect (or Connect IQ) under the widget's settings:

| Setting | Default | Range |
|---|---|---|
| Beer strength (% ABV) | 4.7 | 0.5–15 |
| Beer size (ml) | 330 | 100–1000 |
| Burn-off rate (‰ per hour) | 0.15 | 0.05–0.3 |
| Weight if not in Garmin profile (kg) | 80 | 30–250 |
| Sex if not in Garmin profile | Male | Male / Female |

## Supported devices
Fenix 8 43 mm, 47 mm, Pro 47 mm, Solar 47 mm and Solar 51 mm (see `manifest.xml`).

---

## Developer notes

### Project layout

| Path | Contents |
|---|---|
| `source/AlcoMeterApp.mc` | App entry point: main view and glance |
| `source/AlcoMeterView.mc`, `AlcoMeterDelegate.mc` | Main screen and its button handling |
| `source/BacCalculator.mc` | Widmark model, formatting, colours |
| `source/BacGraph.mc` | Curve drawing |
| `source/DrinkStore.mc` | Current-session beers (persistent storage) |
| `source/BeerListMenu.mc` | Beer list, delete, Clear all |
| `source/StatsStore.mc` | Daily history, month and week summaries |
| `source/StatsMenu.mc`, `MonthWeeksView.mc` | Stats screens |
| `source/AlcoMeterTests.mc` | Unit tests (only built with `-t`) |
| `resources/settings/` | User settings and their defaults |

### Prerequisites
1. Install the **Connect IQ SDK Manager** from <https://developer.garmin.com/connect-iq/sdk/>. Use it to download an SDK and the **devices** you want to build for. A device that isn't downloaded fails with `Invalid device id`.
2. Install the **Monkey C** extension for VS Code (optional, but it makes building easier).
3. Create a **developer key**. You only need to do this once, and you must keep it: builds signed with a different key can't replace each other on the watch.
   - In VS Code: *Monkey C: Generate a Developer Key*
   - Or with openssl:
     ```sh
     openssl genrsa -out developer_key.pem 4096
     openssl pkcs8 -topk8 -inform PEM -outform DER -in developer_key.pem -out developer_key -nocrypt
     ```

Below, `$SDK` is the SDK's `bin` folder, for example:

```sh
SDK=~/Library/Application\ Support/Garmin/ConnectIQ/Sdks/connectiq-sdk-mac-<version>/bin
```

### Run in the simulator
```sh
"$SDK/monkeyc" -f monkey.jungle -d fenix847mm -o bin/AlcoMeter.prg -y /path/to/developer_key
"$SDK/connectiq" &                      # start the simulator
"$SDK/monkeydo" bin/AlcoMeter.prg fenix847mm
```
In VS Code you can do the same with *Run → Run Without Debugging* (F5 debugs).

In the simulator's menus (the exact names vary a little between SDK versions):
- **Time simulation** moves the clock forward to test sessions and stats.
- **Edit Persistent Storage** inspects or clears the stored beers (`drinks`) and history (`statsDays`, `statsOpen`).
- **Edit Application.Properties** changes the settings.

### Unit tests
```sh
"$SDK/monkeyc" -f monkey.jungle -d fenix847mm -t -o bin/AlcoMeterTest.prg -y /path/to/developer_key
"$SDK/monkeydo" bin/AlcoMeterTest.prg fenix847mm -t
```
Or use *Monkey C: Run Tests* in VS Code.

### Install on your own watch (sideloading, no store release)
1. **Build for your exact watch model.** Use the device ID from `manifest.xml` that matches your watch, for example `fenix847mm` for a Fenix 8 47 mm AMOLED:
   ```sh
   "$SDK/monkeyc" -f monkey.jungle -d fenix847mm -r -o AlcoMeter.prg -y /path/to/developer_key
   ```
   `-r` builds a release version without debug info, which is smaller. In VS Code you can use *Monkey C: Build for Device* instead.
2. **Connect the watch** to your computer with its USB cable.
   - The Fenix 8 connects over **MTP**, which macOS can't open by itself. Use a tool such as [OpenMTP](https://openmtp.ganeshrvel.com/). On Windows it shows up in Explorer.
   - Quit Garmin Express first if it is running, because it blocks the connection.
3. **Copy `AlcoMeter.prg`** into the watch's `GARMIN/APPS/` folder.
4. **Disconnect** the watch. It installs the app when you unplug it. AlcoMeter then appears in the widget/glance loop. If it doesn't, add it from the glance settings on the watch.

**To update**, copy a new `.prg` with the same file name over the old one. Build it with the same developer key, or the watch rejects it.

**To remove**, delete the file from `GARMIN/APPS/`, or remove the widget on the watch.

#### Things that work differently when sideloaded
- **Settings can't be changed in Garmin Connect.** That only works for apps installed from the Connect IQ Store, so the defaults in `resources/settings/properties.xml` are used. To use other values, change the defaults there and rebuild.
- **The stored data survives updates** as long as the app ID in `manifest.xml` and the signing key stay the same. That covers the current session and the stats history.
- **Crash logs** are written to `GARMIN/APPS/LOGS/CIQ_LOG.YML` on the watch. To have the app write its own log, create an empty `GARMIN/APPS/LOGS/AlcoMeter.TXT` (named after the `.prg`) and any `System.println` output goes there.

#### Alternative: private beta in the Connect IQ Store
To test the settings in Garmin Connect before a public release:
1. Export a package with *Monkey C: Export Project* (or `monkeyc -e -o AlcoMeter.iq …`).
2. Upload it as a **beta app** in the Connect IQ developer dashboard.

Beta apps are visible only to your own account and install like normal store apps. Settings in Garmin Connect work for them.
