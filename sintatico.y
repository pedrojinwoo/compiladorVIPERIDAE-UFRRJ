%{
#include <iostream>
#include <string>

#include <map>
#include <vector>

#define YYSTYPE attributes

using namespace std;

struct attributes
{
	string label;
	string traducao;
	string type;
};
struct symbol
{
	string id;
	string alias;
	string type;
};

int var_temp_qnt;
int linha = 1;
string codigo_gerado;
map<string, symbol> symbol_table;
map<string, string> alias_types;

int yylex(void);
void yyerror(string);
string genAlias(string type);
string resultType(string t1, string t2);
void varDeclaration(string name, string type);
attributes opCodeGenerator(string op, attributes left, attributes right);
attributes unopCodeGenerator(string op, attributes right);
attributes litCodeGenerator(string type, string value);
attributes IDVerifier(string name);
attributes castCodeGenerator(string tType, attributes right);
attributes logicRelCodeGenerator(string op, attributes left, attributes right);
attributes stringOrchestrator(string op, attributes left, attributes right);
// attributes stringOrchestrator(string op, attributes iterable, int factor);
attributes stringAssignment(attributes left, attributes right);
%}

%token TK_SEMICOLON\
%token TK_ID TK_NUM_INT TK_NUM_FLOAT TK_CHAR TK_BOOL TK_STRING
%token TK_LPAREN TK_RPAREN
%token TK_ASSIGN TK_EQ TK_NEQ TK_LT TK_GT TK_LEQ TK_GEQ
%token TK_TYPE_INT TK_TYPE_FLOAT TK_TYPE_CHAR TK_TYPE_BOOL TK_TYPE_STRING
%token TK_AND TK_OR TK_NOT
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
									codigo_gerado = "/*Compilador VIPERIDAE*/\n"
													"#include <stdio.h>\n"
													"int main(void) {\n";

									for(int i=1; i<=var_temp_qnt; i++) {
										string t = "_t" + to_string(i);
										codigo_gerado += "\t" + alias_types[t] + " " + t + ";\n";
									}

									codigo_gerado += "\n";

									codigo_gerado += $1.traducao;

									codigo_gerado += "\treturn 0;"
												"\n}\n";
								}
								;

