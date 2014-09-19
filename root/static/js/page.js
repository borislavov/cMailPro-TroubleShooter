window.addEvent('domready', function() {
    var mootree = new mooTree($('navigation-menu'), {expand_level: 1});

    $('navigation-search').addEvent('focus', function(e) {
	this.set('value', '');
	this.fireEvent('keyup');
    });

    $('navigation-search').addEvent('keyup', function(e) {
	var search_text = new RegExp (this.get('value'),"i");

	$$('.navigation-topic-items > li').each(function(item,index) {
	    if (item.get('text').match(search_text)) {
		item.removeClass("navigation-menu-hide-item");
	    } else {
		item.addClass("navigation-menu-hide-item");
	    }
	});
    });

    if ($('account-verify-password-form')) {
	$('account-verify-password-form').addEvent('submit', function(e) {
	    e.stop();
	    var data  = $('account-verify-password-form');
	    data = $(data).toQueryString(); //.parseQueryString();

	    var xhr = new Request.JSON({
		url: $('account-verify-password-form').get('action'),
		method: 'post',
		data: data,
		onSuccess: function(responseJSON, responseText) {

		    if (!responseJSON) {

			reponseJSON = JSON.decode(responseText);

			if (!responseJSON) {
			    $('account-verify-password-result').set('text', 'Unable to verify password.');
			    return;
			}
		    }

		    if (!responseJSON.verify_account_password) {
			$('account-verify-password-result').set('text', 'Unable to verify password.');
			return;
		    }
		    var result = responseJSON.verify_account_password;

		    $('account-verify-password-result').set('text', result);

		    if (/^valid$/i.test(result)) {
			$('account-verify-password-result').addClass('account-verify-password-result-valid')
			$('account-verify-password-result').removeClass('account-verify-password-result-invalid')
		    } else {
			$('account-verify-password-result').addClass('account-verify-password-result-invalid')
			$('account-verify-password-result').removeClass('account-verify-password-result-valid')
		    }
		},

		onError: function() {
		    $('account-verify-password-result').set('text', 'Unable to verify password.');
		},

		onFailure: function() {
		    $('account-verify-password-result').set('text', 'Unable to verify password');
		},
	    });

	    $('account-verify-password-result').removeClass('account-verify-password-result-invalid')
	    $('account-verify-password-result').removeClass('account-verify-password-result-valid')
	    $('account-verify-password-result').set('text', 'Verifying…');
	    xhr.send(data);
	});
    }
});
