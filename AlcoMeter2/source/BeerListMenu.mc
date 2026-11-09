import Toybox.Lang;
import Toybox.Time;
import Toybox.WatchUi;

module BeerListMenu {

    function title(count as Number) as String {
        return "Beers (" + count.format("%d") + ")";
    }

    function beerLabel(number as Number) as String {
        return "Beer " + number.format("%d");
    }

    // Menu layout: [+ Add beer] [newest beer ... oldest beer] [Clear all] [disclaimer]
    function open() as Void {
        var drinks = DrinkStore.load();
        var n = drinks.size();
        var menu = new WatchUi.Menu2({:title => title(n)});
        var ids = [] as Array<Number>;

        menu.addItem(new WatchUi.MenuItem("+ Add beer",
            BacCalculator.gramsPerBeer().format("%.1f") + " g alcohol", :add, null));
        for (var i = n - 1; i >= 0; i--) {
            var ts = drinks[i][0] as Number;
            ids.add(ts);
            menu.addItem(new WatchUi.MenuItem(beerLabel(i + 1),
                BacCalculator.formatTime(ts), ts, null));
        }
        menu.addItem(new WatchUi.MenuItem("Clear all", null, :clear, null));
        menu.addItem(new WatchUi.MenuItem("Estimate only",
            "Not for driving", :info, null));

        WatchUi.pushView(menu, new BeerListDelegate(menu, ids), WatchUi.SLIDE_UP);
    }
}

class BeerListDelegate extends WatchUi.Menu2InputDelegate {

    private var _menu as WatchUi.Menu2;
    // Timestamps of the beer items, in menu order (newest first). Menu index = position + 1.
    private var _ids as Array<Number>;

    function initialize(menu as WatchUi.Menu2, ids as Array<Number>) {
        Menu2InputDelegate.initialize();
        _menu = menu;
        _ids = ids;
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var id = item.getId();
        if (id == :add) {
            BeerActions.addBeer();
            WatchUi.popView(WatchUi.SLIDE_DOWN);
        } else if (id == :clear) {
            if (_ids.size() > 0) {
                WatchUi.pushView(new WatchUi.Confirmation("Clear all beers?"),
                    new BeerConfirmDelegate(self, null), WatchUi.SLIDE_IMMEDIATE);
            }
        } else if (id instanceof Number) {
            WatchUi.pushView(
                new WatchUi.Confirmation("Delete beer from " + BacCalculator.formatTime(id) + "?"),
                new BeerConfirmDelegate(self, id), WatchUi.SLIDE_IMMEDIATE);
        }
    }

    function deleteBeer(ts as Number) as Void {
        DrinkStore.removeAtTime(ts);
        StatsStore.updateOpen(DrinkStore.load(), Time.now().value());
        var pos = _ids.indexOf(ts);
        if (pos >= 0) {
            _menu.deleteItem(pos + 1);
            _ids.remove(ts);
        }
        relabel();
    }

    function clearAll() as Void {
        DrinkStore.clear();
        StatsStore.updateOpen([] as Array<Array<Numeric>>, Time.now().value());
        for (var i = 0; i < _ids.size(); i++) {
            _menu.deleteItem(1);
        }
        _ids = [] as Array<Number>;
        relabel();
    }

    // Keep "Beer N" numbering and the title consistent after a deletion.
    private function relabel() as Void {
        var n = _ids.size();
        for (var i = 0; i < n; i++) {
            var item = _menu.getItem(i + 1);
            if (item != null) {
                item.setLabel(BeerListMenu.beerLabel(n - i));
            }
        }
        _menu.setTitle(BeerListMenu.title(n));
        WatchUi.requestUpdate();
    }
}

class BeerConfirmDelegate extends WatchUi.ConfirmationDelegate {

    private var _parent as BeerListDelegate;
    private var _ts as Number?; // null = clear all

    function initialize(parent as BeerListDelegate, ts as Number?) {
        ConfirmationDelegate.initialize();
        _parent = parent;
        _ts = ts;
    }

    function onResponse(response as WatchUi.Confirm) as Boolean {
        if (response == WatchUi.CONFIRM_YES) {
            var ts = _ts;
            if (ts == null) {
                _parent.clearAll();
            } else {
                _parent.deleteBeer(ts);
            }
        }
        return true;
    }
}
