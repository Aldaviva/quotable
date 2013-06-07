(function(){

	var MONTHS = "Jan. Feb. Mar. Apr. May Jun. Jul. Aug. Sep. Oct. Nov. Dec".split(" ");

	var formatDate = window.formatDate = function(date){
		var month = MONTHS[date.getMonth()];
		var day = date.getDate();

		return month + " " + day;
	};

	var QuotationModel = window.QuotationModel = Backbone.Model.extend({
		idAttribute: '_id',
		parse: function(data){
			if(!(data.date instanceof Date)){
				data.date = new Date(data.date * 1000);
			}

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

	function queue(worker){
		var list = [];
		function run(){
			var args = list[0];
			args.unshift(done);
			worker.apply(null, args);
		}
		function done(){
			list.shift();
			if(list.length){
				run();
			}
		}
		return function(){
			list.push(Array.prototype.slice.apply(arguments));
			if(list.length === 1){
				run();
			}
		}
	}

	window.addQuotation = queue(function(done, model, doSave){
		if(!quotationsCollection.get(model.id)){
			quotationsCollection.add(model);
			doSave && model.save({}, {
				success: function(saved_model){
					model.set(saved_model);
					done();
				}
			});
		}
	});

	var quotationsView = new QuotationsView({ collection: quotationsCollection });
	$$('.quotations').grab(quotationsView.render());

	quotationsCollection.fetch({ reset: true });

})();