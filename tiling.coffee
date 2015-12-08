#mako yass, 2014

#understanding this code:
# I've done something a bit strange by having all code be orientation independent, that is, the same code handles both the vertical case and the horizontal case, just with a different parametization. For example:
#   For accessing properties like clientWidth or clientHeight on an element, we would
#      `ori = orientationKeys[+!isHorizontal]`
#      `element[ori.clientSpan]`
#   We use the same class for representing rows of elements regardless of whether it's a horizontal row or a vertical row(column, actually), we just give them differing isHorizontal construction params. They store their width and height differently depending on their orientation. Those relative dimensions are called long and broad. If all of the components in a Line were square, 'long' would always refers to the dimension that were longer, and broad would always refer to the dimension that were shorter. Altwise, on the broad dimension all elements in the same sequence will have the same position and span.
#   And by doing things this way I have saved a whole lot of typing, and presumably a whole lot of bugs that woulda stemmed from the innatentiveness of a comparitavely mundane task.


#shims

elBounds = (el)->
	cr = el.getBoundingClientRect()
	x: cr.left + document.body.scrollLeft
	y: cr.top + document.body.scrollTop
	w: cr.width
	h: cr.height

insertBefore = (arr, i, nel)->
	fore = arr.slice(0, i)
	fore.push nel
	aft = arr.slice(i, arr.length)
	fore.concat aft

prependChild = (container, child)->
	container.insertBefore(child, container.firstChild)

timeoutSet = (delay, cb)-> setTimeout(cb, delay) #invocations of timeoutSet are more terse in coffeescript than invocations of setTimeout, and, heh, they're arguably more readable in JS

yeildThen = (f)->
	setTimeout(f, 0) #because sometimes in chrome, a transition will fail to animate if you don't yeild before changing the value. Like, it just doesn't get used to the original value and doesn't register that there's been a change.

mouseEvRelTo = (ev, el)->
	cr = el.getBoundingClientRect()
	{
		x: ev.pageX - cr.left
		y: ev.pageY - cr.top
	}

removeEl = (el)-> el.parentNode.removeChild(el)
	


@tilingjs_version = '1.0'

orientationKeys = [
	{span:'width',  Span:'Width',  clientSpan:'clientWidth',  d:'x', D:'X', rear:'left', front:'right', offset:'offsetLeft'}
	{span:'height', Span:'Height', clientSpan:'clientHeight', d:'y', D:'Y', rear:'top', front:'bottom', offset:'offsetTop'}
]
keysForCard = (g)-> orientationKeys[((g>>1)^1)]
keysForOrientation = (bool)-> orientationKeys[+!bool]

# a card represents a cardinal direction succinctly
#  \0/
#  2X3
#  /1\
cardinalFor = (x, y, w, h)->
	m = h/w;
	a = (y > m*x)
	b = (y > h - m*x)
	((a ^ b) << 1) | b
cardIsH = (g)-> !!(g&2)
cardIsV = (g)->  !(g&2)
cardIsForward = (g)-> !!(g&1)
cardForVars = (isHoriz, isForward)->  (isHoriz<<1) | isForward
cardOpposite = (g)-> g ^ 1
cardSide = ['top', 'bottom', 'left', 'right']

# an ordinal is like a cardinal, but points to a corner
# 0 | 1
# --+--
# 2 | 3
ordinalFor = (x, y, w, h)-> ((y > h/2)<<1) | (x > w/2)
ordIsRight = (ord)-> !!(ord&1)
ordIsDown  = (ord)-> !!(ord&2)
ordForVars = (isDown, isRight)-> (isDown << 1) | isRight

#cordinals:
#  0 |4| 1
#  --\ /--  
#  6  X  7 
#  --/ \--
#  2 |5| 3
cardinalOrOrdinal = (cordinal, ifCardinal, ifOrdinal)-> if cordinal <= 3 then ifCardinal(cordinal) else ifOrdinal(cordinal & 3)
forCardinalComponentsOfCordinal = (cordinal, ifNorth, ifEast, ifSouth, ifWest)->
	switch cordinal
		when 0 then ifNorth(); ifWest()
		when 1 then ifNorth(); ifEast()
		when 2 then ifSouth(); ifWest()
		when 3 then ifEast(); ifSouth()
		when 4 then ifNorth()
		when 5 then ifSouth()
		when 6 then ifWest()
		when 7 then ifEast()
	return
fromCardinal = (cardinal)-> cardinal | 4
reflectCordinalHoriz = (cordinal)-> if (cordinal & 6) == 4 then cordinal else cordinal ^ 1
reflectCordinalVert = (cordinal)-> if cordinal >= 6 then cordinal else
	switch cordinal #wow. And the mathematical elegance is gone.
		when 0 then 2
		when 2 then 0
		when 4 then 5
		when 5 then 4
		when 1 then 3
		when 3 then 1