CMDS 						: CMDS CMD
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
								| ASSIGNMENT
								{
									$$.traducao = $1.traducao;
								}
								| E TK_SEMICOLON
								{
									$$.traducao = $1.traducao;
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

ASSIGNMENT			: TK_ID TK_ASSIGN E TK_SEMICOLON
								{
									if(!symbol_table.count($1.label)) {
										yyerror("Erro Semantico: Variavel '" + $1.label + "' nao declarada!");
        								$$.traducao = "";
									} else {
										if($3.type != "error") {
											if(symbol_table[$1.label].type == $3.type) {
												if($3.type == "string") {
													attributes temp = stringOrchestrator("=", $1, $3);
													$$.traducao = $3.traducao + temp.traducao;
												} else {
													$$.traducao = $3.traducao + "\t" + symbol_table[$1.label].alias + " = " + $3.label + ";\n";
												}
											} else {
												yyerror("Erro Semantico: Tipos incompativeis! '" + $1.label + "' e " + symbol_table[$1.label].type + " mas recebeu " + $3.type);
												$$.traducao = $3.traducao;
											}
										} else {
											$$.traducao = $3.traducao;
										}
									}
								}
								;

E								: E '+' E
								{
									$$ = opCodeGenerator("+", $1, $3);
								}
								|	E '-' E
								{
									$$ = opCodeGenerator("-", $1, $3);
								}
								| E '*' E
								{
									$$ = opCodeGenerator("*", $1, $3);
								}
								| E '/' E
								{
									$$ = opCodeGenerator("/", $1, $3);
								}
								| TK_LPAREN E TK_RPAREN
								{
									$$.label = $2.label;
									$$.traducao = $2.traducao;
									$$.type = $2.type;
								}
								| TK_NUM_INT
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
								| E TK_EQ E
								{
									$$ = logicRelCodeGenerator("==", $1, $3);
								}
								| E TK_NEQ E
								{
									$$ = logicRelCodeGenerator("!=", $1, $3);
								}
								| E TK_LT E
								{
									$$ = logicRelCodeGenerator("<", $1, $3);
								}
								| E TK_GT E
								{
									$$ = logicRelCodeGenerator(">", $1, $3);
								}
								| E TK_LEQ E
								{
									$$ = logicRelCodeGenerator("<=", $1, $3);
								}
								| E TK_GEQ E
								{
									$$ = logicRelCodeGenerator(">=", $1, $3);
								}
								| E TK_AND E
								{
									$$ = logicRelCodeGenerator("&&", $1, $3);
								}
								| E TK_OR E
								{
									$$ = logicRelCodeGenerator("||", $1, $3);
								}
								| TK_NOT E
								{
									$$ = unopCodeGenerator("!", $2);
								}
								| TK_LPAREN TK_TYPE_INT TK_RPAREN E %prec CAST_PREC
								{
									$$ = castCodeGenerator("int", $4);
								}
								| TK_LPAREN TK_TYPE_FLOAT TK_RPAREN E %prec CAST_PREC
								{
									$$ = castCodeGenerator("float", $4);
								}
								| TK_LPAREN TK_TYPE_CHAR TK_RPAREN E %prec CAST_PREC
								{
									$$ = castCodeGenerator("char", $4);
								}
								| TK_LPAREN TK_TYPE_BOOL TK_RPAREN E %prec CAST_PREC
								{
									$$ = castCodeGenerator("bool", $4);
								}
								;

%%

#include "lex.yy.c"

int yyparse();

string genAlias(string type)
{
	var_temp_qnt++;
	string name = "_t" + to_string(var_temp_qnt);
	alias_types[name] = type;
	return name;
}
string resultType(string t1, string t2)
{
	if(t1 == "error" || t2 == "error") return "error";
	if(t1 == "char" || t2 == "char") return "error";
	if(t1 == "bool" || t2 == "bool") return "error";
	if(t1 == "float" || t2 == "float") return "float";
	return "int";
}
void varDeclaration(string name, string type)
{
	if(symbol_table.count(name)) {
		yyerror("Erro Sintatico: Variavel '" + name + " ja declarada!");
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
		symbol_table[name] = {name, t, type};		
	}
}
attributes opCodeGenerator(string op, attributes left, attributes right)
{
	attributes r;
	if(left.type=="error"||right.type=="error") {
		r.label = "";
        r.type = "error";
        r.traducao = "";
        return r;
	}
	string opType = resultType(left.type, right.type);
	if(opType == "error") {
		yyerror("Erro Semantico: Tipos Incompativeis");
		r.label = "";
		r.type = "error";
		r.traducao = "";
		return r;
	}
	string accumulatedTransl = left.traducao + right.traducao;
	string leftLabel = left.label;
	string rightLabel = right.label;
	if(opType == "float") {
		if(left.type == "int") {
			string t_conv = genAlias("float");
			accumulatedTransl += "\t" + t_conv + " = (float) " + left.label + ";\n";
			leftLabel = t_conv;
		}
		if(right.type == "int") {
			string t_conv = genAlias("float");
			accumulatedTransl += "\t" + t_conv + " = (float) " + right.label + ";\n";
			rightLabel = t_conv;
		}
	}
	r.label = genAlias(opType);
	r.type = opType;
	r.traducao = accumulatedTransl + "\t" + r.label + " = " + leftLabel + " " + op + " " + rightLabel + ";\n";
	return r;
}
attributes unopCodeGenerator(string op, attributes right)
{
	attributes r;
    if(right.type != "bool") {
        yyerror("Erro Semantico: Operador '!' exige tipo booleano.");
        r.label = "";
        r.type = "error";
        r.traducao = "";
        return r;
    }
    r.label = genAlias("int");
    r.type = "bool";
    r.traducao = right.traducao + "\t" + r.label + " = " + op + right.label + ";\n";
    return r;
}
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
			"\tstrcpy(" + r.label + ", \"" + value + "\");\n";
	} else {
		r.traducao = "\t" + r.label + " = " + value + ";\n";
	}
	return r;
}
attributes IDVerifier(string name)
{
	attributes r;
	if(symbol_table.count(name)) {
		r.label = symbol_table[name].alias;
		r.type = symbol_table[name].type;
		r.traducao = "";
	} else {
		yyerror("Erro Sintatico: Variavel '" + name + "' nao foi declarada!");
		r.label = "";
		r.type = "error";
		r.traducao = "";
	}
	return r;
}
attributes castCodeGenerator(string tType, attributes right)
{
	attributes r;
	if(right.type == "error") {
		r.label = "";
		r.type = "error";
		r.traducao = "";
		return r;
	}
	bool error = false;
	if(tType != "char") {
		if(right.type == "char") error = true;
	}
	else if(tType == "char") {
		if(right.type != "char") error = true;
	}
    if (error) {
		yyerror("Erro Semantico: Conversao ilegal de '" + right.type + "' para '" + tType + "'");
		r.label = "";
        r.type = "error";
        r.traducao = "";
        return r;
    }
    if (right.type == tType) {
		return right;
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
    r.traducao = right.traducao + "\t" + r.label + " = (" + tType + ") " + right.label + ";\n";
    return r;
}
attributes logicRelCodeGenerator(string op, attributes left, attributes right)
{
	attributes r;
	if(left.type == "error" || right.type == "error") {
		r.label = "";
        r.type = "error";
        r.traducao = "";
        return r;
	}
	if(op == "&&" || op == "||") {
		if(left.type != "bool" || right.type != "bool") {
			yyerror("Erro Semantico: Operadores logicos exigem tipos booleanos!");
			r.label = "";
			r.type = "error";
			r.traducao = "";
			return r;
		}
	}
	if((left.type == "char"&&right.type!="char") || (left.type!="char"&&right.type=="char")) {
		yyerror("Erro Semantico: Nao e possivel comparar char com outros tipos!");
		r.label = "";
		r.type = "error";
		r.traducao = "";
		return r;
	}
    r.label = genAlias("int"); 
    r.type = "bool"; 
    string leftLabel = left.label;
    string rightLabel = right.label;
    string extraTrad = "";
    if(left.type != right.type && (left.type == "float" || right.type == "float")) {
        if(left.type == "int") {
            string t = genAlias("float");
            extraTrad += "\t" + t + " = (float) " + left.label + ";\n";
            leftLabel = t;
        }
        if(right.type == "int") {
            string t = genAlias("float");
            extraTrad += "\t" + t + " = (float) " + right.label + ";\n";
            rightLabel = t;
        }
    }
    r.traducao = left.traducao + right.traducao + extraTrad + 
                 "\t" + r.label + " = " + leftLabel + " " + op + " " + rightLabel + ";\n";
    return r;
}
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
	symbol &sym = symbol_table[left.label];
	r.label = sym.alias;
	r.type = "string";
	r.value = right.value;
	string tradFree = "";
	if(holds_alternative<string>(sym.value) && !get<string>(sym.value).empty()) {
		tradFree = "\tfree(" + sym.alias + ");\n";
	}
	sym.value = right.value;
	r.traducao =
		right.traducao +
		tradFree +
		"\t" + sym.alias + " = (char*)malloc(" + to_string(get<string>(right.value).size() + 1) + ");\n" +
		"\tstrcpy(" + sym.alias + ", \"" + get<string>(right.value) + "\");\n";
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
