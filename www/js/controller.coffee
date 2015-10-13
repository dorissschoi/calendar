env = require './env.coffee'

AppCtrl = ($rootScope, $scope, $http, platform, authService, model) ->	
	# set authorization header once mobile authentication completed
	fulfill = (data) ->
		if data?
			$http.defaults.headers.common.Authorization = "Bearer #{data.access_token}"
			authService.loginConfirmed()
	
	$scope.$on 'event:auth-forbidden', ->
		platform.auth().then fulfill, alert
	$scope.$on 'event:auth-loginRequired', ->
		platform.auth().then fulfill, alert
	
MenuCtrl = ($scope) ->
	$scope.env = env
	$scope.navigator = navigator
					
CalendarEditCtrl = ($rootScope, $scope, $state, $stateParams, $location, model, $filter) ->
	class CalendarEditView  			

		constructor: (opts = {}) ->
			_.each @events, (handler, event) =>
				$scope.$on event, @[handler]
			
		update: ->
			@model = $scope.model		
			@model.task = $scope.model.newtask
			@model.location = $scope.model.newlocation
			@model.project = $scope.model.newproject
			@model.notes = $scope.model.newnotes
			$scope.model.newdateStart = $scope.datepickerObjectStart.inputDate
			$scope.model.newdateEnd = $scope.datepickerObjectEnd.inputDate
			$scope.model.newtimeStart = $scope.timePickerStartObject.inputEpochTime
			$scope.model.newtimeEnd = $scope.timePickerEndObject.inputEpochTime
			output = new Date($scope.model.newdateStart.getFullYear(),$scope.model.newdateStart.getMonth(), $scope.model.newdateStart.getDate(), parseInt($scope.model.newtimeStart / 3600), $scope.model.newtimeStart / 60 % 60)
			@model.dateStart = output
			output = new Date($scope.model.newdateEnd.getFullYear(),$scope.model.newdateEnd.getMonth(), $scope.model.newdateEnd.getDate(), parseInt($scope.model.newtimeEnd / 3600), $scope.model.newtimeEnd / 60 % 60)
			@model.dateEnd = output 
			@model.$save().then =>
				$state.go 'app.upcomingList', {}, { reload: true }
				
		backpage: ->
			if _.isNull $stateParams.backpage
				$state.go $rootScope.URL, {}, { reload: true }
			else	
				$state.go $stateParams.backpage, {}, { reload: true }
			
	$scope.collection = $stateParams.myCalendarCol
	$scope.model = $stateParams.SelectedCalendar
	$scope.model.newtask = $scope.model.task
	$scope.model.newlocation = $scope.model.location
	$scope.model.newproject = $scope.model.project
	$scope.model.newnotes = $scope.model.notes
	newdate = new Date($filter('date')($scope.model.dateStart, 'MMM dd yyyy UTC'))
	
	# ionic-datepicker 0.9
	currDate = new Date
	$scope.datepickerObjectStart = {
		titleLabel: 'start date',
		inputDate: newdate,
		callback: (val) ->
			$scope.datePickerStartCallback(val)
	}
	$scope.datePickerStartCallback = (val) ->
		if typeof val == 'undefined'
			$scope.datepickerObjectStart.inputDate = new Date($filter('date')(currDate, 'MMM dd yyyy UTC'))
		else
			$scope.datepickerObjectStart.inputDate = val
			if $scope.datepickerObjectEnd.inputDate < val
				$scope.datepickerObjectEnd.inputDate = val
		return
		
	newdate = new Date($filter('date')($scope.model.dateEnd, 'MMM dd yyyy UTC'))
		
	$scope.datepickerObjectEnd = {
		titleLabel: 'end date',
		inputDate: newdate,
		callback: (val) ->
			$scope.datePickerEndCallback(val)
	}	
	$scope.datePickerEndCallback = (val) ->
		if typeof val == 'undefined'
			$scope.datepickerObjectEnd.inputDate = new Date($filter('date')(currDate, 'MMM dd yyyy UTC'))
		else
			$scope.datepickerObjectEnd.inputDate = val
			if $scope.datepickerObjectStart.inputDate > val
				$scope.datepickerObjectStart.inputDate = val
		return

	# ionic-timepicker 0.3
	$scope.timePickerStartObject = {
		inputEpochTime: $scope.model.dateStart.getHours()*60*60 + $scope.model.dateStart.getMinutes()*60,  
		step: 30,  
		format: 12,  
		titleLabel: 'start time',  
		callback: (val) ->   
			$scope.timePickernewStartCallback(val)
	}
	
	$scope.timePickernewStartCallback = (val) ->
		if typeof val != 'undefined'
			$scope.timePickerStartObject.inputEpochTime = val
			adate = $scope.datepickerObjectStart.inputDate
			adate.setHours(0,0,0,0)
			bdate = $scope.datepickerObjectEnd.inputDate
			bdate.setHours(0,0,0,0)
			if (adate - bdate) == 0
				if $scope.timePickerEndObject.inputEpochTime < val
					$scope.timePickerEndObject.inputEpochTime = val
		return
	
	$scope.timePickerEndObject = {
		inputEpochTime: $scope.model.dateEnd.getHours()*60*60 + $scope.model.dateEnd.getMinutes()*60,  
		step: 30,  
		format: 12,  
		titleLabel: 'end time',  
		callback: (val) ->   
			$scope.timePickernewEndCallback(val)
	}	
	
	$scope.timePickernewEndCallback = (val) ->
		if typeof val != 'undefined'
			$scope.timePickerEndObject.inputEpochTime = val
			adate = $scope.datepickerObjectStart.inputDate
			adate.setHours(0,0,0,0)
			bdate = $scope.datepickerObjectEnd.inputDate
			bdate.setHours(0,0,0,0)
			if (adate - bdate) == 0
				if $scope.timePickerStartObject.inputEpochTime > val
					$scope.timePickerStartObject.inputEpochTime = val
		return			
		
	$scope.controller = new CalendarEditView model: $scope.model
	