# cordinalFromCardinals = (a, b)->
# 	if a == b then a
# 	else if (a ^ b)&2 then throw new Error 'cannot derive cordinal from opposing cardinals'
# 	else if a == 0
# 		if b == 3 then 1
# 		else 0
# 	else
# 		if a == 

minimumTileSpan = 10
animationDuration = 140
fadeDuration = 140
creationColor = 'rgb(255,255,255)'

afterAnim = (cb)->  setTimeout(cb, animationDuration)
afterFade = (cb)->  setTimeout(cb, fadeDuration)

tileOrLine = (component, ifTile, ifLine)-> if component.constructor == Line then ifLine component else ifTile component

@destructiveFade = (el)->
	el.style.opacity = 0
	afterAnim -> el.remove()

TODO = -> console.error('feature not implemented')

class @ShadeGenerator
	shuffle = (arr)->
		for i in [0 ... arr.length]
			j = i + Math.floor(Math.random()*(arr.length - i))
			bf = arr[i]
			arr[i] = arr[j]
			arr[j] = bf
		return
	constructor: ->
		darkest = 17
		lightest = 68
		ngradations = 14
		@shades = (Math.round(darkest + igradation*(lightest - darkest)/ngradations) for igradation in [0 .. ngradations])
		shuffle @shades
		@shadeCounter = 0
	takeShade: ->
		@shadeCounter = (@shadeCounter + 1)%@shades.length
		@shades[@shadeCounter]
	colorFor = (shade)-> 'rgb('+shade+','+shade+','+shade+')'
	takeColor: ->
		colorFor(@takeShade())


class LineForming
	constructor:(@ar)->
class ForSpan
	constructor:(@ar)->
class DetailedPosition
	constructor:(@obj)->
@widthBeing = (args...)-> new ForSpan(args)
@upto = (args...)-> args
@line = (args...)-> new LineForming args
@position = (obj)-> new DetailedPosition obj
@mount = (container, baseLine)-> new Mount container, baseLine

