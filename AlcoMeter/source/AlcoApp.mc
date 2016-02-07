using Toybox.Application as App;
using AlcoViews;
using AlcoViewsNavigation;
using Toybox.System as Sys;

class AlcoMeter{

    var AlcoholBurnRate = 0.015;

    function bloodAlcohol(drinks){
        var profile = UserProfile.getProfile();
        var gender = profile.gender;
        var r = 0.66;

        if(gender == UserProfile.GENDER_MALE){
            r = 0.70;
        }

        var weight = profile.weight;

        var deviceSettings = new Sys.DeviceSettings();

        var weightUnit = deviceSettings.weightUnits;

        if(weightUnit !=  Sys.UNIT_METRIC){
            weight = weight * 0.4535923;
        }


        // todo: simulator sets weight to 30844.277344 kgs?
        if(weight > 200){
            weight = 70;
        }

        // TODO Calcualte hours from first drink
        //var moment = new Moment();
        //var now = moment.now()
        //var hoursSinceFirstDrink = now.substract(firstDrinkTime);
        var hoursSinceFirstDrink = 0;

        // todo calculate grams of pure alcohol from the drinks
        // now assume 1 drink = 1 standard issue drink
        // for future refence = volume ml * ac * 0,789 ~= grams of alcohol
        var alcoholGrams = drinks * 12; // finnish standard issue drink has approx 12 grams of alcohol

        var bac =  widmarkEquation(alcoholGrams, hoursSinceFirstDrink, weight, r);

        // Note: BAC is in g / mL (US), conver to mg/g (used in Scandinavia)
        bac = bac * 0.943; // TODO: check conversion accuracy & make this a use preference

        Sys.println(bac);

        var bacString = bac.toString().substring(0,4);

        return bacString;
    }

    function widmarkEquation(alhocholInGrams, hours, weight, r){
        var bac = ((alhocholInGrams / (weight * 1000 * r)) * 100) - AlcoholBurnRate * hours;
        Sys.println(bac);

        if(bac <= 0){
            return 0;
        }
        return bac;
    }
}


class BeersApp extends App.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    //! onStart() is called on application start up
    function onStart() {
    }

    //! onStop() is called when your application is exiting
    function onStop() {

    }

    //! Return the initial view of your application here
    function getInitialView() {
        var alcoMeter = new AlcoMeter();
        var bac = alcoMeter.bloodAlcohol(5);
        return [ new AlcoViews.MainView(bac), new AlcoViewsNavigation.MainViewBehaviourDelegate() ];
    }

}