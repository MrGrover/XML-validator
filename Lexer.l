
%option yylineno
%option noyywrap

%{

                                                  //SPEC:   http://www.w3.org/TR/xml/
#include <string.h>
#include "y.tab.h"

int debug = 0;


int flagPI = 0 ;
int flagDOCKTYPE=0;
int helpFlag = 0;

%}
S1  [\n\r\t ] 
S   {S1}+                                  
                                                  // S[3]
CharRef   "&#"[0-9]+";"|"&#x"[0-9a-fA-F]+";"      
                                                  // CharRef[66] 
Eq25    {S}?"="{S}?                               
                                                  // Eq[25]

Name    ([_:]|[\x41-\x5A]|[\x61-\x7A]|[\xC0-\xD6]|[\xD8-\xF6]|[\xF8-\xFF])(([\x41-\x5A]|[\x61-\x7A]|[\xC0-\xD6]|[\xD8-\xF6]|[\xF8-\xFF])|[0-9.\-_:])*
                                                  //Name[5] = NameStartChar (NameChar)* 

chardata  [^<]*                                   
                                                  //[a-zA-Z0-9_\-.:" "\"\'\\]* chardata[14]
attvalue  \"[^"]*\"|\'[^']*\' 
                                                  // \"[^"]*\"|\'[^']*\' attvalue[10]

DocTypeCE                                         {DT_IdentSE}({S})?(\[({DT_ItemSE})*]({S})?)?

DT_IdentSE                                        {S}{Name}({S}({Name}|{QuoteSE}))*

DT_ItemSE                                         \<(!(--{Until2Hyphens}>|[^-]{MarkupDeclCE})|\?{Name}({PI_Tail}))|%{Name};|{S}

QuoteSE                                           \"[^"]*\"|'[^']*'

PI_Tail                                           \?>|{S1}{UntilQMs}([^>?]{UntilQMs})*>

UntilQMs                                          [^?]*\?+

UntilHyphen                                       [^-]*-

Until2Hyphens                                     {UntilHyphen}([^-]{UntilHyphen})*-

MarkupDeclCE                                      ([^\]"'><]+|{QuoteSE})*> 


%x STXMLDECL COMMENT XMLDECL_END STSTART_DOCKTYPE IN_TAG


%%

<INITIAL>{

              "<?"[Xx][Mm][Ll] {
                if (debug==1) printf ("\n START_XMLDECL:%s\n",yytext);
                  BEGIN(STXMLDECL);
                  return STARTXMLDECL;
                
              }
              "<!--" {
                if (debug==1) printf ("\n STARTCOMMENT:%s\n",yytext);
                if (yylineno==1){
                      printf("\n [L] Error: XMLDecl MUST start at first line and before doctypedecl\n");
                      exit(10);
                }else BEGIN(COMMENT);
                
              }
              "<!DOCTYPE" {
                    if (debug==1) printf ("\n START_DOCTYPE:%s\n",yytext); 
                    flagDOCKTYPE=1;
                    BEGIN(STSTART_DOCKTYPE);
                    return START_DOCKTYPE;
              }

              {S} {};
              . {
                    printf("[L] Error in line %d after <?: unrecognized character %s \n",yylineno,yytext) ; 
                    exit(10);
                  }



              

}



<STXMLDECL>{
                  {S}"version"{Eq25} {
                    if (yylineno!=1){
                      printf("\n [L] Error: XMLDecl MUST start at first line and before doctypedecl\n");
                      exit(10);
                    }
                    if (debug==1) printf ("\n VERSIONINFO :%s\n",yytext);
                    return VERSIONINFO;
                  }

                  {S}"encoding"{Eq25} {
                    if (debug==1) printf ("\n ENCODING :%s\n",yytext);
                    return ENCODING;
                  }
                  {S}"standalone"{Eq25} {
                    if (debug==1) printf ("\n STANDALONE :%s\n",yytext);
                    return STANDALONE;
                  }

                  {S}?"?>"  {
                    if (debug==1) printf ("\n END_XMLDECL :%s\n",yytext);
                    BEGIN(XMLDECL_END);
                    return ENDXMLDECL;
                  }
                  \"[^\"]+\" { 
                    if (debug==1) printf ("\n TERSTRING:%s\n",yytext);
                    int lenVer;
                    for (lenVer=1; (yytext[lenVer] != '"') ; lenVer++ );
                    yytext[lenVer] = 0;
                    yylval.strVal = strdup(yytext+1);
                    return TERSTRING;
                  }
                 

                  . {
                    printf("[L] Error in line %d after <?: unrecognized character %s \n",yylineno,yytext) ; 
                    exit(10);
                  }
}