class Mount
	#a mount config is like
	# {
	#   //mandatory:
	#    container: the positioned html element that the contents will be placed in
	#   //optional:
	#    rootLine: a configuration of tiles as produced by nested line() expressions.
	#    defaultContentGenerator: a function that returns new default contents/provides the initial content. Various keybindings can invoke this. defaults to generateNullContent
	# }
	constructor: (configArgs)-> #rootLine is produced by a line() expression. container must be positioned.
		if !configArgs.container then throw new Error('configArgs container is mandatory')
		#prep shade generator
		@shadegen = new ShadeGenerator()
		
		@container = configArgs.container
		@container.addEventListener 'contextmenu', (ev)=> if @ctrlHeld then ev.preventDefault()
		@defaultContentGenerator = configArgs.defaultContentGenerator || => @generateNullContent()
		rootLineExpression = configArgs.initial ||(
			line(@defaultContentGenerator())
		)
		
		#list of resizings to attempt after positioning, resizing is like {tile, x, y}. x, y == 0 will be ignored
		preferenceResizings = []
		
		#converts the config expression into the structure
		prime = (component, parent, isHoriz, broadOrigin, longOrigin, broadSpan, longSpan)=> #resolves the lineSpec into a Line
			ori = keysForOrientation isHoriz
			otherOri = keysForOrientation !isHoriz
			switch component.constructor
				when LineForming
					componentArray = component.ar
					i = 1
					originb = longOrigin
					generatedLine = new Line(parent, isHoriz, broadOrigin, longOrigin, broadSpan, longSpan)
					generatedLine.components = componentArray.map( (cgen)=> #(children need generatedLine target in order to parent)
						nextoriginb = longOrigin + Math.round i*longSpan/componentArray.length
						spanb = nextoriginb - originb
						ret = prime cgen, generatedLine, !isHoriz, originb, broadOrigin, spanb, broadSpan
						i += 1
						originb = nextoriginb
						ret
					)
					generatedLine
				when DetailedPosition
					dob = component.obj
					tile = prime dob.content, parent, isHoriz, broadOrigin, longOrigin, broadSpan, longSpan
					if dob.desiredWidth or dob.desiredHeight
						preferenceResizings.push {tile:tile, x:dob.desiredWidth, y:dob.desiredHeight}
					tile
				when ForSpan
					fors = component.ar
					#select the appropriate layout
					ww = @container.clientWidth
					if ww == 0
						console.error 'needed the width of container to be set already in order to initialize. No width. Gonna suck.'
					i = 0
					comp = null
					loop
						if fors[i].length == 1
							comp = fors[i][0]
							break
						else if ww <= fors[i][0]
							comp = fors[i][1]
							break
						else if i + 1 == fors.length
							throw new Error 'no sizing for this. Consider adding a catchall to the end, in which you specify no maximum width'
						i += 1
					prime(comp, parent, isHoriz, broadOrigin, longOrigin, broadSpan, longSpan)
				when TileContent
					tl = @boxTile(component, parent, isHoriz, broadOrigin, longOrigin, broadSpan, longSpan)
					@container.appendChild tl.tray
					tl.opening()
					tl
				
		listeners = ['resize', 'mousemove', 'mousedown', 'mouseup', 'keydown', 'keyup']
		@listeners = []
		listeners.forEach (name)=>
			cb = => Mount.prototype[name].apply(@, arguments)
			@listeners.push {name:name, callback:cb}
			window.addEventListener name, cb, false
		@prevMouseX = 0
		@prevMouseY = 0
		@tileBeingResized = null
		@resizationCordinal = null
		@selectionAllowed = true
		@middleBtnDown = false
		@rootLine = prime(rootLineExpression, null, false, 0, 0, @container.offsetWidth, @container.offsetHeight)
		#now try to do the resizings
		for {tile, x, y} in preferenceResizings
			tbroad = if tile.isHorizontal then y else x
			tlong = if tile.isHorizontal then x else y
			if tbroad then tile.tryMoveBroadForthBoundary tbroad - tile.broadSpan
			if tlong then tile.tryMoveLongForthBoundary tlong - tile.longSpan

	generateNullContent: ->
		nelinner = document.createElement 'div'
		nelinner.classList.add 'tilingjs_default_tile_inner'
		nelinner.style.backgroundColor = @shadegen.takeColor()
		# nelinner.textContent = '∅' #'☉'
		content nelinner
		
	dragOperationInProgress: -> !!@tileBeingResized || !!@liftedTile
	
	# maybeAllowSelection: ->
	# 	if @dragOperationInProgress()
	# 		@selectionAllowed = true
	
	# maybePreventSelection: ->
	# 	if @dragOperationInProgress()
	# 		@selectionAllowed = false

	mousemove: (ev)->
		relx = ev.pageX - @prevMouseX
		rely = ev.pageY - @prevMouseY
		@prevMouseX = ev.pageX
		@prevMouseY = ev.pageY
		if @tileBeingResized
			@resizeTile @tileBeingResized, @resizationCordinal, relx, rely
		if @middleBtnDown and not @dragOperationInProgress()
			#we're gonna move something in some way
			tile = @tileUnderMouse()
			if tile
				tb = elBounds(tile.tray)
				rx = @prevMouseX - tb.x
				ry = @prevMouseY - tb.y
				if tb.w/3 < rx and rx < tb.w/3*2 and
				   tb.h/3 < ry and ry < tb.h/3*2
						#center box, relocating the tile
						@liftTile tile
				else
					@startResize tile, ordForVars ry > tb.h/2, rx > tb.w/2
					
		
	mouseup: (ev)->
		@stopResize()
		@stopShiftingTile()
		if ev.button == 1
			@middleBtnDown = false

	mousedown: (ev)->
		if @ctrlHeld
			if ev.button == 0
				whatIsMoused = @tileUnderMouse()
				if whatIsMoused
					@liftTile whatIsMoused
				ev.preventDefault()
				ev.stopPropagation()
			else if ev.button == 2
				@startResizing()
				ev.preventDefault()
				return false
		if @dragOperationInProgress()
			ev.stopPropagation()
			ev.preventDefault()
		else if ev.button == 1
			@middleBtnDown = true
		
	keydown: (ev)->
		switch ev.keyCode
			when 17 #ctrl
				@ctrlHeld = true
			when 18 #alt
				@altHeld = true
			when 67 #C
				if ev.altKey and not (ev.shiftKey or ev.ctrlKey or ev.metaKey) then @createSignal()
			when 66 #B
				if ev.altKey and not (ev.shiftKey or ev.ctrlKey or ev.metaKey) then @deleteSignal()
		
	keyup: (ev)->
		switch ev.keyCode 
			when 17 #ctrl
				@ctrlHeld = false
				@stopResize()
				@stopShiftingTile()
			when 18 #alt
				@altHeld = false
				@stopShiftingTile()
			when 88 #x
				@stopShiftingTile()
	
	deleteSignal: (ev)->
		whatIsMoused = @tileUnderMouse()
		@deleteTile whatIsMoused if whatIsMoused
	# deleteEndSignal: (ev)->
			
	createSignal: ->
		@addAt @defaultContentGenerator(), @prevMouseX, @prevMouseY
	# createEndSignal: ->
		
	startResizing: ->
		whatIsMoused = @tileUnderMouse()
		if whatIsMoused
			ep = elBounds whatIsMoused.tray
			@resizationCordinal = ordinalFor @prevMouseX - ep.x, @prevMouseY - ep.y, whatIsMoused.tray.clientWidth, whatIsMoused.tray.clientHeight
			# #reflect the cordinal on the cardinals pointing straight at a wall upon which no movement is possible
			# NAAAHHHHH.
			# @resizationCordinal = forCardinalComponentsOfCordinal preliminaryCordinal,
			# 	-> 
			# 	-> 
			# 	-> 
			# 	-> 
			# 	@resizationCordinal = cardOpposite @resizationCordinal
			@startResize whatIsMoused, @resizationCordinal
	
	stopShiftingTile: ->
		if @liftedTile
			whatIsMoused = @tileUnderMouse()
			if whatIsMoused
				wimpos = elBounds whatIsMoused.tray
				@dropTile whatIsMoused, cardinalFor(@prevMouseX - wimpos.x, @prevMouseY - wimpos.y, whatIsMoused.tray.clientWidth, whatIsMoused.tray.clientHeight)
			else
				@releaseLiftedTile()
	
	

	tileUnderMouse: ->
		cop = elBounds @container
		@seek @prevMouseX - cop.x, @prevMouseY - cop.y

	boxTile: (content, parent, isHorizontal, broadOrigin, longOrigin, broadSpan, longSpan)->
		tray = document.createElement 'div'
		tray.classList.add 'tilingjs_tray'
		tray.style.backgroundColor = @shadegen.takeShade()
		box = new Tile content, tray, parent, isHorizontal, broadOrigin, longOrigin, broadSpan, longSpan
		tray.addEventListener 'mouseover', (ev)=>
			@tileMouseIsOver = box
		box

	detach: ->
		for binding in @listeners
			window.removeEventListener binding.name, binding.cb
		# for sh in @jwertySubhandles
		# 	sh.unbind()
		# @listeners = @jwertySubhandles = null
	
	removeLiftingmask = (tile)->
		elist = tile.tray.getElementsByClassName('tilingjs_liftingmask')
		while elist.length > 0
			removeEl elist[0]
	
	releaseLiftedTile: ->
		if @liftedTile
			removeLiftingmask @liftedTile
			@liftedTile = null
	
	liftTile: (tile)->
		@liftedTile = tile
		liftingmask = document.createElement 'div'
		liftingmask.classList.add 'tilingjs_liftingmask'
		tile.tray.appendChild liftingmask
	
	dropTile: (target, cardinal)->
		if @liftedTile
			removeLiftingmask @liftedTile
			if @liftedTile != target
				upa = @liftedTile.content
				#if the user is dragging a tile onto its neighbor, do not allow it to be placed right back in the segment it's already in; the user could not possibly want that
				tcom = target.parent.components
				ti = tcom.indexOf target
				if tcom.length > ti + 1 and tcom[ti + 1] == @liftedTile
					orientation = target.parent.isHorizontal
					if (cardIsH cardinal) == orientation
						cardinal = cardForVars orientation, false
				else if ti > 0 and tcom[ti - 1] == @liftedTile
					orientation = target.parent.isHorizontal
					if (cardIsH cardinal) == orientation
						cardinal = cardForVars orientation, true
				@removeTile @liftedTile
				@insertOver target, upa, cardinal
			@liftedTile = null
	
	resize: (ev)->
		nw = @container.clientWidth
		nh = @container.clientHeight
		nb = (if @rootLine.isHorizontal then nh else nw) - @rootLine.broadSpan
		nl = (if @rootLine.isHorizontal then nw else nh) - @rootLine.longSpan
		@rootLine.scaleLongForth nl
		@rootLine.scaleBroadForth nb
		@rootLine.forAllTiles (tile)-> tile.resized()
	
	resizeTile: (tile, cornordinal, relx, rely)->
		xish = if tile.isHorizontal then 'Long' else 'Broad'
		yish = if tile.isHorizontal then 'Broad' else 'Long'
		forCardinalComponentsOfCordinal cornordinal,
			-> tile['tryMove'+yish+'RearBoundary'](rely)
			-> tile['tryMove'+xish+'ForthBoundary'](relx)
			-> tile['tryMove'+yish+'ForthBoundary'](rely)
			-> tile['tryMove'+xish+'RearBoundary'](relx)
	
	removeTile: (tile)-> #returns the content that was removed
		oldControl = tile.content
		removeFrom = (ancestor, tracing)=>
			if ancestor.components.length == 1
				if ancestor.parent
					removeFrom(ancestor.parent, ancestor)
				else
					#replace tracing with a default
					replaceTracing = (tr)=>
						if tr.constructor == Tile
							tr.replaceContent @defaultContentGenerator()
						else
							replaceTracing tr.components[0]
					replaceTracing tracing
			else
				pi = ancestor.components.indexOf tracing
				ancestor.components.splice pi, 1
				if pi < ancestor.components.length
					ancestor.components[pi].justMoveBroadRear -tracing.broadSpan
				else
					ancestor.components[pi-1].justMoveBroadForth tracing.broadSpan
				tile.tray.classList.add 'tilingjs_animation'
				destructiveFade tile.tray
		
		removeFrom(tile.parent, tile)
		oldControl
	
	deleteTile:(tile)->
		oldControl = @removeTile tile
		oldControl.onClose()
	
	
	stopResize: ->
		@tileBeingResized = null
		@resizationCordinal = null
	
	startResize: (tile, cordinal)->
		@tileBeingResized = tile
		@resizationCordinal = cordinal
	
	animateRect: (cardinal, color, left, top, right, bottom)-> #coords are rel to origin, not like css
		r = document.createElement 'div'
		r.classList.add 'tilingjs_animation'
		r.style['background-color'] = color
		ogs = [top, bottom, left, right]
		self = @
		fromOrigin = (g)-> ogs[g] + 'px'
		fromBottomRight = (g)-> (self.container[orientationKeys[(g>>1)^1].clientSpan] - ogs[g]) + 'px'
		fromItsSide = (g)-> if cardIsForward g then fromBottomRight g else fromOrigin g
		inlineDim = cardIsH cardinal
		lateralsDim = ! inlineDim
		#set sides
		g = cardForVars lateralsDim, false
		r.style[cardSide[g]] = fromOrigin(g)
		g = cardForVars lateralsDim, true
		r.style[cardSide[g]] = fromBottomRight(g)
		#set dimesions for compressed state
		gopp = cardOpposite cardinal
		r.style[cardSide[gopp]] = fromItsSide gopp
		dspan = keysForCard(gopp).span
		r.style[dspan] = '0px'
		prependChild @container, r
		#now animate the decompression
		yeildThen -> r.style[dspan] = Math.abs(ogs[gopp] - ogs[cardinal]) + 'px'
		# r.style[cardSide[cardinal]] = fromItsSide cardinal
		
		afterAnim ->
			destructiveFade r
	
	seek: (offx, offy)->
		ob = if @rootLine.isHorizontal then offy else offx
		ol = if @rootLine.isHorizontal then offx else offy
		@rootLine.seekProper ob, ol
	
	addAt: (newContent, ox, oy)->
		r = @insert newContent, ox, oy, -> newContent.onOpen()
	insert: (newContent, offx, offy, animationEndCallback)-> #offs are relative to document. Returns the new tile or null if the coordinate is not inside @container
		cop = elBounds @container
		target = @seek offx - cop.x, offy - cop.y
		if target
			elp = elBounds target.tray
			direction = cardinalFor offx - elp.x, offy - elp.y, target.tray.clientWidth, target.tray.clientHeight
			@insertOver target, newContent, direction, animationEndCallback
		else
			null
	insertOver: (parent, content, cardinal, animationEndCallback)->
		partray = parent.tray
		gopp = cardOpposite(cardinal)
		fadecb = @animateRect gopp, content.el.style['background-color'] || 'rgb(255,255,255)',
			if gopp == 2 then partray.offsetLeft + (partray.clientWidth >> 1) else partray.offsetLeft
			if gopp == 0 then partray.offsetTop + (partray.clientHeight >> 1) else partray.offsetTop
			if gopp == 3 then partray.offsetLeft + (partray.clientWidth >> 1) else partray.offsetLeft + partray.clientWidth
			if gopp == 1 then partray.offsetTop + (partray.clientHeight >> 1) else partray.offsetTop + partray.clientHeight
		dirIsHorizontal = cardIsH cardinal
		dirIsForward = cardIsForward cardinal
		ori = orientationKeys[+!dirIsHorizontal]
		otherOri = orientationKeys[+dirIsHorizontal]
		parentsPart = Math.floor partray[ori.clientSpan]/2
		newTilesPart = partray[ori.clientSpan] - parentsPart
		parpar = parent.parent
		precedentTileIndex = parpar.components.indexOf parent
		newTile = null
		if dirIsHorizontal == parpar.isHorizontal
			newTile = @boxTile(content, parpar, parent.isHorizontal, parent.broadOrigin+parentsPart*dirIsForward, parent.longOrigin, newTilesPart, parent.longSpan)
			afterAnim =>
				parent.setBroadSpan parentsPart
				parent.justTranslateBroadBy newTile.broadSpan if !dirIsForward
				parpar.components = insertBefore(parpar.components, precedentTileIndex + dirIsForward, newTile)
				@container.appendChild newTile.tray
				animationEndCallback() if animationEndCallback
		else
			newLine = new Line(parpar, parent.isHorizontal, parent.broadOrigin, parent.longOrigin, parent.broadSpan, parent.longSpan)
			newTile = @boxTile(content, newLine, !parent.isHorizontal, newLine.longOrigin+dirIsForward*parentsPart, newLine.broadOrigin, newTilesPart, newLine.broadSpan)
			afterAnim =>
				parent.parent = newLine
				parent.isHorizontal = !newLine.isHorizontal
				parent.setBroadOrigin newLine.longOrigin + newTilesPart*!dirIsForward
				parent.setLongOrigin newLine.broadOrigin
				parent.setBroadSpan parentsPart
				parent.setLongSpan newLine.broadSpan
				newLine.components = if dirIsForward then [parent, newTile] else [newTile, parent]
				parpar.components[precedentTileIndex] = newLine
				@container.appendChild newTile.tray
				animationEndCallback() if animationEndCallback
		newTile
	

