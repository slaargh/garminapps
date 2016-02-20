using Toybox.WatchUi as Ui;
using Toybox.System;
using Toybox.Graphics as Graphics;
using Toybox.System as Sys;

module AlcoViews{

    class MainView extends Ui.View {
        var _alcoCalc;
        var _image;

        function initialize(alcoCalc) {
            _alcoCalc = alcoCalc;
            View.initialize();
        }

        //! Load your resources here
        function onLayout(dc) {
            setLayout(Rez.Layouts.MainLayout(dc));
        }

        //! Called when this View is brought to the foreground. Restore
        //! the state of this View and prepare it to be shown. This includes
        //! loading resources into memory.
        function onShow() {
         _image = Ui.loadResource( Rez.Drawables.BeerSmall );

        }

        //! Update the view
        function onUpdate(dc) {
            View.onUpdate(dc);

            var promillesNow = _alcoCalc.promillesNow();

            var formatPromilles = promillesNow.format("%.3G");

            var txt = new Text({:text => formatPromilles, :color=>Graphics.COLOR_WHITE, :font=>Graphics.FONT_NUMBER_HOT});
            txt.setLocation(100, 80);
            txt.draw(dc);

            dc.drawBitmap( 20, 50, _image );

            var drinkCount = _alcoCalc.getConsumedDrinks();
            var txt2 = new Text({:text => "x " + drinkCount, :color=>Graphics.COLOR_BLUE, :font=>Graphics.FONT_SMALL });
            txt2.setLocation(100, 70);
            txt2.draw(dc);

            var txt3 = new Text({:text => "5 hours til sober", :color=>Graphics.COLOR_DK_GRAY, :font=>Graphics.FONT_TINY });
            txt3.setLocation(70, 165);
            txt3.draw(dc);


            // Call the parent onUpdate function to redraw the layout
            //View.onUpdate(dc);
        }

        //! Called when this View is removed from the screen. Save the
        //! state of this View here. This includes freeing resources from
        //! memory.
        function onHide() {
        }
    }

    class HistoryView extends Ui.View {

        var _alcoCalc;
        function initialize(alcoCalc) {
            _alcoCalc = alcoCalc;
            View.initialize();
        }

        //! Load your resources here
        function onLayout(dc) {
            setLayout(Rez.Layouts.MainLayout(dc));
        }

        //! Called when this View is brought to the foreground. Restore
        //! the state of this View and prepare it to be shown. This includes
        //! loading resources into memory.
        function onShow() {

        }

        //! Update the view
        function onUpdate(dc) {
            // call base to reset view
            View.onUpdate(dc);



            var teksti = new Text({:text => "History", :color=>Graphics.COLOR_DK_GRAY, :font=>Graphics.FONT_SMALL });
            teksti.setLocation(50, 10);
            teksti.draw(dc);

            var history = _alcoCalc.getDrinkHistory();

            System.println(history.size());

            var size = history.size();
            for(var i = size-1; i >= 0; i--){
                System.println(history[i]);
                var teksti = new Text({:text => history[i], :color=>Graphics.COLOR_WHITE, :font=>Graphics.FONT_TINY });
                teksti.setLocation(50, 10 + 20*(size-i));
                teksti.draw(dc);

            }


            return true;
        }

        //! Called when this View is removed from the screen. Save the
        //! state of this View here. This includes freeing resources from
        //! memory.
        function onHide() {
        }
    }

    class SoberView extends Ui.View {

        function initialize() {
            View.initialize();
        }

        //! Load your resources here
        function onLayout(dc) {
            setLayout(Rez.Layouts.MainLayout(dc));
        }

        //! Called when this View is brought to the foreground. Restore
        //! the state of this View and prepare it to be shown. This includes
        //! loading resources into memory.
        function onShow() {

        }

        //! Update the view
        function onUpdate(dc) {
            // call base to reset view
            View.onUpdate(dc);
            var teksti = new Text({:text => "Sober", :color=>Graphics.COLOR_WHITE, :font=>Graphics.FONT_SMALL });
            teksti.setLocation(50, 10);
            teksti.draw(dc);
            return true;
        }

        //! Called when this View is removed from the screen. Save the
        //! state of this View here. This includes freeing resources from
        //! memory.
        function onHide() {
        }
    }

    class GraphView extends Ui.View {

        function initialize() {
            View.initialize();
        }

        //! Load your resources here
        function onLayout(dc) {
            setLayout(Rez.Layouts.MainLayout(dc));
        }

        //! Called when this View is brought to the foreground. Restore
        //! the state of this View and prepare it to be shown. This includes
        //! loading resources into memory.
        function onShow() {

        }

        //! Update the view
        function onUpdate(dc) {
            // call base to reset view
            View.onUpdate(dc);
            var teksti = new Text({:text => "Graph", :color=>Graphics.COLOR_WHITE, :font=>Graphics.FONT_SMALL });
            teksti.setLocation(50, 10);
            teksti.draw(dc);
            return true;
        }

        //! Called when this View is removed from the screen. Save the
        //! state of this View here. This includes freeing resources from
        //! memory.
        function onHide() {
        }
    }
}