CalendarCtrl = ($rootScope, $scope, $state, $stateParams, $location, model, $filter) ->
	class CalendarView  			

		constructor: (opts = {}) ->
			_.each @events, (handler, event) =>
				$scope.$on event, @[handler]
			@model = opts.model
			$scope.calendar = {task: ''}
				
		add: ->
			@model = new model.Calendar
			@model.task = $scope.calendar.task
			@model.location = $scope.calendar.location
			@model.project = $scope.calendar.project
			@model.notes = $scope.calendar.notes
			$scope.endDate = $scope.datepickerObjectEnd.inputDate
			$scope.startDate = $scope.datepickerObjectStart.inputDate
			$scope.startTime = $scope.timePickerStartObject.inputEpochTime
			$scope.endTime = $scope.timePickerEndObject.inputEpochTime
			output = new Date($scope.startDate.getFullYear(),$scope.startDate.getMonth(), $scope.startDate.getDate(), parseInt($scope.startTime / 3600), $scope.startTime / 60 % 60)
			@model.dateStart = output
			output = new Date($scope.endDate.getFullYear(),  $scope.endDate.getMonth(),   $scope.endDate.getDate(), parseInt($scope.endTime / 3600), $scope.endTime / 60 % 60)
			@model.dateEnd = output
			@model.$save().catch alert
			$scope.calendar.task = ''
			$state.go 'app.upcomingList', {}, { reload: true, cache: false }
		
	$scope.controller = new CalendarView model: $scope.model
	
	# ionic-datepicker 0.9
	currDate = new Date
	$scope.datepickerObjectStart = {
		titleLabel: 'start date',
		inputDate: new Date,
		callback: (val) ->
			$scope.datePickerStartCallback(val)
	}
	
	$scope.datePickerStartCallback = (val) ->
		if typeof val == 'undefined'
			$scope.datepickerObjectStart.inputDate = new Date($filter('date')(currDate, 'MMM dd yyyy UTC'))
		else
			$scope.datepickerObjectStart.inputDate = val
			if $scope.datepickerObjectEnd.inputDate < val
				$scope.datepickerObjectEnd.inputDate = val
		return
		
	$scope.datepickerObjectEnd = {
		titleLabel: 'end date',
		inputDate: new Date,
		callback: (val) ->
			$scope.datePickerEndCallback(val)
	}	
	$scope.datePickerEndCallback = (val) ->
		if typeof val == 'undefined'
			$scope.datepickerObjectEnd.inputDate = new Date($filter('date')(currDate, 'MMM dd yyyy UTC'))
		else
			$scope.datepickerObjectEnd.inputDate = val
			if $scope.datepickerObjectStart.inputDate > val
				$scope.datepickerObjectStart.inputDate = val
		return
	
	# ionic-timepicker 0.3
	$scope.timePickerStartObject = {
		inputEpochTime: ((new Date()).getHours() * 60 * 60),  
		step: 30,  
		format: 12,  
		titleLabel: 'start time',  
		callback: (val) ->   
			$scope.timePickerStartCallback(val)
	}
	
	$scope.timePickerStartCallback = (val) ->
		if typeof val == 'undefined'
			$scope.timePickerStartObject.inputEpochTime = 0
		else 	
			$scope.timePickerStartObject.inputEpochTime = val
			adate = $scope.datepickerObjectStart.inputDate
			adate.setHours(0,0,0,0)
			bdate = $scope.datepickerObjectEnd.inputDate
			bdate.setHours(0,0,0,0)
			if (adate - bdate) == 0
				if $scope.timePickerEndObject.inputEpochTime < val
					$scope.timePickerEndObject.inputEpochTime = val
		return
	
	$scope.timePickerEndObject = {
		inputEpochTime: ((new Date()).getHours() * 60 * 60),  
		step: 30,  
		format: 12,  
		titleLabel: 'end time',  
		callback: (val) ->   
			$scope.timePickerEndCallback(val)
	}	
	
	$scope.timePickerEndCallback = (val) ->
		if typeof val == 'undefined'
			$scope.timePickerEndObject.inputEpochTime = 0
		else 	
			$scope.timePickerEndObject.inputEpochTime = val
			adate = $scope.datepickerObjectStart.inputDate
			adate.setHours(0,0,0,0)
			bdate = $scope.datepickerObjectEnd.inputDate
			bdate.setHours(0,0,0,0)
			if (adate - bdate) == 0
				if $scope.timePickerStartObject.inputEpochTime > val
					$scope.timePickerStartObject.inputEpochTime = val
		return

	$scope.controllername = 'CalendarCtrl'
				
			
