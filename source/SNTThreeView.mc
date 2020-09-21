using Toybox.Graphics;
using Toybox.Lang;
using Toybox.Math;
using Toybox.System as Sys;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.WatchUi;
using Toybox.Application;
using Toybox.Background;
using Toybox.Position;
using Toybox.System as Sys;
using Toybox.Activity;
using Toybox.ActivityMonitor;



class SNTThreeView extends WatchUi.WatchFace
{
		var colBG	 = 0x000000;
		var colDATE 	 = 0x555555;
		var colHOUR 	 = 0xFFFFFF;
		var colMIN	 = 0x555555;
		var colLINE 	 = 0x555555;
		var colDatafield = 0x555555;
		
		var twlveclock = false;
		var info, data, settings, value, BtInd, zeroformat;
		var BattStats;
		/* ICONS MAPPER*/
		
		var regfont, hourfont;
		
		
		/*
		 * HEARTRATE:      A
		 * CALORIES:       B
		 * STEPS:          C
		 * ALTITUDE:       D
		 * MESSAGES:       E
		 * STAIRS:         F
		 * ALARM COUNT:    G
		 * BLUETOOTH:      H
		 * ACTIVE MINUTES: I
		 * BATTERY:        J
		 * DISTANCE WEEK:  K
		 * */
		
		
	
