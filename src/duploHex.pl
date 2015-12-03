:- use_module(library(clpfd)).
:- expects_dialect(sicstus).
%% "includes" change greed so if moves same payoff he random picks, and bug das peças compostas

:-[includes],[printBoard],[utilities].
:-use_module(library(random)).
:-use_module(library(lists)).
%%Which Player is the bot
:-dynamic bot/1.
%% Tab,Number of Rings/Disc Player
:-dynamic stats/2.
%% Greedy or Random
:-dynamic playMode/1.


%%Game Cycle
duploHex(Mode,Player):-initialize(Player,Mode),initStats,stats(tab,Tab),
play(Tab,black,_).

initStats:-asserta((stats(white,[24,24]))),asserta((numberList([0,1,2,3,4,5,6]))),asserta((stats(black,[24,24])))
,asserta((stats(tab,[
			[0,0,0,0,0,0,0],
			  [0,0,0,0,0,0,0],
				[0,0,0,0,0,0,0],
				  [0,0,0,0,0,0,0],
					[0,0,0,0,0,0,0],
					  [0,0,0,0,0,0,0],
						[0,0,0,0,0,0,0]
						]))).

initialize(Player,Mode):-playerTypes(PlayerTypes),botTypes(BotTypes),belongs(Player,PlayerTypes),belongs(Mode,BotTypes),
getNextPlayer(Player,Playerbot),asserta((bot(Playerbot))),asserta((playMode([Mode,Playerbot]))).

initialize(Player1,Player2):-playerTypes(PlayerTypes),belongs(Player1,PlayerTypes),belongs(Player2,PlayerTypes).

initialize(Bot,Bot1):- botTypes(BotTypes),belongs(Bot,BotTypes),belongs(Bot1,BotTypes),
asserta((bot(white))),asserta((bot(black))),asserta((playMode([Bot,black]))),asserta((playMode([Bot1,white]))).


a([
			[7,0,1,1,0,0,0],
			  [7,0,4,3,0,0,0],
				[3,0,4,3,0,0,0],
				  [4,4,4,3,0,0,0],
					[0,0,0,4,3,0,0],
					  [0,0,0,0,4,3,0],
						[0,0,0,0,0,1,1]
						]).
validatePlayer(Player):-getDisk(Player,Disk),getRing(Player,Ring),(validateNumberOfPieces(Player,Disk); validateNumberOfPieces(Player,Ring)).

play(Tab,Player,_):-checkEndGame(Tab,Player,Dist),Dist=:=0,!,printGameStatus(Tab),nl,result(victory,Player,Tab).

play(Tab,Player,_):-getNextPlayer(Player,NextPlayer),checkEndGame(Tab,NextPlayer,Dist),Dist=:=0,!,printGameStatus(Tab),result(victory,NextPlayer,Tab).

play(Tab,Player,_):-getNextPlayer(Player,NextPlayer),\+(validatePlayer(Player)),\+(validatePlayer(NextPlayer)),!,printGameStatus(Tab),result(draw).

play(Tab,Player,NewTab):-bot(Player) ,!,playMode([BotMode,Player|[]]) ,playBot(BotMode,Tab,NewTab,Player) ,getNextPlayer(Player,NextPlayer),play(NewTab,NextPlayer,_).

play(Tab,Player,NewTab):-printGameStatus(Tab),printStats(Player),pickMoveType(Type),playHuman(Type,Tab,NewTab,Player),getNextPlayer(Player,NextPlayer),play(NewTab,NextPlayer,_).

playBot(random,Tab,NewTab,Player):- createRandomMove(Tab,Line,Col,Piece,Player),SelectedMove =[Line,Col,Piece] ,updateStats(Player,Piece,SelectedMove,Tab),applyMove(Tab,NewTab,SelectedMove).

playBot(greedy,Tab,NewTab,Player):-numberList(NumberList),pickGreedyMove(Tab,Player,NumberList,SelectedMove),getMovePiece(SelectedMove,Piece),updateStats(Player,Piece,SelectedMove,Tab),
applyMove(Tab,NewTab,SelectedMove).

playHuman(addPiece,Tab,NewTab,Player):-moveAddPiece(Tab,NewTab,Player).

playHuman(movePiece,Tab,NewTab,Player):-moveChangeLocation(Tab,NewTab,Player).

