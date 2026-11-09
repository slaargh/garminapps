import Toybox.Application;
import Toybox.Lang;
import Toybox.Test;
import Toybox.Time;
import Toybox.Time.Gregorian;

// Unit tests, only compiled with `monkeyc --unit-test`.
// Reference person: 80 kg male (vd = 80 × 0.68 = 54.4 kg), β = 0.15 ‰/h, 12.24 g per beer.
// Absorption is instant: a beer counts fully the moment it is logged.

(:test)
module TestData {
    const VD = 54.4;
    const BETA = 0.15;
    const G = 12.24;
    const T0 = 1700000000;

    function near(logger as Logger, label as String, actual as Numeric, expected as Numeric,
                  tol as Numeric) as Boolean {
        var ok = (actual - expected).abs() <= tol;
        logger.debug(label + ": " + actual.toString() + " (expected " + expected.toString()
            + " ± " + tol.toString() + ")" + (ok ? "" : "  <-- FAIL"));
        return ok;
    }
}

(:test)
function testNoDrinks(logger as Logger) as Boolean {
    var r = BacCalculator.computeWith([] as Array<Array<Numeric>>, TestData.T0, true,
        TestData.VD, TestData.BETA);
    return !r.hasDrinks && r.current == 0.0 && r.peak == 0.0;
}

(:test)
function testFourBeersAtOnce(logger as Logger) as Boolean {
    var t0 = TestData.T0;
    var d = [[t0, TestData.G], [t0, TestData.G], [t0, TestData.G], [t0, TestData.G]]
        as Array<Array<Numeric>>;
    var r = BacCalculator.computeWith(d, t0 + 4 * 3600, true, TestData.VD, TestData.BETA);
    var ok = true;
    // 48.96 g / 54.4 kg = 0.90 ‰, counted instantly.
    ok = TestData.near(logger, "peak", r.peak, 0.90, 0.005) && ok;
    // 0.90 − 4 × 0.15 = 0.30 at 4 h.
    ok = TestData.near(logger, "current@4h", r.current, 0.30, 0.005) && ok;
    // 0.90 / 0.15 = 6 h until sober.
    ok = TestData.near(logger, "soberAt h", (r.soberAt - t0) / 3600.0, 6.0, 0.01) && ok;
    // (0.90 − 0.5) / 0.15 = 2.67 h.
    ok = TestData.near(logger, "driveAt h", (r.driveAt - t0) / 3600.0, 2.667, 0.01) && ok;
    return ok;
}

(:test)
function testBeerCountsImmediately(logger as Logger) as Boolean {
    var t0 = TestData.T0;
    var d = [[t0, TestData.G]] as Array<Array<Numeric>>;
    var ok = true;
    // The moment it is logged: 12.24 g / 54.4 kg = 0.225 ‰.
    var r = BacCalculator.computeWith(d, t0, false, TestData.VD, TestData.BETA);
    ok = TestData.near(logger, "current@0", r.current, 0.225, 0.001) && ok;
    // 15 min later: 0.225 − 0.0375.
    r = BacCalculator.computeWith(d, t0 + 900, false, TestData.VD, TestData.BETA);
    ok = TestData.near(logger, "current@15min", r.current, 0.1875, 0.001) && ok;
    return ok;
}

(:test)
function testDrinkingOverTime(logger as Logger) as Boolean {
    // One beer per hour for 4 h: each adds 0.225, 0.15 burns off per hour.
    var t0 = TestData.T0;
    var d = [[t0, TestData.G], [t0 + 3600, TestData.G], [t0 + 7200, TestData.G],
        [t0 + 10800, TestData.G]] as Array<Array<Numeric>>;
    var r = BacCalculator.computeWith(d, t0 + 10800, false, TestData.VD, TestData.BETA);
    var ok = true;
    // 4 × 0.225 − 3 × 0.15 = 0.45 right after the 4th beer.
    ok = TestData.near(logger, "peak", r.peak, 0.45, 0.001) && ok;
    ok = TestData.near(logger, "current", r.current, 0.45, 0.001) && ok;
    // Sober 3 h after the 4th beer = 6 h after the first (same total alcohol as 4 at once).
    ok = TestData.near(logger, "soberAt h", (r.soberAt - t0) / 3600.0, 6.0, 0.01) && ok;
    ok = (r.driveAt == 0) && ok; // never above 0.5
    return ok;
}