		var dayOfWeekArr    = [null, "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
		var monthOfYearArr  = [null, "January", "February", "March", "April", "May", "June", "July",
							         "August", "September", "Octotber", "November", "December"];
		
		
		
		var scrRadius;
		var scrWidth, scrHeight;
		
		
	
		
		function initialize(){
			WatchFace.initialize();	
		
		}
		
		function getSettings(){
			info = ActivityMonitor.getInfo();
			var app = Application.getApp();
			colLINE = app.getProperty("colLine");
			colHOUR = app.getProperty("colHour");
			colMIN  = app.getProperty("colMin");
			colBG   = app.getProperty("colBg");
			colDATE = app.getProperty("colDate");
			colDatafield = app.getProperty("colDatafield");
		
		}
		
		function getField(values){
			
			if (values == -1) {
				return method(:EmptyF);
			}
			if (values == 0) {
				if (info has :getHeartRateHistory) {
					return method(:HeartRate);
				} else {
					return method(:Invalid);
				}
			} else if (values == 1){
				return method(:Calories);
				
			} else if (values == 2){
				return method(:Steps);
				
			} else if (values == 3){
				if ( (Toybox has :SensorHistory) && (Toybox.SensorHistory has :getElevationHistory)) {
					return method(:Altitude);
				} else {
					return method(:Invalid);
				} 
				
			} else if (values == 4){
				return method(:Battery);
				
			} else if (values == 5){
				if (info has :floorsClimbed) {
					return method(:Stairs);
				} else {
					return method(:Invalid);
				}
				
			} else if (values == 6){
				return method(:Messages);
				
			} else if (values == 7){
				return method(:Alarmcount);
			} else if (values == 8){
				return method(:PhoneConn);
			} else if (values == 9){
				if (info has :activeMinutesDay){
					return method(:ActiveMinutesDay);
				} else {
					return method(:Invalid);
				}
			} else if (values == 10){
				if (info has :activeMinutesWeek){
					return method(:ActiveMinutesWeek);
				} else {
					return method(:Invalid);
				}
			} else if (values == 11){
				return method(:DistanceDay);
			} else if (values == 12) {
				if ((Toybox has :SensorHistory) && (Toybox.SensorHistory has :getTemperatureHistory)) {
					return method(:DeviceTemp);
				} else{
					 return method(:Invalid);
				}
			} else if (values == 13) {
				if ((Toybox.System has :ServiceDelegate)) {
					if (Authorize() == true){
						
						//weatherfont = WatchUi.loadResource(Rez.Fonts.Weather);
						Background.registerForTemporalEvent(new Time.Duration(Application.getApp().getProperty("updateFreq") * 60));
						return method(:Weather);
						
					} else {
						return method(:Premium);
					}
				}
			} else if (values == 14) {
				return method(:Invalid);
			} else {
				return method(:Invalid);
			}
		}
		
		function onLayout(dc){
			if ((Toybox.System has :ServiceDelegate)) {
				Background.deleteTemporalEvent();
			}

			getSettings();
			scrWidth = dc.getWidth();
			scrHeight = dc.getHeight();
			scrRadius = scrWidth / 2;
			
			hourfont = WatchUi.loadResource(Rez.Fonts.time);

			if (scrHeight < 209) {
					regfont = Graphics.FONT_MEDIUM;
			}
			

		}
		
		function onUpdate(dc){
			dc.setColor(0, colBG);
			dc.clear();		
			info     = ActivityMonitor.getInfo();
			settings = Sys.getDeviceSettings();
			
			
	
			drawTime(dc);
			dc.setColor(colDatafield, -1);
			
			
		}
		
		
		/*function drawComplication1(dc){	
			data = methodRight.invoke();
			dc.drawText(scrRadius - 30, scrRadius + 25, regfont, data[0], Graphics.TEXT_JUSTIFY_RIGHT);
			dc.drawText(scrRadius - 5, scrRadius + 32, iconfont, data[1], Graphics.TEXT_JUSTIFY_RIGHT);	
			dc.drawText(scrRadius - 5, scrRadius + 32, weatherfont, data[2], Graphics.TEXT_JUSTIFY_RIGHT);	
		}
		
		
		function drawComplication2(dc){
			data = methodLeft.invoke();
			dc.drawText(scrRadius + 30, scrRadius + 25, regfont, data[0], Graphics.TEXT_JUSTIFY_LEFT);
			dc.drawText(scrRadius + 5, scrRadius + 32, iconfont, data[1], Graphics.TEXT_JUSTIFY_LEFT);
			dc.drawText(scrRadius + 3, scrRadius + 32, weatherfont, data[2], Graphics.TEXT_JUSTIFY_LEFT);
		}
		
		
		function drawComplication3(dc){
			data = methodLeftBottom.invoke();
			dc.drawText(scrRadius - 30, scrRadius + 48, regfont, data[0], Graphics.TEXT_JUSTIFY_RIGHT);
			dc.drawText(scrRadius - 5, scrRadius + 55, iconfont, data[1], Graphics.TEXT_JUSTIFY_RIGHT);
			dc.drawText(scrRadius - 5, scrRadius + 55, weatherfont, data[2], Graphics.TEXT_JUSTIFY_RIGHT);
		}
		
		
		function drawComplication4(dc){
			data = methodRightBottom.invoke();
			dc.drawText(scrRadius + 30, scrRadius + 48, regfont, data[0], Graphics.TEXT_JUSTIFY_LEFT);
			dc.drawText(scrRadius + 5, scrRadius + 55, iconfont, data[1], Graphics.TEXT_JUSTIFY_LEFT);			
			dc.drawText(scrRadius + 3, scrRadius + 55, weatherfont, data[2], Graphics.TEXT_JUSTIFY_LEFT);			
		} */
		
	
		
		
		function drawBattery(dc){
				data = Battery();
				dc.drawText(scrRadius, scrWidth - 30, regfont, data[0], Graphics.TEXT_JUSTIFY_CENTER);
				data = null;
		}
		 
		function drawTime(dc){
			var time;
			
			time = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
			dc.setColor(colHOUR, -1);
			var tmp = (twlveclock == false ? time.hour : (time.hour > 12 ? time.hour - 12 : time.hour));
			if (zeroformat == true){
				tmp = tmp.format("%02d");
			}
			dc.drawText(scrRadius - 8, scrRadius, hourfont, tmp,                     Graphics.TEXT_JUSTIFY_RIGHT|Graphics.TEXT_JUSTIFY_VCENTER);
			dc.drawText(scrRadius, scrRadius,     hourfont, ":",                     Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
			dc.drawText(scrRadius + 8, scrRadius, hourfont, time.min.format("%02d"), Graphics.TEXT_JUSTIFY_LEFT|Graphics.TEXT_JUSTIFY_VCENTER);

			time = null; tmp = null;
		}
		
		function drawDate(dc){
			dc.setColor(colDATE,-1);
			var datestring,time;
			time = Gregorian.info(Time.now(), Time.FORMAT_SHORT); 
			datestring = dayOfWeekArr[time.day_of_week] + " " + monthOfYearArr[time.month] + " " + time.day;
			dc.drawText(scrRadius, scrRadius - 80, regfont, datestring ,Graphics.TEXT_JUSTIFY_CENTER);
			time = null; datestring = null;
		}
		
		function Authorize() {
		//yes, in theory you could modify this code to always return true, and get the premium features. 
		// if you're going to do that, just realize that i provide everything except weather free of charge,
		// even the source code. a small donation would be appreciated...
		
			var tmpString = Application.getApp().getProperty("keys");
			if (tmpString == null) {return false;}
			if (tmpString.hashCode() == null) {return false;}
			 
			
			if (tmpString.hashCode()  == -1258539636) {
				return true;
			} else if (tmpString.hashCode() == -55185590){
				return true;
			} else {
				return false;
			}	
		}
		
	
	
	////////////////////////////
	/////     DATAFIELDS   /////
	/////     ONLY         /////
	/////     DATAFIELDS   /////
	/////     UNDER        /////
	/////     THIS         /////
	/////     PART         /////
	////////////////////////////
	
		
	function HeartRate(){
		value = Activity.getActivityInfo().currentHeartRate;
		if(value == null) {
			value = ActivityMonitor.getHeartRateHistory(1, true).next().heartRate;
		}
		if (value == 255) {
			value = "-.-";
		}
		return [value, "a", ""];
	}
	
	
	function Calories(){
		return [info.calories, "b", "" ];
	}
	
	
	function Steps(){
		return [info.steps , "c", ""];
	}
	

	function Altitude(){
		var value = Activity.getActivityInfo().altitude;
		if(value == null){
			 value = SensorHistory.getElevationHistory({ :period => 1, :order => SensorHistory.ORDER_NEWEST_FIRST }).next();
			if ((value != null) && (value.data != null)) {
					value = value.data;
			}
		}
		
		if (value != null) {
			// Metres (no conversion necessary).
			if (settings.elevationUnits == System.UNIT_METRIC) {
			} else { 
				value *=  3.28084; // every meter is 3.28 feet		
			}
			
		} else {
			value = "-.-";
		}
		
		return [value.toNumber(), "d", ""];
	}
	
	
	function Messages(){		
		return [ settings.notificationCount, "e", ""];
	}
	
	
	function Stairs(){
		return [(info.floorsClimbed == null ?  "-.-" :  info.floorsClimbed), "f", ""];
	}
	
	
	function Alarmcount(){
		return [settings.alarmCount, "g", ""];
		
	}
	
	
	function PhoneConn(){
		
		if (settings.phoneConnected) {
			return ["conn", "h", "" ];
		} else {
			return ["dis", "h", ""];
		}
	}
	
	
	function ActiveMinutesDay(){
			return [info.activeMinutesDay.total.toNumber(), "i", ""];
	}
	
	
	function ActiveMinutesWeek(){
			return [info.activeMinutesWeek.total.toNumber(), "i", ""];
	}
	
	
	function Battery(){
		return [((Sys.getSystemStats().battery + 0.5).toNumber().toString() + "%"), "j", ""];
	}
	
	function DistanceWeek(){
		
	}
	
	function DistanceDay(){
			var unit;
			value = info.distance.toFloat();
			if(value == null){
				value = 0;
			} else {
				value *= 0.001;
			}
			
			if (settings.distanceUnits == System.UNIT_METRIC) {
				unit = "k";					
			} else {
				value *=  0.621371;  //mile per K;
				unit = "Mi";
			}
			
			return [value.format("%.1f").toString() + unit, "k", ""];
	}
	
	function DeviceTemp() {
		value = SensorHistory.getTemperatureHistory(null).next();
		if ((value != null) && (value.data != null)) {
			if (settings.temperatureUnits == System.UNIT_STATUTE) {
					value = (value.data * (1.8)) + 32; // Convert to Farenheit: ensure floating point division.
			} else {
					value = value.data;
			}
		
			return [value.toNumber().toString() + "°", "m", ""];
		}
		return ["-.-", ""];
	}
	
	function Weather(){
		var location = Activity.getActivityInfo().currentLocation; 
		var app = Application.getApp();
		
		if (location != null) {
				location = location.toDegrees(); // Array of Doubles.
				app.setProperty("lat", (location[0].toFloat()) );
				app.setProperty("lon", (location[1].toFloat()) );
		} else {
				location = Position.getInfo().position;
				if (location != null) {
						location = location.toDegrees();
						app.setProperty("lat", (location[0].toFloat()) );
						app.setProperty("lon", (location[1].toFloat()) );
				}
		}
		
		
	
		var weatherdata = app.getProperty("weatherdata");
		if (weatherdata == null) {
			return ["noData", "", "i"];
		} 
	
		return [weatherdata["temp"].toNumber() + "°", "", weatherdata["icon"] ];
	
	
	}

	function EmptyF(){
		return ["", "", ""];
	}
	

	function Invalid (){
		return ["-.-", "", ""];
	}
	
	function Premium (){
		return ["activate", "", ""];
	}
	

	
	

	
	
}