printStats(Player):-getNextPlayer(Player,NextPlayer),getNumberOfRings(Player,NR),getNumberOfDisks(Player,ND),getNumberOfRings(NextPlayer,OR),getNumberOfDisks(NextPlayer,OD),
write('Player: '),write(Player),write('        |        '),write(NextPlayer),nl,
write('Rings:  '),write(NR),write('           |        '),write( OR),nl,
write('Disks:  '),write(ND),write('           |        '),write( OD),nl.

printGameStatus(Tab):-read(_),cls,printBoard(Tab),nl.
result(draw):-nl,write('It´s a draw!'),nl,retract.
result(victory,Player,Tab):-printGameStatus(Tab),write('Player: '-Player-' won the game'),retract,nl.
retract:-retract((bot(_))),retract((playMode(_))),retract((stats(white,_))),retract((stats(black,_))),retract((stats(tab,_))),asserta((numberList(_))).

/****************************************************************************************************************************************/
%%Gets

getElement(Tab,Line,Col,Element):-getLine(Tab,Line,LineToSearch),getCol(LineToSearch,Col,Element).
getLine(Tab,Line,Value):-getLine(Tab,Line,Value,0).
getLine([H|_],Line,H,Line).
getLine([_|T],Line,Value,Counter):- Counter1 is Counter +1,Counter<Line,getLine(T,Line,Value,Counter1).

getCol(Line,Col,Element):-getCol(Line,Col,0,Element).
getCol([H|_],Col,Col,H).
getCol([_|T],Col,Counter,Value):-Counter1 is Counter +1,Counter<Col,getCol(T,Col,Counter1,Value).

 %%cada move será uma Lista constituida por [Line,Col,Piece]
getMoveLine(Move,MoveLine):-getCol(Move,0,MoveLine).
getMoveCol(Move,MoveCol):-getCol(Move,1,MoveCol).
getMovePiece(Move,MovePiece):-getCol(Move,2,MovePiece).

getPieces(black,Pieces):-blackPieces(TempPieces),appendLists(TempPieces,Pieces).
getPieces(white,Pieces):-whitePieces(TempPieces),appendLists(TempPieces,Pieces).

getNumberOfPiece(Player,1,Number):-getNumberOfRings(Player,Number).
getNumberOfPiece(Player,2,Number):-getNumberOfDisks(Player,Number).
getNumberOfPiece(Player,3,Number):-getNumberOfRings(Player,Number).
getNumberOfPiece(Player,4,Number):-getNumberOfDisks(Player,Number).

getRandomPiece(Piece,black):-getRadomNumber(Line,2),blackPieces(BlackPieces),getCol(BlackPieces,Line,Piece).
getRandomPiece(Piece,white):-getRadomNumber(Line,2),whitePieces(WhitePieces),getCol(WhitePieces,Line,Piece).

getRadomNumber(Number,UpperLimit):-random(0,UpperLimit,Number). 

getStartingPointUp(black,_,_,6,_,_,_):-fail.
getStartingPointUp(white,_,6,_,_,_,_):-fail.	
getStartingPointUp(Player,Tab,Line,Col,PossiblePiece,Line,Col):-Col<7,Line<7,getElement(Tab,Line,Col,PossiblePiece),getPieces(Player,ValidPieces),belongs(PossiblePiece,ValidPieces).
getStartingPointUp(black,Tab,Line,Col,PossiblePiece,Line1,Col1):-Col<6,NextCol is Col+1,getStartingPointUp(black,Tab,Line,NextCol,PossiblePiece,Line1,Col1).
getStartingPointUp(white,Tab,Line,Col,PossiblePiece,Line1,Col1):-Line<6,NextLine is Line+1,getStartingPointUp(white,Tab,NextLine,Col,PossiblePiece,Line1,Col1).


getStartingPointDown(black,_,_,0,_,_,_):-fail.
getStartingPointDown(white,_,0,_,_,_,_):-fail.	
getStartingPointDown(Player,Tab,Line,Col,PossiblePiece,Line,Col):-Col>0,Line>0,getElement(Tab,Line,Col,PossiblePiece),getPieces(Player,ValidPieces),belongs(PossiblePiece,ValidPieces).
getStartingPointDown(black,Tab,Line,Col,PossiblePiece,Line1,Col1):-Col>0,NextCol is Col-1,getStartingPointDown(black,Tab,Line,NextCol,PossiblePiece,Line1,Col1).
getStartingPointDown(white,Tab,Line,Col,PossiblePiece,Line1,Col1):-Line>0,NextLine is Line-1,getStartingPointDown(white,Tab,NextLine,Col,PossiblePiece,Line1,Col1).

