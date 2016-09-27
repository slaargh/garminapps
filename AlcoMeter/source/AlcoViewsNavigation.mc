using Toybox.WatchUi as Ui;
using Toybox.System;
using Toybox.Graphics as Graphics;

module AlcoViewsNavigation {
using AlcoViews;

   class DrinkMenuInputDelegate extends Ui.MenuInputDelegate{

        var _bartender;
        var _alcoCalc;

        function initialize(bartender, alcoCalc){
            _bartender = bartender;
            _alcoCalc = alcoCalc;
        }

        function onMenuItem(item){
            var selectedNumber = item;

            if(item == -1){
                _alcoCalc.removePrevious();
            }
            else if ( item == -2){
                _alcoCalc.removeAll();
            }
            else{
                var drink = _bartender.makeDrink(item, Time.now());

                _alcoCalc.addDrink(drink);
            }

            return true;
        }
    }

    class HistoryViewBehaviorDelegate extends Ui.BehaviorDelegate {

        var _alcoCalc;

        function initialize(alcoCalc){
            _alcoCalc = alcoCalc;
        }

        function onBack(){

        Ui.popView(Ui.SLIDE_RIGHT);
        return true;
        }


       function onSelect() {
            var menu = new Menu();
            var bartender = new Bartender();
            var drinkList = bartender.getDrinkList();


            for(var i = 0; i < drinkList.size(); i++){
                menu.addItem(drinkList[i].getDisplayName(),drinkList[i].id);
            }

            // dont want to lose that nice history of last bier accidently so place the remove selection as last :)
            menu.addItem("Remove previous",-1);
            menu.addItem("Remove all",-2);
            menu.setTitle("Drink menu");
            Ui.pushView(menu, new DrinkMenuInputDelegate(bartender, _alcoCalc) , SLIDE_LEFT);
            Ui.requestUpdate();
            return true;
        }


        function onNextPage() {
            Ui.switchToView(new AlcoViews.GraphView(_alcoCalc), new GraphViewBehaviorDelegate(_alcoCalc) , SLIDE_DOWN);
            Ui.requestUpdate();
            return true;
        }

        function onPreviousPage() {
            Ui.switchToView(new AlcoViews.GraphView(_alcoCalc), new GraphViewBehaviorDelegate(_alcoCalc) , SLIDE_DOWN);
            Ui.requestUpdate();
            return true;
        }
    }


    class GraphViewBehaviorDelegate extends Ui.BehaviorDelegate {

        var _alcoCalc;
        function initialize(alcoCalc){
            _alcoCalc = alcoCalc;
        }

        function onNextPage() {
            Ui.switchToView(new AlcoViews.HistoryView(_alcoCalc), new HistoryViewBehaviorDelegate(_alcoCalc) , SLIDE_UP);
            Ui.requestUpdate();
            return true;
        }

        function onBack(){
            Ui.popView(Ui.SLIDE_RIGHT);
            return true;
        }

        function onPreviousPage() {
            Ui.switchToView(new AlcoViews.HistoryView(_alcoCalc), new HistoryViewBehaviorDelegate(_alcoCalc) , SLIDE_UP);
            Ui.requestUpdate();
            return true;
        }
    }

    class MainViewBehaviourDelegate extends Ui.BehaviorDelegate {

        var _alcoCalc;

        function initialize(alcoCalc){
            _alcoCalc = alcoCalc;
        }


        function onSelect() {
            Ui.pushView(new AlcoViews.HistoryView(_alcoCalc), new HistoryViewBehaviorDelegate(_alcoCalc) , SLIDE_LEFT);
            Ui.requestUpdate();
            return true;
        }

    }
}
