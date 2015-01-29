$(document).ready(function(){

$( ".toggle-visibility" ).click(function() {
  // This is used to show and hide the detailed report forms.
  
  var target_selector = $(this).attr('data-target');
  var $target = $( target_selector );
  
  if ($target.is(':hidden'))
  {
    $target.show( "slow" );
  }
  else
  {
    $target.hide( "slow" );
  }
  
  console.log($target.is(':visible'));

  
});

$(".select-prior").click(function () {
  // This is used in the report form to hide other priors and only display the one clicked

  var target_selector = $(this).attr('data-target');
  var target = $ ( target_selector );

  // Hide all priors
  $("[id^=prior]").hide();

  // Show the right one
  $(target).show();

})

});