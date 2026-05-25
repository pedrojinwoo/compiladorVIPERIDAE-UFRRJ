%{
#include <iostream>
#include <string>
#include <variant>
#include <map>
#include <vector>
#include <stack>

#define YYSTYPE attributes

using namespace std;

struct attributes
{
	string label;
	string traducao;
	string type;
	variant<monostate, int, float, char, bool, string> value;
};
struct symbol
{
	string id;
	string alias;
	string type;
	variant<monostate, int, float, char, bool, string> value;
};
struct labelPair
{
	string startLabel;
	string falseLabel;
	string stepLabel;
	string endLabel;
};

// CLASSE PARA ESCOPO
class Scope
{
	public:
		map<string, symbol> table;
		Scope*parent;
		Scope(Scope*p) : parent(p) {}
		symbol*lookup(string name) {
			if(table.count(name)) {
				return &table[name];
			}
			if(parent!=nullptr) {
				return parent->lookup(name);
			}
			return nullptr;
		}
};

// VARIÁVEIS, MAPAS E FUNÇÕES/CALLS GLOBAIS
int var_temp_qnt;
int label_qnt=0;
int linha = 1;
bool generalError = false;
bool stringScan = false;
string codigo_gerado;
map<string, string> alias_types;
static stack<labelPair> labelStack;
stack<string> loopEndStack;
Scope*current_scope = new Scope(nullptr);
int yylex(void);
void yyerror(string);

// Construtores de funções
string genAlias(string type);
int genLabel();
string resultType(string t1, string t2);
void varDeclaration(string name, string type);
attributes opCodeGeneratorOrchestrator(string op, attributes left, attributes right);
attributes complexStringCodeGenerator(attributes left, attributes right);
attributes commonOpCodeGenerator(string op, attributes left, attributes right, string opType);
attributes unopCodeGenerator(string op, attributes right);
attributes litCodeGenerator(string type, string value);
attributes IDVerifier(string name);
attributes castCodeGenerator(string tType, attributes right);
string implicitCast(attributes left, attributes right, string &leftLabel, string &rightLabel, string &extraTrad);
attributes logicRelCodeGenerator(string op, attributes left, attributes right);
attributes stringOrchestrator(string op, attributes left, attributes right);
// attributes stringOrchestrator(string op, attributes iterable, int factor);
attributes stringAssignment(attributes left, attributes right);
void pushScope();
void popScope();
attributes errorReport(string msg);
attributes ScanCodeGenerator(string op, attributes right);
attributes breakCodeGenerator(int depth);
%}

%token TK_SEMICOLON TK_ALL
%token TK_ID TK_NUM_INT TK_NUM_FLOAT TK_CHAR TK_BOOL TK_STRING
%token TK_TYPE_INT TK_TYPE_FLOAT TK_TYPE_CHAR TK_TYPE_BOOL TK_TYPE_STRING
%token TK_LPAREN TK_RPAREN TK_LBRACE TK_RBRACE
%token TK_ASSIGN TK_EQ TK_NEQ TK_LT TK_GT TK_LEQ TK_GEQ
%token TK_AND TK_OR TK_NOT
%token TK_SCAN TK_PRINT
%token TK_IF TK_ELSE TK_WHILE TK_FOR
%token TK_BREAK
%nonassoc CAST_PREC

%start S

%right TK_ASSIGN
%left TK_AND TK_OR
%left TK_EQ TK_NEQ 
%left TK_LT TK_GT TK_LEQ TK_GEQ
%left '+' '-'
%left '*' '/'
%right TK_NOT

%%

