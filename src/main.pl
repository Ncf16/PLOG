
%% "includes"
:-use_module(library(random)).

%% "defines"
validPieces([0,1,2,3,4,5,6]).
ringPieces([1,3]).
diskPieces([2,4]).
fullCell([5,6,7,8]).
validPieceNames(["disk","d","D","ring","r","R"]).
cls :- write('\e[H\e[2J').
constant("minRows",0).
constant("maxRows",6).
constant("lineSize",LineSize):-constant("maxRows",Y),LineSize is Y*2+8. 
 
 %Starting Tabuleiro
stats("Tab",[[0,0,0,1,2,0,0],[0,0,0,0,0,0,0],[0,0,0,0,0,0,0],[0,0,0,0,0,0,0],[0,0,0,0,0,0,0],[0,0,0,0,0,0,0],[0,0,0,0,0,0,0]]).
%				Discs|Rings
%insirir dinâmicamente e depois remover
stats("White",[24,24]).
stats("Black",[24,24]).

%%Aux
abs(X,Y):-X>=0,!,Y is X.
abs(X,Y):-X<0,Y is (-1)*X. 

max(X,Y,X):-X>=Y,!.
max(X,Y,Y):-Y>X,!.

belongs(_,[]):-fail.
belongs(Element,[Element|_]).
belongs(Element,[_|T]):-belongs(Element,T).

listLength([],0).
listLength([_|T],Length):-listLength(T,X),Length is X+1.

getNextPlayer("White","Black").
getNextPlayer("Black","White").

%%Get 
getDisc(Player,Discs):-stats(Player,[Discs|_]).
getRings(Player,Rings):-stats(Player,[_|[Rings|_]]).

getElement(Tab,Line,Col,Element):-getLine(Tab,Line,LineToSearch),getCol(LineToSearch,Col,Element).
getLine(Tab,Line,Value):-getLine(Tab,Line,Value,0).
getLine([H|_],Line,H,Line).
getLine([_|T],Line,Value,Counter):- Counter1 is Counter +1,Counter<Line,getLine(T,Line,Value,Counter1).

getCol(Line,Col,Element):-getCol(Line,Col,0,Element).
getCol([H|_],Col,Col,H).
getCol([_|T],Col,Counter,Value):-Counter1 is Counter +1,Counter<Col,getCol(T,Col,Counter1,Value).

%%Set
setElement(Tab,Line,Col,Element,NewTab):-setLine(Tab,Line,Col,Element,NewTab).

setLine(Tab,Line,Col,Element,NewTab):-setLine(Tab,Line,Col,Element,NewTab,0).
setLine([H|T],Line,Col,Element,[H1|T],Line):-setCol(Element,Col,H,H1,0).
setLine([H|T],Line,Col,Element,[H|T1],Counter):-Counter1 is Counter +1,Counter<Line,setLine(T,Line,Col,Element,T1,Counter1).

setCol(Element,Col,[_|T],[Element|T],Col).
setCol(Element,Col,[H|T],[H|T1],Counter):-Counter1 is Counter +1,Counter<Col,setCol(Element,Col,T,T1,Counter1).

%Game Cycle
duploHex:-stats("Tab",Tab),stats("Black",Player),duploHex(Tab,Player,0),printTabuleiro(Tab).
duploHex(Tab,Player,0):-readMove(Line,Col,Piece),validateMove(Tab,Line,Col,Piece),!,setElement(Tab,Line,Col,Piece,NewTab),getNextPlayer(Player,NextPlayer),duploHex(Tab,NextPlayer,GameStatus).
%% If readMove valid then Validate Move, If validateMove Valid then Change the Board
%move(Tab,Player):-readMove(Line,Col,Piece),!,validateMove(),!,setElementl(Tab,Line,Col,Piece,NewTab).

%%Read
readMove(Line,Col,Piece):-readCoord(Line,0),readCoord(Col,1),readPiece(Piece).
readPiece(Piece):-write('Please Pick the Piece type (R/D): '),nl,read(Piece),validatePieceRead(Piece).
%%Read a Line
readCoord(Coord,0):-write('Please Pick the Line: '),nl,read(Coord),validateLineColRead(Coord).
%%Read a column
readCoord(Coord,1):-write('Please Pick the Column: '),nl,read(Coord),validateLineColRead(Coord).
%% Validate Input 

validateLineColRead('q'):-fail.
validateLineColRead(Input):-integer(Input),!,validPieces(VP),belongs(Input,VP).
validatePieceRead('q'):-fail.
validatePieceRead(Input):-validPieceNames(VPN),belongs(Input,VPN).

 
%% Validation of play
validateMove(Tab,PosL,PosC,Piece,Player):-getElement(Tab,PosL,PosC,CellElement),validateMoveCell(CellElement,Piece,Player),!.
%%the cell is empty everything is valid   
validateMoveCell(0,_,_).
%%situations where it must fail
validateMoveCell(CellElement,_,_):-fullCell(FC),belongs(CellElement,FC),!,fail.
%%on the board there is a ring and we must place a disk TODO CHANGE THE GET OF PIECES TO TAKE INTO ACCOUNT THE PLAYERS
validateMoveCell(CellElement,Piece,Player):-ringPieces(RP),diskPieces(DP),belongs(CellElement,RP),belongs(Piece,DP).
%%on the board there is a disk and we must place a ring
validateMoveCell(CellElement,Piece,Player):-ringPieces(RP),diskPieces(DP),belongs(CellElement,RP),belongs(Piece,DP).

 %%cada move será uma Lista constituida por [Line,Col,Piece,Score]
getMoveLine(Move,MoveLine):-getCol(Move,0,MoveLine).
getMoveCol(Move,MoveCol):-getCol(Move,1,MoveCol).
getMovePiece(Move,MovePiece):-getCol(Move,2,MovePiece).

getValidMove(Tab,Line,Col).

%%Picks a random move from the valid ones
getRandomMove(ValidMoves,RandomMove):-listLength(ValidMoves,UpperLimit),getRadomNumber(Number,UpperLimit),getRandomMove(ValidMoves,RandomMove,Number).
getRandomMove([H|_],H,0).
getRandomMove([_|T],RandomMove,Counter):- Counter>0,!,Counter1 is Counter-1,getRandomMove(T,RandomMove,Counter1).
getRadomNumber(Number,UpperLimit):-random(0,UpperLimit,Number).
 
%% Picks the Best Move from the available Moves

%%Sorted Insert where it inserts in the front if better than the one at the top or in the back if not... 
%%must make sure to keep everything ordered

%%Apply Move
applyMove(Tab,NewTab,Move):-getMoveLine(Move,MoveLine),getMoveCol(Move,MoveCol),getMovePiece(Move,MovePiece),setElement(Tab,MoveLine,MoveCol,MovePiece,NewTab).

%%To know if a player wins we need the initial piece coordinates and check the other side, ->black is always from 0 to 6 Lines and white 0 to 6 Col
%%therefore the only (I must read rules but I remember the player being able to place the piece wherever he felt like doing)
%%pontuar jogadas e criar jogadas válidas...

:-duploHex,stats("Tab",Tab),printTabuleiro(Tab).