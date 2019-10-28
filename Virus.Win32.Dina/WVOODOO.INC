NULL = 0
; GlobalAlloc flags
GMEM_FIXED      =   0000h
GMEM_MOVEABLE   =   0002h
GMEM_NOCOMPACT  =   0010h
GMEM_NODISCARD  =   0020h
GMEM_ZEROINIT   =   0040h
GMEM_MODIFY     =   0080h
GMEM_DISCARDABLE=   0100h
GMEM_NOT_BANKED =   1000h
GMEM_DDESHARE   =   2000h
GMEM_SHARE      =   2000h
GMEM_NOTIFY     =   4000h
GMEM_LOWER      =   GMEM_NOT_BANKED
GHND            =   GMEM_MOVEABLE+GMEM_ZEROINIT
GPTR            =   GMEM_FIXED+GMEM_ZEROINIT
;-----------
 FILE_ATTRIBUTE_READONLY     =    00000001h
 FILE_ATTRIBUTE_HIDDEN       =    00000002h
 FILE_ATTRIBUTE_SYSTEM       =    00000004h
 FILE_ATTRIBUTE_DIRECTORY    =    00000010h
 FILE_ATTRIBUTE_ARCHIVE      =    00000020h
 FILE_ATTRIBUTE_NORMAL       =    00000080h
 FILE_ATTRIBUTE_TEMPORARY    =    00000100h
;-----------
FILE_FLAG_WRITE_THROUGH         = 80000000h
FILE_FLAG_OVERLAPPED            = 40000000h
FILE_FLAG_NO_BUFFERING          = 20000000h
FILE_FLAG_RANDOM_ACCESS         = 10000000h
FILE_FLAG_SEQUENTIAL_SCAN       = 08000000h
FILE_FLAG_DELETE_ON_CLOSE       = 4000000h
FILE_FLAG_BACKUP_SEMANTICS      = 02000000h
FILE_FLAG_POSIX_SEMANTICS       = 01000000h

;------------------------
CREATE_NEW         = 1
CREATE_ALWAYS      = 2
OPEN_EXISTING      = 3
OPEN_ALWAYS        = 4
TRUNCATE_EXISTING  = 5

;-----------
GENERIC_READ               = 80000000h
GENERIC_WRITE              = 40000000h
FILE_SHARE_READ            = 00000001h
FILE_SHARE_WRITE           = 00000002h
;-----------
 PAGE_NOACCESS          = 01h
 PAGE_READONLY          = 02h
 PAGE_READWRITE         = 04h
 PAGE_WRITECOPY         = 08h
 PAGE_EXECUTE           = 10h
 PAGE_EXECUTE_READ      = 20h
 PAGE_EXECUTE_READWRITE = 40h
 PAGE_EXECUTE_WRITECOPY = 80h
 PAGE_GUARD             = 100h
 PAGE_NOCACHE           = 200h
;-------------------
FILE_MAP_WRITE = 2
FILE_MAP_READ  = 4
;-------------------
 NORMAL_PRIORITY_CLASS      = 00000020h
 IDLE_PRIORITY_CLASS        = 00000040h
 HIGH_PRIORITY_CLASS        = 00000080h
 REALTIME_PRIORITY_CLASS    = 00000100h
