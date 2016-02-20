# AlcoMeter widget for Garmin Connect IQ
Had a drink or two? Fancy one more but not sure if you really should? No worries! Track your drinking and blood alcohol content with this awsum widget for Fenix 3!

## Implemented features
- Widget + navigation walking skeleton
- Add drinks via menu
- History of drinks
- Calculates BAC in real time
- Esimate how many hours until sober

## Planned features:
- Graph of promille/bac over time
- Persist consumed drinks
- Remove drinks from history that don't have effect on the BAC levels (x minutes old drinks)
- Globalization/Localization:
-- Support for other bac unit
-- text translations
-- drinks (now only in liters)
- Configurable user settings: 
-- bac unit (current is used bac by mass, not bac by volume as in for example in the states) 
-- alcohol burn rate
-- own drinks
- Remove previous drink

## Planned code improvements
- Improve navigation code
- Move classes from app to new file(s) / modules
- Add class for handling arrays (list like functions, add, remove, etc.?)