(function(){

	var form = $$("form.addQuotation")[0];

	function revealForm(){
		form.removeClass('hidden');
	}

	function onSubmitForm(){
		var validationError = getValidationError();
		if(validationError != null){
			alert("Your quotation isn't ready to submit:\n"+validationError+'.');
			return false;
		}
		//if the user didn't even enter anything, just hide the form? and tell the user what happened?
		//maybe just let the form time out if it's open and not interacted with for a while?
	}

	function getValidationError(){
		var body = form.body.value;
		if(body.trim() == ''){
			return 'Body is empty';
		}

		var author = form.author.value;
		if(author.trim() == ''){
			return 'Author is empty';
		}

		return null;
	}

	form.addEvent('submit', onSubmitForm);

	var revealerLink = $(form).getElement('.revealer');

	revealerLink.addEvent('click', function(e){
		revealForm();
		return false;
	});

	var submitLink = form.getElement('.submitLink');

	submitLink.addEvent('click', function(e){
		form.fireEvent('submit');
		return false;
	})

})();