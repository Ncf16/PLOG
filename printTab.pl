
%%function called by "user"
%no more lines to read ends the function
%%head represents a board line,the tail represents the remaning lines
printTabuleiro(Tab):-printTabuleiro(Tab,1).
printTabuleiro([],_):-constant("maxRows",Max),EndTab is Max+1,constant("lineSize",LineSize), printChar(' ',EndTab),printChar('-',LineSize).
printTabuleiro(_,8):-constant("maxRows",Max),printChar(' ',Max),printChar('-',Max).
printTabuleiro([L|R],N):- N>=1,N=<7,N1 is N+1,printLine(L,N) ,printTabuleiro(R,N1).


printLine([]):-printChar('\n').
printLine([H|T]):- printChar(' '),printElement(H),printChar('|'),printLine(T).
%%procurar algo para substituir o 33/!
printLine([],_):-printChar('!').
printLine(Line,NumberOfLine):-NumberOfSpaces is NumberOfLine+1, printChar(' ',NumberOfSpaces),constant("lineSize",LineSize),printChar('-',LineSize),printChar('\n'),printChar(' ',NumberOfSpaces),printChar('|'),printLine(Line).

%%display in the console the char with the code Code
%%prints a character Ntimes times
printChar(Code):- write(Code).
printChar(_,0).
printChar(Code,Ntimes):-Ntimes >0,Ntimes1 is Ntimes-1,printChar(Code),printChar(Code,Ntimes1).
printLineElement([H|T],N,NumberOfSpaces):-N>0,!,printChar(' ',NumberOfSpaces).

%% prints empty cell
printElement(0):- printChar(' ').
%% prints cell with white ring
printElement(1):- printChar('w').
%% prints cell with white disk
printElement(2):- printChar('W').
%% prints cell with back ring
printElement(3):- printChar('b').
%% prints cell with black disk
printElement(4):- printChar('B').
%% prints cell with white ring and white disk
printElement(5):- printChar('F').
%% prints cell with white ring and black disk
printElement(6):- printChar('f').
%% prints cell with black ring and black disk
printElement(7):- printChar('P').
%% prints cell with black ring and white disk
printElement(8):- printChar('p').
%%printTabuleiro([[0,0,0,0,0,0,0],[0,0,0,0,0,0,0],[0,0,0,0,0,0,0],[0,0,0,0,0,0,0],[0,0,0,0,0,0,0],[0,0,0,0,0,0,0],[0,0,0,0,0,0,0]]) .