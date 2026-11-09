import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

// One month as a bar chart, one bar per week (beer count). UP/DOWN moves the selection;
// the selected week's dates, beer count and highest ‰ are shown above the chart.
class MonthWeeksView extends WatchUi.View {

    private var _year as Number;
    private var _month as Number;
    private var _weeks as Array<Array<Number>>;
    private var _sel as Number = 0;

    function initialize(year as Number, month as Number, days as Array<Number>, now as Number) {
        View.initialize();
        _year = year;
        _month = month;
        _weeks = StatsStore.weekSummaries(days, year, month);
        // Current month: start on the current week.
        var today = StatsStore.dayKeyOf(now);
        if (today / 100 == year * 100 + month) {
            var d = today % 100;
            for (var i = 0; i < _weeks.size(); i++) {
                if (d >= _weeks[i][0] && d <= _weeks[i][1]) {
                    _sel = i;
                }
            }
        }
    }

    function move(delta as Number) as Void {
        var n = _sel + delta;
        if (n >= 0 && n < _weeks.size()) {
            _sel = n;
            WatchUi.requestUpdate();
        }
    }

    function onUpdate(dc as Dc) as Void {
        var w = dc.getWidth();
        var h = dc.getHeight();
        var cx = w / 2;

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        dc.drawText(cx, (h * 8) / 100, Graphics.FONT_TINY,
            StatsMenu.monthLabel(_year, _month), Graphics.TEXT_JUSTIFY_CENTER);

        var week = _weeks[_sel];
        var mon = StatsMenu.monthName(_month);
        var range = week[0] == week[1]
            ? week[0].format("%d") + " " + mon
            : week[0].format("%d") + "-" + week[1].format("%d") + " " + mon;
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, (h * 20) / 100, Graphics.FONT_XTINY, range, Graphics.TEXT_JUSTIFY_CENTER);

        var count = week[2];
        if (count == 0) {
            dc.drawText(cx, (h * 28) / 100, Graphics.FONT_SMALL, "No beers",
                Graphics.TEXT_JUSTIFY_CENTER);
        } else {
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(cx, (h * 28) / 100, Graphics.FONT_SMALL, StatsMenu.beersText(count),
                Graphics.TEXT_JUSTIFY_CENTER);
            dc.setColor(BacCalculator.levelColor(week[3] / 100.0), Graphics.COLOR_TRANSPARENT);
            dc.drawText(cx, (h * 39) / 100, Graphics.FONT_XTINY, StatsMenu.maxText(week[3]),
                Graphics.TEXT_JUSTIFY_CENTER);
        }

        drawBars(dc, (w * 18) / 100, (h * 52) / 100, w - 2 * ((w * 18) / 100), (h * 26) / 100);
    }

    private function drawBars(dc as Dc, x as Number, y as Number, gw as Number, gh as Number) as Void {
        var n = _weeks.size();
        var maxCount = 1;
        for (var i = 0; i < n; i++) {
            if (_weeks[i][2] > maxCount) {
                maxCount = _weeks[i][2];
            }
        }
        var base = y + gh;
        var slot = gw / n;
        var barW = (slot * 6) / 10;

        for (var i = 0; i < n; i++) {
            var c = _weeks[i][2];
            var selected = (i == _sel);
            var bx = x + i * slot + (slot - barW) / 2;
            var bh = (c * gh) / maxCount;
            if (c > 0 && bh < 3) {
                bh = 3;
            }
            if (bh == 0 && selected) {
                bh = 2; // keep the cursor visible on an empty week
            }
            dc.setColor(selected ? 0xFFAA00 : 0x885500, Graphics.COLOR_TRANSPARENT);
            if (bh > 0) {
                dc.fillRectangle(bx, base - bh, barW, bh);
            }
            dc.setColor(selected ? Graphics.COLOR_WHITE : Graphics.COLOR_LT_GRAY,
                Graphics.COLOR_TRANSPARENT);
            dc.drawText(bx + barW / 2, base + 3, Graphics.FONT_XTINY,
                _weeks[i][0].format("%d"), Graphics.TEXT_JUSTIFY_CENTER);
        }

        dc.setPenWidth(1);
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(x, base, x + gw, base);
    }
}

class MonthWeeksDelegate extends WatchUi.BehaviorDelegate {

    private var _view as MonthWeeksView;

    function initialize(view as MonthWeeksView) {
        BehaviorDelegate.initialize();
        _view = view;
    }

    // DOWN / swipe up: next week.
    function onNextPage() as Boolean {
        _view.move(1);
        return true;
    }

    // UP / swipe down: previous week.
    function onPreviousPage() as Boolean {
        _view.move(-1);
        return true;
    }

    function onBack() as Boolean {
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
        return true;
    }
}
