(function(){
	$$('h1').addEvent('click', function(){
		window.location.reload(); //TODO does this needlessly invalidate caches?
	});

	function getRandomPaperName(){
		var suffixes = [
			"Advertiser",
			"Advocate",
			"Asswipe",
			"Banner",
			"Beacon",
			"Bee",
			"Bollocks",
			"Bugle",
			"Bugler",
			"Bulletin",
			"Bystander",
			"Chronicle",
			"Citizen",
			"Clarion",
			"Clipper",
			"Comet",
			"Courier",
			"Dealer",
			"Dispatch",
			"Echo",
			"Enterprise",
			"Examiner",
			"Express",
			"Extra",
			"Frontiersman",
			"Gazette",
			"Glob",
			"Globe",
			"Gossip",
			"Guardian",
			"Herald",
			"Hour",
			"Independent",
			"Inquirer",
			"Inquisitor",
			"Journal",
			"Ledger",
			"Mail",
			"Mentioner",
			"Mercury",
			"Messenger",
			"Mirror",
			"News",
			"Newspapes",
			"Observer",
			"Picayune",
			"Pioneer",
			"Planet",
			"Post",
			"Press",
			"Preview",
			"Record",
			"Register",
			"Report",
			"Reporter",
			"Review",
			"Sentinel",
			"Shopper",
			"Standard",
			"Star",
			"Statesman",
			"Sub-par",
			"Sun",
			"Tally Ho",
			"Tattler",
			"Telegraph",
			"Times",
			"Today",
			"Tribune",
			"Villager",
			"Voice",
			"Word"
		];
		var prefixes = [
			"Action",
			"Bronze",
			"County",
			"Daily",
			"District",
			"Eastern",
			"Evening",
			"Financial",
			"Gotham",
			"Hometown",
			"Local",
			"Metropolis",
			"Modern",
			"Morning",
			"National",
			"New",
			"Northern",
			"Old",
			"Southern",
			"State",
			"Tanty",
			"Tri-County",
			"Tri-National",
			"Tri-State",
			"Valley",
			"Weekly",
			"Western",
			"What All This Then"
		].concat(suffixes);

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