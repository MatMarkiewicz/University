%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Dictionary
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


:- [skladnicaTagsBases].

hasTag(Word, Tag) :- tagAndBase(Word,_Base,Tag).

hasTag(w, prep:loc).
 
:- op(1050, xfx, ==>).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMMAR
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


likeAdj(adj:L:P:R:_, L, P, R).
likeAdj(ppas:L:P:R:_, L, P, R).
likeAdj(pact:L:P:R:_, L, P, R).
likeAdj(padj:L:P:R:_, L, P, R).

np(L,P,R) ==> adj(L,P,R), np(L,P,R).
np(L,P,R) ==> np(L,P,R), adj(L,P,R).
np(L,P,R) ==> num(L,P,_), np(L,P,R).
np(L,P,R) ==> np(L,P,R), np(_,gen,_).
np(pl,P,R1) ==> np(_,P,R1), [i], np(_,P,_R2).
np(L,P,R) ==> subst(L,P,R).
np(L,P,R) ==> psupst(L,P,R), np(L,P,R).
np(L,P,R) ==> np(L,P,R), [,], np(L,P,R).
np(L,P,R) ==> np(L,P,R), [z], np(L,P,R).
np(L,P,R) ==> np(L,P,R), [do], np(_,_,_).
np(L,P,R) ==> np(L,P,R), [w], np(_,loc,_).
np(L,P,R) ==> np(L,P,R), [we], np(_,loc,_).
np(L,P,R) ==> np(L,P,R), [na], np(_,_,_).
np(L,P,R) ==> np(L,P,R), [z], np(_,_,_).
np(L,P,R) ==> np(_,_,_), [z], np(L,P,R).
np(L,P,R) ==> ger(_,P,R), np(L,P,R).

subst(L,P,R) ==> [X], {hasTag(X,subst:L:P:R)}.
subst(sg,nom,m2) ==> subst(sg,nom,m2), subst(sg,nom,m2).
subst(sg,nom,m1) ==> subst(sg,nom,m1), subst(sg,nom,m1).
subst(L,nom,R) ==> subst(L,nom,R), [w], subst(L,loc,_).

adja() ==> [X], {hasTag(X,adja)}.
adj(L,P,R) ==> [X], {hasTag(X, Tag), likeAdj(Tag,L,P,R)}.
adj(L,P,R) ==> adja(), [-], adj(L,P,R).
adj(L,P,R) ==> adj(L,P,R), [i], adj(L,P,R).

num(L,P,R) ==> [X], {hasTag(X, num:L:P:R:_)}.
num(L,P,R) ==> num(L,P,R), [tys], [.].
num(L,P,R) ==> num(L,P,R), [proc], [.].
num(L,P,R) ==> num(L,P,R), [mln].
num(L,P,R) ==> [ok], [.], num(L,P,R).

psupst(L,P,R) ==> [X], {hasTag(X, psubst:L:P:R)}.

ppron3(L,P,R) ==> [X], {hasTag(X, ppron3:L:P:R:_)}.

ger(L,P,R) ==> [X], {hasTag(X, ger:L:P:R:_:_)}.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parse
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
commasToList((X,Y), [X|Rest]) :- 
   !, commasToList(Y,Rest).
commasToList(X,[X]).   


allign( [[W]| Rest], [W|T], Alligment) :-
   !,allign(Rest, T, Alligment). 
allign( [At|Rest], Ts, [ (At,Pref) | ARest]):-
   Pref = [_|_],
   append(Pref, RestT, Ts),
   allign(Rest, RestT, ARest).
allign( [{C}], [], []) :- C.
allign( [], [], []).


   
parse(A,TokensToParse) :-
   (A ==> Right),
   commasToList(Right, ListRight),
   allign(ListRight, TokensToParse, Alligment),
   parsePairs(Alligment).
   
parsePairs([]).
parsePairs([(A,L)| Rest]):-
   parse(A,L),
   parsePairs(Rest).

writeList([A]) :- write(A),!.
writeList([A|As]):- write(A), write(' '),writeList(As).
   
parse0 :-
   %see('phrases.pl'),
   see('bad_phrases3.pl'),
   parsing,
   seen.

parsing :-
   repeat,
   read(L),
   analyze(L),
   L = end_of_file,!.

analyze(end_of_file) :-
   write('DONE!'), nl, !.
analyze(L) :-   
   length(L,N),
   N < 9,
   parse(np(_,_,_), L),
   write('GOOD:'),
   writeList(L),nl,!.
analyze(L) :-
   write('BAD:'), writeList(L),nl,!.


:- parse0.
