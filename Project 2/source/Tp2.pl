:- use_module(library(clpfd)).
:-use_module(library(lists)).
:-use_module(library(random)).
:-dynamic tabSize/1.
:-dynamic partSize/1.
:-dynamic calls/1.

%%check numbers with more than 1 space
cls :- write('\e[H\e[2J').
writeEndOfLine:- nl. 
printStartEnd('_').
printColPart1(' ').
printSide('|'). 
printWhiteDot('o'). 
printBlackDot('+').
defaultSize(6).

reset_timer :- statistics(walltime,_).	
print_time :- statistics(walltime,[_,T]),
TS is ((T//10)*10)/1000,
nl,
write('Time: '),
write(TS),
write('s'),
nl,
nl.

%Simple Pieces
printBorder(0,right):-write('|').
printBorder(0,down):-write('_').
printBorder(1,right):-printWhiteDot(Dot),
write(Dot).
printBorder(2,right):-printBlackDot(Dot),
write(Dot).
printBorder(3,down):-printWhiteDot(Dot),
write(Dot).
printBorder(4,down):-printBlackDot(Dot),
write(Dot).

%Complex Pieces
printBorder(5,right):-printBorder(1,right).
printBorder(5,down):-printBorder(4,down).
printBorder(6,right):-printBorder(2,right).
printBorder(6,down):-printBorder(4,down).
printBorder(7,right):-printBorder(1,right).
printBorder(7,down):-printBorder(3,down).
printBorder(8,right):-printBorder(2,right).
printBorder(8,down):-printBorder(3,down).

%any other symbol
printBorder(_,down):-write('_').
printBorder(_,right):-write('|').
retractIfExists(tabSize):-retract(tabSize(_)).
retractIfExists(partSize):-retract(partSize(_)).
retractIfExists(_).

/****************************************************************************************************************************************/
cleanList:-retract(calls(_)),
asserta(calls([])),
calls(X),
write(X),
nl.

printNTimes(ToPrint,Ntimes):-printNTimes(ToPrint,Ntimes,0).
printNTimes(_,Ntimes,Ntimes).
printNTimes(ToPrint,Ntimes,Counter):-Counter<Ntimes,
write(ToPrint),
Counter1 is Counter +1,
printNTimes(ToPrint,Ntimes,Counter1).

printListNtimes(ToPrint,Ntimes):-printListNtimes(ToPrint,Ntimes,0).
printListNtimes(_,Ntimes,Ntimes).
printListNtimes(ToPrint,Ntimes,Counter):-
Counter<Ntimes,
printList(ToPrint),
Counter1 is Counter +1,
printListNtimes(ToPrint,Ntimes,Counter1).

printList([]).
printList([H|T]):-write(H),
printList(T).

joinAll([],[]).
joinAll([H|T],List):-append(H,Rest,List),
joinAll(T,Rest).

createMatrix(NumberList,SizeL,SizeC):-createMatrix(NumberList,0,SizeL,SizeC).
createMatrix([],SizeN,SizeN,_).
createMatrix([H|T],Counter,SizeN,SizeC):-Counter1 is Counter+1,
createMatrixRow(H,0,SizeC),
createMatrix(T,Counter1,SizeN,SizeC).

createMatrixRow([],SizeC,SizeC).
createMatrixRow([_|T],Counter,SizeC):-
Counter1 is Counter+1,
createMatrixRow(T,Counter1,SizeC).

mapLine(NumberList):-maplist(all_distinct,NumberList).

getRow(_,_,SizeN,[],SizeN).
getRow(NumberList,RowNumber,SizeN,[RowElement|T],Counter):-CounterNext is Counter+1,
nth0(Counter,NumberList,LineElement),
nth0(RowNumber,LineElement,RowElement),
getRow(NumberList,RowNumber,SizeN,T,CounterNext).

mapRow(NumberList):-tabSize(SizeN),
mapRow(NumberList,0,SizeN).

mapRow(_,SizeN,SizeN).
mapRow(NumberList,Counter,SizeN):-
Counter<SizeN,
CounterNext is Counter+1,
getRow(NumberList,Counter,SizeN,Row,0),
all_distinct(Row),
mapRow(NumberList,CounterNext,SizeN).


printNumber(Number):-var(Number),
write(' ').
printNumber(Number):-nonvar(Number),
write(Number).

% replace(+X, +Symbol+, +List, -NewList)
replace(_, _, [], []).
replace(0, Symbol, [_ | T], L2) :- append([Symbol], T, L2).
replace(X, Symbol, [H | T], L2) :- X1 is X - 1,
replace(X1, Symbol, T, L3),
append([H], L3, L2).

deleteList(_, _, [], []).
deleteList(0,  [_ | T], T).
deleteList(X, [H | T], [H|T2]):- X1 is X - 1 ,
deleteList(X1,T,T2).

getRadomNumber(Number,LowerLimit,UpperLimit):-random(LowerLimit,UpperLimit,Number). 

createListWithXElemYTimes([],_,Ytimes,Ytimes).
createListWithXElemYTimes([XElemt|T],XElemt,Ytimes,Counter):-Counter<Ytimes,
Counter1 is Counter+1,
createListWithXElemYTimes(T,XElemt,Ytimes,Counter1).
createListWithXElemYTimes(List,XElemt,Ytimes):-createListWithXElemYTimes(List,XElemt,Ytimes,0).

integerSize(Interger,Size):-
integer(Interger),
number_codes(Interger,X),
length(X,Size).
integerSize(_,1).

setPartSize(BoardSize):-defaultSize(Size),
integerSize(BoardSize,Length),
Length>=Size,
asserta((partSize(BoardSize))).
setPartSize(_):-defaultSize(Size),
asserta((partSize(Size))).

checkDom([]).
checkDom([H|T]):-var(H),
fd_dom(H,Res),
write(Res),
nl,
checkDom(T).

checkDom([H|T]):-nonvar(H),
checkDom(T).

copyList([],[]).
copyList([H|T],[H|Tc]):-nonvar(H),
copyList(T,Tc).

copyList([H|T],[_|Tc]):-var(H),
copyList(T,Tc).

/****************************************************************************************************************************************/

% Main predicates default [leftmost,step,up,satisfy]
solveKropki(BorderList,NumberList,LabelOptions):-!,
length(BorderList,SizeN),
setPartSize(SizeN),
createMatrix(NumberList,SizeN,SizeN),
asserta((tabSize(SizeN))),!,
joinAll(NumberList,JoinedList),!,
domain(JoinedList,1,SizeN),
mapLine(NumberList),!,
mapRow(NumberList),!,
cycle(NumberList,BorderList),!,
write(JoinedList),
reset_timer,
labeling(LabelOptions,JoinedList),print_time,fd_statistics.
% 

kropki(BorderList,NumberList):-
retractIfExists(tabSize),
retractIfExists(partSize),!,
solveKropki(BorderList,NumberList,[ffc,step,up,satisfy]),
nl,
write('Answer'),nl,
printKropki(BorderList,NumberList),
nl,retract((tabSize(_))),retract((partSize(_))).

kropki(_,_):- write('No solution was Found'),
nl,nl,retract((tabSize(_))),retract((partSize(_))).

/****************************************************************************************************************************************/

%% TESTE
writePos(PosX,PosY):-write('POS: '),
write(PosX),
write('  '),
write(PosY),nl.

teste(N,Answer):-testBoard(N,Board),
testNumberList(N,Answer),
kropki(Board,Answer).

teste(N,Answer):-testBoard(N,Board),
kropki(Board,Answer).

%% TEST BOARDS
testBoard(0,[[0,0],[0,0]]).
testBoard(1,[[5,7,7,0],[8,4,0,3],[1,7,7,4],[0,0,2,0]]).
testBoard(2,[[0,0,3,3,3],[0,0,6,1,0],[1,8,0,3,4],[0,3,1,8,0],[2,1,0,0,0]]).
testBoard(3,[[0,0,0,0,0,0],[0,3,3,4,0,3],[0,0,0,0,0,0],[0,0,0,0,0,0],[0,0,0,0,0,0],[0,0,0,0,0,0]]).
testBoard(4,[[8,3,0,0,0,4],[0,0,2,1,2,0],[5,3,1,0,0,3],[0,0,1,2,1,0],[7,4,0,1,0,3],[1,0,1,1,1,0]]).
testBoard(5,[[1,5],[2,8]]).

testNumberList(3,[[_,_,_,_,_,_],[_,5,_,_,_,_],[_,_,_,_,_,_],[_,_,_,_,_,_],[_,_,_,_,4,_],[_,_,_,_,_,_]]).

validateKropki(MaxSize,PokN,PokB):-validateKropki(MaxSize,1,PokN,PokB).
validateKropki(MaxSize,MaxSize,_,_).
validateKropki(MaxSize,CurrentSize,PokN,PokB):-CurrentSize <MaxSize,
CurrentSize1 is CurrentSize+1,
write('CurrentSize: '),
write(CurrentSize),nl,
createRandom(CurrentSize,PokN,PokB,B,N),
copyList(B,B1),
copyList(N,N1),
write('Restriction List: '),
write(B1),nl,
write('Numers list: '),
write(N),nl,kropki(B1,N1),
write('Restriction List: '),write(B1),nl,
write('Numers list: '),
write(N1),
nl,
get_code(_),!,
cleanList,
validateKropki(MaxSize,CurrentSize1,PokN,PokB).

/****************************************************************************************************************************************/
 
printKropki(BorderList,NumberList):-length(BorderList,Length),
length(NumberList,Length),
printKropkiTop(Length),
printKropki(BorderList,NumberList,Length,0),
printLegenda.

printKropki([],[],_,_).
printKropki([BorderHead|BorderTail],[NumberHead|NumberTail],Length,CurrentLine):-CurrentLine=<Length,
CurrentLine1 is CurrentLine+1,
printKropkiLine(BorderHead,NumberHead,CurrentLine,Length),!,
printKropki(BorderTail,NumberTail,Length,CurrentLine1).   
 
printKropkiTop(Nsize):-write('_'),
printStartEnd(ToPrint),
partSize(N),
TopSize is N+1,
createListWithXElemYTimes(Top,ToPrint,TopSize),
printListNtimes(Top,Nsize),
writeEndOfLine.

printKropkiLine([],[],Nsize,Nsize):-printSide(Side),
write(Side),
printStartEnd(ToPrint),
printNTimes(ToPrint,Nsize),
write(Side),
writeEndOfLine.

printKropkiLine(Border,Number,CurrentLine,Nsize):-CurrentLine<Nsize,
printKropkiColPart1(0,Nsize),
printSide(Side),
write(Side),
printKropkiColPart2(Border,Number,0,Nsize),
printKropkiColPart3(Border,Number,0,Nsize).
 
printKropkiColPart1(Nsize,Nsize):-printSide(Side),
write(Side),
printColPart1(ToPrint),
partSize(N),
createListWithXElemYTimes(Part1,ToPrint,N),
printListNtimes(Part1,N),
writeEndOfLine.

printKropkiColPart1(CurrentCol,Nsize):-partSize(N),
CurrentCol=<Nsize,CurrentCol1 is CurrentCol+1,
printSide(Side),
write(Side),
printColPart1(ToPrint),
printNTimes(ToPrint,N),
printKropkiColPart1(CurrentCol1,Nsize).

printKropkiColPart2([],[],Nsize,Nsize):-writeEndOfLine.
printKropkiColPart2([Bh|Bt],[Nh| Nt],CurrentCol,Nsize):-partSize(N),
integerSize(Nh,IntergerSize),
CurrentCol<Nsize,
CurrentCol1 is CurrentCol+1,
FirstPart is round(N/2-1),
printNTimes(' ',FirstPart),
printNumber(Nh),
SecondPart is round(N/2-IntergerSize+1),
printNTimes(' ',SecondPart),
printBorder(Bh,right),
printKropkiColPart2(Bt,Nt,CurrentCol1,Nsize).	

printKropkiColPart3([],_,Nsize,Nsize):-printSide(Side),
write(Side),
writeEndOfLine.

printKropkiColPart3([Bh|Bt],_,CurrentCol,Nsize):-partSize(N),
CurrentCol<Nsize,
CurrentCol1 is CurrentCol+1,
FirstPart is round(N/2-1),
SecondPart is round(N/2),
printSide(Side),
write(Side),
printNTimes('_',FirstPart),
printBorder(Bh,down),
printNTimes('_',SecondPart),
printKropkiColPart3(Bt,_,CurrentCol1,Nsize).

printLegenda:-printWhiteDot(WhiteDot),
write('White Dot: '),
write(WhiteDot),nl,
printBlackDot(BlackDot),
write('Black Dot: '),
write(BlackDot),nl.
/****************************************************************************************************************************************/
 
% Simple restriction
% 0 -> No restriction besides being different
restriction(_,_,_,_,0).
% 1 -> white dot right
restriction(NumberList,NumberElement,PosX,PosY,1):-tabSize(Nsize),
PosYnew is PosY +1,
PosYnew<Nsize,
nth0(PosX,NumberList,Line),
nth0(PosYnew,Line,NextColElement),!,
NumberElement#=NextColElement+1#\/NumberElement#=NextColElement-1.
% 2 -> black dot right
restriction(NumberList,NumberElement,PosX,PosY,2):-tabSize(Nsize),
PosYnew is PosY +1,PosYnew<Nsize,
nth0(PosX,NumberList,Line),
nth0(PosYnew,Line,NextColElement),!,
NumberElement#=NextColElement*2#\/NextColElement#=NumberElement*2.
% 3 -> white dot down 
restriction(NumberList,NumberElement,PosX,PosY,3):-tabSize(Nsize),
PosXnew is PosX +1,
PosXnew<Nsize,
nth0(PosXnew,NumberList,Line),
nth0(PosY,Line,NextLineElement),!,
NumberElement#=NextLineElement+1#\/NumberElement#=NextLineElement-1.
% 4 -> black dot down
restriction(NumberList,NumberElement,PosX,PosY,4):-tabSize(Nsize),
PosXnew is PosX +1,PosXnew<Nsize,
nth0(PosXnew,NumberList,Line),
nth0(PosY,Line,NextLineElement),!,
NumberElement#=NextLineElement*2#\/NextLineElement#=NumberElement*2.

% Multiple restrictions
% 5 -> white dot right AND black dot down
restriction(NumberList,NumberElement,PosX,PosY,5):-restriction(NumberList,NumberElement,PosX,PosY,1),
restriction(NumberList,NumberElement,PosX,PosY,4).
% 6 -> black dot right AND black dot down
restriction(NumberList,NumberElement,PosX,PosY,6):-restriction(NumberList,NumberElement,PosX,PosY,2),
restriction(NumberList,NumberElement,PosX,PosY,4).
% 7 -> white dot right AND white dot down
restriction(NumberList,NumberElement,PosX,PosY,7):-restriction(NumberList,NumberElement,PosX,PosY,1),
restriction(NumberList,NumberElement,PosX,PosY,3).
% 8 -> black dot right AND white dot down
restriction(NumberList,NumberElement,PosX,PosY,8):-restriction(NumberList,NumberElement,PosX,PosY,2),
restriction(NumberList,NumberElement,PosX,PosY,3).

/****************************************************************************************************************************************/
% Apply restrictions cycle
cycle(NumberList,BorderList):-cycle(NumberList,BorderList,0,0).
cycle(_,_,Nsize,_):-tabSize(Nsize).
cycle(NumberList,BorderList,PosX,Nsize):-tabSize(Nsize),!,
PosX<Nsize,!,
PosXnext is PosX+1,
cycle(NumberList,BorderList,PosXnext,0).

cycle(NumberList,BorderList,PosX,PosY):-tabSize(Nsize),
PosY<Nsize,PosYnext is PosY+1,
nth0(PosX,BorderList,BorderLine),
nth0(PosY,BorderLine,BorderElement),
nth0(PosX,NumberList,NumberLine),
nth0(PosY,NumberLine,NumberElement),
restriction(NumberList,NumberElement,PosX,PosY,BorderElement),
cycle(NumberList,BorderList,PosX,PosYnext).

/****************************************************************************************************************************************/
 
createRandom(Size,ProbabilityOfKeepingNumber,RestrictionProbability,BorderListToReturn,NumberListToReturn):-retractIfExists(tabSize),
retractIfExists(partSize),
createMatrix(BorderListToReturn,Size,Size),
createListWithXElemYTimes(Line,0,Size),
createListWithXElemYTimes(BorderList,Line,Size),!,
solveKropki(BorderList,NumberList,[variable(sel1),step,up,satisfy]),!,
retract((tabSize(_))), placeRestrictions(NumberList,RestrictionProbability,Size,BorderListToReturn),
eraseNumber(NumberList,ProbabilityOfKeepingNumber,Size,NumberListToReturn),
printKropki(BorderListToReturn,NumberListToReturn),retract((partSize(_))).

eraseNumber(NumberList,ProbabilityOfKeepingNumber,Size,ErasedList):-eraseCycle(NumberList,ProbabilityOfKeepingNumber,0,0,Size,ErasedList).

eraseCycle(ErasedList,_,Nsize,_,Nsize,ErasedList).
eraseCycle(NumberList,Probability,PosX,Nsize,Nsize,ErasedList):-PosX<Nsize,!,
PosXnext is PosX+1,
eraseCycle(NumberList,Probability,PosXnext,0,Nsize,ErasedList).

eraseCycle(NumberList,Probability,PosX,PosY,Nsize,ErasedList):-PosY<Nsize,
PosYnext is PosY+1,getRadomNumber(Number,1,101),
Probability>=Number,
eraseCycle(NumberList,Probability,PosX,PosYnext,Nsize,ErasedList).

eraseCycle(NumberList,Probability,PosX,PosY,Nsize,ErasedList):-PosY<Nsize,
PosYnext is PosY+1,
nth0(PosX,NumberList,NumberLine),
nth0(PosY,NumberLine,_),
replace(PosY,_,NumberLine,NewLine),
replace(PosX,NewLine,NumberList,NewNumberList),
eraseCycle(NewNumberList,Probability,PosX,PosYnext,Nsize,ErasedList).


placeRestrictions(NumberList,RestricProb,Size,Return):-placeRestrictionsCycle(NumberList,RestricProb,0,0,Size,Return),
write(Return),nl.

placeRestrictionsCycle(_,_,Size,_,Size,_).
placeRestrictionsCycle(NumberList,RestricProb,PosX,Size,Size,Return):-!,PosX<Size,!,
PosXnext is PosX+1,
placeRestrictionsCycle(NumberList,RestricProb,PosXnext,0,Size,Return).

%place restriction
placeRestrictionsCycle(NumberList,RestricProb,PosX,PosY,Size,Return):-PosY<Size,PosYnext is PosY+1,
getRadomNumber(Number,1,101),
RestricProb>=Number,
nth0(PosX,NumberList,NumberLine),
nth0(PosY,NumberLine,NumberElement),
getValidRestriction(NumberList,NumberElement,PosX,PosY,BorderElement,Size),
nth0(PosX,Return,BorderLine),
nth0(PosY,BorderLine,BorderElement),
placeRestrictionsCycle(NumberList,RestricProb,PosX,PosYnext,Size,Return).

%no restriction
placeRestrictionsCycle(NumberList,RestricProb,PosX,PosY,Size,Return):-PosY<Size,
PosYnext is PosY+1,
nth0(PosX,Return,BorderLine),
nth0(PosY,BorderLine,0),
placeRestrictionsCycle(NumberList,RestricProb,PosX,PosYnext,Size,Return).

%Multiple restrictions 
% 5 -> white dot right AND black dot down
getValidRestriction(NumberList,NumberElement,PosX,PosY,5,Nsize):-getValidRestriction(NumberList,NumberElement,PosX,PosY,1,Nsize),
getValidRestriction(NumberList,NumberElement,PosX,PosY,4,Nsize).
% 6 -> black dot right AND black dot down
getValidRestriction(NumberList,NumberElement,PosX,PosY,6,Nsize):-getValidRestriction(NumberList,NumberElement,PosX,PosY,2,Nsize),
getValidRestriction(NumberList,NumberElement,PosX,PosY,4,Nsize).
% 7 -> white dot right AND white dot down
getValidRestriction(NumberList,NumberElement,PosX,PosY,7,Nsize):-getValidRestriction(NumberList,NumberElement,PosX,PosY,1,Nsize),
getValidRestriction(NumberList,NumberElement,PosX,PosY,3,Nsize).
% 8 -> black dot right AND white dot down
getValidRestriction(NumberList,NumberElement,PosX,PosY,8,Nsize):-getValidRestriction(NumberList,NumberElement,PosX,PosY,2,Nsize),
getValidRestriction(NumberList,NumberElement,PosX,PosY,3,Nsize).

% 1 -> white dot right
getValidRestriction(NumberList,NumberElement,PosX,PosY,1,Nsize):-PosYnew is PosY +1,PosYnew<Nsize,
nth0(PosX,NumberList,Line),
nth0(PosYnew,Line,NextColElement),!,
(NumberElement is NextColElement+1;NumberElement is NextColElement-1).
% 2 -> black dot right
getValidRestriction(NumberList,NumberElement,PosX,PosY,2,Nsize):-PosYnew is PosY +1,PosYnew<Nsize,
nth0(PosX,NumberList,Line),
nth0(PosYnew,Line,NextColElement),!,
(NumberElement is NextColElement*2;NextColElement is NumberElement*2 ).
% 3 -> white dot down 
getValidRestriction(NumberList,NumberElement,PosX,PosY,3,Nsize):-PosXnew is PosX +1,PosXnew<Nsize,
nth0(PosXnew,NumberList,Line),
nth0(PosY,Line,NextLineElement),!,
(NumberElement is NextLineElement+1;NumberElement is NextLineElement-1).
% 4 -> black dot down
getValidRestriction(NumberList,NumberElement,PosX,PosY,4,Nsize):-PosXnew is PosX +1,PosXnew<Nsize,
nth0(PosXnew,NumberList,Line),
nth0(PosY,Line,NextLineElement),!,
(NumberElement is NextLineElement*2; NextLineElement is NumberElement*2 ).

getValidRestriction(_,_,_,_,0,_).

sel1(Vars,Selected,Rest):- length(Vars, N), random(0, N, R), R1 is R+1,calls(X),retract(calls(_)),asserta(calls([R|X])), element(R1, Vars, Selected),var(Selected),deleteList(R,Vars, Rest).

b([[0,0,0,0,0,0,0,0,1,0,1,0],[7,0,1,0,0,0,0,1,0,0,0,0],[0,0,0,1,0,0,0,1,0,0,0,0],[0,0,0,0,0,0,6,0,0,0,0,0],[0,0,1,0,1,0,0,1,0,0,0,0],[0,0,0,0,0,0,0,0,0,0,0,0],[0,0,0,5,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0,0,0,0,0],[0,1,0,0,0,0,1,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0,0,0],[0,0,1,0,0,1,0,0,0,0,0,0],[0,0,0,0,0,0,1,0,0,0,0,0]]).

n( [[_6935597,_6935865,_6936227,11,_6936849,8,_6937659,_6938491,5,_6939583,_6940697,_6941905],[5,6,_6943641,_6944191,_6944835,_6945573,7,_6946571,_6947591,_6948705,_6949913,_6951215],
	[4,10,_6953045,_6953689,_6954427,_6955259,_6956185,_6957205,_6958319,6,_6959693,_6961089],[10,_6962847,_6963491,_6964229,_6965061,_6965987,_6967007,6,1,5,11,_6968785],
	[_6970471,_6971115,_6971853,_6972685,_6973611,4,_6974797,_6976005,_6977307,_6978703,10,2],[8,4,12,5,_6981291,_6982405,2,_6983779,_6985175,_6986665,_6988249,6],
	[_6990195,8,10,_6991359,_6992473,_6993681,_6994983,_6996379,_6997869,_6999453,_7001131,_7002903],[9,2,6,_7005369,10,7,_7006909,_7008399,_7009983,_7011661,1,_7013599],
	[_7015661,_7016681,_7017795,_7019003,_7020305,_7021701,9,8,_7023523,_7025295,_7027161,1],[_7029389,11,5,_7030835,_7032231,_7033721,1,_7035471,_7037243,_7039109,_7041069,_7043123],
	[_7045373,_7046581,_7047883,_7049279,_7050769,11,_7052519,_7054291,_7056157,_7058117,7,5],[3,_7060771,_7062167,_7063657,_7065241,_7066919,_7068691,5,_7070723,2,_7072943,_7075185]]).
