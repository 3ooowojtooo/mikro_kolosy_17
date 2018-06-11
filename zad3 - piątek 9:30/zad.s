.data
	external_loop_counter: .quad 0
	internal_loop_counter: .quad 0
	current_mask_bit: .quad 0

	.equ ascii_zero, '0'
	.equ ascii_nine, '9'
.text
.type encode, @function
.globl encode

encode:
xor %r11, %r11
xor %r12, %r12
xor %r13, %r13
xor %r14, %r14

mov %rdi, %r11 # char * buf
mov %esi, %r12d # unsigned int mask
mov %edx, %r13d # int operation
mov %ecx, %r14d # int character

# przygotowanie rejestrow source i destination. z nich korzystaja polecenia lodsb oraz stosb - doczytaj na necie jesli niejasne
mov %r11, %rsi 
mov %r11, %rdi

external_loop: # petla po 10 najmlodsyzch bitach maski

lodsb # pobranie kolejnej cyfry z char * buf do rejestru %rax

cmp $0, %al # patrzenie czy pobrany kolejny znak nie jest znakiem konca stringu. jesli jest, to nic z nim nie robie
# i koncze program. UWAGA! to jest jedyny warunek stopu w tym zadaniu, bo niby jest powiedziane, ze
# liczy sie tylko 10 bitow maski, ale ja to zrozumialem tak, ze jesli wykorzytsamy juz wszystkie znaczace bity maski,
# to na dlaszych znakach po prostu wykonujemy operacje, bo maska sie nie liczy. nie patrzymy na jej
# kolejne bity. aczkolwiek zadanie jest sformulowane conajmniej dziwnie, wiec ta interpretacja moze nie byc
# prawidlowa ;/
jnz not_end_of_string
stosb
jmp job_done

not_end_of_string:

cmp $9, external_loop_counter # jesli wykorzystalismy juz 10 bitow maski, dalsze jej bity nie maja znaczenia, zgodnie z
# trescia zadania, wiec skaczemy odrazu do operacji
jg operations

#jesli licznik mniejszy lub rowny 9, to dalej musimy uwzgledniac maske

# wyciaganie koljengo bitu z maski
push %r12
push %rcx
mov external_loop_counter, %rcx
shr %cl, %r12
pop %rcx
and $1, %r12 # najmlodszy bit jest teraz w %12
mov %r12, current_mask_bit
pop %r12
# teraz odpowiedni bit jst w zmiennej current_mask_bit, a wykorzystane rejestry maja swoja stara wartosc

cmp $0, current_mask_bit # dany bit rowna sie zero - nie przetwarzamy w zaden sposob cyfry, oddajemy do buf jej stara wartosc
jz external_loop_store_and_next

#dany bit ma wartosc 1, dokonujemy operacji

operations:

#tu taki jakby switch(operation)
cmp $0, %r13
jz operation0
cmp $1, %r13
jz operation1
cmp $2, %r13
jz operation2
cmp $3, %r13
jz operation3

# jesli opearcja ma wartosc inna niz z zakresu 0..3, to wykona sie wersja dla operation = 0
# czyli nic nie robienie ;p

operation0: #nic nie robienie, czyli po prostu oddajemy do buf ten sam znak co pobralismy i wykonujemy petle ponownie
jmp external_loop_store_and_next

operation1: # usuniecie znaku
jmp external_loop_next # wykonujemy nastepny obieg petli, ale uwaga! nie wykonujemy stosb
# w ten wlasnie sposob "ominiemy" daną cyfre w przypadku opeeation = 1

operation2: # transpozycja
push %rbx # pushowanie rejestru pomocniczego, w celu odzyskanie jego dawnej wartosci po operacji
mov %rax, %rbx # w rax (a wlasciwie w jego najmlodszym bajcie al) jest obecny char, ktory pobralismy instrukcja lodsb
sub $ascii_zero, %rbx # przeliczanie cyfry na liczbe, tzn '2' --> 2 ; '1' ---> 1 itd.
mov $ascii_nine, %rax # teraz wystarczy od ascii cyfry '9' odjac powzysza liczbe i zapisac ja w rax
sub %rbx, %rax
pop %rbx # odzyskanie wartosci pomocniczego rejestru rbx
jmp external_loop_store_and_next


#jmp external_loop_store_and_next 

operation3: # podmiana cyfry na character podany jako 4 argument funkcji
mov %r14b, %al # ustawiam rejest al na character, poniewaz to z al stosb wyciaga wartosc, ktora ma zapisac
# do char* buf
jmp external_loop_store_and_next

# uwaga, ciekawy myk: 2 warianty przechodzenia do nowego obiegu funkcji. z zapisywaniem obecnego chara do bufa i bez
# musialem to zrobic, zeby mozliwe bylo pomijanie zapisywania chara, czyli tak naprawde operation 1.
external_loop_store_and_next:
stosb # zapisanie obecnej wartosci chara do bufa. ta funkcja robi tyle, ze przenosi %al (najmlodszy bajt rax) pod adres
# w pamieci wskazywany przez %rdi. czyli tak naprawde robi movb %al, (%rdi). potem jeszcze inkrementuje %rdi.
external_loop_next:
incq external_loop_counter # inkrementacja i skok na poczatek petli
jmp external_loop

job_done: # wszystkie operacje wykonane, bo doszlismy do bajtu zerowego w stringu, czyli do konca
# zwracamy char* buf przez rax
mov %r11, %rax
ret
