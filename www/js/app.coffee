module = angular.module('starter', ['ionic', 'starter.controller', 'http-auth-interceptor', 'ngTagEditor', 'ActiveRecord', 'angularFileUpload', 'ngTouch', 'ngAnimate', 'ionic-datepicker', 'ionic-timepicker', 'mwl.calendar'])

module.run ($ionicPlatform, $location, $http, authService) ->
	$ionicPlatform.ready ->
		if (window.cordova && window.cordova.plugins.Keyboard)
			cordova.plugins.Keyboard.hideKeyboardAccessoryBar(true)
		if (window.StatusBar)
			StatusBar.styleDefault()
		
	# set authorization header once browser authentication completed
	if $location.url().match /access_token/
			data = $.deparam $location.url().split("/")[1]
			$http.defaults.headers.common.Authorization = "Bearer #{data.access_token}"
			authService.loginConfirmed()
		
module.config ($stateProvider, $urlRouterProvider) ->
	    
	$stateProvider.state 'app',
		url: ""
		abstract: true
		controller: 'AppCtrl'
		templateUrl: "templates/menu.html"
		
	$stateProvider.state 'app.search',
		url: "/search"
		views:
			'menuContent':
				templateUrl: "templates/search.html"
	
    
    # My calendar list page
	$stateProvider.state 'app.mycalendarpage',
		url: "/calendar/mycalendarpage"
		cache: false
		views:
			'menuContent':
				templateUrl: "templates/calendar/mylistpage.html"
				controller: 'MyCalendarListPageCtrl'
    		
	# My upcoming calendar list
	$stateProvider.state 'app.upcomingList',
		url: "/calendar/upcomingList"
		cache: false
		views:
			'menuContent':
				templateUrl: "templates/calendar/upcominglist.html"
				controller: 'UpcomingListCtrl'

	$stateProvider.state 'app.createCalendar',
		url: "/calendar/create"
		cache: false
		views:
			'menuContent':
				templateUrl: "templates/calendar/create.html"
				controller: 'CalendarCtrl'
	
	$stateProvider.state 'app.readCalendar',
		url: "/calendar/read"
		params: SelectedCalendar: null, myCalendarCol: null, backpage: null
		cache: false
		views:
			'menuContent':
				templateUrl: "templates/calendar/read.html"
				controller: 'CalendarReadCtrl'
				
	$stateProvider.state 'app.editCalendar',
		url: "/calendar/edit"
		params: SelectedCalendar: null, myCalendarCol: null, backpage: null
		cache: false
		views:
			'menuContent':
				templateUrl: "templates/calendar/edit.html"
				controller: 'CalendarEditCtrl'				

	# My calendar day
	$stateProvider.state 'app.today',
		url: "/calendar/today"
		cache: false
		views:
			'menuContent':
				templateUrl: "templates/calendar/today.html"
				controller: 'TodayCtrl'
					
	# My calendar week
	$stateProvider.state 'app.week',
		url: "/calendar/week"
		cache: false
		views:
			'menuContent':
				templateUrl: "templates/calendar/week.html"
				controller: 'WeekCtrl'											
	
	# My calendar group by project
	$stateProvider.state 'app.projectCalendar',
		url: "/calendar/project"
		cache: false
		views:
			'menuContent':
				templateUrl: "templates/calendar/project.html"
				controller: 'ProjectCalendarCtrl'
				
	$urlRouterProvider.otherwise('/calendar/project')
	#$urlRouterProvider.otherwise('/calendar/week')	
	#$urlRouterProvider.otherwise('/calendar/today')						
	#$urlRouterProvider.otherwise('/calendar/cal')														
	#$urlRouterProvider.otherwise('/calendar/upcomingList')
	#$urlRouterProvider.otherwise('/calendar/mycalendarpage')
	
	