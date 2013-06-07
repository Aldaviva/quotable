(function(){
	$$('h1').addEvent('click', function(){
		window.location.reload(); //TODO does this needlessly invalidate caches?
	});

	function getRandomPaperName(){
		var suffixes = "Post Star Gossip News Times Herald Record Advertiser Dispatch Gazette Journal Bugle Review Pioneer Citizen Standard Bulletin Clipper Press Sentinel Extra Voice Tribune Reporter Report Independent Express Beacon Echo Advocate Statesman Observer Ledger Clarion Chronicle Globe Telegraph Messenger Sun Examiner Mail Register Enterprise".split(' ');
		var prefixes = "New Old Daily Weekly Hometown Local County National State Tri-County Valley District Northern Southern Eastern Western".split(' ').concat(suffixes);

		return "The " + sample(prefixes) + " " + sample(suffixes) + (Math.random() >= 0.5 ? '–'+sample(suffixes) : '');
	}

	function sample(arr){
		return arr[Math.floor(Math.random() * arr.length)];
	}

	// var randomPaperName = getRandomPaperName();
	var h1 = $$('h1')[0];
	h1.setStyle('visibility', 'hidden');

	$$('h1, head title').set('text', getRandomPaperName());

	while(h1.clientHeight > 217){ //TODO solve for fontSize if possible
		h1.setStyle('fontSize', parseInt(h1.getStyle('fontSize'), 10) - 3);
	}
	h1.setStyle('visibility', 'visible');

})();