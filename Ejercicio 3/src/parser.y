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
  int num;
  char* str;
}

/* Tokens tipados */
%token <str> LETRA
/* Tipo de los no-terminales que llevan valor */
%type  <num> cadena

/* Precedencias */

%%

inicio:
    /* vacio */
  | inicio linea
  ;

linea:
    '\n'
  | cadena '\n'  { printf("= %d\n", $1); }
  | error '\n'    { yyerrok; }
  ;

cadena:
    cadena LETRA  { $$ = $1;
                    if (strcmp($2, "a") == 0) {
                      $$ = $$ + 1;
                    }
                    free($2);}
  | LETRA         { $$ = 0;
                    if (strcmp($1, "a") == 0) {
                      $$ = $$ + 1;
                    }
                    free($1); }
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
