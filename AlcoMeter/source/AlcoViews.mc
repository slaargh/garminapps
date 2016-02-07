using Toybox.WatchUi as Ui;
using Toybox.System;
using Toybox.Graphics as Graphics;
using Toybox.System as Sys;

module AlcoViews{

    class MainView extends Ui.View {
        var _bac;

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

        }

        //! Update the view
        function onUpdate(dc) {
            View.onUpdate(dc);
            var string = "BAC:" + _bac;
            var teksti = new Text({:text => string, :color=>Graphics.COLOR_WHITE, :font=>Graphics.FONT_SMALL });
            teksti.setLocation(50, 10);
            teksti.draw(dc);


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