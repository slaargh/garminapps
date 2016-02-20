using Toybox.Application as App;
using AlcoViews;
using AlcoViewsNavigation;
using Toybox.System as Sys;
using Toybox.Time as Time;

class AlcoCalc {

    var _userInfo;
    var _drinks;

    function initialize(userInfo, drinks){
        _userInfo = userInfo;
        _drinks = drinks;
    }

    function promillesNow(){
        var gramsOfAlcohol = 4*12; // TODO CALC this stuff out

        var promilles = gramsOfAlcohol / (_userInfo.getRValue() * _userInfo.getWeight());

        return promilles;
    }
}

class UserInfo{

    function getBurnRate(){
        // TODO: make this a setting / find rule for women (studies point out that women might actually burn alcohol more efficiently..)
        // Typical male burns one gram of alcohol for every 10 kilograms of weight in an hour
        var burnRate = getWeight() / 10/ 60 /60; // in seconds?

        return burnRate;
    }

    function getWeight(){
        var profile = UserProfile.getProfile();
        var weight = profile.weight;

        // TODO: AP doc states weight is in grams, is this true if weightUnits is not metric??
        var weightInKilos = weight / 1000;

        System.println(weightInKilos);
        return weightInKilos;

    }

    function getRValue(){
        var profile = UserProfile.getProfile();
        var gender = profile.gender;

        var r = 0.66;

        if(gender == UserProfile.GENDER_MALE){
            r = 0.75;
        }

        return r;
    }
}

class Drink{

    var _grams;
    var _consumedTime;

    function initialize(grams, consumedTime){
        _grams = grams;
        _consumedTime = consumedTime;
    }

    function getGramsOfAlcohol(){
        return _grams;
    }

    function getTimeConsumed(){
        return _consumedTime;
    }
}

class Drinkable{
    var name;
    var percent;
    var volume;
    var id;

    function getDisplayName(){
        var displayVolume = volume.format("%.3G") + " l";

        if( volume < 0.3) {
            var volumeInCl = volume * 1000;
            displayVolume = volumeInCl.format("%.3G") + " cl";
        }

        var string = name + " (" + percent.format("%.2G") + "%) " + displayVolume;

        return string;
    }
}

class Bartender{

    const AlcoholDensity = 789;

    function getDrinkList(){
        var drink1 = new Drinkable();
        drink1.name = "Beer III";
        drink1.percent = 4.5;
        drink1.volume = 0.33;
        drink1.id = 0;

        var drink2 = new Drinkable();
        drink2.name = "Viinaa";
        drink2.percent = 40;
        drink2.volume = 0.04;
        drink2.id = 1;

        var drinkList = [drink1, drink2];

        return drinkList;
    }

    function makeDrink(id){
        var drinks = getDrinkList();

        var drinkable = null;

        // the id is a symbol, could a dictionary be used for better perf?
        for(var i = 0; i < drinks.size(); i++){
            if(drinks[i].id == id){
                drinkable = drinks[i];
                break;
            }
        }

        var alcoholGrams = drinkable.volume * drinkable.percent / 100 * AlcoholDensity;

        var roundedGrams = alcoholGrams.format("%.3G");

        System.println(roundedGrams);

        var now = new Time.Moment();
        var drink = new Drink(roundedGrams, now);

        return drink;

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
        var userInfo = new UserInfo();
        var drinks = new [2];
        var alcoCalc = new AlcoCalc(userInfo, drinks);
        var bac = alcoCalc.promillesNow();
        System.println(bac);
        return [ new AlcoViews.MainView(bac), new AlcoViewsNavigation.MainViewBehaviourDelegate() ];
    }

}