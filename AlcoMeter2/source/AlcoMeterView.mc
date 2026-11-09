import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Time;
import Toybox.Timer;
import Toybox.WatchUi;

class AlcoMeterView extends WatchUi.View {

    private var _timer as Timer.Timer?;

    function initialize() {
        View.initialize();
    }

    function onShow() as Void {
        var timer = new Timer.Timer();
        timer.start(method(:onTick), 60000, true);
        _timer = timer;
    }

    function onHide() as Void {
        if (_timer != null) {
            _timer.stop();
            _timer = null;
        }
    }

    function onTick() as Void {
        WatchUi.requestUpdate();
    }

    function onUpdate(dc as Dc) as Void {
        var w = dc.getWidth();
        var h = dc.getHeight();
        var cx = w / 2;
        var now = Time.now().value();
        var res = BacCalculator.computeNow(true);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        var count = DrinkStore.load().size();
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, (h * 9) / 100, Graphics.FONT_XTINY,
            StatsMenu.beersText(count), Graphics.TEXT_JUSTIFY_CENTER);

        drawLevel(dc, cx, (h * 15) / 100, res.current);

        if (!res.hasDrinks) {
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(cx, (h * 46) / 100, Graphics.FONT_SMALL, "No beers yet",
                Graphics.TEXT_JUSTIFY_CENTER);
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(cx, (h * 60) / 100, Graphics.FONT_XTINY, "START: add a beer",
                Graphics.TEXT_JUSTIFY_CENTER);
            dc.drawText(cx, (h * 68) / 100, Graphics.FONT_XTINY, "UP: beer list",
                Graphics.TEXT_JUSTIFY_CENTER);
            dc.drawText(cx, (h * 76) / 100, Graphics.FONT_XTINY, "DOWN: stats",
                Graphics.TEXT_JUSTIFY_CENTER);
            return;
        }

        var gx = (w * 13) / 100;
        var gw = w - 2 * gx;
        var gy = (h * 40) / 100;
        var gh = (h * 27) / 100;
        BacGraph.draw(dc, res, now, gx, gy, gw, gh);

        // Not "current == 0": right after a drink the level is still 0 while it is absorbed.
        var sober = res.soberAt <= now;
        if (sober) {
            dc.setColor(0x55FF55, Graphics.COLOR_TRANSPARENT);
            dc.drawText(cx, (h * 76) / 100, Graphics.FONT_TINY, "Sober now",
                Graphics.TEXT_JUSTIFY_CENTER);
        } else {
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(cx, (h * 75) / 100, Graphics.FONT_TINY,
                "Sober " + BacCalculator.formatTime(res.soberAt),
                Graphics.TEXT_JUSTIFY_CENTER);
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(cx, (h * 84) / 100, Graphics.FONT_XTINY,
                "in " + BacCalculator.formatDuration(res.soberAt - now),
                Graphics.TEXT_JUSTIFY_CENTER);
        }
    }

    // Large number with a smaller "‰" next to it, centred as one unit.
    private function drawLevel(dc as Dc, cx as Number, y as Number, level as Float) as Void {
        var numFont = Graphics.FONT_NUMBER_MILD;
        var unitFont = Graphics.FONT_SMALL;
        var num = BacCalculator.formatLevel(level) + " ";
        var unit = "‰";
        var wn = dc.getTextWidthInPixels(num, numFont);
        var wu = dc.getTextWidthInPixels(unit, unitFont);
        var x = cx - (wn + wu) / 2;
        var unitY = y + Graphics.getFontAscent(numFont) - Graphics.getFontAscent(unitFont);

        dc.setColor(BacCalculator.levelColor(level), Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, y, numFont, num, Graphics.TEXT_JUSTIFY_LEFT);
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x + wn, unitY, unitFont, unit, Graphics.TEXT_JUSTIFY_LEFT);
    }
}
