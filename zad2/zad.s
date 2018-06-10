.data
	occurance_counter: .quad 0 # licznik wsytapien, na koncu programu bedzie zawieral najwieksza wartosc wystapien
	external_loop_counter: .quad 0 # licznik zewnetrznej petli. przy okazji liczba ta wskazuje, jakiej wartosci szukamy
	# w tablicy w danym obiegu petli. bedzie przyjmowal wartosci 0...63
	internal_loop_counter: .quad 0
	helper: .quad 1 # bedzie zawieral kolejne potegi 2, uzywany do ustawiania bitow
	bit_result: .quad 0 # bedzie zawieral ustawione kolejne bity, mowiace o tym, czy kolejne wartosci wystepuja w tablicy,
	# zgodnie z trescia zadania
	found: .byte 0 # flaga wskazujaca, czy w danym obiegu petli wewnetrznej znaleziono juz choc raz dana liczbe.
	# zastosowalem rozwiazanie z flaga, zeby nie ustawiac niepotrzebnie kilka razy tego samego bitu w bit_result w przypadku, gdy
	# dana wartosc wystepuje w tablicy wejsciowej wiecej niz raz. 0 - nie znaleziono, 1 - znaleziono
	
.text
.type check_tab, @function
.globl check_tab

check_tab:

xor %r11, %r11
mov %esi, %r11d # przenosze sobie n - 2 argument funckji do rejestru pomocniczego
mov %rdx, %r12 # to samo z int* max - 3 argument

external_loop: # petla zewnetrzna, ktorej zadaniem jest 64 razy puscic petle wewnetrzna po wszystkich elementach tablicy
# w poszukiwaniu w tablicy liczb z zakresu 0..63
xor %r9, %r9 # zerujemy licznik wystapien obecnej liczby w tablicy

internal_loop: # petla wewnetrzna - to tak naprawde for each po tablicy

mov internal_loop_counter, %r13 # przeniesienie pomocnicze
shl $2, %r13 # mnozymy licznik petli wewnetrznej przez 4, czyli rozmiar integera w bajtach. przypominam, ze tablica zawiera inty
# a my musimy sie jakos dobrac do kolejnych elemetnow tej tablicy. dlatego bedziemy dodawac do wskaznika int * tab - ktory 
# jest w %rdi - kolejne wielokrotnosci 4 
push %rdi # zapisujemy sobie poczatkowa wartosc rdi, zeby potem ja odzyskac
add %r13, %rdi
xor %rbx, %rbx # zerowanie rbx
movl (%rdi), %ebx # ebx zawiera konkretny element tablicy. z kazdym obiegiem petli wewnetrznej jest to nastepny element tablicy
# ebx to mlodsze 32 bity (4 bajty) rbx. zapis (%rdi) oznacza idz do miejsca pamieci, ktorego numer jest w rejestrze %rdi.
# to cos takiego jak w C dereferencja wksaznika: int * wsk = ... ; *wsk = 5; to *wsk robi to samo co nawiasy wokol rejestru
pop %rdi # stara wartosc rdi. przypominam, ze jest to wskaznik do naszej tablicy
cmp %rbx, external_loop_counter # sprawdzamy, czy obecny element tablicy rowna sie szukanemu w tym obiegu petli zewnetrznej.
# counter petli zewnetrznej odpowiada kolejnym wartosciom 0..63 ktorych szukamy
jnz inner_loop_next # obecny element tablicy nie rowna sie szukanemu, przeskakujemy do nastepnego kroku petli wewnetrznej

# znaleziono element - inkrementujemy licznik wystapien, ktory mamy w %r9 oraz ustawiamy
# odpowiedni bit w bit_result, jesli jeszcze tego nie zrobilismy wczesniej
inc %r9 # inkrementacja licznika
cmp $1, found
jz inner_loop_next # flaga found wskazuje, ze juz ustawilismy odpowiedni bit, nie musimy tego robic kolejny raz

# nie ustawilismy jeszcze bitu
mov external_loop_counter, %rcx # przenosimy counter do 64 bitowego rejestru rcx. za chwile wykorzystamy najmlodszy bajt
# tego licznika do (%cl) do przesuniecia bitowego w lewo w celu uzyskania odpowiedniej potegi 2, ktora nastepnie
# wykorzystamy do ustawienia odpowiedniego bitu w bit_result
shlq %cl, helper # cl to najmlodszy bajt rcx, trzeba tu wykorzystac wlasnie ten rejestr. patrz opis shl na necie
push %rax # zapisanie wartosci rejestrow
push %rbx
mov bit_result, %rax # pomocnicze przeniesienia bit_result i helpera. or nie moze pracowac na 2 zmiennych, najlepiej wiec
# przenosic zmienne do rejestrow, wykonywac dana operacje a potem przenosic z powrotem
mov helper, %rbx
or %rbx, %rax
mov %rax, bit_result # rax zawiera poprawnie ustawione bity, przenosimy do bit_result
pop %rbx # przywracamy wartosci rejestrow
pop %rax
movq $1, found # ustawiamy flage, ze bit dla danej wartosci 0..63 zostal ustawiony - nie trzeba tego robic ponownie
movq $1, helper # helper ustawiany na wartosc 1. jest to konieczne, aby w nastepnym obiegu prawidlowo zostala wyznaczona potega 2

inner_loop_next: 
incq internal_loop_counter # inkrementacja licznika wewnetrznej petli
cmp %r11, internal_loop_counter
jl internal_loop # sprawdzam czy licznik mniejszy od rozmiaru tablicy. zupelnie jak w zwyklym forze w C
# jesli warunek jest spelniony, to petle wykonuje ponownie

# po petli wewnetrznej
cmp occurance_counter, %r9 # porownuje dotychczas najwieksza ilosc wystapien zmiennej do tej uzyskanej w ostatnim obiegu
# zamiana jesli nowa wartosc jest wieksza. w ten sposob na koncu uzyskamy wartosc maxymalna
jle external_loop_next

mov %r9, occurance_counter

external_loop_next:
incq external_loop_counter # inkrementacja licznika petli zewnetrznej
movq $0, internal_loop_counter # zerowanie licznika wewnetrznej
movq $0, found # zerowanie flagi. gdybysmy tego nie zrobili, zaden bit nie zostalby juz ustawiony w przyszlych obiegach petli
cmp $64, external_loop_counter # cos jak for (int i = 0; i < 64 ; ). jesli licznik mniejszy od 64, to wykonuje zewnetrzna petle ponownie
jl external_loop


result: # wyniki
mov bit_result, %rax # przez rax zwracamy bit_result
mov occurance_counter, %rbx # pomocniczy mov najwiekszej wartosci wystapien do rejestru
movl %ebx, (%r12) # r12 to tak naprawde int* max, ktory podalismy na poczatku przy wywolaniu funkcji po stronie C.
# ta instrukcja ustawi *max = najwieksza_wartosc_wystapien
ret
