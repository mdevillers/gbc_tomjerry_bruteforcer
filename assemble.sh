filename=$(basename $1 .asm)

nasm -felf64 -O0 -g $filename.asm
ld -g -o $filename $filename.o
rm $filename.o

# filenameO0=$filename'_O0'
# cp $filename.asm $filenameO0.asm
# nasm -felf64 -O0 $filenameO0.asm
# ld -s -o $filenameO0 $filenameO0.o
# rm $filenameO0.o $filenameO0.asm

# filenameO1=$filename'_O1'
# cp $filename.asm $filenameO1.asm
# nasm -felf64 -O1 $filenameO1.asm
# ld -s -o $filenameO1 $filenameO1.o
# rm $filenameO1.o $filenameO1.asm

# filenameOx=$filename'_Ox'
# cp $filename.asm $filenameOx.asm
# nasm -felf64 -Ox $filenameOx.asm
# ld -s -o $filenameOx $filenameOx.o
# rm $filenameOx.o $filenameOx.asm

