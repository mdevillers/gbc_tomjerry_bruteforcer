## "Tom and Jerry in mouse Attacks" gameboy game password bruteforcer

This program attempt to discover each valid password of the gameboy game "Tom and Jerry in Mouse Attacks".
It iterates and tests the validity of each possible password combination, replicating the checks of the original game. 

## assemble (64-bit only)
```
bash ./assemble.sh bruteforcer.asm
```
or
```
nasm -felf64 -O0 -g bruteforcer.asm
ld -g -o bruteforcer bruteforcer.o
rm bruteforcer.o
```
## output

To display the password levels without duplicates, launch the script <print_passwords.sh>

