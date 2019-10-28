; User procedures. Currently just one procedure, that initialises table
; permutation.

UserProc_InitTables	proc
	push	esi
	lea	edi,[Tbls][ebp]

	lea	esi,[VTbl][ebp]
	mov	ecx,VTbll
	Call	TravelJmpTable

	lea	esi,[GarbTbl][ebp]
	mov	ecx,GarbLen
	Call	TravelJmpTable

	lea	esi,[OpTbl][ebp]
	Call	TravelOpTable
	lea	esi,[DataTbl][ebp]
	Call	TravelOpTable
	lea	esi,[MutTbl][ebp]
	Call	TravelOpTable
	pop	esi
	ret
UserProc_InitTables	endp

