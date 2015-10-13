env = require '../../../env.coffee'
lib = require '../lib.coffee'
mongoose = require 'mongoose'
model = require '../../../model.coffee'
_ = require 'underscore'

error = (res, msg) ->
	res.json 500, error: msg

class Calendar

	@upcominglist: (req, res) ->
		page = if req.query.page then req.query.page else 1
		limit = if req.query.per_page then req.query.per_page else env.pageSize
		opts = 
			skip:	(page - 1) * limit
			limit:	limit
			
		order_by = lib.order_by model.Calendar.ordering()
		if req.query.order_by and lib.field(req.query.order_by) in model.Calendar.ordering_fields() 
			order_by = lib.order_by req.query.order_by

		today = new Date()
		today = today.setHours(0,0,0,0)
		cond = { $and: [ { dateStart: { $gte: today } }, { createdBy: req.user } ] }
		
		model.Calendar.find(cond, null, opts).populate('resource createdBy').sort(order_by).exec (err, calendars) ->				
			if err
				return error res, err
			model.Calendar.count {}, (err, count) ->
				if err
					return error res, err
				res.json {count: count, results: calendars}

	@mylistpage: (req, res) ->
		page = if req.query.page then req.query.page else 1
		limit = if req.query.per_page then req.query.per_page else env.pageSize
		opts = 
			skip:	(page - 1) * limit
			limit:	limit
			
		order_by = lib.order_by model.Calendar.ordering()
		if req.query.order_by and lib.field(req.query.order_by) in model.Calendar.ordering_fields() 
			order_by = lib.order_by req.query.order_by
		
		cond = { createdBy: req.user } 				
		model.Calendar.find(cond, null, opts).populate('resource createdBy').sort(order_by).exec (err, calendars) ->
			if err
				return error res, err
			model.Calendar.count {}, (err, count) ->
				if err
					return error res, err
				res.json {count: count, results: calendars}


	@list: (req, res) ->
		page = if req.query.page then req.query.page else 1
		limit = if req.query.per_page then req.query.per_page else env.pageSize
		opts = 
			skip:	(page - 1) * limit
			limit:	limit

		order_by = lib.order_by model.Calendar.ordering()
		if req.query.order_by and lib.field(req.query.order_by) in model.Calendar.ordering_fields() 
			order_by = lib.order_by req.query.order_by

		cond = { createdBy: req.user } 
		
		if req.query.fmDate and req.query.toDate
			date1 = new Date(req.query.fmDate)
			date2 = new Date(req.query.toDate)
			p1 = new lib.Period(date1, date2)
			cond = _.extend cond, p1.intersect("dateStart", "dateEnd")
			
		model.Calendar.find(cond).populate('resource createdBy').sort(order_by).exec (err, calendars) ->				
			if err
				return error res, err
			model.Calendar.count {}, (err, count) ->
				if err
					return error res, err
				res.json {count: count, results: calendars}
							
	@listold: (req, res) ->
		page = if req.query.page then req.query.page else 1
		limit = if req.query.per_page then req.query.per_page else env.pageSize
		opts = 
			skip:	(page - 1) * limit
			limit:	limit
			
		cond = {}
		if req.query.search 
			pattern = new RegExp(req.query.search, 'i')
			fields = _.map model.Calendar.search_fields(), (field) ->
				ret = {}
				ret[field] = pattern
				return ret
			cond = $or: fields
			 
		if req.query.dtStart 
			date1 = new Date(req.query.dtStart)
			#cond1 = $gte: date1
			cond1 = dateStart : {$gte: date1}
			#cond1 = dateStart : {$gte: new Date("2015-06-14T00:00:00.000Z")}
			cond = cond1
					
		order_by = lib.order_by model.Calendar.ordering()
		if req.query.order_by and lib.field(req.query.order_by) in model.Calendar.ordering_fields() 
			order_by = lib.order_by req.query.order_by
		
		model.Calendar.find(cond, null, opts).populate('createdBy updatedBy').sort(order_by).exec (err, calendars) ->
			if err
				return error res, err
			model.Calendar.count {}, (err, count) ->
				if err
					return error res, err
				if req.query.dtStart 	
					res.json {count: calendars.length, results: calendars}
				else	
					res.json {count: count, results: calendars}
							
	@create: (req, res) ->
		data = req.body
		data.createdBy = req.user 
		calendar = new model.Calendar data
		calendar.save (err) =>
			if err
				return error res, err
			res.json calendar			
				
	@read: (req, res) ->
		id = req.param('id')
		model.Calendar.findById(id).populate('createdBy updatedBy').exec (err, user) ->
			if err or calendar == null
				return error res, if err then err else "Calendar not found"
			res.json calendar			
			
		
	@update: (req, res) ->
		id = req.param('id')
		model.Calendar.findOne {_id: id, __v: req.body.__v}, (err, calendar) ->
			if err or calendar == null
				return error res, if err then err else "Calendar not found"
			
			attrs = _.omit req.body, '_id', '__v', 'dateCrated', 'createdBy', 'lastUpdated', 'updatedBy'
			_.map attrs, (value, key) ->
				calendar[key] = value
			calendar.updatedBy = req.user
			calendar.save (err) ->
				if err
					error res, err
				else res.json calendar						

	@delete: (req, res) ->
		id = req.param('id')
		model.Calendar.findOne {_id: id}, (err, calendar) ->		
			if err or calendar == null
				return error res, if err then err else "Calendar not found"
			
			calendar.remove (err, calendar) ->
				if err
					error res, err
				else
					res.json {deleted: true}
								
module.exports = 
	Calendar: 		Calendar