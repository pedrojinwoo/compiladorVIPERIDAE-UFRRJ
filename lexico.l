%{
#include <string>
%}

%option noyywrap

ESPACO [ \t]
DIGIT [0-9]
CHARACTER [a-zA-Z_]
IDSTART [a-zA-Z]
STRCONTENT[^\"]*

DELIM               {ESPACO}+
NUM_INT             {DIGIT}+
NUM_FLOAT           {DIGIT}+"."{DIGIT}+
ID                  {IDSTART}({CHARACTER}|{DIGIT})*
CHAR                \'{CHARACTER}\'
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

";"                 { return TK_SEMICOLON; }

"int"               { return TK_TYPE_INT; }
"float"             { return TK_TYPE_FLOAT; }
"char"              { return TK_TYPE_CHAR; }
"bool"              { return TK_TYPE_BOOL; }
"string"            { return TK_TYPE_STRING; }

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