MyCalendarListPageCtrl = ($rootScope, $scope, $state, $stateParams, $location, model) ->
	class MyCalendarListPageView
		constructor: (opts = {}) ->
			_.each @events, (handler, event) =>
				$scope.$on event, @[handler]
			@collection = opts.collection

		remove: (calendar) ->
			@model.remove(calendar)
	
	$scope.loadMore = ->
		$scope.collection.$fetch()
			.then ->
				$scope.$broadcast('scroll.infiniteScrollComplete')
			.catch alert
					
	$scope.collection = new model.MyCalendarList()
	$scope.collection.$fetch().then ->
		$scope.$apply ->	
			$scope.controller = new MyCalendarListPageView collection: $scope.collection
		

UpcomingListCtrl = ($rootScope, $scope, $state, $stateParams, $location, $filter, model) ->
	class UpcomingListView
		constructor: (opts = {}) ->
			_.each @events, (handler, event) =>
				$scope.$on event, @[handler]
			@collection = opts.collection

		remove: (calendar) ->
			@collection.remove(calendar)
			$rootScope.$broadcast 'calendar:getUpcomingListView'
			
		read: (selectedModel) ->
			$state.go 'app.readCalendar', { SelectedCalendar: selectedModel, myCalendarCol: null, backpage: 'app.upcomingList' }, { reload: true }

		edit: (selectedModel) ->
			$state.go 'app.editCalendar', { SelectedCalendar: selectedModel, myCalendarCol: null, backpage: 'app.upcomingList' }, { reload: true }

		$scope.formatDate = (inStr, format) ->
			inStr = new Date(parseInt(inStr))
			return $filter("date")(inStr, format)

	$rootScope.$on 'calendar:getUpcomingListView', ->
		#start
		$scope.collection = new model.UpcomingList()
		$scope.collection.$fetch().then ->
			$scope.$apply ->
				$scope.reorder()
		#end		
		
	$rootScope.$on 'calendar:refreshView', ->
		#start
		$scope.reorder()
		#end
		
	$scope.reorder = ->
		#expand day range task
		$scope.events = []
		oneDay = 24*60*60*1000
		angular.forEach $scope.collection.models, (element) ->
			sdate = new Date(element.dateStart)
			sdate = new Date(sdate.setHours(0,0,0,0))
			edate = new Date(element.dateEnd)
			edate = new Date(edate.setHours(0,0,0,0))
								
			diffDays = Math.round(Math.abs((sdate.getTime() - edate.getTime())/(oneDay)))
			tomorrow = new Date(element.dateStart)
			tomorrow = new Date(tomorrow.setHours(0,0,0,0))
			i=0
			while i <= diffDays
				@newmodel = new model.Calendar element
				@newmodel.oStDate = tomorrow
				if i == 0
					@newmodel.oStTime = element.dateStart
					@newmodel.oStDate = sdate
				else
					tomorrow = new Date(tomorrow.setDate(tomorrow.getDate()+1))
					@newmodel.oStTime = tomorrow
									
				if diffDays == i	
					@newmodel.oEnTime = element.dateEnd
							
				if i < diffDays 
					dayEnd = new Date(@newmodel.oStDate)
					dayEnd = new Date(dayEnd.setHours(23,59,0,0))
					@newmodel.oEnTime = dayEnd 
									
				$scope.events.push @newmodel
				i++
							
		#grouping
		$scope.eventsGP = _.groupBy($scope.events,'oStDate')
					
		#new groupby
		$scope.groupedByDate = _.groupBy($scope.events, (item) ->
			item.oStDate.setHours(0,0,0,0)
		)	
											
		$scope.collection.calendars = $scope.groupedByDate
		$scope.controller = new UpcomingListView collection: $scope.collection	
			
	$scope.loadMore = ->
		$scope.collection.$fetch()
			.then ->
				$scope.$broadcast('scroll.infiniteScrollComplete')
				$scope.$apply ->
					$rootScope.$broadcast 'calendar:refreshView'
			.catch alert
					
	$rootScope.$broadcast 'calendar:getUpcomingListView'

