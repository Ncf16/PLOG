
%piece(+Number,+Order,+PieceType).

%translate representation code
piece(0,_,_):- writeSpace(1).
piece(1,_,ring):- write('*').
piece(1,_,disc):- writeSpace(1).
piece(2,_,ring):- writeSpace(1).
piece(2,1,disc):- write('\\').
piece(2,2,disc):- write('/').
piece(3,_,ring):- write('0').
piece(3,_,disc):- writeSpace(1).
piece(4,_,ring):- writeSpace(1).
piece(4,_,disc):- write('+').
piece(5,Order,ring):- piece(1,Order,ring).
piece(5,Order,disc):- piece(2,Order,disc).
piece(6,Order,ring):- piece(1,Order,ring).
piece(6,Order,disc):- piece(4,Order,disc).
piece(7,Order,ring):- piece(3,Order,ring).
piece(7,Order,disc):- piece(4,Order,disc).
piece(8,Order,ring):- piece(3,Order,ring).
piece(8,Order,disc):- piece(2,Order,disc).

/****************************************************************************************************************************************/


%writePrevious(+SpaceNumber,+LineIndex,+GroupIndex,+Orientation).
%writeAfter(+SpaceNumber,+LineIndex,+GroupIndex,+Orientation).

%top left - White presentation
writePrevious(Space,0,3,top):-
Space1 is round(Space/2)-3,
Space2 is Space1+1,
writeSpace(Space1),
write('White'),
writeSpace(Space2).

%bottom left - Black presentation
writePrevious(Space,0,2,bottom):-
Space1 is round(Space/2)-3,
Space2 is Space1+1,
writeSpace(Space1),
write('Black'),
writeSpace(Space2).

%Numeric line presentation - top
writePrevious(Space,1,I,top):-
Space1 is Space - 3,
writeSpace(Space1),
I1 is I-1,
write(I1),
writeSpace(2).

%Numeric line presentation - bottom
writePrevious(Space,2,I,bottom):-
Space1 is Space - 3,
writeSpace(Space1),
I1 is 7-I,
write(I1),
writeSpace(2).

%Non numeric lines
writePrevious(Space,_,_,_):-
writeSpace(Space).

%top right - Black presentation
writeAfter(Space,0,3,top):-
Space1 is round(Space/2)-3,
Space2 is Space1+1,
writeSpace(Space2),
write('Black'),
writeSpace(Space1).

%bottom right - White presentation
writeAfter(Space,0,2,bottom):-
Space1 is round(Space/2)-3,
Space2 is Space1+1,
writeSpace(Space2),
write('White'),
writeSpace(Space1).

%Numeric line presentation - top
writeAfter(_,1,I,top):-
writeSpace(2),
I1 is I-1,
write(I1).

%Numeric line presentation - bottom
writeAfter(_,2,I,bottom):-
writeSpace(2),
I1 is 7-I,
write(I1).

%Non numeric lines
writeAfter(_,_,_,_).

/****************************************************************************************************************************************/

%printPiece(Piece,N,Type,Order).
%calls piece(Piece,Order,Type) N times.

printPiece(_,0,_,_):-!.
printPiece(Piece,N,Type,Order):-
piece(Piece,Order,Type),
N1 is N-1,
printPiece(Piece,N1,Type,Order).

/****************************************************************************************************************************************/

%printInfo.
%info about representation meaning

printInfo:-
write('           \\/                          ++'),nl,
write('White disc:/\\,ring:**     Black disc, :++, ring:00').

/****************************************************************************************************************************************/

%printBoard(+Board).
%main function, calls every other

printBoard(Board):-
clear,
drawTop(Board,0,7),
writeSpace(3),drawTopRow(Board,3,7,0,13),nl, %middle
drawBottom(Board,7,0), nl, nl,
printInfo.

/****************************************************************************************************************************************/

%drawTop(+Board,+MinCell,+MaxCell).
%responsible for top representation

%drawTopLine(+Board,+Spacing,+Cell,+MinLine,+MaxLine).
%responsible for each horizontal cell

%drawTopRow(+Board,+Line,+Cell,+MinXNav,+MaxXNav).
%reponsible for each line

drawTop(_,Max,Max).
drawTop(Board,I,Max):-
I1 is I+1,
Spacing is 6+7*(7-I1),
drawTopLine(Board,Spacing,I1,0,3),
drawTop(Board,I1,Max).

drawTopLine(_,_,_,KMax,KMax).
drawTopLine(Board,Spacing,I,K,KMax):-
Space is Spacing-K,
writePrevious(Space,K,I,top),
K1 is K+1,
JMax is I*2-1,
drawTopRow(Board,K,I,0,JMax),
writeAfter(Space,K,I,top),nl,
drawTopLine(Board,Spacing,I,K1,KMax).

