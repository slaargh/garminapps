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

            dc.drawBitmap( 20, 50, _image );

            var promillesNow = _alcoCalc.promillesNow();

            if(promillesNow == 0){
                var noDrinkTxt1 = new Text({:text => "Press start twice", :color=>Graphics.COLOR_BLUE, :font=>Graphics.FONT_TINY });
                noDrinkTxt1.setLocation(90, 70);
                noDrinkTxt1.draw(dc);

                var noDrinkTxt2 = new Text({:text => "to add drinks!", :color=>Graphics.COLOR_BLUE, :font=>Graphics.FONT_TINY });
                noDrinkTxt2.setLocation(100, 100);
                noDrinkTxt2.draw(dc);


                return true;
            }
            var formatPromilles;
            if(promillesNow > 1){
                formatPromilles = promillesNow.format("%.3G");
            }
            else{
             formatPromilles = promillesNow.format("%.2G");
            }



            var txt = new Text({:text => formatPromilles, :color=>Graphics.COLOR_WHITE, :font=>Graphics.FONT_NUMBER_HOT});
            txt.setLocation(100, 80);
            txt.draw(dc);

            var drinkCount = _alcoCalc.getConsumedDrinks();
            var txt2 = new Text({:text => "x " + drinkCount, :color=>Graphics.COLOR_BLUE, :font=>Graphics.FONT_SMALL });
            txt2.setLocation(100, 70);
            txt2.draw(dc);

            var minutesUntilSober = _alcoCalc.minutesUntilSober();
            var soberText;

            if(minutesUntilSober > 60){
                var hoursUntilSober = minutesUntilSober / 60.0;

                if(hoursUntilSober < 10){
                    soberText = hoursUntilSober.format("%.1G") + "+ hours til sober";
                }
                else{
                    soberText = hoursUntilSober.format("%.2G") + " hours til sober";
                }

            }
            else if ( minutesUntilSober == 0){
                soberText = "";
            }
            else {
                soberText = minutesUntilSober.format("%.2G") + "+ mins til sober";
            }

            var txt3 = new Text({:text => soberText, :color=>Graphics.COLOR_DK_GRAY, :font=>Graphics.FONT_TINY });
            txt3.setLocation(50, 165);
            txt3.draw(dc);

            return true;


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

            //System.println(history.size());

            var size = history.size();
            for(var i = size-1; i >= 0; i--){
                //System.println(history[i]);
                var teksti = new Text({:text => history[i], :color=>Graphics.COLOR_WHITE, :font=>Graphics.FONT_TINY });
                teksti.setLocation(41, 10 + 20*(size-i));
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