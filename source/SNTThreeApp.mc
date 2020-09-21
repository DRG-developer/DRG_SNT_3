// Copyright by Dexter Braunius.

using Toybox.Application;
using Toybox.WatchUi as Ui;
using Toybox.System as Sys;

// This is the primary entry point of the application.
class SNTThreeWatch extends Application.AppBase
{
	var View;
	var counter;

	function initialize() {
		AppBase.initialize();
	}

	// This method runs each time the main application starts.
	function getInitialView() {
		View = new SNTThreeView();
		Ui.requestUpdate();
		return [View];
        
	}
    
	function onSettingsChanged(){	
			View.getSettings();
			Ui.requestUpdate();
			return;
	}
	
	function onBackgroundData(data){
		Sys.println(data);
		Sys.println(data[1]);
		if(data[0] == 200 ){
			Application.getApp().setProperty("weatherdata", data[1]);
			counter = 0;
		} else if ( counter < 3){
			counter ++;
		} else {
			Application.getApp().setProperty("weatherdata", null);
		}
	}
	
	function getServiceDelegate() {
		return [new SNTThreeServiceDelegate()];
	}
    
}
