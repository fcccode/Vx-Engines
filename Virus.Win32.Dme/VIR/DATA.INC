xSrc		dd	?
xDst		dd	?
xBase		dd	?
xAddOffset	dd	?
xPos		dd	?

incheck		db	?
RegMask		dd	?

NoGen		db	?

MaxMorph	dd	?

BlockNum	dd	?
Datan		dd	?
Jmpn		dd	?
Tbln		dd	?

Blocks		dd	2*MaxBlocks	dup (0)

Jumps		dd	2*MaxJumps	dup (0)

Datas		dd	2*MaxData	dup (0)

Tbls		dd	2*MaxTbls	dup (0)

