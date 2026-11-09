import Toybox.Lang;
import Toybox.Time;
import Toybox.WatchUi;

// Stats screen: the last 13 months, newest first. Selecting a month opens its weekly bar chart.
module StatsMenu {

    const MONTH_NAMES = ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
        "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"] as Array<String>;

    function monthName(m as Number) as String {
        return MONTH_NAMES[m - 1];
    }

    function monthLabel(y as Number, m as Number) as String {
        return monthName(m) + " " + y.format("%d");
    }

    function beersText(count as Number) as String {
        return count == 1 ? "1 beer" : count.format("%d") + " beers";
    }

    function maxText(peakX100 as Number) as String {
        return "max " + BacCalculator.formatLevel(peakX100 / 100.0) + "‰";
    }

    function summaryText(count as Number, peakX100 as Number) as String {
        if (count == 0) {
            return "No beers";
        }
        return beersText(count) + " · " + maxText(peakX100);
    }

    function open() as Void {
        var now = Time.now().value();
        var days = StatsStore.allDays(now);
        var months = StatsStore.monthSummaries(days, now);
        var menu = new WatchUi.Menu2({:title => "Stats"});
        for (var i = 0; i < months.size(); i++) {
            var mo = months[i];
            menu.addItem(new WatchUi.MenuItem(monthLabel(mo[0], mo[1]),
                summaryText(mo[2], mo[3]), i, null));
        }
        WatchUi.pushView(menu, new StatsMenuDelegate(months, days, now), WatchUi.SLIDE_UP);
    }
}

class StatsMenuDelegate extends WatchUi.Menu2InputDelegate {

    private var _months as Array<Array<Number>>;
    private var _days as Array<Number>;
    private var _now as Number;

    function initialize(months as Array<Array<Number>>, days as Array<Number>, now as Number) {
        Menu2InputDelegate.initialize();
        _months = months;
        _days = days;
        _now = now;
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var id = item.getId();
        if (id instanceof Number) {
            var mo = _months[id];
            var view = new MonthWeeksView(mo[0], mo[1], _days, _now);
            WatchUi.pushView(view, new MonthWeeksDelegate(view), WatchUi.SLIDE_LEFT);
        }
    }
}
