using Toybox.Application as App;
using AlcoViews;
using AlcoViewsNavigation;
using Toybox.System as Sys;
using Toybox.Time as Time;
using Toybox.Time.Gregorian as Greg;


class SavedDrink{
    var Id;
    var Ticks;

    function initialize(id, ticks){
        Id = id;
        Ticks = ticks;
    }

}

class AlcoCalc {

    var _userInfo;
    var _drinks;

    function initialize(userInfo, drinks){
        _userInfo = userInfo;
        _drinks = drinks;
    }

    function removeAll(){
        _drinks =  new [0];
    }

    function removePrevious(){
        if(_drinks.size() <= 0){
            return;
        }

        // pop!
        var tempDrinks = new [_drinks.size()-1];

        for(var i = 0; i < _drinks.size()-1; i++){
            if(_drinks[i] == null){
                continue;
            }
            tempDrinks[i] = _drinks[i];
        }

        _drinks =  tempDrinks;

    }

    function removeOldest(){

        if(_drinks.size() <= 0){
            return;
        }

        var tempDrinks = new [_drinks.size()-1];

        for(var i = 1; i < _drinks.size(); i++){
            if(_drinks[i] == null){
                continue;
            }
            tempDrinks[i-1] = _drinks[i];
        }

        _drinks =  tempDrinks;
    }

    function getDrinksForSave(){
        if(_drinks == null){
            return null;
        }

        if(_drinks.size() == 0){
            return null;
        }

        var saveDrinks = new [_drinks.size()];

        for(var i = 0; i < _drinks.size(); i++){
            if(_drinks[i] == null){
                continue;
            }
            var id = _drinks[i].getId();
            var ticks = _drinks[i].getTimeConsumed().value();

            var saveDrink = new [2];
            saveDrink[0] = id;
            saveDrink[1] = ticks;

            saveDrinks[i] = saveDrink;

        }

        return saveDrinks;
    }


    function getConsumedDrinks(){
        return _drinks.size();
    }

    function getDrinkHistory(){
        var history = new [_drinks.size()];

        for(var i = 0; i < _drinks.size(); i++){
            if(_drinks[i] == null){
                continue;
            }
            history[i] = _drinks[i].getDisplayName();
        }

        return history;
    }

    function addDrink(drink){

        // one can drink more than 20 but not in such fastion that the the first drink is still in blood
        // except for the professionals
        if(_drinks.size() > 20){
            removeOldest();
        }
        var newDrinkArray = new [_drinks.size() + 1];

        for(var i = 0; i < _drinks.size(); i++){
            newDrinkArray[i] = _drinks[i];
        }

        newDrinkArray[newDrinkArray.size()-1] = drink;

        _drinks = newDrinkArray;
    }

    function promillesNow(){

        var gramsOfAlcohol = getGramsOfAlcoholNow();

        if(gramsOfAlcohol <= 0){
            return 0;
        }

        var promilles = gramsOfAlcohol / (_userInfo.getRValue() * _userInfo.getWeight());
        return promilles;
    }

    function getGramsOfAlcoholNow(){

        var drinksTotal = _drinks.size();

        if(drinksTotal == 0){
            return 0;
        }

        var gramsOfAlcohol = 0;
        var now = Time.now();

        for(var i = 0; i < drinksTotal; i++){
            var drink = _drinks[i];

            if(drink == null){
                continue;
            }

            var minutesSinceDrank = now.subtract(drink.getTimeConsumed()).value() / 60.0;
            var gramsLeft = drink.getGramsOfAlcohol() - _userInfo.getBurnRate()* minutesSinceDrank;

            if(gramsLeft < 0){
                continue;
            }
             gramsOfAlcohol += gramsLeft;

         }
         return gramsOfAlcohol;
    }

    function minutesUntilSober(){
        var alcoholLeftToBurn = getGramsOfAlcoholNow();
        var minutes = alcoholLeftToBurn / _userInfo.getBurnRate();
        return minutes;

    }
}

class UserInfo{

    function getBurnRate(){
        // TODO: make this a setting / find rule for women (studies point out that women might actually burn alcohol more efficiently..)
        // Typical male burns one gram of alcohol for every 10 kilograms of weight in an hour
        var burnRate = getWeight() / 10.0 / 60; // in minutes

        return burnRate;
    }

