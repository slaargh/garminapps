import Toybox.Application;
import Toybox.Lang;
import Toybox.Time;

// Persists consumed drinks as [epochSeconds, gramsOfAlcohol] pairs, oldest first.
// Grams are stored per drink, so changing the ABV setting later only affects new beers.
(:glance)
module DrinkStore {

    const KEY = "drinks";
    // Drinks older than this cannot contribute to the current level any more.
    const MAX_AGE_SEC = 86400;

    function load() as Array<Array<Numeric>> {
        var out = [] as Array<Array<Numeric>>;
        var raw = Storage.getValue(KEY);
        if (!(raw instanceof Array)) {
            return out;
        }
        var cutoff = Time.now().value() - MAX_AGE_SEC;
        for (var i = 0; i < raw.size(); i++) {
            var d = raw[i];
            if (d instanceof Array && d.size() >= 2 && (d[0] as Number) >= cutoff) {
                out.add([d[0] as Number, d[1] as Numeric]);
            }
        }
        return out;
    }

    function save(drinks as Array<Array<Numeric>>) as Void {
        Storage.setValue(KEY, drinks as Array<Application.PropertyValueType>);
    }

    // Adds a drink now, keeping the list sorted by time. If the earlier drinks have already
    // burned off (sober again), they belong to a finished session and are forgotten, so the
    // count and the list only show the current session.
    // Returns true when this drink started a new session.
    function add(grams as Float) as Boolean {
        var drinks = load();
        var now = Time.now().value();
        if (drinks.size() > 0 && BacCalculator.compute(drinks, now, false).soberAt <= now) {
            drinks = [] as Array<Array<Numeric>>;
        }
        var newSession = drinks.size() == 0;
        var pos = drinks.size();
        while (pos > 0 && (drinks[pos - 1][0] as Number) > now) {
            pos--;
        }
        var entry = [now, grams] as Array<Numeric>;
        if (pos == drinks.size()) {
            drinks.add(entry);
        } else {
            drinks = drinks.slice(0, pos).addAll([entry]).addAll(drinks.slice(pos, null));
        }
        save(drinks);
        return newSession;
    }

    // Removes the first drink logged at the given timestamp.
    function removeAtTime(ts as Number) as Void {
        var drinks = load();
        for (var i = 0; i < drinks.size(); i++) {
            if ((drinks[i][0] as Number) == ts) {
                drinks = drinks.slice(0, i).addAll(drinks.slice(i + 1, null));
                break;
            }
        }
        save(drinks);
    }

    function clear() as Void {
        Storage.deleteValue(KEY);
    }
}
