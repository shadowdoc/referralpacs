// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

// Code for Ajax timeouts
// Stolen from http://codejanitor.com/wp/2006/03/23/ajax-timeouts-with-prototype/
// Thanks!  Also, added code to show and hide "ajax-indcator" during ajax request.

function callInProgress (xmlhttp) {
    switch (xmlhttp.readyState) {
        case 1: case 2: case 3:
            return true;
            break;
        // Case 4 and 0
        default:
            return false;
            break;
    }
}

function showFailureMessage() {
  alert('It looks like the network is down. Try again shortly');
}

// Register global responders that will occur on all AJAX requests
Ajax.Responders.register({
    onCreate: function(request) {
        if (Ajax.activeRequestCount > 0)
            Element.show('ajax-indicator');
        request['timeoutId'] = window.setTimeout(
            function() {
                // If we have hit the timeout and the AJAX request is active, abort it and let the user know
                if (callInProgress(request.transport)) {
                   request.transport.abort();
                   showFailureMessage();
                    // Run the onFailure method if we set one up when creating the AJAX object
                    if (request.options['onFailure']) {
                        request.options['onFailure'](request.transport, request.json);
                    }
                }
            },
        5000 // Five seconds
        );
    },

    onComplete: function(request) {
        // Clear the timeout, the request completed ok
        window.clearTimeout(request['timeoutId']);
        
        // Hide the ajax request indiator
        if (Ajax.activeRequestCount == 0)
            Element.hide('ajax-indicator');
    
    }
});

// Code for photo resize sliders

var scalePhotos, demoSlider, maxHeight;

function scaleIt(v) {
    if(scalePhotos == null){scalePhotos = document.getElementsByClassName('scale-image');}
    
      floorSize = .226;
      ceilingSize = 1.0;
      v = floorSize + (v * (ceilingSize - floorSize));
    
      for (i=0; i < scalePhotos.length; i++) {
    	scalePhotos[i].style.width = (v*1200)+'px';
      }
}


function init() {

    demoSlider = new Control.Slider('slider-handle', 'slider-bar', {
        axis:'horizontal', minimum: 0, maximum: 200, alignX: -5, increment: 2, sliderValue: 1
    });

	demoSlider.options.onSlide = function(value) {
		scaleIt(value);
	}

	demoSlider.options.onChange = function(value) {
		scaleIt(value);
	}

	scalePhotos = document.getElementsByClassName('scale-image');
	scaleContainer = document.getElementsByClassName('img-container');

	scaleIt(demoSlider.options.sliderValue);

};

// Code for image popout for radiologist workflow

function imagepopup(encounter_id) {
  window.newwindow = window.open('/encounter/openimages/' + encounter_id,'images',
                                 'height=800,width=800,scrollbars=1,status=no');
  return false;
}




