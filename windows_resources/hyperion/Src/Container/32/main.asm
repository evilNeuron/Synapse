; Hyperion 32-Bit container.exe

include 'image_base.inc'
format PE GUI 4.0 at IMAGE_BASE
entry start

include '..\..\..\Fasm\INCLUDE\win32a.inc'
include 'hyperion.inc'
include 'createstrings.inc'
include 'pe.inc'
;automatically generated by hyperion cpp stub
include 'key_size.inc'
include 'infile_size.inc'
include 'image_size.inc'
;---

;this contains the decrypted and loaded executable
section '.bss' data readable writeable

decrypted_infile: db IMAGE_SIZE dup (?)

;--------------------------------------------------

;this contains the encrypted exe
section '.data' data readable writeable

encrypted_infile: include 'infile_array.inc'

;--------------------------------------------------

section '.text' code readable executable

;include necessary functions
include 'logfile_select.asm'
include 'loadapis.asm'
include 'loadexecutable.asm'
;automatically generated by hyperion cpp stub
include 'decryption_payload.asm'
;---

start:	 stdcall MainMethod
	 invoke ExitProcess,0

proc MainMethod stdcall
	 local str1[256]:BYTE,\
	 APITable:DWORD,\
	 CreateFileMapping_:DWORD,\
	 MapViewOfFile_:DWORD,\
	 UnmapViewOfFile_:DWORD,\
	 CreateFile_:DWORD,\
	 CloseHandle_:DWORD,\
	 DeleteFile_:DWORD,\
	 GetModuleHandle_:DWORD,\
	 VirtualAlloc_:DWORD,\
	 VirtualProtect_:DWORD,\
	 VirtualFree_:DWORD

	 ;pointer to the API table
	 lea eax,[CreateFileMapping_]
	 mov [APITable],eax

	 ;load APIs for log file access
	 stdcall loadLogAPIs,[APITable]
	 test eax,eax
	 jz main_exiterrornolog

	 ;create logfile and write initial message into it
	 initLogFile APITable 
	 test eax,eax
	 jz main_exiterrornolog

	 ;load all necessary APIs
	 stdcall loadRegularAPIs, [APITable]
	 test eax,eax
	 jz main_exiterror
	 writeNewLineToLog APITable
	 test eax,eax
	 jz main_exiterror

	 ;decrypt exe in data section
	 stdcall decryptExecutable, [APITable], encrypted_infile
	 test eax,eax
	 jz main_exiterror

	 ;load the executable at its image base
	 ;(this will overwrite current MZ header and bss section)
	 stdcall loadExecutable, [APITable], encrypted_infile
	 test eax,eax
	 jz main_exiterror

	 ;start program execution
	 mov edx,IMAGE_BASE
	 mov eax,[edx+IMAGE_DOS_HEADER.e_lfanew]
	 add eax,edx
	 add eax,4
	 ;image file header now in eax
	 add eax,sizeof.IMAGE_FILE_HEADER
	 mov eax,[eax+IMAGE_OPTIONAL_HEADER32.AddressOfEntryPoint]
	 add eax,IMAGE_BASE
	 ;entry point of original exe is now in eax
	 jmp eax

;finished without errors
main_exitsuccess:
	 writeNewLineToLog APITable
	 createStringDone str1
	 lea eax,[str1]
	 writeLog APITable, eax
	 ret

;finished with errors after logfile API loading
main_exiterror:
	 writeNewLineToLog APITable
	 createStringError str1
	 lea eax,[str1]
	 writeLog APITable, eax
	 ret

;finished with errors before logfile API loading
main_exiterrornolog:
	 ret

endp

;import table
section '.idata' import data readable writeable

	 library kernel,'KERNEL32.DLL'

	 import kernel,\
	    GetProcAddress,'GetProcAddress',\
	    LoadLibrary,'LoadLibraryA',\
	    ExitProcess,'ExitProcess'
