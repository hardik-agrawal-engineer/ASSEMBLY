global _start  ;This line tells (assembler and linker) this is the starting point of the total code

section .bss  ;The bss = block started by symbol , It is used to store unintialized data and variable
    buffer resb 32  ; The word buffer is used as variable name here 
    output resb 32  ; resb 32 means reserve 32 byte for this variable
    num1 resq 1
    num2 resq 1     ; resq 1 means reserve 1 quad word (8 byte)
    operation resb 2

section .data  ;The data block is used to store the initialized data in variable like given below
    label_1 db "Enter first number: ", 0  ;label_1 is the varibale name , db is declare byte meaning every element size would be 1 byte 
    label_1_len equ $ - label_1           ;equ means equate and it give a value to variable
                                                ; $ return the current memory adress and mathematically substract with the label_1 
                                                ; starting memory address eventually giving us the size of label_1.
    label_2 db "Enter operation (+, -, *, /): ", 0 ; Here the 0 is used to tell the cpu that the entry of the element has completed
    label_2_len equ $ - label_2                    ; Now terminate the program by 0 

    label_3 db "Enter second number: ", 0
    label_3_len equ $ - label_3

    result_msg db "Result: ", 0
    result_msg_len equ $ - result_msg




section .text ; the text block is used to store the actual cpu execution commands
    _start:  ; It tells the assembler and linker  that the cpu instructions start from here (like main() in c)
        ;Getting num1
        mov rsi, label_1  ; moving the label_1 into the rsi register inside the cpu
        mov rdx, label_1_len
        call print  ;Here we called a function named print which is written above
        call input
        call parse_it_to_integer
        mov [num1], rax 
        
        ;Getting the operation character
        mov rsi, label_2
        mov rdx, label_2_len
        call print
        mov eax, 0
        mov edi, 0
        mov rsi, operation
        mov rdx, 2
        syscall
        
        ; Getting num2 
        mov rsi, label_3
        mov rdx, label_3_len
        call print
        call input
        call parse_it_to_integer
        mov [num2], rax
        
        ;math begins
        mov rax,  [num1]
        mov rbx, [num2]
        mov cl, [operation]
        cmp cl, '+'
        je .add
        cmp cl, '-'
        je .sub
        cmp cl, '*'
        je .mul
        cmp cl, '/'
        je .div

        ;Funtion defintion in side the main block
        .add:
            add rax, rbx
            call result
        .sub:
            sub rax, rbx
            call result
        .mul:
            imul rax, rbx
            call result
        .div: ; this div will just remove the floating as it is now made for the integer values
            mov rdx, 0
            idiv rbx
            call result
        

;Now after writing a function without dot in starting gets out of the previous block.
print: 
    mov eax, 1    ; assembly convention for telling the linux kernel to print some thing (telling os to what to do)
    mov edi, 1    ; it for giving stdout means (Where to do it) like the terminal
    syscall       ; it is to call the linux kernel to read the register and do according to the convention
    ret           ; it wor return to the place where the call function was called
input:
    mov eax, 0    ;Assembly convention for telling the linux kernel to take input(what to do)
    mov edi, 0    ; it is for giving stdin like in the c (where to do)
    mov rsi, buffer ; Rsi will store the value of the input
    mov edx, 32
    syscall
    ret
parse_it_to_integer: ;This is the function to convert the string input to string
    xor rax, rax
    xor rcx, rcx
    .parse_loop:
        mov cl, [rsi]
        cmp cl, 10
        je .parse_done
        cmp cl, 0
        je .parse_done
        sub cl, '0'
        imul rax, rax,10
        add rax, rcx
        inc rsi
        jmp .parse_loop
    .parse_done:
        ret
print_as_string: ; This function will change the integer to the string so that linux could print it
    mov rbx, 10
    xor rcx, rcx
    .c_loop:
        xor rdx, rdx
        div rbx
        add dl, '0'
        push rdx
        inc rcx
        test rax, rax ;Performs bitwise AND operation and checks that rax has the 0 or another value
        jnz .c_loop ;jnz means jump if not equal to zero
        mov rsi, output
        mov rbx, rsi
    .pop_loop:
        pop rdx
        mov [rsi], dl
        inc rsi
        loop .pop_loop    
        mov byte [rsi], 10 ;This line works as new line character like in the c
        inc rsi
        mov rdx, rsi
        sub rdx, rbx
        mov rsi, rbx
        call print
        ret
result:
    push rax
    mov rsi, result_msg
    mov rdx, result_msg_len
    call print
    pop rax
    call print_as_string
    mov eax, 60 ;To tell the linux kernel to terminate the program
    xor edi,edi
    syscall