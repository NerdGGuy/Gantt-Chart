d3.gantt = ->
  gantt = (tasks) ->
    initTimeDomain tasks
    initAxis!
    initAxisMini!
    body = ((((d3.select 'body').append 'svg').attr 'class', 'chart').attr 'width', width + margin.left + margin.right).attr 'height', height + margin.top + margin.bottom + miniHeight
    ganttChartGroup = ((((body.append 'g').attr 'class', 'gantt-chart').attr 'width', width + margin.left + margin.right).attr 'height', height + margin.top + margin.bottom).attr 'transform', 'translate(' + margin.left + ', ' + margin.top + ')'
    miniGanttChartGroup = ((((body.append 'g').attr 'class', 'mini-gantt-chart').attr 'width', width + margin.left + margin.right).attr 'height', miniHeight).attr 'transform', 'translate(' + margin.left + ', ' + height + margin.bottom + ')'
    (((((((((miniGanttChartGroup.selectAll '.mini-gantt-chart').data tasks, keyFunction).enter!.append 'rect').attr 'rx', 5).attr 'ry', 5).attr 'class', (d) ->
      return 'bar' if taskStatus[d.status] is null
      'bar ' + taskStatus[d.status]).attr 'y', 0).attr 'transform', miniRectTransform).attr 'height', (d) -> miniY.rangeBand!).attr 'width', (d) -> (x d.endDate) - (x d.startDate)
    (((((((((ganttChartGroup.selectAll '.chart').data tasks, keyFunction).enter!.append 'rect').attr 'rx', 5).attr 'ry', 5).attr 'class', (d) ->
      return 'bar' if taskStatus[d.status] is null
      'bar ' + taskStatus[d.status]).attr 'y', 0).attr 'transform', rectTransform).attr 'height', (d) -> y.rangeBand!).attr 'width', (d) -> (x d.endDate) - (x d.startDate)
    (((ganttChartGroup.append 'g').attr 'class', 'x axis').attr 'transform', 'translate(0, ' + height - margin.top - margin.bottom + ')').transition!.call xAxis
    ((ganttChartGroup.append 'g').attr 'class', 'y axis').transition!.call yAxis
    ((miniGanttChartGroup.append 'g').attr 'class', 'y axis').transition!.call miniYAxis
    initBrush miniGanttChartGroup, ganttChartGroup
    gantt
  
  FIT_TIME_DOMAIN_MODE = 'fit'
  FIXED_TIME_DOMAIN_MODE = 'fixed'
  
  margin = {
    top: 10
    right: 40
    bottom: 15
    left: 150
  }
  
  timeDomainStart = d3.time.day.offset (new Date), -3
  timeDomainEnd = d3.time.hour.offset (new Date), +3
  timeDomainMode = FIT_TIME_DOMAIN_MODE
  taskTypes = []
  taskStatus = []
  miniHeight = 100
  height = document.body.clientHeight - margin.top - margin.bottom - miniHeight - 5
  width = document.body.clientWidth - margin.right - margin.left - 5
  tickFormat = '%H:%M'
  
  keyFunction = (d) -> d.startDate + d.taskName + d.endDate
  
  rectTransform = (d) -> 'translate(' + (x d.startDate) + ',' + (y d.taskName) + ')'
  
  x = ((d3.time.scale!.domain [timeDomainStart, timeDomainEnd]).range [0, width]).clamp true
  y = (d3.scale.ordinal!.domain taskTypes).rangeRoundBands [0, height - margin.top - margin.bottom], 0.1
  miniY = (d3.scale.ordinal!.domain taskTypes).rangeRoundBands [0, miniHeight], 0.1
  miniX = ((d3.time.scale!.domain [timeDomainStart, timeDomainEnd]).range [0, width]).clamp true
  
  miniRectTransform = (d) -> 'translate(' + (x d.startDate) + ',' + (miniY d.taskName) + ')'
  
  xAxis = (((((d3.svg.axis!.scale x).orient 'bottom').tickFormat d3.time.format tickFormat).tickSubdivide true).tickSize 8).tickPadding 8
  yAxis = ((d3.svg.axis!.scale y).orient 'left').tickSize 0
  miniYAxis = ((d3.svg.axis!.scale miniY).orient 'left').tickSize 0
  brush = d3.svg.brush!
  
  initBrush = (group, updateGroup) ->
    brushed = ->
      x.domain if brush.empty! then miniX.domain! else brush.extent!
      gantt.timeDomain brush.extent!
      gantt.redrawMain tasks
    (brush.x miniX).on 'brush', brushed
    (((((group.append 'g').attr 'class', 'x brush').call brush).selectAll 'rect').attr 'y', -6).attr 'height', miniHeight
  
  initTimeDomain = (tasks) ->
    if timeDomainMode is FIT_TIME_DOMAIN_MODE
      if tasks is ``undefined`` or tasks.length < 1
        timeDomainStart := d3.time.day.offset (new Date), -3
        timeDomainEnd := d3.time.hour.offset (new Date), +3
        return 
      tasks.sort ((a, b) -> a.endDate - b.endDate)
      timeDomainEnd := tasks[tasks.length - 1].endDate
      tasks.sort ((a, b) -> a.startDate - b.startDate)
      timeDomainStart := tasks.0.startDate
  
  initAxisMini = ->
    miniY := (d3.scale.ordinal!.domain taskTypes).rangeRoundBands [0, miniHeight], 0.1
    miniX := ((d3.time.scale!.domain [timeDomainStart, timeDomainEnd]).range [0, width]).clamp true
    miniYAxis := ((d3.svg.axis!.scale miniY).orient 'left').tickSize 0
  
  initAxis = ->
    x := ((d3.time.scale!.domain [timeDomainStart, timeDomainEnd]).range [0, width]).clamp true
    y := (d3.scale.ordinal!.domain taskTypes).rangeRoundBands [0, height - margin.top - margin.bottom], 0.1
    xAxis := (((((d3.svg.axis!.scale x).orient 'bottom').tickFormat d3.time.format tickFormat).tickSubdivide true).tickSize 8).tickPadding 8
    yAxis := ((d3.svg.axis!.scale y).orient 'left').tickSize 0
  
  gantt.redrawMini = (tasks) ->
    initAxisMini!
    svg = d3.select 'svg'
    (svg.select '.x').transition!.call xAxis
    (svg.select '.y').transition!.call yAxis
    miniGanttChartGroup = svg.select '.mini-gantt-chart'
    miniRect = (miniGanttChartGroup.selectAll '.bar').data tasks, keyFunction
    (((((((miniRect.enter!.insert 'rect', ':first-child').attr 'rx', 5).attr 'ry', 5).attr 'class', (d) ->
      return 'bar' if taskStatus[d.status] is null
      'bar ' + taskStatus[d.status]).transition!.attr 'y', 0).attr 'transform', miniRectTransform).attr 'height', (d) -> miniY.rangeBand!).attr 'width', (d) -> (x d.endDate) - (x d.startDate)
    ((miniRect.transition!.attr 'transform', miniRectTransform).attr 'height', (d) -> miniY.rangeBand!).attr 'width', (d) -> (x d.endDate) - (x d.startDate)
    miniRect.exit!.remove!
    brush.x miniX
    gantt
  
  gantt.redraw = (tasks) ->
    initTimeDomain tasks
    (gantt.redrawMain tasks).redrawMini tasks
    gantt
  
  gantt.redrawMain = (tasks) ->
    initAxis!
    svg = d3.select 'svg'
    ganttChartGroup = svg.select '.gantt-chart'
    rect = (ganttChartGroup.selectAll '.bar').data tasks, keyFunction
    (((((((rect.enter!.insert 'rect', ':first-child').attr 'rx', 5).attr 'ry', 5).attr 'class', (d) ->
      return 'bar' if taskStatus[d.status] is null
      'bar ' + taskStatus[d.status]).transition!.attr 'y', 0).attr 'transform', rectTransform).attr 'height', (d) -> y.rangeBand!).attr 'width', (d) -> (x d.endDate) - (x d.startDate)
    ((rect.transition!.attr 'transform', rectTransform).attr 'height', (d) -> y.rangeBand!).attr 'width', (d) -> (x d.endDate) - (x d.startDate)
    rect.exit!.remove!
    gantt
  
  gantt.margin = (value) ->
    return margin if not arguments.length
    margin := value
    gantt
  
  gantt.timeDomain = (value) ->
    return [timeDomainStart, timeDomainEnd] if not arguments.length
    timeDomainStart := +value.0
    timeDomainEnd := +value.1
    gantt
  
  gantt.timeDomainMode = (value) ->
    return timeDomainMode if not arguments.length
    timeDomainMode := value
    gantt
  
  gantt.taskTypes = (value) ->
    return taskTypes if not arguments.length
    taskTypes := value
    gantt
  
  gantt.taskStatus = (value) ->
    return taskStatus if not arguments.length
    taskStatus := value
    gantt
  
  gantt.width = (value) ->
    return width if not arguments.length
    width := +value
    gantt
  
  gantt.height = (value) ->
    return height if not arguments.length
    height := +value
    gantt
  
  gantt.tickFormat = (value) ->
    return tickFormat if not arguments.length
    tickFormat := value
    gantt
  
  gantt
