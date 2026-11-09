import Toybox.Application;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.UserProfile;

// Result of a BAC simulation. All levels are in per mille (‰), times are epoch seconds.
(:glance)
class BacResult {
    var hasDrinks as Boolean = false;
    var current as Float = 0.0;
    var peak as Float = 0.0;
    var startTime as Number = 0;
    // When the level reaches 0.00 (after the last drink).
    var soberAt as Number = 0;
    // When the level last drops to the driving limit; 0 if it never exceeds it.
    var driveAt as Number = 0;
    // Sampled curve (time, level), ascending in time. Only filled when requested.
    var curveT as Array<Number>;
    var curveV as Array<Float>;

    function initialize() {
        curveT = [] as Array<Number>;
        curveV = [] as Array<Float>;
    }
}

(:glance)
module BacCalculator {

    const DRIVE_LIMIT = 0.5;    // Finnish drink-driving limit, ‰
    const ETHANOL_DENSITY = 0.789;

    function readFloat(key as String, dflt as Float) as Float {
        var v = null;
        try {
            v = Properties.getValue(key);
        } catch (e) {
            v = null;
        }
        if (v instanceof Float || v instanceof Number || v instanceof Double || v instanceof Long) {
            return (v as Numeric).toFloat();
        }
        return dflt;
    }

    // Grams of alcohol in one beer, from the configurable size and ABV.
    function gramsPerBeer() as Float {
        var abv = readFloat("abv", 4.7);
        var vol = readFloat("volumeMl", 330.0);
        return vol * abv / 100.0 * ETHANOL_DENSITY;
    }

    function eliminationRate() as Float {
        var beta = readFloat("eliminationRate", 0.15);
        return beta < 0.01 ? 0.15 : beta;
    }

    // Widmark distribution volume: body weight (kg) × r.
    function distributionKg() as Float {
        var weightKg = readFloat("fallbackWeightKg", 80.0);
        var male = readFloat("fallbackSex", 1.0) >= 0.5;
        var profile = UserProfile.getProfile();
        if (profile != null) {
            var w = profile.weight;
            if (w != null && w > 0) {
                weightKg = w.toFloat() / 1000.0; // profile weight is in grams
            }
            var g = profile.gender;
            if (g != null) {
                male = (g != UserProfile.GENDER_FEMALE);
            }
        }
        if (weightKg < 30.0) {
            weightKg = 30.0;
        }
        return weightKg * (male ? 0.68 : 0.55);
    }

    // Simulates the blood alcohol curve for drinks (sorted [epochSec, grams] pairs).
    function compute(drinks as Array<Array<Numeric>>, now as Number, withCurve as Boolean) as BacResult {
        return computeWith(drinks, now, withCurve, distributionKg(), eliminationRate());
    }

    // Instant-absorption Widmark model: each drink raises the level by grams / vd the moment
    // it is logged, and in between the level falls linearly at beta ‰/h, never below zero.
    // This is exact (no time stepping). vd = body weight × Widmark r (kg).
    function computeWith(drinks as Array<Array<Numeric>>, now as Number, withCurve as Boolean,
                         vd as Float, beta as Float) as BacResult {
        var res = new BacResult();
        var n = drinks.size();
        if (n == 0) {
            return res;
        }
        res.hasDrinks = true;

        var rate = beta / 3600.0; // ‰ per second
        var t = drinks[0][0] as Number;
        var level = 0.0;
        res.startTime = t;
        res.current = -1.0; // "not yet determined"
        if (now < t) {
            res.current = 0.0;
        }
        if (withCurve) {
            res.curveT.add(t);
            res.curveV.add(0.0);
        }

        for (var i = 0; i < n; i++) {
            var ds = drinks[i][0] as Number;
            if (ds > t) {
                level = decay(res, t, level, ds, now, rate, withCurve, false);
                t = ds;
                if (withCurve) {
                    res.curveT.add(t);
                    res.curveV.add(level);
                }
            }
            level += (drinks[i][1] as Numeric).toFloat() / vd;
            if (level > res.peak) {
                res.peak = level;
            }
            if (level > DRIVE_LIMIT) {
                res.driveAt = 0; // above the limit again; the crossing comes later
            }
            if (withCurve) {
                res.curveT.add(t);
                res.curveV.add(level);
            }
        }

        // After the last drink the level falls to zero.
        res.soberAt = t + (level / rate).toNumber();
        decay(res, t, level, res.soberAt, now, rate, withCurve, true);
        if (withCurve) {
            res.curveT.add(res.soberAt);
            res.curveV.add(0.0);
        }
        if (res.current < 0.0) {
            res.current = 0.0;
        }
        return res;
    }

    // Linear burn-off from (t, level) until tEnd. Records the current level if now falls in this
    // segment, the time the level drops to the driving limit, and the zero point on the curve.
    // Returns the level at tEnd.
    function decay(res as BacResult, t as Number, level as Float, tEnd as Number, now as Number,
                   rate as Float, withCurve as Boolean, isLast as Boolean) as Float {
        if (res.current < 0.0 && (now < tEnd || (isLast && now <= tEnd))) {
            var c = level - rate * (now - t);
            res.current = c > 0.0 ? c : 0.0;
        }
        if (level > DRIVE_LIMIT) {
            var cross = t + ((level - DRIVE_LIMIT) / rate).toNumber();
            if (cross <= tEnd) {
                res.driveAt = cross;
            }
        }
        var zeroT = t + (level / rate).toNumber();
        if (zeroT < tEnd) {
            if (withCurve && level > 0.0) {
                res.curveT.add(zeroT);
                res.curveV.add(0.0);
            }
            return 0.0;
        }
        return level - rate * (tEnd - t);
    }

    function computeNow(withCurve as Boolean) as BacResult {
        return compute(DrinkStore.load(), Time.now().value(), withCurve);
    }

    // "21:45" (or "9:45" style on 12h devices).
    function formatTime(ts as Number) as String {
        var info = Gregorian.info(new Time.Moment(ts), Time.FORMAT_SHORT);
        var h = info.hour as Number;
        var m = info.min as Number;
        if (!System.getDeviceSettings().is24Hour) {
            h = h % 12;
            if (h == 0) {
                h = 12;
            }
            return h.format("%d") + ":" + m.format("%02d");
        }
        return h.format("%02d") + ":" + m.format("%02d");
    }

    // "4h 20m" / "35m"
    function formatDuration(sec as Number) as String {
        if (sec < 0) {
            sec = 0;
        }
        var mins = (sec + 59) / 60;
        if (mins < 60) {
            return mins.format("%d") + "m";
        }
        return (mins / 60).format("%d") + "h " + (mins % 60).format("%02d") + "m";
    }

    // Green below 0.2 ‰, yellow below the driving limit, red above.
    function levelColor(level as Float) as Number {
        if (level < 0.2) {
            return 0x55FF55;
        } else if (level < DRIVE_LIMIT) {
            return 0xFFFF00;
        }
        return 0xFF5555;
    }

    function formatLevel(level as Float) as String {
        return level.format("%.2f");
    }
}