S 							: CMDS
								{
									if(!generalError)
									{
										codigo_gerado = 
											"\n"
											"/*Compilador VIPERIDAE*/\n"
											"#include <stdio.h>\n"
											"#include <stdlib.h>\n"
											"#include <string.h>\n"
											;

										if(stringScan) {
											codigo_gerado +=
												"\nchar _stringBuffer[10];"
												"\nint _stringLength(char* _str);"
												"\nvoid _keyboardCleanup();"
												;
										}

										codigo_gerado += "\n\nint main() {\n";

										for(int i=1; i<=var_temp_qnt; i++) {
											string t = "_t" + to_string(i);
											codigo_gerado += "\t" + alias_types[t] + " " + t + ";\n";
										}

										codigo_gerado += "\n";

										codigo_gerado += $1.traducao;

										codigo_gerado += "\treturn 0;"
													"\n}\n";

										if(stringScan) {
											codigo_gerado += 
												"\nint _stringLength(char* _str) {\n"
													"\tint _len;\n"
													"\tchar _tChar;\n"
													"\tchar _tStrClose;\n"
													"\tint _temp1;\n"
													"\t int _tCond;\n"
													"\n"
													"\t_len = 0;\n"
													"\t_tChar = _str[_len];\n"
													"\t_tStrClose = '\\0';\n"
													"\t_temp1 = _tChar != _tStrClose;\n"
													"\t_tCond = _temp1;\n"
													"\twhile(_tCond) {\n"
													"\t\t_len++;\n"
													"\t\t_tChar = _str[_len];\n"
													"\t\t_temp1 = _tChar != _tStrClose;\n"
													"\t\t_tCond = _temp1;\n"
													"\t}\n"
													"\t_len++;\n"
													"\treturn _len;\n"
												"}"

												"\nvoid _keyboardCleanup() {\n"
													"\tint _c1;\n"
													"\tint _c2;\n"
													"\tchar _c3;\n"
													"\tint _c4;\n"
													"\tint _c5;\n"
													"\tint _c6;\n"
													"\tint _c7;\n"
													"\tint _c8;\n"
													"\tint _c9;\n"
													"\tint _c10;\n"
													"\n"
													"\t_c2 = 0;\n"
													"\t_c1 = _c2;\n"
													"\tWHILESTART_1:\n"
													"\t_c3 = \'\\n\';\n"
													"\t_c5 = (int) _c3;\n"
													"\t_c4 = _c1 != _c5;\n"
													"\t_c6 = -1;\n"
													"\t_c7 = _c1 != _c6;\n"
													"\t_c8 = _c4 && _c7;\n"
													"\t_c9 = !_c8;\n"
													"\tif(_c9) goto WHILEEND_1;\n"
													"\t_c10 = getchar();\n"
													"\t_c1 = _c10;\n"
													"\tgoto WHILESTART_1;\n"
													"\tWHILEEND_1:\n"
												"}"
												;
										}
									}
									
								}
								;

CMDS 						: CMD CMDS
								{
									$$.traducao = $1.traducao + $2.traducao;
								}
								| CMD
								{
									$$.traducao = $1.traducao;
								}
								;

CMD							: DECLARATION
								{
									$$.traducao = $1.traducao;
								}
								| ASSIGNCMD
								{
									$$.traducao = $1.traducao;
								}
								| E TK_SEMICOLON
								{
									$$.traducao = $1.traducao;
								}
								| BLOCK
								{
									$$.traducao = $1.traducao;
								}
								| CONTROL
								{
									$$.traducao = $1.traducao;
								}
								| BREAK
								{
									$$.traducao = $1.traducao;
								}
								;

BLOCK						: TK_LBRACE {pushScope();} CMDS TK_RBRACE {popScope();}
								{
									$$.traducao = $3.traducao;
								}

BREAK						: TK_BREAK TK_SEMICOLON
								{
									if(loopEndStack.empty()) {
										yyerror("Erro Semantico: 'break' fora de loop!");
										$$.traducao = "";
										generalError = true;
									} else {
										string endLabel = loopEndStack.top();
										$$.traducao = "\tgoto " + endLabel + ";\n";
									}
								}
								| TK_BREAK TK_NUM_INT TK_SEMICOLON
								{
									int depth = stoi($2.label);
									$$ = breakCodeGenerator(depth);
								}
								| TK_BREAK TK_ALL TK_SEMICOLON
								{
									$$ = breakCodeGenerator(-1);
								}
								;