getStartingPoint(Player,Tab,Piece,Line1,Col1,1):-getStartingPointUp(Player,Tab,0,0,Piece,Line1,Col1) .
getStartingPoint(Player,Tab,Piece,Line1,Col1,0):- getStartingPointDown(Player,Tab,6,6,Piece,Line1,Col1).


getPossibleMoves(Tab,Player,NumberList,L):-findall( [PosL,PosC,NewPiece],(getSimplePieces(Player,PiecesList),member(PosL,NumberList),member(PosC,NumberList),member(Piece,PiecesList),
	validateMove(Tab,PosL,PosC,Piece,Player,NewPiece)),L).	
/****************************************************************************************************************************************/
%%Set
setElement(Tab,Line,Col,Element,NewTab):-setLine(Tab,Line,Col,Element,NewTab).

setLine(Tab,Line,Col,Element,NewTab):-setLine(Tab,Line,Col,Element,NewTab,0).
setLine([H|T],Line,Col,Element,[H1|T],Line):-setCol(Element,Col,H,H1,0).
setLine([H|T],Line,Col,Element,[H|T1],Counter):-Counter1 is Counter +1,Counter<Line,setLine(T,Line,Col,Element,T1,Counter1).

setCol(Element,Col,[_|T],[Element|T],Col).
setCol(Element,Col,[H|T],[H|T1],Counter):-Counter1 is Counter +1,Counter<Col,setCol(Element,Col,T,T1,Counter1).

%ring 													  									%disk ring
setNumberOfPiece(Player,1,NewNumber):-getNumberOfPiece(Player,2,Number),retract((stats(white,_))),asserta((stats(white,[Number,NewNumber]))).
%disk													  									%disk ring
setNumberOfPiece(Player,2,NewNumber):-getNumberOfPiece(Player,1,Number),retract((stats(white,_))),asserta((stats(white,[NewNumber,Number]))).
%ring													  									%disk ring
setNumberOfPiece(Player,3,NewNumber):-getNumberOfPiece(Player,4,Number),retract((stats(black,_))),asserta((stats(black,[Number,NewNumber]))).
%disk													  									%disk ring
setNumberOfPiece(Player,4,NewNumber):-getNumberOfPiece(Player,3,Number),retract((stats(black,_))),asserta((stats(black,[NewNumber,Number]))).

/****************************************************************************************************************************************/

%%Read
readMove(Tab,Line,Col,Piece,Player):-repeat,(readPieceLocation(Line,Col),readPiece(Piece,Line,Col,Tab,Player)).

readPieceLocation(Line,Col):-readCoord(Line,0),readCoord(Col,1).

readPiece(Piece,Line,Col,Tab,Player):-write('Please Pick the Piece type (r/d): '),nl,read(Input),validatePieceRead(Input,Piece,Line,Col,Tab,Player).
%%Read a Line
readCoord(Coord,0):-write('Please Pick the Line: '),nl,read(Coord),validateLineColRead(Coord).
%%Read a column
readCoord(Coord,1):-write('Please Pick the Column: '),nl,read(Coord),validateLineColRead(Coord).

pickMoveType(Type):-repeat,write('Please type - a - to add a Piece or - m - to move a Piece'),nl,read(X),(validateMoveType(X,Type)).

/****************************************************************************************************************************************/
 %%Validate Values a(X),validatePieceRead(1,P,0,1,X,white)

validateNumberOfPieces(Player,Piece):-getNumberOfPiece(Player,Piece,Number),between(Number,1,24).

validateNumberOfPieces(Player,Piece,1):-getNumberOfPiece(Player,Piece,Number),between(Number,1,24).

