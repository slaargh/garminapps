import Toybox.Attention;
import Toybox.Lang;
import Toybox.Time;
import Toybox.WatchUi;

module BeerActions {

    function addBeer() as Void {
        var now = Time.now().value();
        if (DrinkStore.add(BacCalculator.gramsPerBeer())) {
            // The previous session is over: move it into the saved history.
            StatsStore.commitOpen(now);
        }
        StatsStore.updateOpen(DrinkStore.load(), now);
        if (Attention has :vibrate) {
            Attention.vibrate([new Attention.VibeProfile(50, 150)]);
        }
        if (WatchUi has :showToast) {
            WatchUi.showToast("Beer added", null);
        }
        WatchUi.requestUpdate();
    }
}

class AlcoMeterDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    // START button: log a beer.
    function onSelect() as Boolean {
        BeerActions.addBeer();
        return true;
    }

    // Swallow screen taps so they don't turn into onSelect: tapping by accident must not log a
    // beer. Beers can still be added from the beer list's "+ Add beer" item.
    function onTap(evt as WatchUi.ClickEvent) as Boolean {
        return true;
    }

    // DOWN button / swipe up: open the stats.
    function onNextPage() as Boolean {
        StatsMenu.open();
        return true;
    }

    // UP button / swipe down: open the beer list.
    function onPreviousPage() as Boolean {
        BeerListMenu.open();
        return true;
    }

    // MENU (long-press UP): open the beer list.
    function onMenu() as Boolean {
        BeerListMenu.open();
        return true;
    }
}