DECLARATION			: TK_TYPE_INT TK_ID TK_SEMICOLON
								{
									varDeclaration($2.label, "int");
									$$.traducao = "";
								}
								| TK_TYPE_FLOAT TK_ID TK_SEMICOLON
								{
									varDeclaration($2.label, "float");
									$$.traducao = "";
								}
								| TK_TYPE_CHAR TK_ID TK_SEMICOLON
								{
									varDeclaration($2.label, "char");
									$$.traducao = "";
								}
								| TK_TYPE_BOOL TK_ID TK_SEMICOLON
								{
									varDeclaration($2.label, "bool");
									$$.traducao = "";
								}
								| TK_TYPE_STRING TK_ID TK_SEMICOLON
								{
									varDeclaration($2.label, "string");
									$$.traducao = "";
								}
								;

ASSIGNMENT			: TK_ID TK_ASSIGN E
								{
									if(!current_scope->lookup($1.label)) {
										yyerror("Erro Semantico: Variavel '" + $1.label + "' nao declarada!");
        								$$.traducao = "";
												generalError = true;
									} else {
										if($3.type != "error") {
											symbol* s = current_scope->lookup($1.label);
											if(s->type == $3.type) {
												if($3.type == "string") {
													attributes temp = stringOrchestrator("=", $1, $3);
													$$.traducao =
														$3.traducao +
														temp.traducao
													;
												} else {
													$$.traducao =
														$3.traducao +
														"\t" + s->alias + " = " + $3.label + ";\n"
													;
												}
											} else {
												yyerror("Erro Semantico: Tipos incompativeis! '" + $1.label + "' e " + s->type + " mas recebeu " + $3.type);
												$$.traducao = $3.traducao;
												generalError = true;
											}
										} else {
											$$.traducao = $3.traducao;
											generalError = true;
										}
									}
								}
								;
ASSIGNCMD				: ASSIGNMENT TK_SEMICOLON
								{
									$$.traducao = $1.traducao;
								}
								;

CONTROL					: IF BLOCK ELSE 
								{
									labelPair lp = labelStack.top();
									labelStack.pop();
									if($3.traducao == "") {
										$$.traducao =
											$1.traducao +
											"\tif(" + $1.label + ") goto " + lp.endLabel + ";\n" +
											$2.traducao +
											"\t" + lp.endLabel + ":\n"
										;
									} else {
										$$.traducao =
											$1.traducao +
											"\tif(" + $1.label + ") goto " + lp.falseLabel + ";\n" +
											$2.traducao +
											"\tgoto " + lp.endLabel + ";\n" +
											"\t" + lp.falseLabel + ":\n" +
											$3.traducao +
											"\t" + lp.endLabel + ":\n"
										;
									}
								}
								| WHILE BLOCK
								{
									labelPair lp = labelStack.top();
									labelStack.pop();
									$$.traducao =
										$1.traducao +
										$2.traducao +
										"\tgoto " + lp.startLabel + ";\n" +
										"\t" + lp.endLabel + ":\n"
									;
								}
								| TK_FOR TK_LPAREN ASSIGNMENT TK_SEMICOLON LOGICAL TK_SEMICOLON  ASSIGNMENT TK_RPAREN BLOCK
								{
									if($3.traducao == "" || $5.traducao == "" || $7.traducao == "") {
										yyerror("Erro Semantico: Expressão inválida no controle 'for'!");
										$$.traducao = "";
										$$.type = "error";
										generalError = true;
									}
									if($5.type != "bool") {
										yyerror("Erro Semantico: Condição de 'for' deve ser do tipo booleano!");
										$$.traducao = "";
										$$.type = "error";
										generalError = true;
									}
									int controlID = genLabel();
									labelPair lp;
									lp.startLabel = "FORSTART_" + to_string(controlID);
									lp.falseLabel = "";
									lp.stepLabel = "FORSTEP_" + to_string(controlID);
									lp.endLabel = "FOREND_" + to_string(controlID);
									loopEndStack.push(lp.endLabel);
									attributes negOperand = unopCodeGenerator("!", $5);
									$$.traducao =
										$3.traducao +
										"\t" + lp.startLabel + ":\n" +
										negOperand.traducao +
										"\tif(" + negOperand.label + ") goto " + lp.endLabel + ";\n" +
										$9.traducao +
										"\t" + lp.stepLabel + ":\n" +
										$7.traducao +
										"\tgoto " + lp.startLabel + ";\n" +
										"\t" + lp.endLabel + ":\n"
									;
								}
								;