#define one of these for each of your windows
class @TileContent
	onResize: ->
	onClose: ->
	onOpen: ->
	hasUniqueClass: -> false
@content = (element)->
	c = new TileContent
	c.el = element
	c

class Component #abstract
	constructor: (@parent, @isHorizontal, @broadOrigin, @longOrigin, @broadSpan, @longSpan)->
		@isHorizontal = if @parent then !@parent.isHorizontal else false
	ox: -> if @isHorizontal then @longOrigin else @broadOrigin
	oy: -> if @isHorizontal then @broadOrigin else @longOrigin
	w: -> if @isHorizontal then @longSpan else @broadSpan
	h: -> if @isHorizontal then @broadSpan else @longSpan
	canCompressLong: (amount)-> #returns the amount this unit can compress. only concerns the component in question, they do not expect the implementer to look at its neighbors
	canCompressBroad: (amount)->
	forAllTiles: (f)-> f @
	scaleLongForth: (amount)->
	scaleLongRear: (amount)->
	scaleBroadForth: (amount)->
	scaleBroadRear: (amount)->
	justTranslateLongBy: (amount)->
	justTranslateBroadBy: (amount)->
	justMoveLongForth: (amount)-> #the caller knows you can do this(maybe you told it with a canCompress), so just do it
	justMoveBroadForth: (amount)-> 
	justMoveLongRear: (amount)-> 
	justMoveBroadRear: (amount)-> 
	tryMoveLongForthBoundary: (amount)-> #these return the distance you actually moved
	tryMoveBroadForthBoundary: (amount)->
	tryMoveLongRearBoundary: (amount)->
	tryMoveBroadRearBoundary: (amount)->
	
	
