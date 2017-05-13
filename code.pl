bop_arithmetic('+').
bop_arithmetic('-').
bop_arithmetic('*').
bop_arithmetic('%').
bop_comparator('<').
bop_comparator('<=').
bop_comparator('>').
bop_comparator('>=').
bop_comparator('==').
bop_comparator('!=').
uop_boolean('!').
bop_boolean('&&').
bop_boolean('||').
bop_bitset('&').
bop_bitset('|').
bop_bitset('>>').
bop_bitset('<<').
uop_bitset('~').
bop_equals('=').
bop_equals_boolean('&=').
bop_equals_boolean('|=').
bop_equals_int_float('+=').
bop_equals_int_float('-=').
bop_equals_int_float('*=').
bop_equals_int_float('/=').
bop_equals_int_float('%=').
bop_equals_bitset('<<=').
bop_equals_bitset('>>=').

bop_address_increment('+').
bop_address_difference('-').
uop_address_of('&').
type_define('int').
type_define('float').
type_define('boolean').
type_define('bitset').
type_define('address').
conditional_question('?').
conditional_colon(':').

integer_expr(['int']).
integer_expr([X]):-integer(X).
integer_expr([A,B|X]):-integer_expr([A]),bop_arithmetic(B),integer_expr(X).
integer_expr([A,B|X]):-integer_expr([A]),bop_equals_int_float(B),integer_expr(X).
integer_expr([A,B|X]):-address_expr([A]),bop_address_difference(B),address_expr(X).
integer_expr([X]):-integer_expr(X).

float_expr(['float']).
float_expr([X]):-float(X).
float_expr([A,B|X]):-float_expr([A]),bop_arithmetic(B),float_expr(X).
float_expr([A,B|X]):-float_expr([A]),bop_equals_int_float(B),float_expr(X).
float_expr([X]):-float_expr(X).

boolean_expr(['TRUE']).
boolean_expr(['FALSE']).
boolean_expr([[A,B,C]]):-integer_expr([A]),bop_comparator(B),integer_expr([C]).
boolean_expr([[A,B,C]]):-float_expr([A]),bop_comparator(B),float_expr([C]).
boolean_expr([X,Y|Z]):-boolean_expr([X]),bop_boolean(Y),boolean_expr(Z).
boolean_expr([Y|Z]):-uop_boolean(Y),boolean_expr(Z).
boolean_complete_expr(X):-boolean_expr([X]).

bitset_expr(['bitset']).
bitset_expr([Z]):-integer_expr([Z]);float_expr([Z]).
bitset_expr([X,Y|Z]):-bitset_expr([X]),bop_bitset(Y),bitset_expr([Z]).
bitset_expr([Y|Z]):-uop_bitset(Y),bitset_expr(Z).
bitset_expr([X]):-bitset_expr(X).

address_expr(['address']).
address_expr([A,B|T]):-address_expr([A]),bop_address_increment(B),integer_expr(T).

type_assign(X,'int'):-integer_expr(X).
type_assign(X,'float'):-float_expr(X).
type_assign(X,'boolean'):-boolean_expr(X).
type_assign(X,'bitset'):-bitset_expr(X).
type_assign(X,'address'):-address_expr(X).

equals_expr([A,B,C]):-bitset_expr(A),bop_equals_bitset(B),bitset_expr(C).
equals_expr([A,B,C]):-boolean_expr(A),bop_equals_boolean(B),boolean_expr(C).
equals_expr([A,B,C]):-integer_expr(A),bop_equals_int_float(B),integer_expr(C).
equals_expr([A,B,C]):-float_expr(A),bop_equals_int_float(B),float_expr(C).
equals_expr([A,B,C]):-type_assign(A,X),bop_equals(B),type_assign(C,X).
equals_expr([X]):-equals_expr(X).



conditional_expr([E1,E2,E3,E4,E5]):-boolean_expr([E1]),conditional_question(E2),type_assign(E3,X),conditional_colon(E4),type_assign(E5,X).


replace([],_,[]).
replace([H|T],[A,B],[B|Result]) :- H=A, replace(T,[A,B],Result).
replace([H|T],[A,B],[L|Result]) :- replace(H,[A,B],L),replace(T,[A,B],Result).
replace([H|T],[A,B],[H|Result]) :- replace(T,[A,B],Result).

variable_mapping([],L,L).
variable_mapping([[A,B]|T],L,W):-replace(L,[A,B],M),variable_mapping(T,M,W).

replace_address([],_,_,[]).
replace_address([H,I|T],A,C,[C|Result]) :- H=A,type_define(I), replace_address(T,A,C,Result).
replace_address([H|T],A,C,[H|Result]) :- replace_address(T,A,C,Result).

address_of_expr([[A,B]|T],L,O):-variable_mapping([[A,B]|T],L,W),replace_address(W,'&','address',O).

variable_mapping_address([],L,L).
variable_mapping_address([[A,B,C]|T],L,W):-replace(L,[C,A],M),replace_address(M,'*',B,O),variable_mapping_address(T,O,W).

is_correct_no_var(X):-integer_expr(X);float_expr(X);boolean_complete_expr(X);boolean_expr(X);bitset_expr(X);conditional_expr(X);address_expr(X);equals_expr(X).
is_correct([[],Y]):-is_correct_no_var(Y).
is_correct([[[A,B]|T],L]):-variable_mapping([[A,B]|T],L,W),is_correct_no_var(W).
is_correct([[[A,B]|T],L]):-address_of_expr([[A,B]|T],L,O),is_correct_no_var(O).
is_correct([[[A,B,C]|T],L]):-variable_mapping_address([[A,B,C]|T],L,O),is_correct_no_var(O).