(:test)
function testOneBeerStaysUnderLimit(logger as Logger) as Boolean {
    var t0 = TestData.T0;
    var d = [[t0, TestData.G]] as Array<Array<Numeric>>;
    var r = BacCalculator.computeWith(d, t0 + 3 * 3600, false, TestData.VD, TestData.BETA);
    // 0.225 / 0.15 = 1.5 h, so sober again after 3 h.
    return r.driveAt == 0 && r.peak < 0.5 && r.current == 0.0 && (r.soberAt - (t0 + 5400)).abs() <= 1;
}

(:test)
function testSeparateSessions(logger as Logger) as Boolean {
    var t0 = TestData.T0;
    var later = t0 + 20 * 3600;
    var d = [[t0, TestData.G], [later, TestData.G]] as Array<Array<Numeric>>;
    var ok = true;
    // Between sessions the level is 0.
    var mid = BacCalculator.computeWith(d, t0 + 10 * 3600, true, TestData.VD, TestData.BETA);
    ok = TestData.near(logger, "current between sessions", mid.current, 0.0, 0.0001) && ok;
    // The second beer is not affected by the first.
    var single = BacCalculator.computeWith([[later, TestData.G]] as Array<Array<Numeric>>,
        later, false, TestData.VD, TestData.BETA);
    ok = TestData.near(logger, "soberAt matches single beer",
        mid.soberAt, single.soberAt, 1) && ok;
    // A handful of points per drink, regardless of the 18 h gap.
    logger.debug("curve points: " + mid.curveT.size().toString());
    ok = (mid.curveT.size() <= 8) && ok;
    return ok;
}

(:test)
function testCurveShape(logger as Logger) as Boolean {
    var t0 = TestData.T0;
    var d = [[t0, TestData.G], [t0 + 3600, TestData.G], [t0 + 7200, TestData.G]]
        as Array<Array<Numeric>>;
    var r = BacCalculator.computeWith(d, t0 + 3600, true, TestData.VD, TestData.BETA);
    var n = r.curveT.size();
    if (n < 2 || r.curveT[0] != t0 || r.curveT[n - 1] != r.soberAt || r.curveV[n - 1] != 0.0) {
        logger.error("curve endpoints wrong");
        return false;
    }
    for (var i = 1; i < n; i++) {
        if (r.curveT[i] < r.curveT[i - 1] || r.curveV[i] < 0.0) {
            logger.error("curve not monotonic in time or negative at " + i.toString());
            return false;
        }
    }
    return true;
}

(:test)
function testGramsPerBeerDefault(logger as Logger) as Boolean {
    // 330 ml × 4.7 % × 0.789 g/ml
    return TestData.near(logger, "grams", BacCalculator.gramsPerBeer(), 12.24, 0.01);
}

(:test)
function testFormatting(logger as Logger) as Boolean {
    var ok = true;
    ok = BacCalculator.formatDuration(15600).equals("4h 20m") && ok;
    ok = BacCalculator.formatDuration(2100).equals("35m") && ok;
    ok = BacCalculator.formatDuration(-5).equals("0m") && ok;
    ok = BacCalculator.formatLevel(0.4567).equals("0.46") && ok;
    return ok;
}

