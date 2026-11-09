import Toybox.Application;
import Toybox.Lang;
import Toybox.Time;
import Toybox.Time.Gregorian;

// Long-term drinking history: one summary per day (beer count + highest ‰), kept for 13 months.
//
// statsDays: flat array [dayKey, count, peakX100, dayKey, count, peakX100, ...], sorted by day.
//            dayKey = YYYYMMDD (local time), peakX100 = highest ‰ × 100.
// statsOpen: [startTs, count, peakX100] for the session in progress. Kept apart from the saved
//            days so that deleting a beer or "Clear all" can still correct it. It is merged into
//            statsDays when the next session starts.
//
// A session counts on the day its first beer was logged.
module StatsStore {

    const KEY_DAYS = "statsDays";
    const KEY_OPEN = "statsOpen";
    const MONTHS = 13;
    const STRIDE = 3;

    // ---- Date helpers ----

    function dayKeyOf(ts as Number) as Number {
        var info = Gregorian.info(new Time.Moment(ts), Time.FORMAT_SHORT);
        return (info.year as Number) * 10000 + (info.month as Number) * 100 + (info.day as Number);
    }

    // 0 = Monday ... 6 = Sunday (Sakamoto's method; pure arithmetic, no time zones involved).
    function dayOfWeek(y as Number, m as Number, d as Number) as Number {
        var t = [0, 3, 2, 5, 0, 3, 5, 1, 4, 6, 2, 4] as Array<Number>;
        if (m < 3) {
            y -= 1;
        }
        var sun0 = (y + y / 4 - y / 100 + y / 400 + t[m - 1] + d) % 7; // 0 = Sunday
        return (sun0 + 6) % 7;
    }

    function isLeap(y as Number) as Boolean {
        return (y % 4 == 0 && y % 100 != 0) || y % 400 == 0;
    }

    function daysInMonth(y as Number, m as Number) as Number {
        if (m == 2) {
            return isLeap(y) ? 29 : 28;
        }
        return (m == 4 || m == 6 || m == 9 || m == 11) ? 30 : 31;
    }

    // First dayKey still kept: the 1st of the month 12 months before the current one.
    function cutoffKey(now as Number) as Number {
        var key = dayKeyOf(now);
        var y = key / 10000;
        var m = (key / 100) % 100 - (MONTHS - 1);
        while (m < 1) {
            m += 12;
            y -= 1;
        }
        return y * 10000 + m * 100 + 1;
    }

    // ---- Storage ----

    function loadDays() as Array<Number> {
        var out = [] as Array<Number>;
        var raw = Storage.getValue(KEY_DAYS);
        if (!(raw instanceof Array) || raw.size() % STRIDE != 0) {
            return out;
        }
        for (var i = 0; i < raw.size(); i++) {
            var v = raw[i];
            if (!(v instanceof Number)) {
                return [] as Array<Number>;
            }
            out.add(v);
        }
        return out;
    }

    function saveDays(days as Array<Number>) as Void {
        Storage.setValue(KEY_DAYS, days as Array<Storage.ValueType>);
    }

    function loadOpen() as Array<Number>? {
        var raw = Storage.getValue(KEY_OPEN);
        if (raw instanceof Array && raw.size() >= 3) {
            return [raw[0] as Number, raw[1] as Number, raw[2] as Number] as Array<Number>;
        }
        return null;
    }

    // Records the current session (the drinks in DrinkStore). An empty list removes it.
    function updateOpen(drinks as Array<Array<Numeric>>, now as Number) as Void {
        if (drinks.size() == 0) {
            Storage.deleteValue(KEY_OPEN);
            return;
        }
        var peak = BacCalculator.compute(drinks, now, false).peak;
        Storage.setValue(KEY_OPEN, [drinks[0][0] as Number, drinks.size(),
            (peak * 100.0 + 0.5).toNumber()] as Array<Storage.ValueType>);
    }

    // Moves the finished session into the saved days and drops days older than 13 months.
    function commitOpen(now as Number) as Void {
        var open = loadOpen();
        if (open == null) {
            return;
        }
        var days = merge(loadDays(), dayKeyOf(open[0]), open[1], open[2]);
        saveDays(prune(days, now));
        Storage.deleteValue(KEY_OPEN);
    }

    // Saved days plus the session in progress, for display. Nothing is written.
    function allDays(now as Number) as Array<Number> {
        var days = loadDays();
        var open = loadOpen();
        if (open != null) {
            days = merge(days, dayKeyOf(open[0]), open[1], open[2]);
        }
        return prune(days, now);
    }

    // Adds count to the day and keeps the higher peak. Returns the (possibly new) array.
    function merge(days as Array<Number>, key as Number, count as Number,
                   peakX100 as Number) as Array<Number> {
        var pos = 0;
        while (pos < days.size() && days[pos] < key) {
            pos += STRIDE;
        }
        if (pos < days.size() && days[pos] == key) {
            days[pos + 1] = days[pos + 1] + count;
            if (peakX100 > days[pos + 2]) {
                days[pos + 2] = peakX100;
            }
            return days;
        }
        var entry = [key, count, peakX100] as Array<Number>;
        if (pos == days.size()) {
            return days.addAll(entry);
        }
        return days.slice(0, pos).addAll(entry).addAll(days.slice(pos, null));
    }

    function prune(days as Array<Number>, now as Number) as Array<Number> {
        var cutoff = cutoffKey(now);
        var start = 0;
        while (start < days.size() && days[start] < cutoff) {
            start += STRIDE;
        }
        return start == 0 ? days : days.slice(start, null);
    }

    // ---- Summaries ----

    // Count and highest peak for days whose key is in [fromKey, toKey]. Returns [count, peakX100].
    function sumRange(days as Array<Number>, fromKey as Number, toKey as Number) as Array<Number> {
        var count = 0;
        var peak = 0;
        for (var i = 0; i < days.size(); i += STRIDE) {
            var k = days[i];
            if (k >= fromKey && k <= toKey) {
                count += days[i + 1];
                if (days[i + 2] > peak) {
                    peak = days[i + 2];
                }
            }
        }
        return [count, peak] as Array<Number>;
    }

    // The last 13 months, newest first: [year, month, count, peakX100]. Months without beers included.
    function monthSummaries(days as Array<Number>, now as Number) as Array<Array<Number>> {
        var key = dayKeyOf(now);
        var y = key / 10000;
        var m = (key / 100) % 100;
        var out = [] as Array<Array<Number>>;
        for (var k = 0; k < MONTHS; k++) {
            var base = y * 10000 + m * 100;
            var s = sumRange(days, base + 1, base + 31);
            out.add([y, m, s[0], s[1]] as Array<Number>);
            m -= 1;
            if (m < 1) {
                m = 12;
                y -= 1;
            }
        }
        return out;
    }

    // Monday–Sunday weeks of a month, cut to the month: [firstDay, lastDay, count, peakX100].
    function weekSummaries(days as Array<Number>, y as Number, m as Number) as Array<Array<Number>> {
        var dim = daysInMonth(y, m);
        var base = y * 10000 + m * 100;
        var out = [] as Array<Array<Number>>;
        var start = 1;
        while (start <= dim) {
            var end = start + 6 - dayOfWeek(y, m, start);
            if (end > dim) {
                end = dim;
            }
            var s = sumRange(days, base + start, base + end);
            out.add([start, end, s[0], s[1]] as Array<Number>);
            start = end + 1;
        }
        return out;
    }
}
