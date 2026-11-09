import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

(:glance)
class AlcoMeterApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state as Dictionary?) as Void {
    }

    function onStop(state as Dictionary?) as Void {
    }

    function getInitialView() as [Views] or [Views, InputDelegates] {
        return [new AlcoMeterView(), new AlcoMeterDelegate()];
    }

    (:glance)
    function getGlanceView() as [GlanceView] or [GlanceView, GlanceViewDelegate] or Null {
        return [new AlcoMeterGlanceView()];
    }

    // Settings changed in Garmin Connect: redraw with the new values.
    function onSettingsChanged() as Void {
        WatchUi.requestUpdate();
    }
}

function getApp() as AlcoMeterApp {
    return Application.getApp() as AlcoMeterApp;
}
