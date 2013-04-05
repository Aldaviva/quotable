(function(){

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

	function toggleForm(shouldHideForm){
		if(!shouldHideForm){
			form.removeClass('hidden');
			form.addClass('invalid');
		} else {
			form.addClass('hidden');
			$$('.revealerBar').removeClass('hidden');
		}
	}

	var revealerLink = $$('.revealer')[0];

	revealerLink.addEvent('click', function(e){
		toggleForm();
		$$('.revealerBar').addClass('hidden');
		form.getElement('.date').set('text', window.formatDate(new Date()));
		return false;
	});

	var submitLink = $$('.submitLink');

	submitLink.addEvent('click', function(e){
		form.submitButton.click();
		return false;
	});

	form.addEvent('submit', function(e){
		e.preventDefault();
		toggleForm(true);

		var data = {
			body   : form.body.get('value'),
			author : form.author.get('value'),
			date   : new Date()
		};

		_.each([form.body, form.author], function(el){
			el.set('value', '');
		});


		window.addQuotation(data);
	});

})();