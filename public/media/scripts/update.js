(function(){

	function handleEvent(event){
		try {
			var data = JSON.parse(event.data);
			var model = new QuotationModel(data, { parse: true });
			window.addQuotation(model, false);
		} catch (e) {
			console.error('Failed to parse '+event.data+': '+e);
		}
	}

	var socketUrl = 'ws://' + window.location.host + window.location.pathname + 'api/quotes/websocket';
	var socket = new WebSocket(socketUrl);

	socket.onmessage = handleEvent;

	socket.onerror = function(err){
		console.error(err);
	};

	socket.onopen = function(){
		console.info("Listening for new quotations.");
	};

})();
