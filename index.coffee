
intMultiplication = Math.imul || (a, b)->
  ah  = (a >>> 16) & 0xffff
  al = a & 0xffff
  bh  = (b >>> 16) & 0xffff
  bl = b & 0xffff
  ((al * bl) + (((ah * bl + al * bh) << 16) >>> 0)|0)


mouseEvRelTo = (ev, el)->
	cr = el.getBoundingClientRect()
	{
		x: ev.pageX - cr.left
		y: ev.pageY - cr.top
	}

class NonDirectlyRepeatingRNG
	lcg = (v)->
		(intMultiplication(v,22695477) + 1)|0
	takeRn: ->
		@state = lcg(@state)
		Math.abs(@state) % @n
	constructor: (@n, @state = 432)->
		@previous = @state % @n
	next: ->
		@previous = (@previous + 1 + (@takeRn() % (@n - 1))) % @n
		


window.onload = ->
	
	shadegen = new ShadeGenerator()
	
	centering = (el)-> #====___________====
		rootc = document.createElement 'div'
		rootc.classList.add 'tilingjs_filling'
		rootc.style.display = 'table'
		rootc.style['text-align'] = 'center'
		rootc.style['line-height'] = '0px' # ==============__________________________________________==============
		innec = document.createElement 'div'
		innec.style.display = 'table-cell'
		innec.style['vertical-align'] = 'middle'
		rootc.appendChild innec
		el.style.display = 'inline-block'
		innec.appendChild el
		rootc
	
	genStdDiv = ->
		el = document.createElement 'div'
		el.classList.add 'tilingjs_filling'
		el.style.backgroundColor = shadegen.takeColor()
		el
	
	#gens return a tilePack( {el:the element, onResize, onClose, onOpen} )
	tileVariants = [
		{ called:'Help Message', gen: ->
			el = genStdDiv()
			el.innerHTML ="""
				You can move and resize tiles by middle clicking and dragging. Dragging from the center will move, dragging a corner will resize.
				You can create tiles by pressing alt+c<br>
				You can banish tiles by pressing alt+b<br>
			"""
			el.style.padding = '7px'
			content el
		}
		{ called:'Title', gen: ->
			el = genStdDiv()
			el.textContent = 'tiling.js'
			el.style.lineHeight = '100%'
			el.style.padding = '4px'
			el.classList.add 'title'
			content el
		}
		{ called:'About', gen: ->
			el = genStdDiv()
			el.style.padding = '7px'
			h = document.createElement 'h2'
			h.textContent = "What is tiling.js?"
			el.appendChild h
			el.appendChild document.createTextNode """
				A tiling window manager for web applications
			"""
			content el
		}
		{ called:'Empty', gen: -> content genStdDiv()
		}
		{ called:'Logo', gen: ->
			img = document.createElement 'img'
			img.src = 'roundlogo.png'
			cenel = centering img
			cenel.style.backgroundColor = shadegen.takeColor()
			content cenel
		}
	]
	tileVariantMatchSet = matchset tileVariants.map((o)-> [o.called, o.gen]), null, true
	tileFor = (called)->
		for tv in tileVariants
			if tv.called == called
				return tv.gen()
		return null
	
	class StemContent extends @TileContent
		constructor: ->
			input = document.createElement 'input'
			input.addEventListener 'mouseover', => input.focus()
			@input = input
			stemback = document.createElement 'div'
			stemback.classList.add 'stemtile', 'tilingjs_filling'
			stemback.style.backgroundColor = shadegen.takeColor()
			stemback.appendChild input
			@el = stemback
			@au = attachAutocompletion {
				input: input
				matchset: tileVariantMatchSet
				matchCallback: (gen)=>
					newContent = gen()
					@onClose()
					@tileHolder.replaceContent newContent
					newContent.onOpen()
				firesOnSpace: true
				erasesOnEscape: true
			}
		onOpen: -> @input.focus()
		onClose: -> @au.detach()
	
	containts = document.getElementById('containts')
	
	m = mount {
		container: containts
		defaultContentGenerator: -> new StemContent
		initial:
			widthBeing(
				upto( 629,
					line(
						line(
							position {
								content: tileFor 'Logo'
								desiredWidth: 77
								desiredHeight: 77
							}
							tileFor 'Title'
						)
						position {
							content: tileFor 'About'
							desiredHeight: 110
						}
						tileFor 'Help Message'
					)
				)
				upto(
					line(
						line(
							position {
								content: tileFor 'Logo'
								desiredWidth: 77
								desiredHeight: 77
							}
							tileFor 'Title'
						)
						line(
							tileFor 'About'
							tileFor 'Help Message'
						)
					)
				)
			)
		
		
	}
	@mounting = m