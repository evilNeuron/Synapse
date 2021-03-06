; Hyperion 64-Bit container.exe

include 'image_base.inc'
format PE64 GUI 5.0 at IMAGE_BASE
entry start

include '..\..\..\Fasm\INCLUDE\win64a.inc'
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

start:
	 sub rsp,8
	 fastcall MainMethod
	 test rax,rax
	 jz the_end_my_friend
	 ;file was loaded, execute it
	 add rsp,8
	 jmp rax
the_end_my_friend:
	 invoke ExitProcess,0

proc MainMethod
	 local str1[256]:BYTE,\
	 APITable:QWORD,\
	 CreateFileMapping_:QWORD,\
	 MapViewOfFile_:QWORD,\
	 UnmapViewOfFile_:QWORD,\
	 CreateFile_:QWORD,\
	 CloseHandle_:QWORD,\
	 DeleteFile_:QWORD,\
	 GetModuleHandle_:QWORD,\
	 VirtualAlloc_:QWORD,\
	 VirtualProtect_:QWORD,\
	 VirtualFree_:QWORD,\
	 RetVal:QWORD

	 ;pointer to the API table
	 lea rax,[CreateFileMapping_]
	 mov [APITable],rax

	 ;load APIs for log file access
	 fastcall loadLogAPIs,[APITable]
	 test rax,rax
	 jz main_exiterrornolog

	 ;create logfile and write initial message into it
	 initLogFile APITable
	 test rax,rax
	 jz main_exiterrornolog

	 ;load all necessary APIs
	 fastcall loadRegularAPIs, [APITable]
	 test rax,rax
	 jz main_exiterror
	 writeNewLineToLog APITable
	 test rax,rax
	 jz main_exiterror

	 ;decrypt exe in data section
	 fastcall decryptExecutable, [APITable], encrypted_infile
	 test rax,rax
	 jz main_exiterror

	 ;load the executable at its image base
	 ;(this will overwrite current MZ header and bss section)
	 fastcall loadExecutable, [APITable], encrypted_infile
	 test rax,rax
	 jz main_exiterror

	 ;start program execution
	 mov rdx,IMAGE_BASE
	 xor rax,rax
	 mov eax,[rdx+IMAGE_DOS_HEADER.e_lfanew]
	 add rax,rdx
	 add rax,4
	 ;image file header now in eax
	 add rax,sizeof.IMAGE_FILE_HEADER
	 xor rdx,rdx
	 mov edx,[rax+IMAGE_OPTIONAL_HEADER64.AddressOfEntryPoint]
	 mov rax,IMAGE_BASE
	 add rdx,rax
	 ;entry point of original exe is now in rdx
	 mov [RetVal],rdx

;finished without errors
main_exitsuccess:
	 writeNewLineToLog APITable
	 createStringDone str1
	 lea rax,[str1]
	 writeLog APITable, rax
	 mov rax,[RetVal]
	 jmp main_exit

;finished with errors after logfile API loading
main_exiterror:
	 writeNewLineToLog APITable
	 createStringError str1
	 lea rax,[str1]
	 writeLog APITable, rax
	 sub rax,rax

main_exit:
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
