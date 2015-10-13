controller = require "../controller/calendar.coffee"
passport = require 'passport'
bearer = passport.authenticate('bearer', { session: false })

ensureLoggedIn = require('connect-ensure-login').ensureLoggedIn
middleware = require '../../../middleware.coffee'
ensurePermission = middleware.ensurePermission
 

bearer = middleware.rest.user
 
@include = ->

	@get '/api/mycalendarpage', bearer, ->
		controller.Calendar.mylistpage(@request, @response)
	
	@get '/api/myupcomingcalendar', bearer, ->
		controller.Calendar.upcominglist(@request, @response)
		
	@post '/api/calendar', bearer,  ->
		controller.Calendar.create(@request, @response)
		 
	@put '/api/calendar/:id', bearer,  ->
		controller.Calendar.update(@request, @response)	

	@get '/api/calendar', bearer, ->
		controller.Calendar.list(@request, @response)
				
	@get '/api/calendar/:id', bearer,   ->
		controller.Calendar.read(@request, @response)
		
	@del '/api/calendar/:id', bearer,  ->
		controller.Calendar.delete(@request, @response)		