<COMMENT>{
               {S}|.    {    
                 if (debug==1) printf ("\n  GOOD COMMENT:%s\n",yytext);   
               }
                

                [\-][\-][\-][>] { 
                 if (debug==1) printf ("\n  BAD COMMENT:%s\n",yytext);
                 printf("[L] Error in line %d. Construction <--- or ---> in comment %s \n",yylineno,yytext) ; 
                 exit(10);
                }
                [\-][\-][>] {
                  if (debug==1) printf ("\n  EXIT COMMENT:%s\n",yytext);
                  BEGIN(XMLDECL_END);
                  return PICOMMENT;
                }
                [\-][\-] { 
                 if (debug==1) printf ("\n  BAD COMMENT:%s\n",yytext);
                 printf("[L] Error in line %d. Construction  ---> or \"--\" in comment %s \n",yylineno,yytext) ; 
                 exit(10);
                }


}




<XMLDECL_END>{

              "<?"[Xx][Mm][Ll]{S}({S}|([^?]|("?"[^>])))*"?>"|"<?"[Xx][Mm][Ll]"?>" {
              if (flagDOCKTYPE==1) {
                      printf("\n [L] Error: XMLDecl MUST start at first line and before doctypedecl\n");
                      exit(10);
              }
              if (debug==1) printf ("\n\nPIERROR:%s\n",yytext) ; 
              return PIERROR;
}

              "<?"({S}|([^?]|("?"[^>])))*"?>" {  
              if (debug==1) printf ("\n\nPI:%s\n",yytext) ; 
              return PI;
}
              "<!--" {
                if (debug==1) printf ("\n STARTCOMMENT:%s\n",yytext);
                BEGIN(COMMENT);
                
              }
              "<!DOCTYPE" { 
                if (flagDOCKTYPE==0){
                    if (debug==1) printf ("\n START_DOCTYPE:%s\n",yytext); 
                    flagDOCKTYPE=1;
                    BEGIN(STSTART_DOCKTYPE);
                    return START_DOCKTYPE;
              }else{
                      printf("\n [L] Error: Double tag of type \"!DOCKTYPE\"\n");
                      exit(10);
              }
              }

              "<" {
                if (debug==1) printf ("\n\nOPEN_TAG:%s\n",yytext) ; 
                BEGIN(IN_TAG);
                return OPEN_TAG;
              }
              {S}|. {};




}

<IN_TAG>{
              ">" {
                if (debug==1) printf ("\n\nCLOSE_TAG:%s\n",yytext) ; 
                BEGIN(XMLDECL_END);
                return CLOSE_TAG;
              }
              "/" {
                if (debug==1) printf ("\n\nSLASH:%s\n",yytext) ; 
                return SLASH;
              }
              {Eq25} {
                if (debug==1) printf ("\n\nEq:'%s'\n",yytext) ;
                return Eq;
              }
              {Name} {
                if (debug==1) printf ("\n\nID:%s\n",yytext) ; 
                yylval.strVal=strdup(yytext);
                return ID;
              }
              {attvalue} {
                if (debug==1) printf ("\n\nATTVALUE:%s\n",yytext) ;
                if ((strstr(yytext,"<"))|| (strstr(yytext,">"))|| (strstr(yytext,"&"))||(strstr(yytext,"'"))|| (strstr(yytext,"&quot")))
                printf(" [L] Warning in line %d! Characters MUST BE escaped as: \n\t \" - &qout \n\t ' - &apos \n\t < - &lt \n\t > - &qt \n\t & - &amp \n ",yylineno);
                return ATTVALUE;
              }
              {S}|. {};

               




}


<STSTART_DOCKTYPE>{
                     {DocTypeCE}? {      
                            if (debug==1) printf ("\n NAME:%s\n",yytext);
                            return TERSTRING;
                    }
                    \> {
                            if (debug==1) printf ("\n DOCTYPE_CLOSE:%s\n",yytext);
                            BEGIN(XMLDECL_END);
                            return END_DOCKTYPE;
                    }
                    






}

%%