IF 							: TK_IF TK_LPAREN E TK_RPAREN
								{
									if($3.type != "bool") {
										yyerror("Erro Semantico: Condição de 'if' deve ser do tipo booleano!");
										$$.traducao = $3.traducao;
										generalError = true;
									}
									attributes negOperand = unopCodeGenerator("!", $3);
									int controlID = genLabel();
									labelPair lp;
									lp.startLabel = "";
									lp.falseLabel = "IFELSE_" + to_string(controlID);
									lp.stepLabel = "";
									lp.endLabel = "IFEND_" + to_string(controlID);
									labelStack.push(lp);
									$$ = negOperand;
								}
								;
ELSE						: TK_ELSE BLOCK
								{
									$$.traducao = $2.traducao;
								}
								|
								{
									$$.traducao = "";
								}
								;
WHILE						: TK_WHILE TK_LPAREN E TK_RPAREN
								{
									if($3.type != "bool") {
										yyerror("Erro Semantico: Condição de 'while' deve ser do tipo booleano!");
										$$.traducao = $3.traducao;
										generalError = true;
									}
									int controlID = genLabel();
									labelPair lp;
									lp.startLabel = "WHILESTART_" + to_string(controlID);
									lp.falseLabel = "";
									lp.stepLabel = "";
									lp.endLabel = "WHILEEND_" + to_string(controlID);
									labelStack.push(lp);
									loopEndStack.push(lp.endLabel);
									attributes negOperand = unopCodeGenerator("!", $3);
									$$.traducao =
										"\t" + lp.startLabel + ":\n" +
										negOperand.traducao +
										"\tif(" + negOperand.label + ") goto " + lp.endLabel + ";\n"
									;
								}
								;

E								: LOGICAL
								{
									$$ = $1;
								}
								;
LOGICAL					: LOGICAL TK_AND RELATIONAL
								{
									$$ = logicRelCodeGenerator("&&", $1, $3);
								}
								| LOGICAL TK_OR RELATIONAL
								{
									$$ = logicRelCodeGenerator("||", $1, $3);
								}
								| TK_NOT LOGICAL
								{
									$$ = unopCodeGenerator("!", $2);
								}
								| RELATIONAL
								{
									$$ = $1;
								}
								;
RELATIONAL			: RELATIONAL TK_EQ ARITHMETICAL
								{
									$$ = logicRelCodeGenerator("==", $1, $3);
								}
								| RELATIONAL TK_NEQ ARITHMETICAL
								{
									$$ = logicRelCodeGenerator("!=", $1, $3);
								}
								| RELATIONAL TK_LT ARITHMETICAL
								{
									$$ = logicRelCodeGenerator("<", $1, $3);
								}
								| RELATIONAL TK_GT ARITHMETICAL
								{
									$$ = logicRelCodeGenerator(">", $1, $3);
								}
								| RELATIONAL TK_LEQ ARITHMETICAL
								{
									$$ = logicRelCodeGenerator("<=", $1, $3);
								}
								|  RELATIONAL TK_GEQ ARITHMETICAL
								{
									$$ = logicRelCodeGenerator(">=", $1, $3);
								}
								| ARITHMETICAL
								{
									$$ = $1;
								}
								;
ARITHMETICAL		: ARITHMETICAL '+' CAST
								{
									$$ = opCodeGeneratorOrchestrator("+", $1, $3);
								}
								|	ARITHMETICAL '-' CAST
								{
									$$ = opCodeGeneratorOrchestrator("-", $1, $3);
								}
								| ARITHMETICAL '*' CAST
								{
									$$ = opCodeGeneratorOrchestrator("*", $1, $3);
								}
								| ARITHMETICAL '/' CAST
								{
									$$ = opCodeGeneratorOrchestrator("/", $1, $3);
								}
								| CAST
								{
									$$ = $1;
								}
								;