class Line extends Component
	constructor: -> super
	seekProper: (broadC, longC)-> #returns a tile
		for com in @components
			if(
				com.broadOrigin <= longC and longC < com.broadOrigin + com.broadSpan and
				com.longOrigin <= broadC and broadC < com.longOrigin + com.longSpan
			)
				return tileOrLine com,
					(tile)-> tile
					(line)-> line.seekProper(longC, broadC) #so, I'm deliberately flipping the coords at each level because of the way Lines work :S, can't help but feel I may be digging a hole by writing everything to handle both cases. Where and how deeply, though, I'm not sure. The code is a lot shorter than it otherwise would have been.
		null
	
	firstTile: ->
		tileOrLine @components[0],
			(tile)-> tile
			(line)-> line.components[0]
	
	scaleLongRear: (amount)->
		@scaleLong amount
		@justTranslateLongBy amount
	scaleBroadRear: (amount)->
		@scaleBroad amount
		@justTranslateBroadBy amount
	scaleLongForth: (amount)-> @scaleLong amount
	scaleBroadForth: (amount)-> @scaleBroad amount
	
	scaleLong: (amount)-> #element will be `amount` shorter after scaling. Origin does not move.
		return if amount == 0
		weightings = new Array(@components.length)
		totalw = 0
		amountGiven = 0
		for i in [0 ... @components.length]
			com = @components[i]
			has = com.canCompressBroad(amount)
			has = if amount > 0 then Math.sqrt(has) else has*has  #the poor rise faster than the rich, the rich sink faster than the poor
			weightings[i] = has
			totalw += has
		for i in [0 ... @components.length]
			com = @components[i]
			if i == @components.length - 1
				com.scaleBroadForth  amount - amountGiven  #last one gets the remainder to ensure all of the amount has been assigned
			else
				giving = Math.round (weightings[i]/totalw)*amount
				com.scaleBroadForth giving
			com.justTranslateBroadBy amountGiven
			amountGiven += giving
		@longSpan += amount
		return
		
	scaleBroad: (amount)->
		return if amount == 0
		for com in @components
			com.scaleLongForth amount
		@broadSpan += amount
		return
		
	closing: ->
		for comp in @components
			comp.closing()
	canCompressLong: (amount)->
		acc = 0
		for com in @components
			acc += com.canCompressBroad(amount)
			return amount if acc >= amount
		acc
	canCompressBroad: (amount)->
		min = amount
		for com in @components
			min = Math.min(min, com.canCompressLong(amount))
		min
	justTranslateBroadBy: (amount)->
		@broadOrigin += amount
		for com in @components
			com.justTranslateLongBy amount
	justTranslateLongBy: (amount)->
		@longOrigin += amount
		for com in @components
			com.justTranslateBroadBy amount
	justMoveLongForth: (amount)-> @shoveBoundary(@components.length, amount)
	justMoveLongRear: (amount)-> @shoveBoundary(0, amount)
	justMoveBroadForth: (amount)->
		for com in @components
			com.justMoveLongForth amount
		@broadSpan += amount
	justMoveBroadRear: (amount)->
		for com in @components
			com.justMoveLongRear amount
		@broadOrigin += amount
		@broadSpan -= amount
	
	canMoveBoundary: (n, amount)->
		if amount > 0
			remaining = amount
			for i in [n ... @components.length]
				remaining -= @components[i].canCompressBroad(remaining)
				return amount if remaining == 0
			amount - remaining
		else
			remaining = -amount
			for i in [0 ... n]
				remaining -= @components[i].canCompressBroad(remaining)
				return amount if remaining == 0
			amount + remaining
	
	shoveBoundary: (n, amount)-> #assumes there is room to do this (or visibly overflows its bounds)
		return if amount == 0
		if amount > 0
			if n > 0
				@components[n - 1].justMoveBroadForth amount
			else
				@longOrigin += amount
				@longSpan -= amount
			remainsToBeSqueezed = amount
			loop
				if n == @components.length
					@longSpan += remainsToBeSqueezed
					return
				com = @components[n]
				canCompressBy = com.canCompressBroad remainsToBeSqueezed
				com.justMoveBroadRear canCompressBy
				remainsToBeSqueezed -= canCompressBy
				com.justTranslateBroadBy remainsToBeSqueezed
				break if remainsToBeSqueezed == 0
				n += 1
			
		else
			if n < @components.length
				@components[n].justMoveBroadRear amount
			else
				@longSpan += amount
			remainsToBeSqueezed = - amount
			loop
				if n == 0
					@longOrigin -= remainsToBeSqueezed
					@longSpan += remainsToBeSqueezed
					return
				com = @components[n - 1]
				canCompressBy = com.canCompressBroad remainsToBeSqueezed
				com.justMoveBroadForth -canCompressBy
				remainsToBeSqueezed -= canCompressBy
				com.justTranslateBroadBy -remainsToBeSqueezed
				break if remainsToBeSqueezed == 0
				n -= 1
				
		return
	
	tryMoveBoundary: (n, amount)->
		if n == 0 or n == @components.length
			#then it's an outer boundary move, which is to be handled completely differently, deferring to the parent
			if @parent
				if n == 0
					@parent.tryMoveBroadRearBoundary amount
				else
					@parent.tryMoveBroadForthBoundary amount
			else
				#it's the outer bound of the window, this cannot move
				0
		else
			#else we might not have to defer to the parent, and much of the finery is down to us
			internalMovement = @canMoveBoundary n, amount
			if internalMovement == amount
				@shoveBoundary n, internalMovement
				amount
			else
				remaining = amount - internalMovement
				if @parent
					parentMovedBy = 
						if remaining > 0
							@parent.tryMoveBroadForthBoundary remaining
						else
							@parent.tryMoveBroadRearBoundary remaining
					ultimatelyMovedBy = internalMovement + parentMovedBy
					@shoveBoundary n, ultimatelyMovedBy
					ultimatelyMovedBy
				else
					@shoveBoundary(n, internalMovement)
					internalMovement
	
	tryMoveBroadForthBoundary: (amount)->
		return 0 if amount == 0
		if @parent
			myIndex = @parent.components.indexOf @
			@parent.tryMoveBoundary myIndex + 1, amount
		else
			0
	
	tryMoveBroadRearBoundary: (amount)->
		return 0 if amount == 0
		if @parent
			myIndex = @parent.components.indexOf @
			@parent.tryMoveBoundary myIndex, amount
		else
			0
	
	tryMoveLongForthBoundary: (amount)->
		return 0 if amount == 0
		@tryMoveBoundary(@components.length, amount)
	
	tryMoveLongRearBoundary: (amount)->
		return 0 if amount == 0
		@tryMoveBoundary(0, amount)
	
	forAllTiles: (f)-> for com in @components
		tileOrLine com, f, (line)-> line.forAllTiles f
		return





