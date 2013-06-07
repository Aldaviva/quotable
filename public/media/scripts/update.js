(function(){

	var eventSource = new EventSource('api/quotes/eventstream');

	eventSource.addEventListener('message', function(event){
		try {
			var data = JSON.parse(event.data);
			var model = new QuotationModel(data, { parse: true });
			window.addQuotation(model, false);
		} catch (e) {
			console.error('Failed to parse '+event.data+': '+e);
		}
	}, false);

	eventSource.addEventListener('open', function(event) {
		// console.log("Event Stream connected.");
	}, false);

	eventSource.addEventListener('error', function(event) {
		if(event.eventPhase == EventSource.CLOSED){
			// console.error("Event Stream disconnected.");
		}
	}, false);

})();