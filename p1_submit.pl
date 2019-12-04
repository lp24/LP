/*Luis Ferreira, nr83500 */

linha((X,_),X).
coluna((_,X),X).
head([H|_],H).

membro_2(X,[H|_],H):-member(X,H),!.
membro_2(X,[_|T],H):-membro_2(X,T,H).
/* de uma lista de listas, devolve a lista(correspondente ao termometro) que tem o membro(posicao) 'X' */

propaga([Pos|_],Pos,Ac,Propagado):-append(Ac,[Pos],Propagado),!.
propaga([H|T],Pos,Ac,Propagado):-H\==Pos,
	append(Ac,[H],Ac_aux),
	propaga(T,Pos,Ac_aux,Propagado).

propaga([First_termometer|_],Pos,Propagado):-membro_2(Pos,First_termometer,Termometer),
	propaga(Termometer,Pos,[],Propagado_aux),
	sort(Propagado_aux,Propagado).
/* Da lista de termometros, escolhe o que tem a posicao 'Pos', e copia os elementos da base do termometro ate essa posicao, e ordena*/

verifica_parcial([_,_,T_Colunas],Ja_Preenchidas,Dim,Poss):-append(Ja_Preenchidas,Poss,Aux),
	remove_repetidos(Aux,Todas_Posicoes),
	verifica_colunas(T_Colunas,Todas_Posicoes,Dim,1).
/*Concatena as listas de posicoes, remove os duplicados,e 'verifica_colunas' faz a verificacao das colunas*/

remove_repetidos([],[]):-!.
remove_repetidos([H|T],L):-member(H,T),!,remove_repetidos(T,L).
remove_repetidos([H|T],[H|L]):-remove_repetidos(T,L).
/*Funcao do Livro Logica e Raciocinio de Joao Pavao Martins, remove elementos repetidos */

verifica_colunas(_,_,Dim,Col):- Dim+1=:=Col,!.
verifica_colunas([H|T],Posicoes,Dim,Col):-Dim>=Col,
	soma_col(Col,Posicoes,Soma,0),
	Soma=<H,
	Col_aux is Col+1,
	verifica_colunas(T,Posicoes,Dim,Col_aux).
/*Dada a lista de posicoes 'Posicoes' e a lista de totais '[H|T]',verifica que a soma de cada coluna 'Soma' e menor que o total permitido para essa coluna 'H' */

soma_col(Col,[H|T],Soma,Ac):-coluna(H,Column),
	Column==Col,!,
	Ac_aux is Ac+1,
	soma_col(Col,T,Soma,Ac_aux).

soma_col(Col,[H|T],Soma,Ac):-coluna(H,Column),
	Column=\=Col,!,
	soma_col(Col,T,Soma,Ac).

soma_col(_,[],Soma,Soma).
/*Soma o numero de elemento numa coluna */

nao_altera_linhas_anteriores([],_,_):-!.
nao_altera_linhas_anteriores([H|T],L,Ja_Preenchidas):-linha(H,Line),
	Line<L,!,member(H,Ja_Preenchidas),
	nao_altera_linhas_anteriores(T,L,Ja_Preenchidas).

nao_altera_linhas_anteriores([H|T],L,Ja_Preenchidas):-linha(H,Line),Line>=L,nao_altera_linhas_anteriores(T,L,Ja_Preenchidas).

/* Dada uma Lista de Posicoes '[H|T]', se a primeira posicao 'H' tiver linha menor que 'L', verifica se esta tambem na lista 'Ja_preenchidas'. Verifica para o resto la lista */

escolhe_N(_,N,Escolhidos,N,Escolhidos):-!.
escolhe_N(Lista,N,Escolhidos,Ac_N,Ac_Esc):-Ac_N<N,
	member(M,Lista),
	(Ac_Esc\==[]->coluna(M,M_Col),last(Ac_Esc,Ultimo),coluna(Ultimo,Last_Col),M_Col>=Last_Col;true),
	append(Ac_Esc,[M],Ac_Esc_aux),
	Ac_N_aux is Ac_N+1,
	select(M,Lista,Lista_aux),
	escolhe_N(Lista_aux,N,Escolhidos,Ac_N_aux,Ac_Esc_aux).
/*de uma linha L, escolhe N elementos (sem reposicao). */

testa(Puz,Posicoes_linha,Ja_Preenchidas,Escolha,[],Dim,Possibilidade,Possibilidade):-!,head(Posicoes_linha,X),
	linha(X,Linha),
	foreach((member(M,Possibilidade),linha(M,M_Linha),M_Linha=:=Linha),member(M,Escolha)),
	foreach((member(M_2,Ja_Preenchidas),linha(M_2,M_2_L),M_2_L=:=Linha),member(M_2,Possibilidade)),
	nao_altera_linhas_anteriores(Possibilidade,Linha,Ja_Preenchidas),
	verifica_parcial(Puz,Ja_Preenchidas,Dim,Possibilidade).
/*Verifica se uma escolha e possivel */