ProjectCalendarCtrl = ($rootScope, $scope, $state, $stateParams, $location, $filter, model) ->
	class ProjectCalendarView
		constructor: (opts = {}) ->
			_.each @events, (handler, event) =>
				$scope.$on event, @[handler]
			@collection = opts.collection

		remove: (calendar) ->
			@collection.remove(calendar)
			$rootScope.$broadcast 'calendar:getProjectCalendarView'
			
		read: (selectedModel) ->
			$state.go 'app.readCalendar', { SelectedCalendar: selectedModel, myCalendarCol: null, backpage: 'app.projectCalendar' }, { reload: true }

		edit: (selectedModel) ->
			$state.go 'app.editCalendar', { SelectedCalendar: selectedModel, myCalendarCol: null, backpage: 'app.projectCalendar' }, { reload: true }
		
		$scope.formatDate = (inStr, format) ->
			inStr = new Date(parseInt(inStr))
			return $filter("date")(inStr, format)

	$rootScope.$on 'calendar:getProjectCalendarView', ->
		#start
		$scope.collection = new model.UpcomingList()
		$scope.collection.$fetch({params: {order_by: 'project'}}).then ->
			$scope.$apply ->
				$scope.reorder()
		#end		
		
	$rootScope.$on 'calendar:refreshProjectCalendarView', ->
		#start
		$scope.reorder()
		#end
		
	$scope.reorder = ->
		#expand day range task	
		$scope.events = []
		oneDay = 24*60*60*1000
		angular.forEach $scope.collection.models, (element) ->
			sdate = new Date(element.dateStart)
			sdate = new Date(sdate.setHours(0,0,0,0))
			edate = new Date(element.dateEnd)
			edate = new Date(edate.setHours(0,0,0,0))
								
			diffDays = Math.round(Math.abs((sdate.getTime() - edate.getTime())/(oneDay)))
			tomorrow = new Date(element.dateStart)
			tomorrow = new Date(tomorrow.setHours(0,0,0,0))
			i=0
			while i <= diffDays
				@newmodel = new model.Calendar element
				@newmodel.oStDate = tomorrow
				if i == 0
					@newmodel.oStTime = element.dateStart
					@newmodel.oStDate = sdate
				else
					tomorrow = new Date(tomorrow.setDate(tomorrow.getDate()+1))
					@newmodel.oStTime = tomorrow
									
				if diffDays == i	
					@newmodel.oEnTime = element.dateEnd
							
				if i < diffDays 
					dayEnd = new Date(@newmodel.oStDate)
					dayEnd = new Date(dayEnd.setHours(23,59,0,0))
					@newmodel.oEnTime = dayEnd 
									
				$scope.events.push @newmodel
				i++
							
		#grouping
		$scope.eventsGP = _.groupBy($scope.events,'oStDate')
					
		#new groupby
		group1 = _.groupBy($scope.events, (item) ->
			return item.project  
		)
		 
		$scope.p = []
		angular.forEach group1, (element) ->
			group2 = _.groupBy(element, (item) ->
				item.oStDate.setHours(0,0,0,0)
			)
			$scope.p.push {project : element[0].project, 	models : group2	}	
			
		
		$scope.collection.calendars = $scope.p
		$scope.controller = new ProjectCalendarView collection: $scope.collection	
			
	$scope.loadMore = ->
		$scope.collection.$fetch()
			.then ->
				$scope.$broadcast('scroll.infiniteScrollComplete')
				$scope.$apply ->
					$rootScope.$broadcast 'calendar:refreshProjectCalendarView'
			.catch alert
					
	$rootScope.$broadcast 'calendar:getProjectCalendarView'

