using Toybox.WatchUi as Ui;
using Toybox.System;
using Toybox.Graphics as Graphics;
using Toybox.System as Sys;
using Toybox.Time.Gregorian as Greg;
using Toybox.Math as Math;
using Toybox.Time as Time;

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
                var noDrinkTxt1 = new Text({:text => "Press start twice", :color=>Graphics.COLOR_ORANGE, :font=>Graphics.FONT_TINY });
                noDrinkTxt1.setLocation(90, 70);
                noDrinkTxt1.draw(dc);

                var noDrinkTxt2 = new Text({:text => "to add drinks!", :color=>Graphics.COLOR_ORANGE, :font=>Graphics.FONT_TINY });
                noDrinkTxt2.setLocation(100, 100);
                noDrinkTxt2.draw(dc);


                return true;
            }
            var formatPromilles = promillesNow.format("%.2f");

            var txt = new Text({:text => formatPromilles, :color=>Graphics.COLOR_WHITE, :font=>Graphics.FONT_NUMBER_HOT});
            txt.setLocation(100, 80);
            txt.draw(dc);

            var drinkCount = _alcoCalc.getConsumedDrinks();
            var txt2 = new Text({:text => "x " + drinkCount, :color=>Graphics.COLOR_BLUE});
            txt2.setLocation(100, 70);
            txt2.draw(dc);

            var minutesUntilSober = _alcoCalc.minutesUntilSober();
            var soberText;

            if(minutesUntilSober >= 60){
                var hoursUntilSober = minutesUntilSober / 60.0;

                if(hoursUntilSober > 10){
                    soberText = hoursUntilSober.format("%d") + "+ hours til sober";
                }
                else{
                    // TODO 1.7 hour -> 2 hours but no roundin available in the framework :(
                    soberText = hoursUntilSober.format("%.1f") + " hours til sober";
                }




            }
            else if ( minutesUntilSober == 0){
                soberText = "";
            }
            else {
                soberText = minutesUntilSober.format("%d") + "+ mins til sober";
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



            var teksti = new Text({:text => "History", :color=>Graphics.COLOR_ORANGE, :font=>Graphics.FONT_SMALL });
            teksti.setLocation(50, 10);
            teksti.draw(dc);

            var history = _alcoCalc.getDrinkHistory();

            //System.println(history.size());

            var size = history.size();
            for(var i = size-1; i >= 0; i--){
                //System.println(history[i]);
                var teksti = new Text({:text => history[i], :color=>Graphics.COLOR_WHITE, :font=>Graphics.FONT_TINY });
                teksti.setLocation(35, 10 + 20*(size-i));
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

    class GraphView extends Ui.View {

        var _alcoCalc;
        function initialize(alcoCalc) {
            View.initialize();
            _alcoCalc = alcoCalc;
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

            var title = new Text({:text => "Graph", :color=>Graphics.COLOR_ORANGE, :font=>Graphics.FONT_SMALL });
            title.setLocation(50, 10);
            title.draw(dc);

            // 1 pixel = 1 minute, fenix 3 has 218 pixels so thats good 3+ hours of graph
           var minutes = dc.getWidth();
           var zeroLine = dc.getHeight() / 1.5;

           var hours = minutes / 60;
           //var hours = Math.floor();
           var text = hours + " hours";
           var subtitle = new Text({:text => text, :color=>Graphics.COLOR_LT_GRAY, :font=>Graphics.FONT_TINY });
           subtitle.setLocation(50, zeroLine);
           subtitle.draw(dc);

           var yPoints = new [minutes];

           var now = Time.now();
           var ticksNow =  now.value();

           for(var i = 0; i < minutes; i++){
                // calculate promilles for each 5 min (serious performance issues otherwise!)
                if( i != 0 && i % 5 != 0){
                    yPoints[i] = yPoints[i-1]; // set previous value for non-calculated values
                    continue;
                }

                var ticksPast = ticksNow - i * 60;
                var timePast = new Time.Moment(ticksPast);
                var bac = _alcoCalc.getGramsOfAlcoholAtTime(timePast);

                if(bac != 0){
                    bac = bac + 5; // graph would look small, add moar value!
                }

                var yPoint = zeroLine - bac;
                yPoints[i] = yPoint;
            }

            // lets draw history!
            for(var i = 0; i < yPoints.size()-1; i++){

                var first = yPoints[i];
                var second = yPoints[i+1];

                var x = minutes-4-i; // move graph few pixels so that the bezel does not hide latest

                // fill
                dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_BLACK);
                dc.drawLine(x, first, x, zeroLine);

                // graph line
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
                dc.drawLine(x, first, x+1, second);
            }

            // draw zero line
            dc.setColor(Graphics.COLOR_ORANGE, Graphics.COLOR_BLACK);
            dc.drawLine(0, zeroLine, minutes, zeroLine);


            return true;
        }

        //! Called when this View is removed from the screen. Save the
        //! state of this View here. This includes freeing resources from
        //! memory.
        function onHide() {
        }
    }
}