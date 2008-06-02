Nonterminals
  grammar
  statements
  statement_ending
  ending_token
  module_decl
  functions
  function
  exprs
  expr
  match_expr
  comp_expr
  comp_op
  add_expr
  add_op
  mult_expr
  mult_op
  pow_expr
  pow_op
  unary_expr
  unary_op
  erl_funcall_expr
  erl_funcall
  funcall_expr
  funcall
  range_expr
  primitive
  inline_statements
  number
  list
  tuple
  dict
  entries
  lambda
  .
  
Terminals
  true false nil
  float integer string regexp atom identifier constant module
  eol indent dedent def fun do 
  '(' ')' '[' ']' '{' '}' '|' % '<<' '>>'
  '+' '-' '*' '/' '%' '**'
  '.' '..' ',' ':' '::' ';'
  '=' '==' '!=' '>' '<' '<=' '>='
  .

Rootsymbol grammar.

grammar -> statements : '$1'.

%% Program statements
statements -> module_decl : ['$1'].
statements -> expr : ['$1'].
statements -> expr statement_ending : ['$1'].
statements -> expr statement_ending statements : ['$1'|'$3'].

%% Statement endings
statement_ending -> ending_token : '$1'.
statement_ending -> statement_ending ending_token : '$1'.
ending_token -> ';' : '$1'.
ending_token -> eol : '$1'.

%% Inline statements
inline_statements -> expr : ['$1'].
inline_statements -> expr ';' exprs : ['$1'|'$3'].

%% Module declaration
module_decl -> module constant eol indent functions dedent : {module, line('$1'), '$2', '$5'}.

%% Functions
functions -> function : ['$1'].
functions -> function functions : ['$1'|'$2'].

function -> def identifier eol indent statements dedent : {function, line('$1'), '$2', [], '$5'}.
function -> def identifier '(' exprs ')' eol indent statements dedent : {function, line('$1'), '$2', '$4', '$8'}.

%% Expressions
exprs -> expr : ['$1'].
exprs -> expr ',' exprs : ['$1'|'$3'].

expr -> match_expr : '$1'.

match_expr -> comp_expr '=' match_expr : {match, line('$2'), '$1', '$3'}.
match_expr -> comp_expr : '$1'.

comp_expr -> add_expr comp_op add_expr : {op, '$2', '$1', '$3'}.
comp_expr -> add_expr : '$1'.

add_expr -> add_expr add_op mult_expr : {op, '$2', '$1', '$3'}.
add_expr -> mult_expr : '$1'.

mult_expr -> mult_expr mult_op pow_expr : {op, '$2', '$1', '$3'}.
mult_expr -> pow_expr : '$1'.

pow_expr -> pow_expr pow_op unary_expr : {op, '$2', '$1', '$3'}.
pow_expr -> unary_expr : '$1'.

unary_expr -> unary_op unary_expr : {op, '$1', '$2'}.
unary_expr -> erl_funcall_expr : '$1'.

erl_funcall_expr -> erl_funcall : '$1'.
erl_funcall_expr -> funcall_expr : '$1'.

funcall_expr -> funcall : '$1'.
funcall_expr -> range_expr : '$1'.

range_expr -> range_expr '..' primitive : {range, line('$2'), '$1', '$3'}.
range_expr -> primitive : '$1'.

primitive -> identifier : '$1'.
primitive -> nil        : '$1'.
primitive -> true       : '$1'.
primitive -> false      : '$1'.
primitive -> number     : '$1'.
primitive -> string     : '$1'.
primitive -> regexp     : '$1'.
primitive -> list       : '$1'.
primitive -> tuple      : '$1'.
primitive -> dict       : '$1'.
primitive -> atom       : '$1'.
primitive -> lambda     : '$1'.
primitive -> '(' expr ')' : '$2'.

%% Comparison operators
comp_op -> '==' : '$1'.
comp_op -> '!=' : '$1'.
comp_op -> '>'  : '$1'.
comp_op -> '<'  : '$1'.
comp_op -> '>=' : '$1'.
comp_op -> '<=' : '$1'.

%% Addition operators
add_op -> '+' : '$1'.
add_op -> '-' : '$1'.

%% Multiplication operators
mult_op -> '*' : '$1'.
mult_op -> '/' : '$1'.
mult_op -> '%' : '$1'.

%% Exponentation operator
pow_op -> '**' : '$1'.

%% Unary operators
unary_op -> '+' : '$1'.
unary_op -> '-' : '$1'.

