using Toybox.WatchUi as Ui;
using Toybox.System;
using Toybox.Graphics as Graphics;

module AlcoViewsNavigation{
using AlcoViews;

 // todo simpler way of navigating between views
// view order: // main --start--> history --next--> sober  -next--> graph

    class HistoryViewBehaviorDelegate extends Ui.BehaviorDelegate {
        function onNextPage() {
            Ui.switchToView(new AlcoViews.SoberView(), new SoberViewBehaviorDelegate() , SLIDE_UP);
            Ui.requestUpdate();
            return true;
        }

        function onPreviousPage() {
            Ui.switchToView(new AlcoViews.GraphView(), new GraphViewBehaviorDelegate() , SLIDE_DOWN);
            Ui.requestUpdate();
            return true;
        }
    }

    class SoberViewBehaviorDelegate extends Ui.BehaviorDelegate {
        function onNextPage() {
            Ui.switchToView(new AlcoViews.GraphView(), new GraphViewBehaviorDelegate() , SLIDE_UP);
            Ui.requestUpdate();
            return true;
        }

        function onPreviousPage() {
            Ui.switchToView(new AlcoViews.HistoryView(), new HistoryViewBehaviorDelegate() , SLIDE_DOWN);
            Ui.requestUpdate();
            return true;
        }
    }

    class GraphViewBehaviorDelegate extends Ui.BehaviorDelegate {
        function onNextPage() {
            Ui.switchToView(new AlcoViews.HistoryView(), new HistoryViewBehaviorDelegate() , SLIDE_UP);
            Ui.requestUpdate();
            return true;
        }

        function onPreviousPage() {
            Ui.switchToView(new AlcoViews.SoberView(), new SoberViewBehaviorDelegate() , SLIDE_DOWN);
            Ui.requestUpdate();
            return true;
        }
    }

    class MainViewBehaviourDelegate extends Ui.BehaviorDelegate {
        function onSelect() {
            Ui.switchToView(new AlcoViews.HistoryView(), new HistoryViewBehaviorDelegate() , SLIDE_LEFT);
            Ui.requestUpdate();
            return true;
        }

    }
}