CAST						: TK_LPAREN TK_TYPE_INT TK_RPAREN BASE %prec CAST_PREC
								{
									$$ = castCodeGenerator("int", $4);
								}
								| TK_LPAREN TK_TYPE_FLOAT TK_RPAREN BASE %prec CAST_PREC
								{
									$$ = castCodeGenerator("float", $4);
								}
								| TK_LPAREN TK_TYPE_CHAR TK_RPAREN BASE %prec CAST_PREC
								{
									$$ = castCodeGenerator("char", $4);
								}
								| TK_LPAREN TK_TYPE_BOOL TK_RPAREN BASE %prec CAST_PREC
								{
									$$ = castCodeGenerator("bool", $4);
								}
								| TK_LPAREN TK_TYPE_STRING TK_RPAREN BASE %prec CAST_PREC
								{
									$$ = castCodeGenerator("string", $4);
								}
								| BASE
								{
									$$ = $1;
								}
								;
BASE						:	LITERAL
								{
									$$ = $1;
								}
								| IO
								{
									$$ = $1;
								}
								| TK_LPAREN E TK_RPAREN
								{
									$$.label = $2.label;
									$$.traducao = $2.traducao;
									$$.type = $2.type;
								}
								;
LITERAL					: TK_NUM_INT
								{
									$$ = litCodeGenerator("int", $1.label);
								}
								| TK_NUM_FLOAT
								{
									$$ = litCodeGenerator("float", $1.label);
								}
								| TK_CHAR
								{
									$$ = litCodeGenerator("char", $1.label);
								}
								| TK_BOOL
								{
									$$ = litCodeGenerator("bool", $1.label);
								}
								| TK_STRING
								{
									$$ = litCodeGenerator("string", $1.label);
								}
								| TK_ID
								{
									$$ = IDVerifier($1.label);
								}
								;
IO							: TK_SCAN TK_LPAREN TK_ID TK_RPAREN
								{
									attributes idAttr = IDVerifier($3.label);
									$$ = ScanCodeGenerator("scan", idAttr);
								}
								| TK_PRINT TK_LPAREN E TK_RPAREN
								{
									if($3.type == "complexString") {
										string args = get<string>($3.value);
										$$.traducao = 
											$3.traducao +
											"\tprintf(\"" + $3.label + "\\n\"" + args + ");\n"
										;
									} else {
										string format = "";
										if ($3.type == "int") {
											format = "%d\\n";
										} else if ($3.type == "float") {
											format = "%f\\n";
										} else if ($3.type == "char") {
											format = "%c\\n";
										} else if ($3.type == "bool") {
											format = "%d\\n";
										} else if ($3.type == "string") {
											format = "%s\\n";
										}
										
										$$.traducao =
											$3.traducao +
											"\tprintf(\"" + format + "\", " + $3.label + ");\n"
										;
									}
								}
								;

%%

#include "lex.yy.c"

int yyparse();



// FUNÇÕES GERAIS
string genAlias(string type)
{
	var_temp_qnt++;
	string name = "_t" + to_string(var_temp_qnt);
	alias_types[name] = type;
	return name;
}
int genLabel()
{
	label_qnt++;
	return label_qnt;
}
string resultType(string t1, string t2)
{
	if(t1 == "error" || t2 == "error") return "error";
	if(t1 == "string" || t2 == "string" || t1 == "complexString" || t2 == "complexString") {
		return "complexString";
	}
	if(t1 == "char" || t2 == "char") return "error";
	if(t1 == "bool" || t2 == "bool") return "error";
	if(t1 == "float" || t2 == "float") return "float";
	return "int";
}
attributes errorReport(string msg) {
	attributes r;
	yyerror(msg);
	r.label = "";
	r.type = "error";
	r.traducao = "";
	r.value = monostate();
	generalError = true;
	return r;
}
attributes IDVerifier(string name)
{
	attributes r;
	symbol*s = current_scope->lookup(name);
	if(s) {
		r.label = s->alias;
		r.type = s->type;
		r.value = s->value;
		r.traducao = "";
	} else {
		r = errorReport("Erro Semantico: Variavel '" + name + "' nao declarada!");
	}
	return r;
}
void varDeclaration(string name, string type)
{
	if(current_scope->table.count(name)) {
		yyerror("Erro Sintatico: Variavel '" + name + " ja declarada!");
		generalError = true;
		return;
	} else {
		string aliasType;
		if(type == "bool") {
			aliasType = "int";
		} else if(type == "string") {
			aliasType = "char*";
		} else {
			aliasType = type;
		}
		string t = genAlias(aliasType);
		current_scope->table[name] = {name, t, type};
	}
}



