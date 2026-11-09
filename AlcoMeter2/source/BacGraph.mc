import Toybox.Graphics;
import Toybox.Lang;

// Draws the BAC curve from the first drink until sober.
module BacGraph {

    const COL_STEP = 2; // px between sampled columns

    function draw(dc as Dc, res as BacResult, now as Number,
                  x as Number, y as Number, w as Number, h as Number) as Void {
        var ct = res.curveT;
        var cv = res.curveV;
        if (ct.size() < 2) {
            return;
        }
        var t0 = res.startTime;
        var t1 = res.soberAt;
        if (t1 <= t0 + 600) {
            t1 = t0 + 600;
        }
        var span = (t1 - t0).toFloat();
        var limit = BacCalculator.DRIVE_LIMIT;
        var yMax = (res.peak > limit ? res.peak : limit) * 1.15;
        var base = y + h;

        // Sample the curve once per column.
        var cols = w / COL_STEP + 1;
        var ys = new [cols] as Array<Number>;
        var idx = 0;
        var last = ct.size() - 1;
        for (var c = 0; c < cols; c++) {
            var t = t0 + (span * c * COL_STEP / w).toNumber();
            while (idx < last - 1 && ct[idx + 1] < t) {
                idx++;
            }
            var ta = ct[idx];
            var tb = ct[idx + 1];
            var v = cv[idx];
            if (tb > ta) {
                var f = (t - ta).toFloat() / (tb - ta);
                if (f > 1.0) {
                    f = 1.0;
                } else if (f < 0.0) {
                    f = 0.0;
                }
                v = cv[idx] + (cv[idx + 1] - cv[idx]) * f;
            }
            ys[c] = base - (v / yMax * h).toNumber();
        }

        var nowX = x + ((now - t0).toFloat() / span * w).toNumber();

        // Filled area: dimmer for the past, brighter amber for what's still ahead.
        dc.setPenWidth(COL_STEP);
        for (var c = 0; c < cols; c++) {
            var px = x + c * COL_STEP;
            if (ys[c] < base) {
                dc.setColor(px < nowX ? 0x553311 : 0x885500, Graphics.COLOR_TRANSPARENT);
                dc.drawLine(px, base, px, ys[c]);
            }
        }

        // Curve outline.
        dc.setPenWidth(2);
        for (var c = 1; c < cols; c++) {
            var px = x + c * COL_STEP;
            dc.setColor(px < nowX ? 0xAA7733 : 0xFFAA00, Graphics.COLOR_TRANSPARENT);
            dc.drawLine(px - COL_STEP, ys[c - 1], px, ys[c]);
        }

        // Baseline.
        dc.setPenWidth(1);
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(x, base, x + w, base);

        // Dashed 0.5 ‰ driving limit.
        var ly = base - (limit / yMax * h).toNumber();
        dc.setColor(0xFF5555, Graphics.COLOR_TRANSPARENT);
        for (var dx = 0; dx < w; dx += 10) {
            dc.drawLine(x + dx, ly, x + dx + 5, ly);
        }
        // Where the curve drops below the limit: dot + time, if that's still ahead.
        if (res.driveAt > now) {
            var dx = x + ((res.driveAt - t0).toFloat() / span * w).toNumber();
            dc.fillCircle(dx, ly, 4);
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(dx + 6, ly - 2, Graphics.FONT_XTINY, "0.5‰ " + BacCalculator.formatTime(res.driveAt),
                Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
        } else {
            dc.drawText(x + w, ly - 2, Graphics.FONT_XTINY, "0.5",
                Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
        }

        // "Now" marker.
        if (nowX >= x && nowX <= x + w) {
            dc.setPenWidth(2);
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawLine(nowX, y, nowX, base);
            dc.setPenWidth(1);
        }

        // Time labels.
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, base + 2, Graphics.FONT_XTINY, BacCalculator.formatTime(t0),
            Graphics.TEXT_JUSTIFY_LEFT);
        dc.drawText(x + w, base + 2, Graphics.FONT_XTINY, BacCalculator.formatTime(res.soberAt),
            Graphics.TEXT_JUSTIFY_RIGHT);
    }
}
