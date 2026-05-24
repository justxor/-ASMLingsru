; ============================================================================
; EXAMPLE 05 — Stack: PUSH, POP, обмен значениями
; ----------------------------------------------------------------------------
; Стек — память, организованная как LIFO (Last-In, First-Out).
; Состоит из сегмента SS и указателя вершины SP.
;
; PUSH ax:
;   SP = SP - 2
;   [SS:SP] = AX
;
; POP bx:
;   BX = [SS:SP]
;   SP = SP + 2
;
; Классический трюк: обмен значениями через стек, без вспомогательного регистра.
; (хотя есть прямая инструкция XCHG, см. упражнение 24 в asmlings).
;
; Начало:  AX = 0xAAAA, BX = 0xBBBB
; Конец:   AX = 0xBBBB, BX = 0xAAAA
;
; Ассерты:
;   ASSERT_REG: AX == 0xBBBB
;   ASSERT_REG: BX == 0xAAAA
; ============================================================================

global _start
section .text

_start:
    mov ax, 0xAAAA
    mov bx, 0xBBBB

    push ax             ; стек: [AAAA]
    push bx             ; стек: [BBBB, AAAA]   <- вершина BBBB

    pop  ax             ; AX = BBBB, стек: [AAAA]
    pop  bx             ; BX = AAAA, стек пустой

    hlt