class Tile extends Component
	closing: ->
		@content.onClose()
	opening: ->
		@content.onOpen()
	resized: -> #this will only fire on window resizes right now, you'll have to badger mako if you want this finished
		@content.onResize()
	
	constructor: (@content, @tray, parent, isHorizontal, broadOrigin, longOrigin, broadSpan, longSpan, @minBroad = minimumTileSpan, @minLong = minimumTileSpan)-> #do not construct, use Mount.boxTile
		@tray.appendChild @content.el
		@content.tileHolder = @
		super parent, isHorizontal, broadOrigin, longOrigin, broadSpan, longSpan
		ori = keysForOrientation !@isHorizontal
		otherOri = keysForOrientation @isHorizontal
		@tray.style[ori.rear] = @broadOrigin + 'px'
		@tray.style[otherOri.rear] = @longOrigin + 'px'
		@tray.style[ori.span] = @broadSpan + 'px'
		@tray.style[otherOri.span] = @longSpan + 'px'
	
	replaceContent: (newContent)-> #returns the old content
		#TODO animate
		@tray.removeChild @content.el
		@tray.appendChild newContent.el
		oldContent = @content
		@content = newContent
		newContent.tileHolder = @
		oldContent
	
	canCompressLong: (amount)->
		Math.min(amount, Math.max(@longSpan - @minLong, 0))
	canCompressBroad: (amount)->
		Math.min(amount, Math.max(@broadSpan - @minBroad, 0))
	justTranslateBroadBy: (amount)->
		@setBroadOrigin @broadOrigin + amount
	justTranslateLongBy: (amount)->
		@setLongOrigin @longOrigin + amount
	setLongOrigin: (@longOrigin)->
		feild = keysForOrientation(@isHorizontal).rear
		value = @longOrigin + 'px'
		@tray.style[feild] = value
	setLongSpan: (@longSpan)->
		feild = keysForOrientation(@isHorizontal).span
		value = @longSpan + 'px'
		@tray.style[feild] = value
	setBroadOrigin: (@broadOrigin)->
		feild = keysForOrientation(!@isHorizontal).rear
		value = @broadOrigin + 'px'
		@tray.style[feild] = value
	setBroadSpan: (@broadSpan)->
		feild = keysForOrientation(!@isHorizontal).span
		value = @broadSpan + 'px'
		@tray.style[feild] = value
	justMoveLongForth: (amount)->
		@setLongSpan @longSpan + amount
	justMoveLongRear: (amount)->
		@setLongOrigin @longOrigin + amount
		@setLongSpan @longSpan - amount
	justMoveBroadForth: (amount)->
		@setBroadSpan @broadSpan + amount
	justMoveBroadRear: (amount)->
		@setBroadOrigin @broadOrigin + amount
		@setBroadSpan @broadSpan - amount
	
	scaleLongForth: (amount)-> @justMoveLongForth amount
	scaleBroadForth: (amount)-> @justMoveBroadForth amount
	scaleLongRear: (amount)-> @justMoveLongRear amount
	scaleBroadRear: (amount)-> @justMoveBroadRear amount
	
	forAllTiles: (f)-> f @
	
	tryMoveBroadForthBoundary: (amount)->
		return 0 if amount == 0
		if @parent
			myIndex = @parent.components.indexOf @
			@parent.tryMoveBoundary myIndex + 1, amount
		else
			0
	
	tryMoveBroadRearBoundary: (amount)->
		return 0 if amount == 0
		if @parent
			myIndex = @parent.components.indexOf @
			@parent.tryMoveBoundary myIndex, amount
		else
			0
	
	tryMoveLongForthBoundary: (amount)->
		return 0 if amount == 0
		if @parent
			@parent.tryMoveBroadForthBoundary(amount)
		else
			0
	
	tryMoveLongRearBoundary: (amount)->
		return 0 if amount == 0
		if @parent
			@parent.tryMoveBroadRearBoundary(amount)
		else
			0