TodayCtrl = ($rootScope, $scope, $state, $stateParams, $location, $filter, model) ->
	class TodayView
		constructor: (opts = {}) ->
			_.each @events, (handler, event) =>
				$scope.$on event, @[handler]
			@collection = opts.collection

		timeRuler: () ->
			timeHeight = new Date()
			return timeHeight.getHours()*84 + (timeHeight.getMinutes() / 60) * 84
			
		previousDay: ->
			$scope.today = $scope.today.setDate($scope.today.getDate()-1)
			$scope.today = new Date($scope.today)
			$scope.fmDate = new Date($scope.today)
			$scope.fmDate = new Date($scope.fmDate.setHours(0,0,0,0))
			$scope.toDate = new Date($scope.today)
			$scope.toDate = new Date($scope.toDate.setHours(23,59,0,0))
			$rootScope.$broadcast 'calendar:getTodayView'		
		
		nextDay: ->
			$scope.today = $scope.today.setDate($scope.today.getDate()+1)
			$scope.today = new Date($scope.today)
			$scope.fmDate = new Date($scope.today)
			$scope.fmDate = new Date($scope.fmDate.setHours(0,0,0,0))
			$scope.toDate = new Date($scope.today)
			$scope.toDate = new Date($scope.toDate.setHours(23,59,0,0))
			$rootScope.$broadcast 'calendar:getTodayView'	
			
		remove: (calendar) ->
			@collection.remove(calendar)
			$rootScope.$broadcast 'calendar:getTodayView'
			
		read: (selectedModel) ->
			$state.go 'app.readCalendar', { SelectedCalendar: selectedModel, myCalendarCol: null, backpage: 'app.today' }, { reload: true }

		edit: (selectedModel) ->
			$state.go 'app.editCalendar', { SelectedCalendar: selectedModel, myCalendarCol: null, backpage: 'app.today' }, { reload: true }

	$rootScope.$on 'calendar:getTodayView', ->
		#start
		$scope.collection = new model.CalendarRangeList()
		$scope.collection.$fetch({params: {fmDate: $scope.fmDate, toDate: $scope.toDate}}).then ->
			$scope.$apply ->
				$scope.reorder()
		#end		
	
	$scope.reorder = ->
		#expand day range task
		$scope.events = []
		divLeft = 0
		Etot = $scope.collection.models.length  
		Ecnt = 1
		angular.forEach $scope.collection.models, (element) ->
			@newmodel = new model.Calendar element
			#adjust fmDate, toDate
			if element.dateStart < $scope.fmDate
				@newmodel.dateStart = $scope.fmDate
			if element.dateEnd > $scope.toDate
				@newmodel.dateEnd = $scope.toDate
			
			#top: hour * 84 + per 30 mins * 1.4 (42px)
			@newmodel.top = @newmodel.dateStart.getHours()*84 + @newmodel.dateStart.getMinutes() *1.4
			
			#left: default -1px
			@newmodel.left = divLeft
			divLeft = (100 / Etot) * Ecnt
			
			#width: default 100 / nof events
			@newmodel.width = 100 / Etot
			
			#height: per 30 min * 21 
			diff = @newmodel.dateEnd - @newmodel.dateStart
			#half hour task
			if diff == 0
				@newmodel.height = 42
			else if @newmodel.dateEnd.getMinutes() == 59
				@newmodel.height = (Math.floor(diff/1000/60) / 30 +1) * 42
			else	
				@newmodel.height = (Math.floor(diff/1000/60) / 30) * 42
			
			$scope.events.push @newmodel
			Ecnt = Ecnt + 1
		
		$scope.collection.calendars = $scope.events
		$scope.controller = new TodayView collection: $scope.collection	
			
	#start here
	$scope.today = new Date()
	$scope.fmDate = new Date()
	$scope.fmDate = new Date($scope.fmDate.setHours(0,0,0,0))
	$scope.toDate = new Date()
	$scope.toDate = new Date($scope.toDate.setHours(23,59,0,0))
	$rootScope.$broadcast 'calendar:getTodayView'	