updateStats(Player,1,_,_):-getNumberOfPiece(Player,1,Number),NewNumber is Number-1,setNumberOfPiece(Player,1,NewNumber).
updateStats(Player,2,_,_):-getNumberOfPiece(Player,2,Number),NewNumber is Number-1,setNumberOfPiece(Player,2,NewNumber).
updateStats(Player,3,_,_):-getNumberOfPiece(Player,3,Number),NewNumber is Number-1,setNumberOfPiece(Player,3,NewNumber).
updateStats(Player,4,_,_):-getNumberOfPiece(Player,4,Number),NewNumber is Number-1,setNumberOfPiece(Player,4,NewNumber).
updateStats(white,6,_,_):-updateStats(white,1,_,_).
updateStats(black,6,_,_):-updateStats(black,4,_,_).
updateStats(white,8,_,_):-updateStats(black,2,_,_).
updateStats(black,8,_,_):-updateStats(black,3,_,_).
updateStats(white,5,Move,OldTab):-getMoveLine(Move,Line),getMoveCol(Move,Col),getElement(OldTab,Line,Col,CellElement),updateStats(white,CellElement,_,_).
updateStats(black,7,Move,OldTab):-getMoveLine(Move,Line),getMoveCol(Move,Col),getElement(OldTab,Line,Col,CellElement),updateStats(black,CellElement,_,_).


%%Validate Line Col
validateLineColRead(Input):-integer(Input),!,between(Input,0,6).

%%Validates Piece
validatePieceRead(Input,Piece,Line,Col,Tab,Player):-validPieceNames(VPN),belongs(Input,VPN),stringToBoardMember(Input,Player,BoardMember),!,
validateMove(Tab,Line,Col,BoardMember,Player,Piece),!,updateStats(Player,BoardMember,_,_).



%% Validation of play
validateMove(Tab,PosL,PosC,Piece,Player,NewPiece):-getElement(Tab,PosL,PosC,CellElement),validateMoveCell(CellElement,Piece,Player,NewPiece),validateNumberOfPieces(Player,Piece),!.
%%the cell is empty everything is valid   
validateMoveCell(0,NewPiece,_,NewPiece).
%%situations where it must fail
validateMoveCell(CellElement,_,_,_):-fullCell(FC),belongs(CellElement,FC),!,fail.
%%on the board there is a ring and we must place a disk TODO CHANGE THE GET OF PIECES TO TAKE INTO ACCOUNT THE PLAYERS
validateMoveCell(CellElement,Piece,Player,NewPiece):-ring(Player,RP),diskPieces(DP),belongs(CellElement,DP),belongs(Piece,RP),getNewPieceValue(CellElement,Piece,NewPiece).
%%on the board there is a disk and we must place a ring
validateMoveCell(CellElement,Piece,Player,NewPiece):-ringPieces(RP),disk(Player,DP),belongs(CellElement,RP),belongs(Piece,DP),getNewPieceValue(CellElement,Piece,NewPiece).


validateChange(Tab,NewTab,Player,Line,Col,LineToMove,ColToMove):-adjancent(Line,Col,LineToMove,ColToMove),getElement(Tab,Line,Col,Source),getPieces(Player,ValidPieces),
belongs(Source,ValidPieces),getElement(Tab,LineToMove,ColToMove,Dest),fullCell(FilledCells),\+(belongs(Source,FilledCells)),
\+(belongs(Dest,FilledCells)),getNewPieceValue(Dest,Source,NewDestPiece),setElement(Tab,LineToMove,ColToMove,NewDestPiece,NewTabTemp),
emptyCell(EmptyCellPiece),setElement(NewTabTemp,Line,Col,EmptyCellPiece,NewTab).


/****************************************************************************************************************************************/

%%Apply Move
applyMove(Tab,NewTab,Move):-getMoveLine(Move,MoveLine),getMoveCol(Move,MoveCol),getMovePiece(Move,MovePiece),setElement(Tab,MoveLine,MoveCol,MovePiece,NewTab).
/****************************************************************************************************************************************/

%Human
moveChangeLocation(Tab,NewTab,Player):-write('Pick Piece to move: '),nl,readPieceLocation(Line,Col),nl,write('Move to: '),nl,readPieceLocation(LineToMove,ColToMove),
validateChange(Tab,NewTab,Player,Line,Col,LineToMove,ColToMove),!.

moveAddPiece(Tab,NewTab,Player):-validatePlayer(Player),readMove(Tab,Line,Col,Piece,Player),applyMove(Tab,NewTab,[Line,Col,Piece]).
moveAddPiece(Tab,Tab,_).
/****************************************************************************************************************************************/

%%Greedy

pickGreedyMove(Tab,Player,NumberList,SelectedMove):-getNextPlayer(Player,Opponent),greedyMove(Tab,Player,NumberList,UserMove,UserScore),!,
greedyMove(Tab,Opponent,NumberList,OpponentMove,OpponentScore),!,pickMaxMove(Player,SelectedMove,UserScore,UserMove,OpponentScore,OpponentMove),write(UserMove),nl.

