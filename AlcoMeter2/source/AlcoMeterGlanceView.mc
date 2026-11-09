import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Time;
import Toybox.WatchUi;

(:glance)
class AlcoMeterGlanceView extends WatchUi.GlanceView {

    function initialize() {
        GlanceView.initialize();
    }

    function onUpdate(dc as Dc) as Void {
        var res = BacCalculator.computeNow(false);
        var now = Time.now().value();
        var h = dc.getHeight();

        dc.setColor(Graphics.COLOR_TRANSPARENT, Graphics.COLOR_TRANSPARENT);
        dc.clear();

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(0, h / 4, Graphics.FONT_GLANCE, "ALCOMETER",
            Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);

        var line;
        if (res.soberAt <= now) {
            line = "0.00 ‰ · sober";
        } else {
            line = BacCalculator.formatLevel(res.current) + "‰ · sober "
                + BacCalculator.formatTime(res.soberAt);
        }
        // Use the big glance font only if the whole line fits.
        var font = Graphics.FONT_GLANCE_NUMBER;
        if (dc.getTextWidthInPixels(line, font) > dc.getWidth()) {
            font = Graphics.FONT_GLANCE;
        }
        dc.setColor(BacCalculator.levelColor(res.current), Graphics.COLOR_TRANSPARENT);
        dc.drawText(0, (h * 3) / 4, font, line,
            Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
    }
}
