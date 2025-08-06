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
  struct decla {
    char tipo[10];
    char cadena[1000];
  } decla
}

/* Tokens tipados */
%token <str> ENTERO
%token <str> CARACTER
%token <str> IDENTIFIER
/* Tipo de los no-terminales que llevan valor */
%type  <str> lista_decla
%type  <decla> declaracion
%type  <str> tipo

/* Precedencias */

%%

inicio:
    /* vacio */
  | inicio linea
  ;

linea:
    '\n'
  | lista_decla '\n'  { printf("= [%s]\n", $1); free($1); }
  | error '\n'        { yyerrok; }
  ;

lista_decla:
    lista_decla declaracion ';' { $$ = malloc(strlen($1 + strlen($2.cadena) + 4));
                                  strcpy($$, $1);
                                  strcat($$, ", ");
                                  strcat($$, $2.cadena); }
  | declaracion ';'             { $$ = malloc(strlen($1.cadena) + 1);
                                  strcpy($$, $1.cadena); }
  ;

declaracion:
    declaracion ',' IDENTIFIER  { strcpy($$.tipo, $1.tipo);
                                  strcpy($$.cadena, $1.cadena);
                                  strcat($$.cadena, ", (");
                                  strcat($$.cadena, $3);
                                  free($3);
                                  strcat($$.cadena, ",");
                                  strcat($$.cadena, $$.tipo);
                                  strcat($$.cadena, ")"); }
  | tipo IDENTIFIER             { strcpy($$.tipo, $1);
                                  strcpy($$.cadena, "(");
                                  strcat($$.cadena, $2);
                                  free($2);
                                  strcat($$.cadena, ",");
                                  strcat($$.cadena, $$.tipo);
                                  strcat($$.cadena, ")"); }
  ;

tipo:
    ENTERO    { $$ = strdup($1);
                free($1); }
  | CARACTER  { $$ = strdup($1);
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