    function getWeight(){
        var profile = UserProfile.getProfile();
        var weight = profile.weight;

        // TODO: AP doc states weight is in grams, is this true if weightUnits is not metric??
        var weightInKilos = weight / 1000.0;

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

    var _id;
    var _name;
    var _grams;
    var _consumedTime;

    function initialize(grams, consumedTime, name, id){
        _id = id;
        _grams = grams;
        _consumedTime = consumedTime;
        _name = name;
    }

    function getId(){
        return _id;
    }

    function getGramsOfAlcohol(){
        return _grams;
    }

    function getTimeConsumed(){
        return _consumedTime;
    }

    function getName(){
        return _name;
    }

    function getDisplayName(){
        if(_consumedTime == null){
            return "";
        }

       var infoa = Greg.info(_consumedTime, Time.FORMAT_SHORT);
       if(infoa == null){
            return "";
       }

        return infoa.hour  +":" + infoa.min +" "  +  _name;
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

    const AlcoholDensity = 789.0;

    function getDrinkList(){
        var drink1 = new Drinkable();
        drink1.name = "Beer III";
        drink1.percent = 4.5;
        drink1.volume = 0.33;
        drink1.id = 0;

        var drink2 = new Drinkable();
        drink2.name = "Beer III";
        drink2.percent = 4.5;
        drink2.volume = 0.5;
        drink2.id = 1;

        var drink3 = new Drinkable();
        drink3.name = "La Trappe Dubbel";
        drink3.percent = 7.0;
        drink3.volume = 0.33;
        drink3.id = 2;

        var drink4 = new Drinkable();
        drink4.name = "La Trappe Tripel";
        drink4.percent = 8.0;
        drink4.volume = 0.33;
        drink4.id = 3;

        var drink5 = new Drinkable();
        drink5.name = "La Trappe Quadrupel";
        drink5.percent = 10.0;
        drink5.volume = 0.33;
        drink5.id = 4;

        var drink6 = new Drinkable();
        drink6.name = "Viinaa";
        drink6.percent = 40;
        drink6.volume = 0.04;
        drink6.id = 5;

        var drink7 = new Drinkable();
        drink7.name = "La Trappe Blond";
        drink7.percent = 6.0;
        drink7.volume = 0.33;
        drink7.id = 6;

        var drink8 = new Drinkable();
        drink8.name = "La Trappe Witte";
        drink8.percent = 5.5;
        drink8.volume = 0.33;
        drink8.id = 7;


        var drink9 = new Drinkable();
        drink9.name = "La Trappe Puur";
        drink9.percent = 4.7;
        drink9.volume = 0.33;
        drink9.id = 8;

        var drink10 = new Drinkable();
        drink10.name = "Leffe Blonde";
        drink10.percent = 6.6;
        drink10.volume = 0.33;
        drink10.id = 9;

        var drink11 = new Drinkable();
        drink11.name = "La Chouffe";
        drink11.percent = 8;
        drink11.volume = 0.33;
        drink11.id = 10;

        var drinkList = [drink1, drink2, drink9, drink7, drink8, drink3, drink4, drink5, drink10, drink11, drink6 ];

        return drinkList;
    }

    function makeDrink(id, date){
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

        var drink = new Drink(alcoholGrams, date, drinkable.getDisplayName(), drinkable.id);

        return drink;
    }
}



class BeersApp extends App.AppBase {

    var _alcoCalc;
    function initialize() {
        AppBase.initialize();
    }

    //! onStart() is called on application start up
    function onStart() {
        // load stuff
        var drinks = new [0];
        // key = ticks
        // value = id of the drink
        // use bartender to make the drink
        // add drink to teh alco calco with overload for time (from ticks)
        var savedDrinks = getProperty(1);

        if(savedDrinks != null){
            var bartender = new Bartender();

            drinks = new [savedDrinks.size()];

            for(var i = 0; i < savedDrinks.size(); i++){
               if(savedDrinks[i] == null){
                    continue;
                }

                var savedDrink = savedDrinks[i];
                var id = savedDrink[0];
                var ticks = savedDrink[1];
                var drinkTime = new Time.Moment(ticks);

                var drink = bartender.makeDrink(id, drinkTime);

                drinks[i] = drink;
            }
        }

        var userInfo = new UserInfo();

        _alcoCalc = new AlcoCalc(userInfo, drinks);
    }

    //! onStop() is called when your application is exiting
    function onStop() {
    // persist stuffs from alcocalc!
        save();
    }

    function save(){
        var drinksToSave = _alcoCalc.getDrinksForSave();

        if(drinksToSave == null){
            // history was cleared, remove property
            deleteProperty(1);
        }

     setProperty(1, drinksToSave);

     return true;
    }

    //! Return the initial view of your application here
    function getInitialView() {


// never comment out code
  //      var past = Greg.moment({:hour=> 23, :minute=>19, :day=>20});
   //     var longTimeAgo = Greg.moment({:hour=> 6, :minute=>0, :day=>20});

//        var drink1 = new Drink(12, past, "beer 3");
//        var drink2 = new Drink(12, past,  "beer 3");
//        var drink3 = new Drink(12, longTimeAgo, "beer 3");
//        var drink4 = new Drink(12, longTimeAgo,  "beer 3");

//        var drinks = [drink1, drink2, drink3, drink4 ];
        //var temp = new Time.Moment(1459869965); // temp.value() -> ticks, new Time.Moment(ticks) ^^
       //var infoa = Greg.info(temp, Time.FORMAT_SHORT);


        var bac = _alcoCalc.promillesNow();
        return [ new AlcoViews.MainView(_alcoCalc), new AlcoViewsNavigation.MainViewBehaviourDelegate(_alcoCalc) ];
    }

}