(function(){

	var subscriptionConnection;

	function subscribe(){
		subscriptionConnection = new Request({
			url: 'subscribe',
			noCache: true
		}).addEvents({
			success: onPost,
			timeout: function(){
				// console.log("subscription timeout");
			},
			failure: function(){
				// console.log("subscription failure");
				setTimeout(subscribe, 2000);
			}
		});

		console.log("subscribe");

		subscriptionConnection.get();
	}

	function onPost(data){
		if(data == 'new post'){
			window.location.reload();
		} else {
			// console.log("ignored subscription");
			setTimeout(subscribe, 0);
		}
	}

	function unsubscribe(req){
		subscriptionConnection.cancel();
	}

	window.addEvent('load', subscribe);

	// var form = $$("form.addQuotation")[0];
	// form.addEvent('submit', unsubscribe);

	var revealer = $$('.revealer')[0];
	revealer.addEvent('click', 'unsubscribe');

})();