WeekCtrl = ($rootScope, $scope, $state, $stateParams, $location, $filter, model) ->
	class WeekView
		constructor: (opts = {}) ->
			_.each @events, (handler, event) =>
				$scope.$on event, @[handler]
			@collection = opts.collection

		previousWeek: ->
			curr = new Date($scope.week[0])
			curr = curr.setDate(curr.getDate() - 7)
			$scope.week = $scope.getWeek(new Date(curr))
			$scope.today = new Date()
		
			$scope.fmDate = $scope.week[0]
			$scope.fmDate = new Date($scope.fmDate.setHours(0,0,0,0))
			$scope.toDate = $scope.week[6]
			$scope.toDate = new Date($scope.toDate.setHours(23,59,0,0))
			$rootScope.$broadcast 'calendar:getWeekView'

		nextWeek: ->
			curr = new Date($scope.week[0])
			curr = curr.setDate(curr.getDate() + 7)
			$scope.week = $scope.getWeek(new Date(curr))
			$scope.today = new Date()
		
			$scope.fmDate = $scope.week[0]
			$scope.fmDate = new Date($scope.fmDate.setHours(0,0,0,0))
			$scope.toDate = $scope.week[6]
			$scope.toDate = new Date($scope.toDate.setHours(23,59,0,0))
			$rootScope.$broadcast 'calendar:getWeekView'
			
		isToday: (d) ->
			today = new Date
			today.setHours(0,0,0,0)
			iDate = new Date(d)
			iDate.setHours(0,0,0,0)
			return today.getTime() == iDate.getTime()
			
		remove: (calendar) ->
			@collection.remove(calendar)
			$rootScope.$broadcast 'calendar:getWeekView'
			
		read: (selectedModel) ->
			$state.go 'app.readCalendar', { SelectedCalendar: selectedModel, myCalendarCol: null, backpage: 'app.week' }, { reload: true }

		edit: (selectedModel) ->
			$state.go 'app.editCalendar', { SelectedCalendar: selectedModel, myCalendarCol: null, backpage: 'app.week' }, { reload: true }

	$rootScope.$on 'calendar:getWeekView', ->
		#start
		$scope.collection = new model.CalendarRangeList()
		$scope.collection.$fetch({params: {fmDate: $scope.fmDate, toDate: $scope.toDate}}).then ->
			$scope.$apply ->
				#$scope.reorder()
				$scope.wkreorder()
		#end		
	
	
	$scope.wkreorder = ->
		#find calendar day by day
		i = 0
		wkcalendar = []
		$scope.wkcalendar = new Array()
		while i < 7
		  $scope.dayStart = $scope.week[i]
		  $scope.dayStart = new Date($scope.dayStart.setHours(0,0,0,0))
		  $scope.dayEnd = $scope.week[i]
		  $scope.dayEnd = new Date($scope.dayEnd.setHours(23,59,0,0))
		  #if in a day, (StartA < EndB)  and  (EndA > StartB)
		  angular.forEach $scope.collection.models, (element) ->
		    if ((element.dateStart <= $scope.dayEnd) and (element.dateEnd >= $scope.dayStart))
		      wkcalendar.push element
		  $scope.curr = i  
		  $scope.wkcalendar[$scope.curr] = wkcalendar
		  wkcalendar = [] 
		  $scope.reorder() 
		  i++
		  
	$scope.reorder = ->
		#expand day range task
		$scope.events = []
		divLeft = 0
		Etot = $scope.wkcalendar[$scope.curr].length   
		Ecnt = 1
		angular.forEach $scope.wkcalendar[$scope.curr], (element) ->
			@newmodel = new model.Calendar element
			#adjust fmDate, toDate
			if element.dateStart < $scope.dayStart
				@newmodel.dateStart = $scope.dayStart
			if element.dateEnd > $scope.dayEnd
				@newmodel.dateEnd = $scope.dayEnd
			
			#top: hour * 84 + per 30 mins * 1.4 (42px)
			@newmodel.top = @newmodel.dateStart.getHours()*84 + @newmodel.dateStart.getMinutes() *1.4
			
			#left: default -1px
			@newmodel.left = divLeft
			divLeft = (100 / Etot) * Ecnt
			
			#width: default 100 / nof events
			@newmodel.width = 100 / Etot
			
			#height: per 30 min * 21 
			diff = @newmodel.dateEnd - @newmodel.dateStart
			#half hour task
			if diff == 0
				@newmodel.height = 42
			else if @newmodel.dateEnd.getMinutes() == 59
				@newmodel.height = (Math.floor(diff/1000/60) / 30 +1) * 42
			else	
				@newmodel.height = (Math.floor(diff/1000/60) / 30) * 42
			
			$scope.events.push @newmodel
			Ecnt = Ecnt + 1
		
		$scope.collection.calendars = $scope.events
		$scope.weekcalendar[$scope.curr] = $scope.events
		$scope.controller = new WeekView collection: $scope.collection	

	$scope.getWeek = (fromDate) ->
		sunday = new Date(fromDate.setDate(fromDate.getDate() - fromDate.getDay()))
		result = [ new Date(sunday) ]
		while sunday.setDate(sunday.getDate() + 1) and sunday.getDay() != 0
		  result.push new Date(sunday)
		result
				
	#start here
	$scope.weekcalendar = new Array()
	$scope.week = $scope.getWeek(new Date())
	$scope.today = new Date()
	$scope.curr = 0
	$scope.fmDate = $scope.week[0]
	$scope.fmDate = new Date($scope.fmDate.setHours(0,0,0,0))
	$scope.toDate = $scope.week[6]
	$scope.toDate = new Date($scope.toDate.setHours(23,59,0,0))
	$rootScope.$broadcast 'calendar:getWeekView'

										
