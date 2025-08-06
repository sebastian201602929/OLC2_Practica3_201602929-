%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* Prototipo del scanner */
extern int yylex(void);
/* yyerror con firma estándar */
void yyerror(const char *s);
%}

/* Seguimiento de ubicaciones */
%locations
/* Mensajes de error más detallados */
//%define parse.error verbose

/* Unión de tipos semánticos */
%union {
  char* str;
}

/* Tokens tipados */
%token <str> IMPRIMIR
%token <str> SI
%token <str> ENTONCES
%token <str> SINO
%token <str> IDENTIFIER
%token <str> NUMERO
/* Tipo de los no-terminales que llevan valor */
%type  <str> lista_sentencia
%type  <str> sentencia
%type  <str> s_print
%type  <str> s_if
%type  <str> condicion
/* Precedencias */

%%

inicio:
    /* vacio */
  | inicio linea
  ;

linea:
    '\n'
  | lista_sentencia '\n'  { printf("= %s\n", $1);
                            free($1); }
  | error '\n'            { yyerrok; }
  ;

lista_sentencia:
    lista_sentencia sentencia { $$ = malloc(strlen($1) + strlen($2) + 1 + 1);
                                strcpy($$, $1);
                                strcat($$, $2);
                                strcat($$, "\n");
                                free($1);
                                free($2); }
  | sentencia                 { $$ = malloc(strlen($1) + 1 + 1);
                                strcpy($$, $1);
                                strcat($$, "\n");
                                free($1); }
  ;

sentencia:
    s_print ';' { $$ = malloc(strlen($1) + 1 + 1);
                  strcpy($$, $1);
                  free($1);
                  strcat($$, ";"); }
  | s_if        { $$ = malloc(strlen($1) + 1);
                  strcpy($$, $1);
                  free($1); }
  ;

s_print:
    IMPRIMIR '(' IDENTIFIER ')' { free($1);
                                  $$ = malloc(6 + strlen($3) + 1 + 1);
                                  strcpy($$, "print(");
                                  strcat($$, $3);
                                  free($3);
                                  strcat($$, ")"); }
  ;

s_if:
    SI '(' condicion ')' ENTONCES lista_sentencia                       { free($1);
                                                                          free($5);
                                                                          $$ = malloc(4 + strlen($3) + 7 + (4 + strlen($6)) + 1);
                                                                          strcpy($$, "if (");
                                                                          strcat($$, $3);
                                                                          free($3);
                                                                          strcat($$, ") then\n    ");
                                                                          strcat($$, $6);
                                                                          free($6); }
  | SI '(' condicion ')' ENTONCES lista_sentencia SINO lista_sentencia  { free($1);
                                                                          free($5);
                                                                          free($7);
                                                                          $$ = malloc(4 + strlen($3) + 7 + (4 + strlen($6) + 1) + 5 + (4 + strlen($8) + 1) + 1);
                                                                          strcpy($$, "if (");
                                                                          strcat($$, $3);
                                                                          free($3);
                                                                          strcat($$, ") then\n    ");
                                                                          strcat($$, $6);
                                                                          free($6);
                                                                          strcat($$, "else\n    ");
                                                                          strcat($$, $8);
                                                                          free($8); }
  ;

condicion:
    IDENTIFIER '<' NUMERO     { $$ = malloc(strlen($1) + 1 + strlen($3) + 1);
                                strcpy($$, $1);
                                free($1);
                                strcat($$, "<");
                                strcat($$, $3);
                                free($3); }
  | IDENTIFIER '>' NUMERO     { $$ = malloc(strlen($1) + 1 + strlen($3) + 1);
                                strcpy($$, $1);
                                free($1);
                                strcat($$, ">");
                                strcat($$, $3);
                                free($3); }
  | IDENTIFIER '<' '=' NUMERO { $$ = malloc(strlen($1) + 2 + strlen($4) + 1);
                                strcpy($$, $1);
                                free($1);
                                strcat($$, "<=");
                                strcat($$, $4);
                                free($4); }
  | IDENTIFIER '>' '=' NUMERO { $$ = malloc(strlen($1) + 2 + strlen($4) + 1);
                                strcpy($$, $1);
                                free($1);
                                strcat($$, ">=");
                                strcat($$, $4);
                                free($4); }
  ;
%%

/* definición de yyerror, usa el yylloc global para ubicación */
void yyerror(const char *s) {
    fprintf(stderr,
            "%s en %d:%d\n",
            s,
            yylloc.first_line,
            yylloc.first_column);
}
