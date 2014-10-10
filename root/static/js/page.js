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


    if ($('edit-account-mail-settings')) {
	mail_archives();
    }

    if ($('edit-account-mail-limits')) {
	mail_limits();
    }

    if ($('edit-account-services') ){
	enabled_services_checkboxes({ services_id: 'edit-account-services',
				      default_id: 'account_services_default',
				      all_id:  'account_services_all',
				      none_id:  'account_services_none',
				      checkboxes_class: '.enabled_services_checkboxes'
				    });
    }

    if ($('edit-domain-services')) {
	enabled_services_checkboxes({ services_id: 'edit-domain-services',
				      default_id: 'domain_services_default',
				      all_id:  'domain_services_all',
				      none_id:  'domain_services_none',
				      checkboxes_class: '.enabled_services_checkboxes'
				    });

    }

    if ($('edit-account-defaults-services')) {
	enabled_services_checkboxes({ services_id: 'edit-account-defaults-services',
				      default_id: 'account_defaults_services_default',
				      all_id:  'account_defaults_services_all',
				      none_id:  'account_defaults_services_none',
				      checkboxes_class: '.accd_enabled_services_checkboxes'
				    });

    }

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
	var filter_el = $('realtime-filter');
	var filter = $(filter_el).get('value') || null;
	var data = ( filter ? "filter="+filter : '');
	var url = window.location.href + ( seek ? '/seek/'+seek : '');

	var xhr = new Request.JSON({
	    url: url,
	    method: 'post',
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

	xhr.send(data);
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

function enabled_services_checkboxes(args) {
    if (!args) {
	return null;
    }

    var services = args.services_id;
    var dflt = args.default_id;
    var all = args.all_id;
    var none = args.none_id;
    var checkboxes = args.checkboxes_class;

    if (!dflt || !all || !none || !checkboxes ) {
	return null;
    }

    if ($(services)) {
	var default_services = $(dflt);
	var all_services = $(all);
	var none_services = $(none);

	$(none_services).addEvent('click', function(e) {
	    $$(checkboxes).each(function(item) {
		var id = $(item).get('id');
		if (/_services_none/i.test(id)) {
		    return;
		}

		$(item).set('checked', null);
		$(item).set('disabled', null);
	    });
	});

	$(all_services).addEvent('click', function(e) {
	    $$(checkboxes).each(function(item) {
		var id = $(item).get('id');
		if (/_services_none/i.test(id) ||
		    /_services_all/i.test(id) ||
		    /_services_default/i.test(id)) {

		    if(!/_services_all/i.test(id)) {
			$(item).set('checked', null);
		    }
		    return;
		}

		$(item).set('checked', 'checked');
		$(item).set('disabled', null);
	    });
	});

	$(default_services).addEvent('click', function(e) {
	    $$(checkboxes).each(function(item) {
		var id = $(item).get('id');
		if (/_services_default/i.test(id) ||
		    /_services_none/i.test(id) ||
		    /_services_all/i.test(id)) {

		    if(!/_services_default/i.test(id)) {
			$(item).set('checked', null);
		    }

		    return;
		}

		$(item).set('disabled', !$(item).get('disabled'));
	    });
	});

    }
}

function mail_archives() {
    if ($('edit-account-mail-settings')) {
	$('account-mail-archives').addEvent('keydown', function(e) {
	    var val = $(this).get('value');
	    if (!/[0-9dwsh]/i.test(e.key)) {
		if (e.code != 13) {
		    e.stop();
		}
	    }
	});

	$('account-mail-archives-set').addEvent('change', function(e) {
	    var val = $('account-mail-archives-set').get('value');
	    if (val == 'other') {
		$('account-mail-archives').set('disabled', null);
		$('account-mail-archives').set('value', '');
	    } else {
		$('account-mail-archives').set('disabled', 'disabled');
		$('account-mail-archives').set('value', val);
	    }
	});
    }
}

function mail_limits() {
    if ($('edit-account-mail-limits')) {
	$('account-mail-limits-in-flow-messages').addEvent('keydown', function(e) {
	    var val = $(this).get('value');
	    if (!/[0-9dwsh]/i.test(e.key)) {
		if (e.code != 13) {
		    e.stop();
		}
	    }
	});

	$('account-mail-limits-in-flow-period').addEvent('keydown', function(e) {
	    var val = $(this).get('value');
	    if (!/[0-9dwsh]/i.test(e.key)) {
		if (e.code != 13) {
		    e.stop();
		}
	    }
	});

	$('account-mail-limits-in-flow-messages-set').addEvent('change', function(e) {
	    var val = $(this).get('value');
	    var input = 'account-mail-limits-in-flow-messages';
	    if (val == 'other') {
		$(input).set('disabled', null);
		$(input).set('value', '');
	    } else {
		$(input).set('disabled', 'disabled');
		$(input).set('value', val);
	    }
	});

	$('account-mail-limits-in-flow-period-set').addEvent('change', function(e) {
	    var val = $(this).get('value');
	    var input = 'account-mail-limits-in-flow-period';
	    if (val == 'other') {
		$(input).set('disabled', null);
		$(input).set('value', '');
	    } else {
		$(input).set('disabled', 'disabled');
		$(input).set('value', val);
	    }
	});


	$('account-mail-limits-out-flow-messages').addEvent('keydown', function(e) {
	    var val = $(this).get('value');
	    if (!/[0-9dwsh]/i.test(e.key)) {
		if (e.code != 13) {
		    e.stop();
		}
	    }
	});

	$('account-mail-limits-out-flow-period').addEvent('keydown', function(e) {
	    var val = $(this).get('value');
	    if (!/[0-9dwsh]/i.test(e.key)) {
		if (e.code != 13) {
		    e.stop();
		}
	    }
	});

	$('account-mail-limits-out-flow-messages-set').addEvent('change', function(e) {
	    var val = $(this).get('value');
	    var input = 'account-mail-limits-out-flow-messages';
	    if (val == 'other') {
		$(input).set('disabled', null);
		$(input).set('value', '');
	    } else {
		$(input).set('disabled', 'disabled');
		$(input).set('value', val);
	    }
	});

	$('account-mail-limits-out-flow-period-set').addEvent('change', function(e) {
	    var val = $(this).get('value');
	    var input = 'account-mail-limits-out-flow-period';
	    if (val == 'other') {
		$(input).set('disabled', null);
		$(input).set('value', '');
	    } else {
		$(input).set('disabled', 'disabled');
		$(input).set('value', val);
	    }
	});



	$('account-mail-limits-size-in').addEvent('keydown', function(e) {
	    var val = $(this).get('value');
	    if (!/[0-9KMGT]/i.test(e.key)) {
		if (e.code != 13) {
		    e.stop();
		}
	    }
	});

	$('account-mail-limits-size-in-set').addEvent('change', function(e) {
	    var val = $(this).get('value');
	    var input = 'account-mail-limits-size-in';
	    if (val == 'other') {
		$(input).set('disabled', null);
		$(input).set('value', '');
	    } else {
		$(input).set('disabled', 'disabled');
		$(input).set('value', val);
	    }
	});


	$('account-mail-limits-size-out').addEvent('keydown', function(e) {
	    var val = $(this).get('value');
	    if (!/[0-9KMGT]/i.test(e.key)) {
		if (e.code != 13) {
		    e.stop();
		}
	    }
	});

	$('account-mail-limits-size-out-set').addEvent('change', function(e) {
	    var val = $(this).get('value');
	    var input = 'account-mail-limits-size-out';
	    if (val == 'other') {
		$(input).set('disabled', null);
		$(input).set('value', '');
	    } else {
		$(input).set('disabled', 'disabled');
		$(input).set('value', val);
	    }
	});

    }
}