CalendarsFilter = ->
	(calendars, search) ->
	 	return _.filter calendars, (calendar) ->
	 		if _.isUndefined(search)
	 			true
	 		else if _.isEmpty(search)
	 			true
	 		else	
	 			calendar.task.indexOf(search) > -1 

# ionic-timepicker plugin directive
standardTimeMeridian  = ->

	restrict: 'AE'
	replace: true
	scope: etime: '=etime'
	template: '<strong>{{stime}}</strong>'
	link: (scope, elem, attrs) ->
	
		prependZero = (param) ->
			if String(param).length < 2
				return '0' + String(param)
			param
	
		epochParser = (val, opType) ->
			if val == null
				return '00:00'
			else
				meridian = [
					'AM'
					'PM'
				]
			if opType == 'time'
				hours = parseInt(val / 3600)
				minutes = val / 60 % 60
				hoursRes = if hours > 12 then hours - 12 else hours
				currentMeridian = meridian[parseInt(hours / 12)]
				return prependZero(hoursRes) + ':' + prependZero(minutes) + ' ' + currentMeridian
			return
	
		scope.stime = epochParser(scope.etime, 'time')
		scope.$watch 'etime', (newValue, oldValue) ->
			scope.stime = epochParser(scope.etime, 'time')
			return
		return

	
