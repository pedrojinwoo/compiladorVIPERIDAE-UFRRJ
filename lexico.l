%{
#include <string>
%}

%option noyywrap

ESPACO [ \t]
DIGIT [0-9]
CHARACTER [a-zA-Z_]
ESCAPE \\[ntr0\\]
IDSTART [a-zA-Z]
STRCONTENT[^\"]*

DELIM               {ESPACO}+
NUM_INT             {DIGIT}+
NUM_FLOAT           {DIGIT}+"."{DIGIT}+
ID                  {IDSTART}({CHARACTER}|{DIGIT})*
CHAR                \'({CHARACTER}|{ESCAPE})\'
STRING              \"{STRCONTENT}\"

%%

"\n"		        { linha++; }

{DELIM} 	        {}

"+"|"-"|"*"|"/"		{ return *yytext; }

"("                 { return TK_LPAREN; }
")"                 { return TK_RPAREN; }
"{"                 { return TK_LBRACE; }
"}"                 { return TK_RBRACE; }

"="                 { return TK_ASSIGN; }
"=="                { return TK_EQ; }
"!="                { return TK_NEQ; }
"<"                 { return TK_LT; }
">"                 { return TK_GT; }
"<="                { return TK_LEQ; }
">="                { return TK_GEQ; }

"&&"                { return TK_AND; }
"||"                { return TK_OR; }

"!"                 { return TK_NOT; }

"+="                { return TK_PASS; }
"-="                { return TK_MASS; }
"*="                { return TK_MUASS; }
"/="                { return TK_DASS; }

";"                 { return TK_SEMICOLON; }
":"                 { return TK_COLON; }
","                 { return TK_COMA; }
"all"               { return TK_ALL; }

"int"               { return TK_TYPE_INT; }
"float"             { return TK_TYPE_FLOAT; }
"char"              { return TK_TYPE_CHAR; }
"bool"              { return TK_TYPE_BOOL; }
"string"            { return TK_TYPE_STRING; }

"stringConcat"      { return TK_STRCONCAT; }
"stringRep"         { return TK_STRREP; }
"stringLen"         { return TK_STRLEN; }

"scan"              { return TK_SCAN; }
"print"             { return TK_PRINT; }

"break"             { return TK_BREAK; }
"continue"          { return TK_CONTINUE; }

"if"                { return TK_IF; }
"else"              { return TK_ELSE; }
"elif"              { return TK_ELIF; }
"while"             { return TK_WHILE; }
"do"                { return TK_DO; }
"for"               { return TK_FOR; }
"switch"            { return TK_SWITCH; }
"case"              { return TK_CASE; }
"default"           { return TK_DEFAULT; }

"EOF"               { yylval.label = "-1"; return TK_NUM_INT; }
"true"              { yylval.label = "1"; return TK_BOOL; }
"false"             { yylval.label = "0"; return TK_BOOL; }
{NUM_INT}		    { yylval.label = yytext; return TK_NUM_INT; }
{NUM_FLOAT}	        { yylval.label = yytext; return TK_NUM_FLOAT; }
{ID}		        { yylval.label = yytext; return TK_ID; }
{CHAR}	            {
                        std::string s(yytext);
                        yylval.label = s.substr(1, s.size()-2);
                        return TK_CHAR;
                    }
{STRING}            {
                        std::string s(yytext);
                        yylval.label = s.substr(1, s.size()-2);
                        return TK_STRING;
                    }   


.			{ fprintf(stderr, "Erro Léxico: Caractere nao reconhecido na linha %d: %s\n", linha, yytext); }

%%