pickMaxMove(Player,ConvertedMove,UserScore,_,OpponentScore,OpponentMove):- OpponentScore<UserScore,convertMove(Player,OpponentMove,ConvertedMove).
pickMaxMove(_,UserMove,UserScore,UserMove,OpponentScore,_):-OpponentScore>=UserScore.

greedyMove(Tab,Player,NumberList,SelectedMove,Score):-validatePlayer(Player),getPossibleMoves(Tab,Player,NumberList,PossibleMoves),
listLength(PossibleMoves,ListLenght),scoreMoves(Tab,Player,PossibleMoves,ScoreList,0,ListLenght),listMin(ScoreList,Score,_),getValuesWithSameScore(ScoreList,Score,SameScoreMoves,0),
random_member(ScoreIndex,SameScoreMoves),getCol(PossibleMoves,ScoreIndex,SelectedMove).


 

getValuesWithSameScore([],_,[],_).
getValuesWithSameScore([H|T],Value,[Contador|T1],Contador):-Contador1 is Contador+1,H=:=Value,!,getValuesWithSameScore(T,Value,T1,Contador1).
getValuesWithSameScore([H|T],Value,Lista,Contador):-Contador1 is Contador+1,H=\=Value,!,getValuesWithSameScore(T,Value,Lista,Contador1).

greedyMove(_,Player,_,_,0):-!,\+(validatePlayer(Player)).

convertMove(Player,OpponentMove,ConvertedMove):-getNextPlayer(Player,Opponent),getMovePiece(OpponentMove,OpponentPiece),equivalent(Opponent,OpponentPiece,EquivalentPiece),setCol(EquivalentPiece,2,OpponentMove,ConvertedMove,0).
 
scoreMoves(_,_,[],[],_,_).

scoreMoves(Tab,Player,[Move|R],[Sc|T],Counter,ListLength):-Counter<ListLength,Counter1 is Counter+1,getCol(Move,0,Line),getCol(Move,1,Col),
getCol(Move,2,Piece),scoreMove(Tab,Player,Line,Col,Piece,Sc),scoreMoves(Tab,Player,R,T,Counter1,ListLength).

scoreMove(Tab,Player,Line,Col,Piece,NewTempSc):-checkEndGame(Tab,Player,TempSc),setElement(Tab,Line,Col,Piece,NewTab),checkEndGame(NewTab,Player,NewTempSc),getNextPlayer(Player,NextPlayer),
checkEndGame(NewTab,NextPlayer,TempSc1),checkIfDef(TempSc,0),checkIfDef(TempSc1,0),NewTempSc< TempSc.
scoreMove(_,_,_,_,_,7).

/****************************************************************************************************************************************/

%%Random  
createRandomMove(Tab,Line,Col,Piece,Player):-repeat,getRadomNumber(Line,7),getRadomNumber(Col,7),getRandomPiece(PieceTemp,Player),(validateMove(Tab,Line,Col,PieceTemp,Player,Piece)).

/****************************************************************************************************************************************/

%Check Distance till End of Game if FinalDist=:=0 then Player has won
checkEndGame(Tab,Player,FinalDist):-checkEndGameT(Tab,Player,Dist1),!,checkEndGameOtherRoute(Tab,Player,Dist2),!,min(Dist1,Dist2,FinalDist),!.

checkEndGameT(Tab,Player,Dist):-getStartingPoint(Player,Tab,Piece,Line1,Col1,1),checkEndGameAux(Tab,Line1,Col1,Piece,[[Line1,Col1]],Player,6,Dist).
checkEndGameT(_,_,7).

checkEndGameOtherRoute(Tab,Player,Dist):-getStartingPoint(Player,Tab,Piece,Line1,Col1,0),checkEndGameB(Tab,Line1,Col1,Piece,[[Line1,Col1]],Player,6,Dist).
checkEndGameOtherRoute(_,_,7).

checkEndGameAux(_,_,_,_,_,0,0).




%%Black only
checkEndGameAux(Tab,6,Col,FirstPiece,_,black,CurrDist,CurrDist):-getElement(Tab,6,Col,Element),getSimplePiece(Element,black,SimpleElement),check(FirstPiece,SimpleElement),CurrDist=:=0,!.

checkEndGameAux(Tab,Line,6,FirstPiece,_,white,CurrDist,CurrDist):-getElement(Tab,Line,6,Element),getSimplePiece(Element,white,SimpleElement),check(FirstPiece,SimpleElement),CurrDist=:=0,!.



