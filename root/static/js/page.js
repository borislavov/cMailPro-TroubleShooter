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
});