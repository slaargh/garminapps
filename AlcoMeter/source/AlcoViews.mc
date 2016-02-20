using Toybox.WatchUi as Ui;
using Toybox.System;
using Toybox.Graphics as Graphics;
using Toybox.System as Sys;

module AlcoViews{

    class MainView extends Ui.View {
        var _bac;
        var _image;

        function initialize(bac) {
            _bac = bac;
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

            var formatBac = _bac.format("%.3G");

            var teksti = new Text({:text => formatBac, :color=>Graphics.COLOR_WHITE, :font=>Graphics.FONT_NUMBER_HOT});
            teksti.setLocation(100, 80);
            teksti.draw(dc);

            dc.drawBitmap( 20, 50, _image );

            var teksti2 = new Text({:text => "x 5", :color=>Graphics.COLOR_BLUE, :font=>Graphics.FONT_SMALL });
            teksti2.setLocation(100, 70);
            teksti2.draw(dc);

            var teksti3 = new Text({:text => "5 hours til sober", :color=>Graphics.COLOR_DK_GRAY, :font=>Graphics.FONT_TINY });
            teksti3.setLocation(70, 165);
            teksti3.draw(dc);


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
            var teksti = new Text({:text => "History", :color=>Graphics.COLOR_WHITE, :font=>Graphics.FONT_SMALL });
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