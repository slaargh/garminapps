using Toybox.Application;
using Toybox.System as Sys;
using Toybox.Time as Time;
using Toybox.Time.Gregorian as Greg;


(:glance)    
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

        // one can drink more than 21 but not in such fashion that the first drink's alcohol is still in blood
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

    function getGramsOfAlcoholAtTime(time){
        var drinksTotal = _drinks.size();

        if(drinksTotal == 0){
            return 0;
        }

        var gramsOfAlcohol = 0;
        var now = time;
        var userBurnRate = _userInfo.getBurnRate();

        for(var i = 0; i < drinksTotal; i++){
            var drink = _drinks[i];

            if(drink == null){
                continue;
            }
            var timeConsumed = drink.getTimeConsumed();
            if(timeConsumed.greaterThan(now)){
                continue;
            }

            var minutesSinceDrank = now.subtract(timeConsumed).value() / 60.0;
            var gramsLeft = drink.getGramsOfAlcohol() - userBurnRate * minutesSinceDrank;
            if(gramsLeft < 0){
                continue;
            }
             gramsOfAlcohol += gramsLeft;

         }
         return gramsOfAlcohol;
    }


    function getGramsOfAlcoholNow(){
        return getGramsOfAlcoholAtTime(Time.now());
    }

    function minutesUntilSober(){
        var alcoholLeftToBurn = getGramsOfAlcoholNow();
        var minutes = alcoholLeftToBurn / _userInfo.getBurnRate();
        return minutes;
    }
}
   (:glance)    
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
   (:glance)    
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

   (:glance)   
class Drinkable{
    var name;
    var percent;
    var volume;
    var id;

    function getDisplayName(){
        var displayVolume = volume.format("%.3G") + " l";

        if( volume < 0.3) {
            var volumeInCl = volume * 100;
            displayVolume = volumeInCl.format("%.3G") + " cl";
        }

        var string = name + " (" + percent.format("%.2G") + "%) " + displayVolume;

        return string;
    }
}

   (:glance)   
class Bartender{

    const AlcoholDensity = 789.0;

    function getDrinkList(){
        var drink1 = new Drinkable();
        drink1.name = Application.Properties.getValue("Drink1Name");
        drink1.percent = Application.Properties.getValue("Drink1Alcohol").toFloat();
        drink1.volume = Application.Properties.getValue("Drink1Volume").toFloat();
        drink1.id = 0;

        var drink2 = new Drinkable();
        drink2.name = Application.Properties.getValue("Drink2Name");
        drink2.percent = Application.Properties.getValue("Drink2Alcohol").toFloat();
        drink2.volume = Application.Properties.getValue("Drink2Volume").toFloat();
        drink2.id = 1;

        var drink3 = new Drinkable();
        drink3.name = Application.Properties.getValue("Drink3Name");
        drink3.percent = Application.Properties.getValue("Drink3Alcohol").toFloat();
        drink3.volume = Application.Properties.getValue("Drink3Volume").toFloat();
        drink3.id = 2;
       
        var drink4 = new Drinkable();
        drink4.name = Application.Properties.getValue("Drink4Name");
        drink4.percent = Application.Properties.getValue("Drink4Alcohol").toFloat();
        drink4.volume = Application.Properties.getValue("Drink4Volume").toFloat();
        drink4.id = 3;
        
        var drink5 = new Drinkable();
        drink5.name = Application.Properties.getValue("Drink5Name");
        drink5.percent = Application.Properties.getValue("Drink5Alcohol").toFloat();
        drink5.volume = Application.Properties.getValue("Drink5Volume").toFloat();
        drink5.id = 4;

        var drinkList = [drink1, drink2, drink3, drink4, drink5 ];

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

class AlcoMeterApp extends Application.AppBase {
	var _alcoCalc;
	
    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state) {
		var drinks = new [0];
		
		var savedDrinks =Toybox.Application.Storage.getValue(1);

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
        else{
      	  Toybox.Application.Storage.setValue(1, drinks); 
        } 
		
		
		var userInfo = new UserInfo();
            
       _alcoCalc = new AlcoCalc(userInfo, drinks);
    }

    // onStop() is called when your application is exiting
    function onStop(state) {
        save();
        _alcoCalc = null;
    }

    function save(){
        var drinksToSave = _alcoCalc.getDrinksForSave();

        if(drinksToSave == null){
            // history was cleared, remove property
            Toybox.Application.Storage.clearValues();
        }
	
	Toybox.Application.Storage.setValue(1, drinksToSave);
    

     return true;
    }

    // Return the initial view of your application here
    function getInitialView() {
 		var bac = _alcoCalc.promillesNow();
        return [ new AlcoViews.MainView(_alcoCalc), new AlcoViewsNavigation.MainViewBehaviourDelegate(_alcoCalc) ];
        //return [ new AlcoMeterView() ];
    }
    
    (:glance)    
    function getGlanceView() {
    	var bac = _alcoCalc.promillesNow();
        return [ new WidgetGlanceView(_alcoCalc) ];
    }

}