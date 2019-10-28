
 ======================================================================
 =============[ LOW METAMORPHIC (PERMUTATION) ENGINE ]=================
 ==================[ BI-PERM ]===========[ v0.2 ]======================
 ==================[ WRITTEN BY MALUM  02.12.07 ]======================
 ======================================================================

 History:
 0.0 - first release
 0.1 - fixed bug, procedure 'permutate' doesn't return size of output code

 src - directory with sources of engine
 inc - directory with assembler's include files 
 demo - demonstartion program of BI-PERM

 BI-PERM is permutation engine. BI-PERM allows you to write your own
 plugins to engine like it was made in RPME (respect, z0mbie :)). You
 can rewrite routines of mutator or disassember without any troubles.
 You can also use standard procedures if you don't want to code new.

 For more datails about usage of engine see comments in source directory
 and read demo.

 files:

 [src]
 permutator.asm - main engine
 mutate.asm     - standard mutation routine
 disasm.asm     - standard disassembler (it calls virxasm32 length-disasm)

 [inc]
 ...the same files as in src directory (in binary format)...
 virxasm32b.inc - binary virxasm32 length-disasm (edit B without data, only code)

 [demo]
 cmd.bat        - make script to build demo (tasm32, ulink (tlink alike linker))
 pdemo.ex~      - compiled demo
 pdemo.asm      - source of demo
 macros.inc     - some usefull macros


 greetings to pri0rity, roy_g_biv, rumi.13
 ----------------------------------
 Mail me, please, if you found bug.
 If you have questions than mail me too and I certainly will try to give answer.
 And I'm sorry I speak English not very well.
 (X) Malum 02.12.07 - malum@mail.ru

; =======[
; ==========================[
; ===============================================[