(:test)
function testDrinkStore(logger as Logger) as Boolean {
    var saved = Storage.getValue(DrinkStore.KEY);
    var ok = true;
    try {
        DrinkStore.clear();
        ok = (DrinkStore.load().size() == 0) && ok;
        ok = DrinkStore.add(12.0) && ok;   // first beer starts a session
        ok = !DrinkStore.add(10.0) && ok;  // still drinking
        var list = DrinkStore.load();
        ok = (list.size() == 2) && ok;
        ok = ((list[0][0] as Number) <= (list[1][0] as Number)) && ok;
        DrinkStore.removeAtTime(list[0][0] as Number);
        ok = (DrinkStore.load().size() == 1) && ok;
        // Entries older than 24 h are dropped on load.
        var old = Time.now().value() - 90000;
        DrinkStore.save([[old, 12.0]] as Array<Array<Numeric>>);
        ok = (DrinkStore.load().size() == 0) && ok;
        // A finished session (already sober, but < 24 h ago) is forgotten when a new beer is added.
        var lastNight = Time.now().value() - 12 * 3600;
        DrinkStore.save([[lastNight, 12.0], [lastNight + 600, 12.0]] as Array<Array<Numeric>>);
        ok = (DrinkStore.load().size() == 2) && ok;
        ok = DrinkStore.add(12.0) && ok;   // new session
        ok = (DrinkStore.load().size() == 1) && ok;
        // While still drinking, earlier beers are kept.
        ok = !DrinkStore.add(12.0) && ok;
        ok = (DrinkStore.load().size() == 2) && ok;
    } finally {
        if (saved == null) {
            DrinkStore.clear();
        } else {
            Storage.setValue(DrinkStore.KEY, saved);
        }
    }
    return ok;
}

// ---- Stats ----

(:test)
module StatsTestData {
    // Noon UTC, so the local date is the same in every time zone within ±11 h.
    function ts(y as Number, m as Number, d as Number) as Number {
        return Gregorian.moment({:year => y, :month => m, :day => d, :hour => 12}).value();
    }
}

(:test)
function testStatsCalendar(logger as Logger) as Boolean {
    var ok = true;
    ok = (StatsStore.dayOfWeek(2026, 11, 1) == 6) && ok;  // Sunday
    ok = (StatsStore.dayOfWeek(2026, 11, 9) == 0) && ok;  // Monday
    ok = (StatsStore.dayOfWeek(2024, 2, 29) == 3) && ok;  // Thursday
    ok = (StatsStore.dayOfWeek(2000, 1, 1) == 5) && ok;   // Saturday
    ok = (StatsStore.daysInMonth(2024, 2) == 29) && ok;
    ok = (StatsStore.daysInMonth(2026, 2) == 28) && ok;
    ok = (StatsStore.daysInMonth(2000, 2) == 29) && ok;
    ok = (StatsStore.daysInMonth(1900, 2) == 28) && ok;
    ok = (StatsStore.daysInMonth(2026, 11) == 30) && ok;
    ok = (StatsStore.daysInMonth(2026, 12) == 31) && ok;
    ok = (StatsStore.dayKeyOf(StatsTestData.ts(2026, 11, 9)) == 20261109) && ok;
    return ok;
}

(:test)
function testStatsWeeks(logger as Logger) as Boolean {
    var days = [20261101, 2, 45, 20261103, 3, 80, 20261105, 1, 30, 20261130, 4, 112,
        20261201, 9, 150] as Array<Number>;
    var w = StatsStore.weekSummaries(days, 2026, 11);
    var ok = (w.size() == 6);
    if (!ok) {
        logger.error("weeks: " + w.size().toString());
        return false;
    }
    ok = (w[0][0] == 1 && w[0][1] == 1 && w[0][2] == 2 && w[0][3] == 45) && ok;
    ok = (w[1][0] == 2 && w[1][1] == 8 && w[1][2] == 4 && w[1][3] == 80) && ok;
    ok = (w[2][0] == 9 && w[2][1] == 15 && w[2][2] == 0) && ok;
    ok = (w[5][0] == 30 && w[5][1] == 30 && w[5][2] == 4 && w[5][3] == 112) && ok;
    return ok;
}