;--------------------
EXCEPTION_DEBUG_EVENT      = 1
CREATE_THREAD_DEBUG_EVENT  = 2
CREATE_PROCESS_DEBUG_EVENT = 3
EXIT_THREAD_DEBUG_EVENT    = 4
EXIT_PROCESS_DEBUG_EVENT   = 5
LOAD_DLL_DEBUG_EVENT       = 6
UNLOAD_DLL_DEBUG_EVENT     = 7
OUTPUT_DEBUG_STRING_EVENT  = 8
RIP_EVENT                  = 9
;--------------------
PROCESS_ALL_ACCESS  =   0F0000h or 00100000h or 0FFFh
;--------------------locals
        extrn   MessageBoxA:PROC
        extrn   Sleep:PROC
        extrn   ExitProcess:PROC
        extrn   CreateThread:PROC
        extrn   GetLastError:PROC
        extrn   GetModuleHandleA:PROC
        extrn   ExitProcess:PROC
        extrn   GetProcAddress:PROC
        extrn   GetModuleHandleA:PROC
        extrn   GetCurrentThread:PROC
        extrn   VirtualProtectEx:PROC
        extrn   DebugActiveProcess:Proc
        extrn   OpenProcess:PROC
        extrn   WriteProcessMemory:PROC
        extrn   SuspendThread:PROC
        extrn   GetCurrentProcessId:PROC
        extrn   LoadLibraryA:PROC
        extrn   MessageBoxA:PROC
        extrn   MessageBeep:PROC
        extrn   GlobalAlloc:PROC ; retern HGLOBAL
                ; UINT Flags  object allocation attributes
                ; DWORD dwBytes mumber of bytes to allocate
        extrn   GlobalLock:PROC ;Pointer to mem
                ; HGLOBAL hMem address of global memory object
        extrn   GlobalUnlock:PROC
                ; HGLOBAL hMem address of global memory object
        extrn   GlobalFree:PROC
                ;HGlobal hMem handle to the global memory object
     ;---- file mapping --------------------------------------
      extrn CreateFileA:PROC
     ;Retern HANDLE
     ;Parametrs:    LPCTSTR :LpFileName
     ;              DWORD   :dwDesiredAccess (read-write)
     ;              DWORD   : dwShareMode
     ; LPSECURITY_ATTRIBTES :LpSecurityAttrib address of security descriptor
     ;              DWORD   :dwCreationDistribution //how to creat
     ;              DWORD   :dwFlagsAndAttributes
     ;             HANDLE   :hTemplateFile //handle of file with attrib to copy
     extrn CreateFileMappingA:PROC
     ;Retern HANDLE
     ; PARAMMETRS    HANDLE :hfile    //handle of file map
     ;  LpSecurity_Attributes LpFileMappingAttributes //optional security attrib
     ;  Dword  :flProtect
     ;  Dword  :dwMaxSizeHigh
     ;  Dword  :dwMaxSizeLow
     ; LPCTSTR :lpName //name of file-mapping object
     extrn MapViewOfFile:PROC ;(hFileMappingObject:HANDLE,
                              ;  dwDesiredAccess:dw,
                              ;  dwFileOffsetHigh,
                              ;  dwFileOffsetLow,
                              ;  dwNumberOfBytesToMap)
     ;
     ;
     ;
     extrn UnmapViewOfFile:PROC
     extrn CloseHandle:PROC
     extrn FlushViewOfFile:PROC;(LpBaseAddress,dwNumberOfBytesToFlush)
    ;--------------------------------------------------------
     extrn GetFileSize:PROC ; (hFile,LPDWORD LpFileSizeHigh)
     extrn CopyFileA:PROC ;(LpExistingFileName,LpNewFileName)
     extrn ReadFile:PROC  ;(hFile,LpBuffer,nMumberOfBytesToRead,
     ;                    LpNumberOfBytesRead,LpOverlapped)
     extrn DeleteFileA    :PROC;(LpFileName)
     extrn GetLastError  :PROC;
     extrn CreateProcessA:PROC;
     extrn CreateProcessW:PROC;
     extrn CreateFileW:PROC;
     extrn GetStartupInfoA:PROC;
     extrn GetCommandLineA:PROC;
     extrn lstrcpyA:PROC;
     extrn   FindFirstFileA:PROC
     extrn   FindNextFileA:PROC
     extrn   Sleep:PROC ;(dwMilliseconds)
     extrn SetFileAttributesA:PROC;(LpFileName,dwFileAttributes)
     extrn SetFileTime:PROC;
     extrn SetCurrentDirectoryA:PROC;
     extrn GetCurrentDirectoryA:PROC;
     extrn GetExitCodeProcess:PROC;
     extrn GetSystemTime:PROC;