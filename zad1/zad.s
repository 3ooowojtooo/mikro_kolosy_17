
.data
	bit_result: .quad 0 # zmienna w ktorej bede ustawial bity w przypadku c roznego od 0
	divider: .quad 1 # zmienna, kotra bede kolejno inkrementowal i dzielil a przez kolejne wartosci 1,2,3,4...64
	counter: .byte 0 # licznik petli
	helper: .quad 1 # zmienna kotra bedzie przechowywac kolejne potegi 2. umozliwi to ostawianie konkretnych bitow
.text
	.type check_div, @function
	.globl check_div

check_div:

cmp $0, %rdx # rdx przechowywuje 3 argument funkcji, czyli c
jnz c_not_zero # c rózne od 0, skaczemy do odpowiedniej wersji programu

# c równe 0 - sprawdzanie podzielności a przez b
push %rdx # zapisuje rdx na stosie, bo bedzie potrzebny przy sprawdzaniu podzielnosci, a nie chce utracic jego wartosci, którą jest c
xor %rdx, %rdx # zerowanie rdx
mov %rdi, %rax # przenoszę argument a, ktory jest w rdi, do rax
div %rsi # dzielenie polaczonego rejestru rdx:rax przez b, ktore jesst w rsi. reszta z dzielenia jest w rdx. doczytac na necie o div jesli niejasne

cmp $0, %rdx
jz a_dividable_by_b # rdx, czyli reszta z dzielenia, jest rowna 0, czyli a podzielne przez b

# a niepodzielne przez b - wstawiam 0 do rax, ktore zawiera to, co chcemy zwrocic z funkcji i skaczemy do returna
pop %rdx # dla porzadku i wyczyszczenia stosu sciagam wartosc, ktora umiescilem na stosie na poczatku
mov $0, %rax
jmp result

a_dividable_by_b:
# a podzielne przez b - wstawiam 1 do rax
pop %rdx # jak wyzej - porzadkuje stos
mov $1, %rax
jmp result

c_not_zero: # wersja programu, gdy c rozne od 0

mov $64, %rcx # licznik petli loop_64bits - wykorzystywany przez assamblera. ustawiajac rcx na 64 otrzymamy 64 obiegi petli
# jesli niejasne poszukaj na necie informacji o poleceniu loop w asemblerze
loop_64bits:
xor %rdx, %rdx # zeruję rdx - jak wczesniej przy dzieleniu. uwaga! rdx zawiera c, ale nie jest nam juz potrzebne tu, bo wiemy ze c rozne od 0
mov %rdi, %rax # przenoszę a do rax. patrz: dzielenie wcześniej w programie
mov divider, %rbx
div %rbx # dziele przez zmienną divider, kotra jest w rbx

# sprawdzanie podzielnosci - jesli rdx = 0, to podzielna, jesli rozny od 0 to niepodzielna
cmp $0, %rdx
jnz loop_continue # uwaga, skaczemy do dalszej czesci petli jesli rdx rozny od 0, czyli a niepodzlene przez obecny divider
# zostawiamy dany bit w zmiennej bit_result na 0

# a podzielne przez dany divider, ustawiamy odpowiedni bit na 1
push %rcx # pushuje sobie %rcx musze odzyskac potem jego wartosc, gdyz rcx jest licznikiem petli
mov counter, %cl # przeniesienie wartosci countera do cl, najmlodszego bajtu rcx, patrz opis shl, shl wymaga tu uzycia cl, dlatego przenosze
mov helper, %rbx # pomocnicze przeniesienie helpera do rbx - shl pracuje na rejestrach, a nie zmiennych
shl %cl, %rbx # ustawianie danej potegi dwojki - przesuniecie bitowe w lewo
mov %rbx, helper # przeniesienie przesunietej wartosci helpera spowrotem do zmiennej
pop %rcx # odzyskanie startej wartosci wartosci %rcx ze stosu
mov helper, %rsi # pomocnicze przeniesienie wartosci helpera do rsi - powod jak wyzej, mov pracuje na rejestrach
mov bit_result, %rbx # kolejne pomocnicze przeniesienie, powod ten sam
or %rsi, %rbx # ustawienie odpowiedniego bitu alternatywa logiczna - poszukaj informacji na necie jesli niejasne
mov %rbx, bit_result # przeniesienie wartosci bitresult do zmiennej
movq $1, helper # ustawienie helpera znow na 1, jak przed wejsciem do petli

loop_continue: # zwiekszenie licznika i dividera
add $1, counter
add $1, divider
loop loop_64bits # patrz opis loop na necie

mov bit_result, %rax # po petli, bit_result zawiera poprawnie ustawione bity, kotre przenosimy do rax w celu zwrocenia ich z naszej funkcji
jmp result # skaczemy do returna - tu mozna by w sumie nie stosowac jmp. result jest tuz nizej. jednak zostawilem dla czytelnosci kodu

result:
ret
