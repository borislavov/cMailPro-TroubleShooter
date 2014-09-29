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

    if ($('account-change-password-form')) {
	xhr_on_change_password();
    }

    if ($('realtime-log-wrapper')) {
	var period_el = $('realtime-refresh');
	var period=(parseInt($(period_el).get('value'))*1000) || 30000;
	xhr_realtime_logs.periodical(period);
    }

    if ($('account-verify-password-form')) {
	xhr_on_verify_password();
    }

});

function xhr_on_change_password() {
    if ($('account-change-password-form')) {
	$('account-change-password-form').addEvent('submit', function(e) {
	    e.stop();
	    var data  = $('account-change-password-form');
	    data = $(data).toQueryString(); //.parseQueryString();

	    var xhr = new Request.JSON({
		url: $('account-change-password-form').get('action'),
		method: 'post',
		data: data,
		onSuccess: function(responseJSON, responseText) {

		    if (!responseJSON) {

			reponseJSON = JSON.decode(responseText);

			if (!responseJSON) {
			    $('account-change-password-result').set('text', 'Unable to change password.');
			    return;
			}
		    }

		    if (!responseJSON.change_account_password) {
			$('account-change-password-result').set('text', 'Unable to change password.');
			return;
		    }
		    var result = responseJSON.change_account_password;

		    $('account-change-password-result').set('text', result);

		    if (/^valid$/i.test(result)) {
			$('account-change-password-result').addClass('account-change-password-result-valid')
			$('account-change-password-result').removeClass('account-change-password-result-invalid')
		    } else {
			$('account-change-password-result').addClass('account-change-password-result-invalid')
			$('account-change-password-result').removeClass('account-change-password-result-valid')
		    }
		},

		onError: function() {
		    $('account-change-password-result').set('text', 'Unable to change password.');
		},

		onFailure: function() {
		    $('account-change-password-result').set('text', 'Unable to change password');
		},
	    });

	    $('account-change-password-result').removeClass('account-change-password-result-invalid')
	    $('account-change-password-result').removeClass('account-change-password-result-valid')
	    $('account-change-password-result').set('text', 'Changing…');
	    xhr.send(data);
	});
    }
}


function xhr_realtime_logs() {
    if ($('realtime-log-wrapper')) {
	var seek_el = $('realtime-seek');
	var seek = (parseInt(seek_el.get('value'))) || 0;
	var xhr = new Request.JSON({
	    url: window.location.href + ( seek ? '/seek/'+seek : ''),
	    method: 'get',
	    onSuccess: function(responseJSON, responseText) {
		if (!responseJSON) {

		    reponseJSON = JSON.decode(responseText);

		    if (!responseJSON) {
			return;
		    }
		}

		var seek_el = $('realtime-seek');
		if (seek_el) {
		    seek_el.set('value', responseJSON.realtime.size);
		}

		var size_el = $('realtime-size');
		if (size_el) {
		    size_el.set('text', responseJSON.realtime.size);
		}

		var p = new Element('p', {
		    'class': 'realtime-log-new-data',
		    text: 'New data at '+new Date(),
		});

		p.inject($('realtime-log-wrapper'), 'bottom');

		responseJSON.realtime.data.each(function(item) {
		    var p = new Element('p', {
			'class': 'realtime-log',
			text: item,
		    });

		    p.inject($('realtime-log-wrapper'), 'bottom');
		});

		var scroll = new Fx.Scroll('realtime-log-wrapper').toBottom();
	    }
	});

	xhr.send();
    }
}

function xhr_on_verify_password () {
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
}