(:test)
function testStatsMonths(logger as Logger) as Boolean {
    var days = [20250101, 5, 60, 20250201, 1, 20, 20251215, 3, 70, 20251231, 2, 90,
        20260110, 4, 50] as Array<Number>;
    var m = StatsStore.monthSummaries(days, StatsTestData.ts(2026, 1, 20));
    var ok = (m.size() == 13);
    ok = (m[0][0] == 2026 && m[0][1] == 1 && m[0][2] == 4 && m[0][3] == 50) && ok;
    ok = (m[1][0] == 2025 && m[1][1] == 12 && m[1][2] == 5 && m[1][3] == 90) && ok;
    ok = (m[2][1] == 11 && m[2][2] == 0 && m[2][3] == 0) && ok;
    // Oldest of the 13 is Jan 2025.
    ok = (m[12][0] == 2025 && m[12][1] == 1 && m[12][2] == 5) && ok;
    return ok;
}

(:test)
function testStatsCommit(logger as Logger) as Boolean {
    var savedDays = Storage.getValue(StatsStore.KEY_DAYS);
    var savedOpen = Storage.getValue(StatsStore.KEY_OPEN);
    var ok = true;
    try {
        var t = TestData.T0;
        var now = StatsTestData.ts(2026, 11, 9);
        // A day 14 months back gets pruned; a day in range stays.
        Storage.setValue(StatsStore.KEY_DAYS,
            [20250901, 6, 100, 20251201, 2, 40, 20261108, 2, 40] as Array<Application.PropertyValueType>);

        // Session on 8 Nov: two beers, then delete one -> stats follow.
        var s1 = StatsTestData.ts(2026, 11, 8);
        var d = [[s1, TestData.G], [s1 + 600, TestData.G]] as Array<Array<Numeric>>;
        StatsStore.updateOpen(d, now);
        var all = StatsStore.allDays(now);
        ok = (StatsStore.sumRange(all, 20261108, 20261108)[0] == 4) && ok;
        StatsStore.updateOpen([[s1, TestData.G]] as Array<Array<Numeric>>, now);
        StatsStore.commitOpen(now);
        ok = (StatsStore.loadOpen() == null) && ok;

        var days = StatsStore.loadDays();
        logger.debug("days: " + days.toString());
        ok = (days.size() == 6) && ok;                      // 20250901 pruned
        ok = (days[0] == 20251201) && ok;                   // cutoff is 1 Nov 2025
        ok = (days[3] == 20261108 && days[4] == 3) && ok;   // 2 + 1 beers
        // Peak: max(0.40, one beer at the default profile) -> still at least 40.
        ok = (days[5] >= 40) && ok;

        // A new day is inserted in order.
        StatsStore.updateOpen([[StatsTestData.ts(2026, 11, 2), TestData.G]]
            as Array<Array<Numeric>>, now);
        StatsStore.commitOpen(now);
        days = StatsStore.loadDays();
        ok = (days.size() == 9 && days[3] == 20261102 && days[6] == 20261108) && ok;

        // Committing with nothing open changes nothing.
        StatsStore.commitOpen(now);
        ok = (StatsStore.loadDays().size() == 9) && ok;
        // Clearing the session removes it from the totals.
        StatsStore.updateOpen([[t, TestData.G]] as Array<Array<Numeric>>, now);
        StatsStore.updateOpen([] as Array<Array<Numeric>>, now);
        ok = (StatsStore.loadOpen() == null) && ok;
    } finally {
        if (savedDays == null) {
            Storage.deleteValue(StatsStore.KEY_DAYS);
        } else {
            Storage.setValue(StatsStore.KEY_DAYS, savedDays);
        }
        if (savedOpen == null) {
            Storage.deleteValue(StatsStore.KEY_OPEN);
        } else {
            Storage.setValue(StatsStore.KEY_OPEN, savedOpen);
        }
    }
    return ok;
}