// ENTRADA E SAÍDA
attributes ScanCodeGenerator(string op, attributes right) {
	attributes r;
	if(right.type == "error") {
		r = errorReport("");
		return r;
	}
	if (right.type == "int") {
		r.traducao = "\tscanf(\"%d\", &" + right.label + ");\n";
	} else if (right.type == "float") {
		r.traducao = "\tscanf(\"%f\", &" + right.label + ");\n";
	} else if (right.type == "char")  {
		r.traducao = "\tscanf(\" %c\", &" + right.label + ");\n";
	} else if (right.type == "bool")  {
		r.traducao = "\tscanf(\"%d\", &" + right.label + ");\n";
	} else if (right.type == "string")  {
		stringScan = true;
		string scanLength = genAlias("int");
		r.traducao =
			"\tscanf(\" %5[^\\n/]\", _stringBuffer);\n"
			"\t_keyboardCleanup();\n"
			"\t" + scanLength + " = _stringLength(_stringBuffer);\n"
			"\t" + right.label + " = (char*)malloc(" + scanLength + ");\n"
			"\tstrcpy(" + right.label + ", _stringBuffer);\n"
		;
	} else {
		r = errorReport("Erro Semantico: Tipo não suportado!");
	}
	return r;

}



// CRIAÇÃO DE LITERAIS
attributes litCodeGenerator(string type, string value)
{
	attributes r;
	string aliasType;
	bool isString = false;
	if(type == "bool") {
		aliasType = "int";
	} else if(type == "string") {
		aliasType = "char*";
		isString = true;
	} else {
		aliasType = type;
	}
	r.label = genAlias(aliasType);
	r.type = type;
	r.value = value;
	if(isString) {
		string attValue = get<string>(r.value);
		r.traducao = 
			"\t" + r.label + " = (char*)malloc(" + to_string(attValue.size() + 1) + ");\n" +
			"\tstrcpy(" + r.label + ", \"" + value + "\");\n"
		;
	} else if(type == "char") {
		r.traducao = "\t" + r.label + " = \'" + value + "\';\n";
	} else{
		r.traducao = "\t" + r.label + " = " + value + ";\n";
	}
	return r;
}



