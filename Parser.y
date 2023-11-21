%{

#include <string.h>
#include <stdio.h>
#include <ctype.h>

void yyerror(char *s);
extern int yydebug;
extern int yylineno;
extern int yylex(void);

%}

%union 
{
  char*       strVal;
}


%token <strVal> TERSTRING   ATTVALUE
%token <strVal> STARTXMLDECL START_DOCKTYPE
%token <strVal> ENDXMLDECL  END_DOCKTYPE  
%token <strVal> VERSIONINFO PICOMMENT
%token <strVal> ENCODING 
%token <strVal> STANDALONE 
%token PI PIERROR 
%token OPEN_TAG CLOSE_TAG 

%token SLASH Eq CHARDATA 
%token <strVal> ID 
%type <strVal> STag
%type <strVal> ETag

%start document

%%
document  :
          prolog element miscs
          | {yyerror("Empty XML file");
                return 1;}
          | error {
            yyclearin;
            yyerror("The XML document does not contain elements other than the root element or miscs");
            return 1;
          }

element
          : 
          STag content ETag {
                if (strcmp($1,$3) != 0)
            {
                yyerror("Different opening and closing tags");
                return 1;
            }
          }
          | EmptyElemTag   {    }
          ;



STag      : 
          OPEN_TAG ID Attr CLOSE_TAG {
            //yyerror("TEST CALL");
            $$ = $2 ;
          }
          ;


EmptyElemTag
 : OPEN_TAG ID Attr SLASH CLOSE_TAG {         }
 ;


Attr      : 
          Attr attribute  {           }
          |  {/*      */}
           ;  
attribute : 
          ID Eq ATTVALUE  {     
          }
           ;

ETag      : 
          OPEN_TAG SLASH ID CLOSE_TAG {
            $$ = $3;
            }
          ;



prolog    :
          xmldecl_y doctypedecl miscs
        | xmldecl_y
        | /* empty */
        | xmldecl_y miscs doctypedecl

        | doctypedecl miscs{
              yyerror("XML file must contain XMLdecl element.\n");
              return 1;
        }
        


content
 : content element            {}
 | content PIERROR            {
  yyerror("processing instruction <?xml ?> impossible\n");
  return 1;
}
 | content PICOMMENT { }
 | {/*      */}
 | content CHARDATA   {}
 ;


xmldecl_y :
          STARTXMLDECL VERSIONINFO TERSTRING ENDXMLDECL {
          if (strcmp($3,"1.0")) {
              yyerror("Unsupported version");
              return 1;
            }
          }
        | STARTXMLDECL VERSIONINFO TERSTRING ENCODING TERSTRING ENDXMLDECL {
          if (strcmp($3,"1.0")) {
              yyerror("Unsupported version");
              return 1;
            }
          else if ((strcasecmp($5, "UTF-8"))&& (strcasecmp($5, "ASCII"))&&(strcasecmp($5, "ISO-8859-1"))&&(strcasecmp($5, "Windows-1252"))&&(strcasecmp($5, "UTF-16"))&&(strcasecmp($5, "Windows-1251"))&&(strcasecmp($5, "ISO-8859"))&&(strcasecmp($5, "ISO-10646-UCS-2"))&&(strcasecmp($5, "ISO-2022-JP"))&&(strcasecmp($5, "Shift_JIS"))&&(strcasecmp($5, "EUC-JP"))){
            yyerror("Supported encodings:\n\t UTF-8\n\t UTF-16\n\t ASCII\n\t ISO-8859-1\n\t ISO-8859\n\t ISO-10646-UCS-2\n\t ISO-2022-JP\n\t Shift_JIS\n\t EUC-JP\n\t Windows-1252\n\t Windows-1251.");
            return 1;
            }
            }
          | STARTXMLDECL VERSIONINFO TERSTRING STANDALONE TERSTRING ENDXMLDECL {
              if (strcmp($3,"1.0")) {
                  yyerror("Unsupported version");
                  return 1;
              }
              else if((strcmp($5,"yes")) && (strcmp($5,"no"))){
                yyerror("Standalone must be \"yes\" or \"no\"");
                return 1;
              }
            }
           | STARTXMLDECL error ENDXMLDECL {
              yyclearin;
              yyerror(" Eror inside <? ?> ");
              return 1;
            }
           | STARTXMLDECL VERSIONINFO TERSTRING ENCODING TERSTRING STANDALONE TERSTRING ENDXMLDECL {
              if (strcmp($3,"1.0")) {
                  yyerror("Unsupported version");
                  return 1;
              }
              else if ((strcasecmp($5, "UTF-8"))&& (strcasecmp($5, "ASCII"))&&(strcasecmp($5, "ISO-8859-1"))&&(strcasecmp($5, "Windows-1252"))&&(strcasecmp($5, "UTF-16"))&&(strcasecmp($5, "Windows-1251"))&&(strcasecmp($5, "ISO-8859"))&&(strcasecmp($5, "ISO-10646-UCS-2"))&&(strcasecmp($5, "ISO-2022-JP"))&&(strcasecmp($5, "Shift_JIS"))&&(strcasecmp($5, "EUC-JP"))){
              yyerror("Supported encodings:\n\t UTF-8\n\t UTF-16\n\t ASCII\n\t ISO-8859-1\n\t ISO-8859\n\t ISO-10646-UCS-2\n\t ISO-2022-JP\n\t Shift_JIS\n\t EUC-JP\n\t Windows-1252\n\t Windows-1251.");
              return 1;
              }
              else if((strcmp($7,"yes")) && (strcmp($7,"no"))) {
                yyerror("Standalone must be \"yes\" or \"no\"");
                return 1;
              }
            }
            ;
  
doctypedecl: START_DOCKTYPE TERSTRING END_DOCKTYPE
            | START_DOCKTYPE END_DOCKTYPE {
                yyerror("Empty Docktype");
                return 1;
            }

            ;


miscs       : 
            miscs misc
            |
            /* empty */;

misc        : PICOMMENT
            | PIERROR { 
                  yyerror("PI beginning with <?xml ?>\n");
                  return 1;

            }
            | PI ;


%%

void yyerror(char *s)
{ 
  printf("\n [P]: Error in line %d : %s\n",yylineno,s);
}

