
clear:-
clear(25), !.

clear(0).
clear(N):-
nl,
N1 is N-1,
clear(N1).

writeSpace(0):-!.
writeSpace(N):-
write(' '),
N1 is N-1,
writeSpace(N1).

getElementAt(X,Y,List,Element):-
nth1(X,List,Row),
nth1(Y,Row,Element).

even(N,even):-
0 is N mod 2.

even(N,odd):-
1 is N mod 2.