checkEndGameAux(Tab,Line,Col,FirstPiece,Path,black,CurrDist,FinalDist):-CurrDist>1,between(Col,1,6),between(Line,0,6),
BeforeCol is Col-1,checkPath([Line,BeforeCol],Path,PathNew),
getElement(Tab,Line,BeforeCol,NewElement),getSimplePiece(NewElement,black,SimpleElement),check(FirstPiece,SimpleElement),!,
checkEndGameAux(Tab,Line,BeforeCol,SimpleElement,PathNew,black,CurrDist,FinalDist).

checkEndGameAux(Tab,Line,Col,FirstPiece,Path,black,CurrDist,FinalDist):-CurrDist>=1,between(Col,0,5),between(Line,0,6),
NextCol is Col+1,checkPath([Line,NextCol],Path,PathNew),getElement(Tab,Line,NextCol,NewElement),getSimplePiece(NewElement,black,SimpleElement),check(FirstPiece,SimpleElement),!
,checkEndGameAux(Tab,Line,NextCol,SimpleElement,PathNew,black,CurrDist,FinalDist).

checkEndGameAux(Tab,Line,Col,FirstPiece,Path,black,CurrDist,FinalDist):-CurrDist>=1,NextDist is CurrDist-1,between(Line,0,5),between(Col,0,6),
NextLine is Line+1,checkPath([NextLine,Col],Path,PathNew),getElement(Tab,NextLine,Col,NewElement),getSimplePiece(NewElement,black,SimpleElement),check(FirstPiece,SimpleElement),!,
checkEndGameAux(Tab,NextLine,Col,SimpleElement,PathNew,black,NextDist,FinalDist).

%%White only
 checkEndGameAux(Tab,Line,Col,FirstPiece,Path,white,CurrDist,FinalDist):-CurrDist>=1,between(Line,1,6),between(Col,0,6),LineBefore is Line-1,
 checkPath([LineBefore,Col],Path,PathNew),getElement(Tab,LineBefore,Col,NewElement),getSimplePiece(NewElement,white,SimpleElement),check(FirstPiece,SimpleElement),!,
 checkEndGameAux(Tab,LineBefore,Col,SimpleElement,PathNew,white,CurrDist,FinalDist).

checkEndGameAux(Tab,Line,Col,FirstPiece,Path,white,CurrDist,FinalDist):-CurrDist>=1,NextDist is CurrDist-1,between(Col,0,5),between(Line,0,6),
NextCol is Col+1,checkPath([Line,NextCol],Path,PathNew),getElement(Tab,Line,NextCol,NewElement),getSimplePiece(NewElement,white,SimpleElement),check(FirstPiece,SimpleElement),!
,checkEndGameAux(Tab,Line,NextCol,SimpleElement,PathNew,white,NextDist,FinalDist).

checkEndGameAux(Tab,Line,Col,FirstPiece,Path,white,CurrDist,FinalDist):-CurrDist>=1,between(Line,0,5),between(Col,0,6),
NextLine is Line+1,checkPath([NextLine,Col],Path,PathNew),getElement(Tab,NextLine,Col,NewElement),getSimplePiece(NewElement,white,SimpleElement),check(FirstPiece,SimpleElement),!,
checkEndGameAux(Tab,NextLine,Col,SimpleElement,PathNew,white,CurrDist,FinalDist).
 
%%Tanto para White como para Black

checkEndGameAux(Tab,Line,Col,FirstPiece,Path,Player,CurrDist,FinalDist):-CurrDist>=1,NextDist is CurrDist-1,between(Col,0,5),
between(Line,0,5),NextCol is Col+1,NextLine is Line+1,checkPath([NextLine,NextCol],Path,PathNew),getElement(Tab,NextLine,NextCol,NewElement),getSimplePiece(NewElement,Player,SimpleElement),
check(FirstPiece,SimpleElement),!,checkEndGameAux(Tab,NextLine,NextCol,SimpleElement,PathNew,Player,NextDist,FinalDist).

checkEndGameAux(_,_,_,_,_,_,CurrDist,CurrDist).

%falta fazer daqui para baixo o simplePiece
checkEndGameB(Tab,0,Col,FirstPiece,_,black,CurrDist,CurrDist):-getElement(Tab,0,Col,Element),getSimplePiece(Element,black,SimpleElement),check(FirstPiece,SimpleElement),CurrDist=:=0,!.