// OPERAÇÕES ARITMÉTICAS
attributes opCodeGeneratorOrchestrator(string op, attributes left, attributes right)
{
	attributes r;
	if(left.type=="error"||right.type=="error") {
		r = errorReport("");
		return r;
	}
	string opType = resultType(left.type, right.type);
	if(opType == "error") {
		r = errorReport("Erro Semantico: Tipos incompatíveis para a operação '" + op + "'");
		return r;
	}
	if(op == "+" && opType == "complexString") {
		r = complexStringCodeGenerator(left, right);
		return r;
	}
	r = commonOpCodeGenerator(op, left, right, opType);
	
	return r;
}
attributes complexStringCodeGenerator(attributes left, attributes right)
{
	attributes r;
	r.type = "complexString";
	r.traducao = left.traducao + right.traducao;
	string leftMasks = "";
	string rightMasks = "";
    if (left.type == "complexString") {
      leftMasks = left.label;
    } else if (left.type == "string") {
      leftMasks = "%s";
    } else if (left.type == "int" || left.type == "bool") {
      leftMasks = "%d";
    } else if (left.type == "float") {
      leftMasks = "%f";
    } else if (left.type == "char") {
      leftMasks = "%c";
    }
    if (right.type == "complexString") {
      rightMasks = right.label;
    } else if (right.type == "string") {
      rightMasks = "%s";
    } else if (right.type == "int" || right.type == "bool") {
      rightMasks = "%d";
    } else if (right.type == "float") {
      rightMasks = "%f";
    } else if (right.type == "char") {
      rightMasks = "%c";
    }
    r.label = leftMasks + rightMasks;
    string arg_left = "";
    if (left.type == "complexString") {
      arg_left = get<string>(left.value);
    } else {
      arg_left = ", " + left.label;
    }
    string arg_right = "";
    if (right.type == "complexString") {
      arg_right = get<string>(right.value);
    } else {
      arg_right = ", " + right.label;
    }
    r.value = arg_left + arg_right;
    return r;
}
attributes commonOpCodeGenerator(string op, attributes left, attributes right, string opType)
{
	attributes r;
	string leftLabel = "";
	string rightLabel = "";
	string extraTrad = "";
	string finalType = implicitCast(left, right, leftLabel, rightLabel, extraTrad);
	if(finalType == "error") {
		r = errorReport("Erro Semantico: Tipos incompatíveis para a operação '" + op + "'");
		return r;
	}
	r.label = genAlias(finalType);
	r.type = finalType;
	r.value = finalType;
	r.traducao =
		left.traducao + 
		right.traducao + 
		extraTrad + 
		"\t" + r.label + " = " + leftLabel + " " + op + " " + rightLabel + ";\n"
	;
	return r;
}



// OPERAÇÕES LÓGICAS E RELACIONAIS
attributes unopCodeGenerator(string op, attributes right)
{
	attributes r;
    if(right.type != "bool") {
			r = errorReport("Erro Semântico: Operador lógico '!' exige tipo booleano!");
			generalError = true;
			return r;
    }
    r.label = genAlias("int");
    r.type = "bool";
    r.traducao = 
			right.traducao + 
			"\t" + r.label + " = " + op + right.label + ";\n"
		;
    return r;
}
attributes logicRelCodeGenerator(string op, attributes left, attributes right)
{
	attributes r;
	if(left.type == "error" || right.type == "error") {
		r = errorReport("Erro Semântico: Tipos incompatíveis para a operação '" + op + "'");
		generalError = true;
		return r;
	}
	if(op == "&&" || op == "||") {
		if(left.type != "bool" || right.type != "bool") {
			r = errorReport("Erro Semântico: Operadores lógicos exigem tipos booleanos!");
			generalError = true;
			return r;
		}
		r.label = genAlias("int");
		r.type = "bool";
		r.traducao = 
			left.traducao + 
			right.traducao + 
			"\t" + r.label + " = " + left.label + " " + op + " " + right.label + ";\n"
		;
		return r;
	}
	r.label = genAlias("int"); 
	r.type = "bool"; 
	string leftLabel = "";
	string rightLabel = "";
	string extraTrad = "";
	string finalType = implicitCast(left, right, leftLabel, rightLabel, extraTrad);
	if(finalType == "error") {
		r = errorReport("Erro Semântico: Tipos incompatíveis para a operação '" + op + "'");
		generalError = true;
		return r;
	}
	r.traducao = 
		left.traducao + 
		right.traducao + 
		extraTrad + 
		"\t" + r.label + " = " + leftLabel + " " + op + " " + rightLabel + ";\n"
	;
	return r;
}



