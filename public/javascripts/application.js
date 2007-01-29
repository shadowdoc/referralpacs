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