testa(Puz,Posicoes_linha,Ja_Preenchidas,Escolha,[H|T],Dim,Possibilidade,Ac):-
	propaga(Puz,H,Propagado),
	append(Ac,Propagado,Ac_with_duplicates),
	remove_repetidos(Ac_with_duplicates,Ac_aux),
	testa(Puz,Posicoes_linha,Ja_Preenchidas,Escolha,T,Dim,Possibilidade,Ac_aux).
/*A lista 'Possibilidade' e uma lista de todos os elementos da lista '[H|T]'(inicialmente uma escolha), depois de propagados todos os seus elementos, removendo duplicados e ordenando. Essa Possibilidade e depois verificada*/

possibilidades(_,_,_,[],Possibilidades_L,Possibilidades_L):-!.
possibilidades(Puz,Posicoes_linha,Ja_Preenchidas,[H|T],Poss_possiveis,Possibilidades_L):-length(Posicoes_linha,Dim),
	(testa(Puz,Posicoes_linha,Ja_Preenchidas,H,H,Dim,Poss_possivel_aux,[])->
		sort(Poss_possivel_aux,Poss_possivel),
		append(Poss_possiveis,[Poss_possivel],Poss_possiveis_aux),
	        possibilidades(Puz,Posicoes_linha,Ja_Preenchidas,T,Poss_possiveis_aux,Possibilidades_L);
        possibilidades(Puz,Posicoes_linha,Ja_Preenchidas,T,Poss_possiveis,Possibilidades_L)).
/* Possibilidades_L e a lista de escolhas '[H|T]' depois de verifica quais das possibilidades sao possiveis (propagadas) */

possibilidades_linha(Puz,Posicoes_linha,Total,Ja_Preenchidas,Possibilidades_L):-findall(Escolha,escolhe_N(Posicoes_linha,Total,Escolha,0,[]),Possibilidades),
	possibilidades(Puz,Posicoes_linha,Ja_Preenchidas,Possibilidades,[],Possibilidades_aux_L),
	sort(Possibilidades_aux_L,Possibilidades_L).
/* Encontra todas as formas de escolher N elementos de uma lista (sem reposicao e ordem nao interessa), e verifica quais sao possibilidades. Depois ordena. */

pos_linha(_,Dim,Posicoes_linha,Posicoes_linha,Col):-Col=:=Dim+1,!.
pos_linha(Linha,Dim,Posicoes_linha,Ac_Posicoes,Col):-Col=<Dim,
	Pos=(Linha,Col),
	append(Ac_Posicoes,[Pos],Ac_Posicoes_aux),
	Col_aux is Col+1,
	pos_linha(Linha,Dim,Posicoes_linha,Ac_Posicoes_aux,Col_aux).
/*Dada o numero de uma linha 'L' e a dimensaodo puzzle 'Dim', devolve uma lista com todas as posicoes dessa linha */

total_linha([Total|_],Linha,Total,Linha):-!.
total_linha([_|T],Linha,Total,Ac):-Linha>Ac,
	Ac_aux is Ac+1,
	total_linha(T,Linha,Total,Ac_aux).
/* devolve o total permitido para uma linha 'L' */

escolhe_possibilidade(_,_,_,_,_,[]):-!,fail.
escolhe_possibilidade(Puz,Solucao,Dim,Ja_Preenchido,Linha,[H|_]):-
	append(Ja_Preenchido,H,Ja_Preenchido_aux_with_duplicates),
	 remove_repetidos(Ja_Preenchido_aux_with_duplicates,Ja_Preenchido_aux),
	 Linha_aux is Linha+1,
	 resolve(Puz,Solucao,Dim,Ja_Preenchido_aux,Linha_aux),!.
	 /* Para verificar se ha mais de uma solucao para o problema, retirar '!'*/

escolhe_possibilidade(Puz,Solucao,Dim,Ja_Preenchido,Linha,[_|T]):-
	escolhe_possibilidade(Puz,Solucao,Dim,Ja_Preenchido,Linha,T).
/*ou utiliza primeira possibilidade, ou retira e escolhe de novo.*/

resolve(_,Solucao,Dim,Ja_Preenchido,Linha):-Linha=:=Dim+1,!,sort(Ja_Preenchido,Solucao).
resolve([Term,T_Linhas,T_Colunas],Solucao,Dim,Ja_Preenchido,Linha):- Linha=<Dim,
	pos_linha(Linha,Dim,Posicoes_linha,[],1),
	total_linha(T_Linhas,Linha,Total,1),
	possibilidades_linha([Term,T_Linhas,T_Colunas],Posicoes_linha,Total,Ja_Preenchido,Possibilidades_L),
	escolhe_possibilidade([Term,T_Linhas,T_Colunas],Solucao,Dim,Ja_Preenchido,Linha,Possibilidades_L).

resolve([Term,T_Linhas,T_Colunas],Solucao):-length(T_Linhas,Dim),resolve([Term,T_Linhas,T_Colunas],Solucao,Dim,[],1).
/*Descobre a lista de posicoes, o total permitido e as possibilidades para cada linha. escolhe uma possibilidade e passa a linha seguinte. */
