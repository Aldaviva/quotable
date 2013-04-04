(function(){

	$$('h1').addEvent('click', function(){
		window.location.reload();
	});

	window.addEvent('load', function(){
		var h1 = $$('h1')[0];
		while(h1.clientHeight > 217){
			h1.setStyle('fontSize', parseInt(h1.getStyle('fontSize'), 10) - 3);
		}
		h1.setStyle('visibility', 'visible');
	});

	var form = $$("form.addQuotation")[0];
	var validator = new Form.Validator(form, {
		stopOnFailure: true,
		ignoreHidden: false,
		evaluateOnSubmit: true,
		evaluateFieldsOnChange: false,
		evaluateFieldsOnBlur: true,
		onElementFail: function(element, failedValidators){
			form.addClass('invalid');
		},
		onFormValidate: function(isValid, form){
			form.toggleClass('invalid', !isValid);
		}
	});

	form.addEvent('keyup', function(){
		form.validate();
	});

	function revealForm(){
		form.removeClass('hidden');
		form.addClass('invalid');
	}

	var revealerLink = $$('.revealer')[0];

	revealerLink.addEvent('click', function(e){
		revealForm();
		$$('.revealerBar').addClass('hidden');
		var now = new Date();
		form.getElement('.date').set('text', now.format("%b. %e, %l:%M ")+now.format("%p").toLowerCase());
		return false;
	});

	var submitLink = $$('.submitLink');

	submitLink.addEvent('click', function(e){
		form.submitButton.click();
		submitLink.removeEvents('click');
		return false;
	});

})();