checkEndGameB(Tab,Line,0,FirstPiece,_,white,CurrDist,CurrDist):-getElement(Tab,Line,0,Element),getSimplePiece(Element,white,SimpleElement),check(FirstPiece,SimpleElement),CurrDist=:=0,!.




checkEndGameB(Tab,Line,Col,FirstPiece,Path,black,CurrDist,FinalDist):-CurrDist>1,between(Col,0,5),between(Line,0,6),NextCol is Col+1,
checkPath([Line,NextCol],Path,PathNew),getElement(Tab,Line,NextCol,NewElement),getSimplePiece(NewElement,black,SimpleElement),check(FirstPiece,SimpleElement),!,
checkEndGameB(Tab,Line,NextCol,SimpleElement,PathNew,black,CurrDist,FinalDist).

checkEndGameB(Tab,Line,Col,FirstPiece,Path,black,CurrDist,FinalDist):-CurrDist>=1,NextDist is CurrDist-1,between(Line,1,6),between(Col,0,6),
BeforeLine is Line-1,checkPath([BeforeLine,Col],Path,PathNew),getElement(Tab,BeforeLine,Col,NewElement),getSimplePiece(NewElement,black,SimpleElement),check(FirstPiece,SimpleElement),!,
checkEndGameB(Tab,BeforeLine,Col,SimpleElement,PathNew,black,NextDist,FinalDist).


checkEndGameB(Tab,Line,Col,FirstPiece,Path,black,CurrDist,FinalDist):-CurrDist>=1,between(Col,1,6),between(Line,0,6),
BeforeCol is Col-1,checkPath([Line,BeforeCol],Path,PathNew),getElement(Tab,Line,BeforeCol,NewElement),getSimplePiece(NewElement,black,SimpleElement),check(FirstPiece,SimpleElement),!,
checkEndGameB(Tab,Line,BeforeCol,SimpleElement,PathNew,black,CurrDist,FinalDist).



 checkEndGameB(Tab,Line,Col,FirstPiece,Path,white,CurrDist,FinalDist):-CurrDist>=1,between(Col,0,6),between(Line,0,5),NextLine is Line+1,checkPath([NextLine,Col],Path,PathNew),
 getElement(Tab,NextLine,Col,NewElement),getSimplePiece(NewElement,white,SimpleElement),check(FirstPiece,SimpleElement),!, 
 checkEndGameB(Tab,NextLine,Col,SimpleElement,PathNew,white,CurrDist,FinalDist).

checkEndGameB(Tab,Line,Col,FirstPiece,Path,white,CurrDist,FinalDist):-CurrDist>=1,between(Line,1,6),between(Col,0,6),BeforeLine is Line-1,checkPath([BeforeLine,Col],Path,PathNew),
getElement(Tab,BeforeLine,Col,NewElement),getSimplePiece(NewElement,white,SimpleElement),check(FirstPiece,SimpleElement),!,
checkEndGameB(Tab,BeforeLine,Col,SimpleElement,PathNew,white,CurrDist,FinalDist). 

checkEndGameB(Tab,Line,Col,FirstPiece,Path,white,CurrDist,FinalDist):-CurrDist>=1,NextDist is CurrDist-1,between(Col,1,6),between(Line,0,6),BeforeCol is Col-1,
checkPath([Line,BeforeCol],Path,PathNew),getElement(Tab,Line,BeforeCol,NewElement),getSimplePiece(NewElement,white,SimpleElement),check(FirstPiece,SimpleElement),!,
checkEndGameB(Tab,Line,BeforeCol,SimpleElement,PathNew,white,NextDist,FinalDist).

%%Tanto para White como para Black


checkEndGameB(Tab,Line,Col,FirstPiece,Path,Player,CurrDist,FinalDist):-CurrDist>=1,NextDist is CurrDist-1,between(Col,1,6),between(Line,1,6),BeforeCol is Col-1,BeforeLine is Line-1, 
checkPath([BeforeLine,BeforeCol],Path,PathNew),getElement(Tab,BeforeLine,BeforeCol,NewElement),getSimplePiece(NewElement,Player,SimpleElement),check(FirstPiece,SimpleElement),!,
checkEndGameB(Tab,BeforeLine,BeforeCol,SimpleElement,PathNew,Player,NextDist,FinalDist).

checkEndGameB(_,_,_,_,_,_,CurrDist,CurrDist).

