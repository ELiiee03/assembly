.model small
.stack 100h

.data
  tasks db 3, 1, 2, 4, 5           ; Tasks with arrival times
  n_tasks equ ($ - tasks)           ; Number of tasks
  burst_times db 10, 5, 8, 2, 6    ; Burst times for tasks
  total_time dw 0                   ; Total time (16-bit word)

.code
 _start:
  mov ax, @data                     ; Remove '@' for segment access
  mov ds, ax                        ; Move segment address to DS

  mov cx, n_tasks                    ; Initialize loop counter
  lea si, tasks                      ; Point to the tasks array
  lea di, burst_times                 ; Point to the burst times array
  mov bx, offset total_time          ; Point to the total time variable (offset for 16-bit)
  xor ax, ax                         ; Clear accumulator register

schedule_loop:
  ; Find the task with the earliest arrival time
  mov al, [si]                        ; Load current task arrival time
  cmp al, [si + 1]                    ; Compare with next task arrival time
  jg skip_task_swap                   ; Jump if next task arrives earlier
  xchg al, [si + 1]                    ; Swap arrival times
  xchg al, [si]                        ; Swap tasks
  mov al, [di]                        ; Swap burst times
;   mov [di], [di + 1]
  mov [di + 1], al

skip_task_swap:
  inc si                              ; Move to the next task arrival time
  add di, 1                           ; Move to the next burst time
  loop schedule_loop                  ; Repeat for all tasks

; Execute tasks in non-preemptive manner
lea si, tasks                       ; Reset task pointer
lea di, burst_times                  ; Reset burst times pointer
mov ax, [si]                         ; Load first task arrival time (16-bit for total time)
mov [bx], ax                         ; Store total time
add ax, [di]                         ; Add first task's burst time to total time
mov [bx], ax                         ; Store updated total time
inc si                              ; Move to the next task
inc di                              ; Move to the next burst time
dec cx                              ; Decrement loop counter

execute_tasks:
  cmp cx, 0                           ; Check if all tasks executed
  je done                             ; Jump to done if all tasks executed
  mov ax, [si]                         ; Load current task arrival time
  cmp ax, [bx]                         ; Compare with total time
  jg skip_task_execution              ; Jump if task has not arrived yet
  add ax, [di]                         ; Add task's burst time to total time
  mov [bx], ax                         ; Store updated total time
  inc si                              ; Move to the next task
  inc di                              ; Move to the next burst time

skip_task_execution:
  loop execute_tasks                  ; Repeat for all tasks

done:
  ; Print result
  mov ah, 09h                       ; DOS function for printing string (INT 21h, AH=09h)
  lea dx, result_msg                ; Load address of result message (using offset)
  int 21h                           ; Call DOS interrupt

  ; Error checking for printing
  jc error_printing                 ; Jump if carry flag set (error occurred)
  jmp end_program                   ; Jump to end of program if printing successful

error_printing:
  ; Error occurred while printing
  mov ah, 09h                       ; Print error message
  lea dx, error_msg                 ; Load address of error message
  int 21h                           ; Call DOS interrupt

end_program:
  ; End of program
  mov ax, 4C00h                     ; DOS function to terminate program
  int 21h                           ; Call DOS interrupt

result_msg db "Tasks executed successfully!$"
error_msg db "Error occurred while printing!$"

end
