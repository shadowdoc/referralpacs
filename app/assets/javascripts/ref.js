// Ref.js
// All of the custom javascript for ReferralPACS

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

function imagepopup(encounter_id, window_name) {
  window.window_name = window.open('/encounter/openimages/' + encounter_id, window_name,
                                 'height=800,width=800,scrollbars=1,resizeable=1,status=no');
  return false;
}

