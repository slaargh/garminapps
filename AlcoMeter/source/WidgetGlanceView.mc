using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;

(:glance)
class WidgetGlanceView extends Ui.GlanceView {
	var _alcoCalc;
    function initialize(alcoCalc) {
      GlanceView.initialize();
      _alcoCalc = alcoCalc;
    }
    
    function onUpdate(dc) {
		var promillesNow = _alcoCalc.promillesNow();
		 var formatPromilles = promillesNow.format("%.2f");
            
            var minutesUntilSober = _alcoCalc.minutesUntilSober();
            var soberText;

            if(minutesUntilSober >= 60){
                var hoursUntilSober = minutesUntilSober / 60.0;

                if(hoursUntilSober > 10){
                soberText = hoursUntilSober.format("%d") + " h til sober";
                }
                else{
                    soberText = "~"+ hoursUntilSober.format("%.1f") + " h til sober";
                }
            }
            else if ( minutesUntilSober == 0){
                soberText = "";
            }
            else {
                soberText = minutesUntilSober.format("%d") + "min til sober";
            }
            
            var txt;
            if(promillesNow == 0)
            {
           	 	txt = new Ui.Text({:text => "Alcometer: 0!\n Lets drink!", :color=>Graphics.COLOR_WHITE, :font=>Gfx.FONT_SMALL });
            }
            else
            {
            	txt = new Ui.Text({:text => formatPromilles +"ppm\n" + soberText, :color=>Graphics.COLOR_WHITE, :font=>Gfx.FONT_SMALL });
            }            
   
            txt.setLocation(1, 1);
            txt.draw(dc);
    }
}