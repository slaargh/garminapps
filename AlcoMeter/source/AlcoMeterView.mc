using Toybox.WatchUi as Ui;
using Toybox.System;
using Toybox.Graphics as Graphics;
using Toybox.System as Sys;
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
                var noDrinkTxt1 = new Ui.Text({:text => "Press start twice", :color=>Graphics.COLOR_ORANGE, :font=>Graphics.FONT_TINY });
                noDrinkTxt1.setLocation(90, 70);
                noDrinkTxt1.draw(dc);

                var noDrinkTxt2 = new Ui.Text({:text => "to add drinks!", :color=>Graphics.COLOR_ORANGE, :font=>Graphics.FONT_TINY });
                noDrinkTxt2.setLocation(100, 100);
                noDrinkTxt2.draw(dc);


                return true;
            }
            var formatPromilles = promillesNow.format("%.2f");

            var txt = new Ui.Text({:text => formatPromilles, :color=>Graphics.COLOR_WHITE, :font=>Graphics.FONT_NUMBER_HOT});
            txt.setLocation(100, Graphics.getFontHeight(Graphics.FONT_MEDIUM)+60);
            txt.draw(dc);

            var drinkCount = _alcoCalc.getConsumedDrinks();
            var txt2 = new Ui.Text({:text => "x " + drinkCount, :color=>Graphics.COLOR_BLUE, :font=>Graphics.FONT_MEDIUM});
            txt2.setLocation(100, 60);
            txt2.draw(dc);

            var minutesUntilSober = _alcoCalc.minutesUntilSober();
            var soberText;

            if(minutesUntilSober >= 60){
                var hoursUntilSober = minutesUntilSober / 60.0;

                if(hoursUntilSober > 10){
                    soberText = hoursUntilSober.format("%d") + "+ hours til sober";
                }
                else{
                    // Round 1.6 hour -> 2 hours: hoursUntilSober = Math.round(hoursUntilSober);
                    soberText = "~"+ hoursUntilSober.format("%.1f") + " hours til sober";
                }
            }
            else if ( minutesUntilSober == 0){
                soberText = "";
            }
            else {
                soberText = minutesUntilSober.format("%d") + "+ mins til sober";
            }

            var txt3 = new Ui.Text({:text => soberText, :color=>Graphics.COLOR_DK_GRAY, :font=>Graphics.FONT_TINY });
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

            var title = new Ui.Text({:text => "History", :color=>Graphics.COLOR_ORANGE, :font=>Graphics.FONT_XTINY });
            title.setLocation(57, 10);
            title.draw(dc);

            var history = _alcoCalc.getDrinkHistory();

            var size = history.size();
            for(var i = size-1; i >= 0; i--){
                var historyLine = new Ui.Text({:text => history[i], :color=>Graphics.COLOR_WHITE, :font=>Graphics.FONT_TINY });
                historyLine.setLocation(35, 10 + 20*(size-i));
                historyLine.draw(dc);
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

            var title = new Ui.Text({:text => "BAC over time", :color=>Graphics.COLOR_ORANGE, :font=>Graphics.FONT_TINY });
            title.setLocation(57, 10);
            title.draw(dc);

            // 1 pixel = 1 minute, fenix 3 has 218 pixels so thats good 3+ hours of graph
           var minutes = dc.getWidth();
           var zeroLine = dc.getHeight() / 1.5;

           var hours = minutes / 60;
           var text = hours + " hours";
           var subtitle = new Ui.Text({:text => text, :color=>Graphics.COLOR_LT_GRAY, :font=>Graphics.FONT_TINY });
           subtitle.setLocation(35, zeroLine);
           subtitle.draw(dc);

           var yPoints = new [minutes];

           var now = Time.now();
           var ticksNow =  now.value();
           var resolution = 5;
           
           for(var i = 0; i < minutes; i++){

                if( i != 0 && i % resolution != 0){
                    // NOTE calculate promilles only for each x min. Serious performance issues otherwise!)
                    continue;
                }

                var ticksPast = ticksNow - i * 60;
                var timePast = new Time.Moment(ticksPast);
                var bac = _alcoCalc.getGramsOfAlcoholAtTime(timePast);

                if(bac != 0){
                    bac = bac + 6; // graph would look small, add moar value!
                }

                var yPoint = zeroLine - bac;
                yPoints[i] = yPoint;
            }

            // lets draw the graph from list of points
            // TODO uses hard coded limit now, does not work with hw that has more pixels
            var points = new [64]; // NOTE: 64 is the point limit, this will do since the graph has data points at minutes/resolutio which is 218/5 ~= 44

            // initialize all points to zeroline
            for(var i = 0; i < points.size(); i++){
                points[i] = [0, zeroLine];
            }

            // fill in bac at given time (minutes)
            var j = 0;
            for(var i = 0; i < yPoints.size(); i++){
                if(yPoints[i] == null){
                    continue;
                }

                points[j] = [minutes-4-i, yPoints[i]]; // point: [minute, bac], substract some extra time so that bezel does not eat up space
                j++;
            }
            
            // draw white line over the graph            
            for(var i = 0; i < points.size()-1; i++){
                var first = points[i];
                var second = points[i+1];

				// gray stripes                
                dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLUE);
                dc.drawLine(first[0], first[1], first[0], zeroLine);
                dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLUE);
                dc.drawLine(first[0]+1, first[1], first[0]+1, zeroLine);
			
				// bolded line :) 
				dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
                dc.drawLine(first[0], first[1], second[0], second[1]);
                dc.drawLine(first[0]+1, first[1], second[0]+1, second[1]);
                
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