// CONVERSÃO
attributes castCodeGenerator(string tType, attributes right)
{
	attributes r;
	if(right.type == "error") {
		r = errorReport("");
		generalError = true;
		return r;
	}
	if (right.type == tType) {
		return right;
	}
	bool isAllowed = false;
	if (tType == "int") {
		if (right.type == "float" || right.type == "char") {
			isAllowed = true;
		}
	}
	else if (tType == "float") {
		if (right.type == "int") {
			isAllowed = true;
		}
	}
	else if (tType == "bool") {
		if (right.type == "int") {
			isAllowed = true;
		}
	}
	else if (tType == "char" || tType == "string") {
		isAllowed = false; 
	}
	if (!isAllowed) {
		r =errorReport("Erro Semântico: Conversão explícita (cast) inválida de '" + right.type + "' para '" + tType + "'");
		generalError = true;
		return r;
	}
	string aliasType;
	if(tType == "bool") {
		aliasType = "int";
	} else if(tType == "string") {
		aliasType = "char*";
	} else {
		aliasType = tType;
	}
	r.label = genAlias(aliasType);
	r.type = tType;
	r.value = tType;
	r.traducao = 
		right.traducao + 
		"\t" + r.label + " = (" + tType + ") " + right.label + ";\n"
	;
	return r;
}
string implicitCast(attributes left, attributes right, string &leftLabel, string &rightLabel, string &extraTrad) {
	leftLabel = left.label;
	rightLabel = right.label;
	if(left.type == right.type) {
		return left.type;
	}
	if(left.type == "error" || right.type == "error") {
		return "error";
	}
	string targetType = "";
	if(left.type == "float" || right.type == "float") {
		targetType = "float";
	} else if(left.type == "int" || right.type == "int") {
		targetType = "int";
	}
	if(targetType != "") {
		if(left.type != targetType) {
			string t = genAlias(targetType);
			extraTrad += "\t" + t + " = (" + targetType + ") " + left.label + ";\n";
			leftLabel = t;
		}
		if(right.type != targetType) {
			string t = genAlias(targetType);
			extraTrad += "\t" + t + " = (" + targetType + ") " + right.label + ";\n";
			rightLabel = t;
		}
	}
	return targetType;
}



// ÁREA DE STRING
attributes stringOrchestrator(string op, attributes left, attributes right)
{
	if(op == "=") {
		return stringAssignment(left, right);
	}
	return attributes();
}
/*attributes stringOrchestrator(string op, attributes iterable, int factor)
{
	return attributes();
}*/
attributes stringAssignment(attributes left, attributes right)
{
	attributes r;
	symbol *sym = current_scope->lookup(left.label);
	r.label = sym->alias;
	r.type = "string";
	r.value = right.value;
	string tradFree = "";
	if(holds_alternative<string>(sym->value) && !get<string>(sym->value).empty()) {
		tradFree = "\tfree(" + sym->alias + ");\n";
	}
	sym->value = right.value;
	r.traducao =
		tradFree +
		"\t" + sym->alias + " = (char*)malloc(" + to_string(get<string>(right.value).size() + 1) + ");\n" +
		"\tstrcpy(" + sym->alias + ", " + right.label + ");\n"
		;
	return r;
}



// ÁREA DE ESCOPO
void pushScope()
{
	current_scope = new Scope(current_scope);
}
void popScope()
{
	Scope*old = new Scope(current_scope);
	current_scope = current_scope->parent;
	delete old;
}



// BREAK CONTROL
attributes breakCodeGenerator(int depth) {
	attributes r;
	if(loopEndStack.empty()) {
		r = errorReport("Erro Semântico: 'break' fora de loop!");
		generalError = true;
		return r;
	}
	stack<string> tempStack = loopEndStack;
	string targetLabel = "";
	if(depth == -1) {
		while(!tempStack.empty()) {
			targetLabel = tempStack.top();
			tempStack.pop();
		}
	} else {
		int counter = depth;
		while(counter>0 && !tempStack.empty()) {
			targetLabel = tempStack.top();
			tempStack.pop();
			counter--;
		}
		if(counter > 0) {
			r = errorReport("Erro Semântico: Quantidade de níveis de 'break' superior à profundidade de loops!");
			generalError = true;
			return r;
		}
	}
	r.traducao = "\tgoto " + targetLabel + ";\n";
	return r;
}



int main(int argc, char* argv[])
{
	var_temp_qnt = 0;

	if (yyparse() == 0)
		cout << codigo_gerado;

	return 0;
}

void yyerror(string MSG)
{
	cerr << "Erro na linha " << linha << ": " << MSG << endl;
}
