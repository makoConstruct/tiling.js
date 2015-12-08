#tiling.js

A tiling window manager for web applications. Tilingjs makes it easy for users to rearrange, banish, or invoke subwindows in your UI. [Take a look at the demo](http://makopool.com/tilingjs/index.html).

###Well, kind of.

The story as it stands: I was thinking of using tiling.js for a commercial project, but somehow a series of sidetracks into projects with greater potential lead me far away from that. About 18 months later, I decided to take a stroll through my old projects, and when I looked at tilingjs I felt guilty for just sitting on it for so long. I would feel much guiltier if I'd kept sitting on it for however long it'll be before it sees the light of day in any of the projects I made it for. The code still looks decent to me, so I decided to open source it.

It's not really ready for end-users yet. Although I love it just the way it is, a thing like this really shouldn't require any instructions to use, as it currently does. Tiles should have some UI component by which the tile can be dragged and moved (conventionally, a title bar, but I'd prefer.. some floating element at the top right corner that can be dragged to move the window and hovered or clicked to bring up Close and Remorph buttons), it should be possible to resize tiles by dragging the borders between them, and there should be a straightforward API for making widgets.. docks,from which new windows can be drawn.

I do think the source and the usage example is quite clear (even if it is coffeescript (yeah I don't stand by that choice. I still think CS is like, objectively the prettiest possible syntax but I wish I'd done it in typescript instead)), so I welcome anyone interested to contribute.