%% "defines"
ring(black,[3]).
ring(white,[1]).
disk(white,[2]).
disk(black,[4]).
playerTypes(['black','white']).
botTypes(['random','greedy']).
blackPieces([3,4]).
whitePieces([1,2]).
ringPieces([1,3]).
diskPieces([2,4]).
fullCell([5,6,7,8]).

equal(0,[0]).
equal(1,[1,5,6]).
equal(2,[2,5,8]).
equal(3,[3,7,8]).
equal(4,[4,6,7]).
equal(5,[1,2,5,6,8]).
equal(6,[1,4,5,6,7]).
equal(7,[3,4,6,7,8]).
equal(8,[2,3,5,7,8]).

getBlackDisk(4).
getBlackRing(3).
getWhiteRing(1).
getWhiteDisk(2).

getDisk(black,Disk):-getBlackDisk(Disk).
getDisk(white,Disk):-getWhiteDisk(Disk).
getRing(black,Ring):-getBlackRing(Ring).
getRing(white,Ring):-getWhiteRing(Ring).

getSimplePieces(black,Pieces):-blackPieces(Pieces).
getSimplePieces(white,Pieces):-whitePieces(Pieces).

stringToBoardMember('r',white,1).
stringToBoardMember('ring',white,1).
stringToBoardMember('R',white,1).

stringToBoardMember('d',white,2).
stringToBoardMember('disk',white,2).
stringToBoardMember('D',white,2).

stringToBoardMember('r',black,3).
stringToBoardMember('ring',black,3).
stringToBoardMember('R',black,3).

stringToBoardMember('d',black,4).
stringToBoardMember('disk',black,4).
stringToBoardMember('D',black,4).

emptyCell(0).

getNewPieceValue(0,Piece,Piece).

getNewPieceValue(1,2,5).
getNewPieceValue(1,4,6).

getNewPieceValue(2,1,5).
getNewPieceValue(2,3,8).

getNewPieceValue(3,2,8).
getNewPieceValue(3,4,7).

getNewPieceValue(4,1,6).
getNewPieceValue(4,3,7).

getNextPlayer(white,black).
getNextPlayer(black,white).


validateMoveType(a,addPiece).
validateMoveType(m,movePiece).

validPieceNames(['disk','d' ,'ring','r']).

cls :- write('\e[H\e[2J').

equivalent(black,3,1).
equivalent(black,4,2).
equivalent(white,1,3).
equivalent(white,2,4).
equivalent(_,5,5).
equivalent(_,6,6).
equivalent(_,7,7).
equivalent(_,8,8).

%% prints cell with white ring and white disk
printElement(5):- printChar('F').

%% prints cell with white ring and black disk
printElement(6):- printChar('f').

%% prints cell with black ring and black disk
printElement(7):- printChar('P').

%% prints cell with black ring and white disk
printElement(8):- printChar('p').

getSimplePiece(8,black,[4]).
getSimplePiece(8,white,[2]).
getSimplePiece(7,black,[3,4]).
getSimplePiece(7,white,[]).
getSimplePiece(6,black,[3]).
getSimplePiece(6,white,[1]).
getSimplePiece(5,black,[]).
getSimplePiece(5,white,[1,2]).
getSimplePiece(Var,_,Var).

getNumberOfRings(Player,Number):-!,stats(Player,[_|[Number|_]]).
getNumberOfDisks(Player,Number):-!,stats(Player,[Number|_]).

%%Aux
abs(X,Y):-X>=0,!,Y is X.
abs(X,Y):-X<0,Y is (-1)*X. 

max(X,Y,X):-X>=Y,!.
max(X,Y,Y):-Y>X,!.

min(X,Y,X):-X=<Y,!.
min(X,Y,Y):-Y<X,!.

between(ValueToTest,MinLimit,MaxLimit):-ValueToTest>=MinLimit,ValueToTest=<MaxLimit.

belongs(_,[]):-fail.
belongs(Element,[Element|_]).
belongs(Element,[_|T]):-belongs(Element,T).

listLength([],0).
listLength([_|T],Length):-listLength(T,X),Length is X+1.
deleteRepetidos([],[]).
deleteRepetidos([H|T],NewList):-member(H,T),deleteRepetidos(T,NewList).
deleteRepetidos([H|T],[H|TnewList]):-deleteRepetidos(T,TnewList).


appendLists(ListPointer,Pieces):-appendLists(ListPointer,Pieces,[]).
appendLists([],Final,Pieces):-deleteRepetidos(Pieces,Final).
appendLists([H|T],Pieces,Temp):-equal(H,ToAppend),append(Temp,ToAppend,NewTemp),appendLists(T,Pieces,NewTemp).


adjancent(X,Y,X1,Y1):-X=:=X1,NewY is Y-1,NewY=:=Y1.

adjancent(X,Y,X1,Y1):-X=:=X1,NewY is Y+1,NewY=:=Y1.

adjancent(X,Y,X1,Y1):-Y=:=Y1,NewX is X-1,NewX=:=X1.

adjancent(X,Y,X1,Y1):-Y=:=Y1,NewX is X+1,NewX=:=X1.

adjancent(X,Y,X1,Y1):-NewX is X-1,NewX=:=X1,NewY is Y+1,NewY=:=Y1.

adjancent(X,Y,X1,Y1):-NewX is X+1,NewX=:=X1,NewY is Y-1,NewY=:=Y1.

check(FirstPiece,NewElement):-equal(FirstPiece,EqualValues),member(NewElement,EqualValues).

checkPath(El,Path,PathNew):- \+(member(El,Path)),!,append([El],Path,PathNew).


checkIfDef(Var,DefaultValue):-var(Var),Var=DefaultValue.

checkIfDef(_,_).

listMin(Zs,Expr,Pos) :- maplist(#=<(Min),Zs),nth0(Pos,Zs,Expr),Expr #= Min.



writeList([]).
writeList([H|T]):-write(H),nl,writeList(T).
 

getValidChangeElements(Ring,Disk):-ringPieces(RingPieces),diskPieces(DiskPieces),belongs(Ring,RingPieces),belongs(Disk,DiskPieces).
getValidChangeElements(Disk,Ring):-ringPieces(RingPieces),diskPieces(DiskPieces),belongs(Ring,RingPieces),belongs(Disk,DiskPieces).
