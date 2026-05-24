; =========================================================
; 13_strcmp.asm — сравнение двух строк через CMPSB
; =========================================================
; CMPSB сравнивает [DS:SI] с [ES:DI], выставляет флаги как SUB,
; затем сдвигает SI и DI на ±1 по DF.
;
; REPE — повторять пока ZF=1 (равны) и CX>0.
; Если после REPE CMPSB ZF=1 — строки равны.
;
; Аналог на C:
;   int memcmp(const char *a, const char *b, size_t n);
; =========================================================

section .data
    s1: db 'ASMLings'
    s2: db 'ASMLings'
    s3: db 'ASMl1ngs'        ; отличается на 4-й позиции

section .text
    cld                  ; идём вперёд

    ; --- сравниваем s1 и s2 ---
    mov si, s1
    mov di, s2
    mov cx, 8
    repe cmpsb           ; побайтовое сравнение
    pushf                ; сохраним флаги в стек
    pop ax               ; AX = флаги
    and ax, 0x40         ; выделим ZF (бит 6)
    mov bx, ax           ; BX = ZF после равных строк (0x40)

    ; --- сравниваем s1 и s3 ---
    mov si, s1
    mov di, s3
    mov cx, 8
    repe cmpsb
    pushf
    pop ax
    and ax, 0x40         ; ZF = 0 → строки разные
    mov dx, ax           ; DX = 0

assert bx == 0x40        ; строки были равны
assert dx == 0           ; строки были разны
