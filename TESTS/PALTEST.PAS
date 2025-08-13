begin
  asm
    mov dx,3c8h
    xor al,al
    out dx,al
    mov cx,3*16
    inc dx
  @@1:
    mov al,000h
    out dx,al
    mov al,03fh
    out dx,al
    mov al,000h
    out dx,al
    DB 0EBh,000h,0EBh,000h
    dec cx
    jnz @@1
  end;
  readLn;
  asm
    mov ax,0003h
    int 10h
  end;
end.