drawTopRow(_,_,_,JMax,JMax).
drawTopRow(Board,K,I,J,JMax):-
J1 is J+1,
X is round(I-1/2*J1),
Y is floor(1+(J1-1)*1/2),
getElementAt(X,Y,Board,Piece),
even(J1,EvenOdd),
selectTopTile(K, EvenOdd,Piece),
drawTopRow(Board,K,I,J1,JMax).

/****************************************************************************************************************************************/

%drawBottom(+Board,+MinCell,+MaxCell).
%drawBottomLine(+Board,+Spacing,+Cell,+MinLine,+MaxLine).
%drawBottomRow(+Board,+Line,+Cell,+MinXNav,+MaxXNav).

drawBottom(_,Min,Min).
drawBottom(Board,I,Min):-
I1 is I-1,
Spacing is 6+7*(7-I),
drawBottomLine(Board,Spacing,I,0,3),
drawBottom(Board,I1,Min).

drawBottomLine(_,_,_,KMax,KMax).
drawBottomLine(Board,Spacing,I,K,KMax):-
Space is Spacing-(KMax-K),
writePrevious(Space,K,I,bottom),
K1 is K+1,
JMax is I*2-1,
drawBottomRow(Board,K,I,0,JMax),
writeAfter(Space,K,I,bottom),nl,
drawBottomLine(Board,Spacing,I,K1,KMax).

drawBottomRow(_,_,_,JMax,JMax).
drawBottomRow(Board,K,I,J,JMax):-
J1 is J+1,
X is floor(8-(J1*1/2)),
Y is floor((8-I)+1/2*J1),
getElementAt(X,Y,Board,Piece),
even(J1,EvenOdd),
selectBottomTile(K, EvenOdd,Piece),
drawBottomRow(Board,K,I,J1,JMax).

/****************************************************************************************************************************************/
%selectTopTile(+Line,+EvenOdd,+Piece).
%checks which tile(cell) need to be called based on line and evenOdd

selectTopTile(0,even,Piece):-printTile(3, odd,Piece).
selectTopTile(1,even,Piece):-printTile(4, even,Piece).
selectTopTile(2,even,Piece):-printTile(5, even,Piece).
selectTopTile(3,even,_):-printTile(0,_,_).
selectTopTile(K,EvenOdd,Piece):-printTile(K,EvenOdd,Piece).

selectBottomTile(0,odd,Piece):-printTile(4, odd,Piece).
selectBottomTile(1,odd,Piece):-printTile(5, odd,Piece).
selectBottomTile(2,odd,_):-printTile(6, _,_).
selectBottomTile(0,even,Piece):-printTile(1, even,Piece).
selectBottomTile(1,even,Piece):-printTile(2, even, Piece).
selectBottomTile(2,even,Piece):-printTile(3, even, Piece).
selectBottomTile(K,EvenOdd,Piece):-printTile(K,EvenOdd,Piece).

/****************************************************************************************************************************************/

%reponsible for represent each tile
%printTile(Line,OddEven,Piece).
%construction of cell is divided in each line and is rebuild

printTile(0,_,_):-
write('____').

printTile(6,_,_):-
write('\\'),
printTile(0,_,_),
write('/').

printTile(1,odd,Piece):-
write('/'),
printTile(1,even,Piece),
write('\\').

printTile(1,even,Piece):-
printPiece(Piece,4,ring,_).

printTile(2,odd,Piece):-
write('/'),
printTile(2,even,Piece),
write('\\').

printTile(2,even,Piece):-
printPiece(Piece,1,ring,_),
writeSpace(4),
printPiece(Piece,1,ring,_).

printTile(3,odd,Piece):-
write('/'),
printTile(3,even,Piece),
write('\\').

printTile(3,even,Piece):-
printPiece(Piece,1,ring,_),
writeSpace(2),
printPiece(Piece,1,disc,1),
printPiece(Piece,1,disc,2),
writeSpace(2),
printPiece(Piece,1,ring,_).

printTile(4,odd,Piece):-
write('\\'),
printTile(4,even,Piece),
write('/').

printTile(4,even,Piece):-
printPiece(Piece,1,ring,_),
writeSpace(2),
printPiece(Piece,1,disc,2),
printPiece(Piece,1,disc,1),
writeSpace(2),
printPiece(Piece,1,ring,_).

printTile(5,odd,Piece):-
write('\\'),
printTile(5,even,Piece),
write('/').

printTile(5,even,Piece):-
printPiece(Piece,6,ring,_).