config = ->
	return
	
angular.module('starter.controller', ['ionic', 'ngCordova', 'http-auth-interceptor', 'starter.model', 'platform']).config [config]	
angular.module('starter.controller').controller 'AppCtrl', ['$rootScope', '$scope', '$http', 'platform', 'authService', 'model', AppCtrl]
angular.module('starter.controller').controller 'MenuCtrl', ['$scope', MenuCtrl]

angular.module('starter.controller').controller 'CalendarEditCtrl', ['$rootScope', '$scope', '$state', '$stateParams', '$location', 'model', '$filter', CalendarEditCtrl]
angular.module('starter.controller').controller 'CalendarCtrl', ['$rootScope', '$scope', '$state', '$stateParams', '$location', 'model', '$filter', CalendarCtrl]

angular.module('starter.controller').controller 'MyCalendarListPageCtrl', ['$rootScope', '$scope', '$state', '$stateParams', '$location', 'model', MyCalendarListPageCtrl]
angular.module('starter.controller').controller 'UpcomingListCtrl', ['$rootScope', '$scope', '$state', '$stateParams', '$location', '$filter', 'model', UpcomingListCtrl]
angular.module('starter.controller').controller 'ProjectCalendarCtrl', ['$rootScope', '$scope', '$state', '$stateParams', '$location', '$filter', 'model', ProjectCalendarCtrl]

angular.module('starter.controller').controller 'WeekCtrl', ['$rootScope', '$scope', '$state', '$stateParams', '$location', '$filter', 'model', WeekCtrl]
angular.module('starter.controller').controller 'TodayCtrl', ['$rootScope', '$scope', '$state', '$stateParams', '$location', '$filter', 'model', TodayCtrl]

angular.module('starter.controller').filter 'calendarsFilter', CalendarsFilter

angular.module('starter.controller').directive 'standardTimeMeridian', standardTimeMeridian 
