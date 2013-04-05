(function(){

	var MONTHS = "Jan. Feb. Mar. Apr. May Jun. Jul. Aug. Sep. Oct. Nov. Dec".split(" ");

	var formatDate = window.formatDate = function(date){
		var month = MONTHS[date.getMonth()];
		var day = date.getDate();

		return month + " " + day;
	};

	var QuotationModel = Backbone.Model.extend({
		parse: function(data){
			data.date = new Date(data.date * 1000);
			return data;
		}
	});

	var QuotationsCollection = Backbone.Collection.extend({
		model: QuotationModel,
		url: "api/quotes/"
	});

	var QuotationView = Backbone.View.extend({
		tagName: 'figure',
		className: 'quotation',

		initialize: function(){
			_.bindAll(this);
		},

		render: function(){
			DOMinate([this.el, ['div',
				['blockquote', this.model.get('body'), {class: 'body'}],
				['div',        this.renderDate(),      {class: 'date'}],
				['figcaption', this.model.get('author')               ]
			]]);
			return this.el;
		},

		renderDate: function(){
			var date = this.model.get('date');
			return formatDate(date);
		}
	});

	var QuotationsView = Backbone.View.extend({
		initialize: function(){
			_.bindAll(this);

			this.collection.on({
				'reset' : this.addAll,
				'add'   : this.addOne
			});
		},

		addAll: function(){
			var els = this.collection.map(this.renderChild);
			this.el.empty().adopt(els);
		},

		addOne: function(model){
			var el = this.renderChild(model);
			this.el.grab(el, 'top');
		},

		renderChild: function(model){
			return new QuotationView({ model: model }).render();
		},

		render: function(){
			return this.el;
		}
	});


	var quotationsCollection = new QuotationsCollection();

	window.addQuotation = function(data){
		var model = new QuotationModel(data);
		quotationsCollection.add(model);
		model.save();
	};

	var quotationsView = new QuotationsView({ collection: quotationsCollection });
	$$('.quotations').grab(quotationsView.render());

	quotationsCollection.fetch({ reset: true });

})();