window.addEvent('domready', function() {
    var url = $('validate-markup').get("href");
    var xhr = new Request({
	url: url,
	method: 'get',
	onSuccess: function(responseText, responseXML) {

	    if (!responseXML) {
		var parser = new DOMParser();
		responseXML = parser.parseFromString("<?xml version='1.0' encoding='UTF-8' ?>"+responseText, "application/xml");
	    }

	    var validation_result = responseXML.getElementById('results_container');
	    var result_el = $('validation-result');

	    validation_result = $(validation_result).getElementsByTagName('h2');
	    validation_result = validation_result[0];

	    if (!validation_result || !$(validation_result).get('class')) {
		$('validation-result').set('text', ': Unknown.');
		return;
	    }

	    validation_result = $(validation_result).get('class');

	    if (validation_result == "invalid") {
		result_el.set('class', "markup-validation-invalid");
	    } else {
		result_el.set('class', "markup-validation-valid");
	    }

	    $(result_el).set("text", ": "+validation_result);
	},

	onError: function() {
	    $('validation-result').set('text', ': Unknown.');
	},

	onFailure: function() {
	    $('validation-result').set('text', ': Unknown.');
	},
    });

    xhr.send();
    $('validation-result').set("text", ": checking…");

});