%% Erlang function calls
erl_funcall -> identifier '::' identifier '(' ')' : {erl_funcall, line('$2'), '$1', '$3', []}.
erl_funcall -> identifier '::' identifier '(' exprs ')' : {erl_funcall, line('$2'), '$1', '$3', '$5'}.

%% Function calls
funcall -> erl_funcall_expr '.' identifier '(' ')' : {funcall, line('$2'), '$1', '$3', []}.
funcall -> erl_funcall_expr '.' identifier '(' exprs ')' : {funcall, line('$2'), '$1', '$3', '$5'}.

%% Function calls with inline blocks
funcall -> erl_funcall_expr '.' identifier '{' inline_statements '}' : {funcall, line('$2'), '$1', '$3', [], {lambda, line('$2'), [], '$5'}}.
funcall -> erl_funcall_expr '.' identifier '{' '|' exprs '|' inline_statements '}' : {funcall, line('$2'), '$1', '$3', [], {lambda, line('$2'), '$6', '$8'}}.
funcall -> erl_funcall_expr '.' identifier '(' ')' '{' inline_statements '}' : {funcall, line('$2'), '$1', '$3', [], {lambda, line('$2'), [], '$7'}}.
funcall -> erl_funcall_expr '.' identifier '(' ')' '{' '|' exprs '|' inline_statements '}' : {funcall, line('$2'), '$1', '$3', [], {lambda, line('$2'), '$8', '$10'}}.
funcall -> erl_funcall_expr '.' identifier '(' exprs ')' '{' inline_statements '}' : {funcall, line('$2'), '$1', '$3', '$5', {lambda, line('$2'), [], '$8'}}.
funcall -> erl_funcall_expr '.' identifier '(' exprs ')' '{' '|' exprs '|' inline_statements '}' : {funcall, line('$2'), '$1', '$3', '$5', {lambda, line('$2'), '$9', '$11'}}.

%% Function calls with multi-line blocks
funcall -> erl_funcall_expr '.' identifier do eol indent statements dedent : {funcall, line('$2'), '$1', '$3', [], {lambda, line('$2'), [], '$7'}}.
funcall -> erl_funcall_expr '.' identifier do '|' exprs '|' eol indent statements dedent : {funcall, line('$2'), '$1', '$3', [], {lambda, line('$2'), '$6', '$10'}}.
funcall -> erl_funcall_expr '.' identifier '(' ')' do eol indent statements dedent : {funcall, line('$2'), '$1', '$3', [], {lambda, line('$2'), [], '$9'}}.
funcall -> erl_funcall_expr '.' identifier '(' ')' do '|' exprs '|' eol indent statements dedent : {funcall, line('$2'), '$1', '$3', [], {lambda, line('$2'), '$8', '$12'}}.
funcall -> erl_funcall_expr '.' identifier '(' exprs ')' do eol indent statements dedent : {funcall, line('$2'), '$1', '$3', '$5', {lambda, line('$2'), [], '$10'}}.
funcall -> erl_funcall_expr '.' identifier '(' exprs ')' do '|' exprs '|' eol indent statements dedent : {funcall, line('$2'), '$1', '$3', '$5', {lambda, line('$2'), [], '$10'}}.

%% Numbers
number -> float : '$1'.
number -> integer : '$1'.

%% Lists
list -> '[' ']' : {list, line('$1'), []}.
list -> '[' exprs ']' : {list, line('$1'), '$2'}.

%% Tuples
tuple -> '(' ')' : {tuple, line('$1'), []}.
tuple -> '(' expr ',' ')' : {tuple, line('$1'), ['$2']}.
tuple -> '(' expr ',' exprs ')': {tuple, line('$1'), ['$2'|'$4']}.

%% Dicts
dict -> '{' '}' : {dict, line('$1'), []}.
dict -> '{' entries : {dict, line('$1'), '$2'}.

entries -> 'comp_expr' ':' expr '}' : [{'$1','$3'}].
entries -> comp_expr ':' expr ',' entries : [{'$1','$3'}|'$5'].

%% Lambdas
lambda -> fun '(' ')' '{' inline_statements '}' : {lambda, line('$1'), [], '$5'}.
lambda -> fun '(' exprs ')' '{' inline_statements '}' : {lambda, line('$1'), '$3', '$5'}.
lambda -> fun do indent statements dedent : {lambda, line('$1'), [], '$4'}.
lambda -> fun '(' exprs ')' do indent statements dedent : {lambda, line('$1'), '$3', '$7'}.

Erlang code.

%% keep track of line info in tokens
line(Tup) -> element(2, Tup).