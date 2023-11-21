#include <stdlib.h>
#include <stdio.h>
extern FILE *yyin;
extern int yyparse(void);

/* yywrap -- return 1 if no more files to parse */
int yywrap(void)
{
  return 1;
}



int main(int argc, char *argv[])
{
  if (argc != 2)
    {
        printf(" [Fatal]: Error! Not ehough arguments given.\n\n");
        exit(1);
    }
   yyin = fopen(argv[1], "r"); 
   if (yyin == NULL)
    {
        printf(" [Fatal]: Error! File %s not found!\n\n",argv[1] );
        exit(-1);
    }
    else
      printf("\n Check file %s\n", argv[1]);

  if (yyparse()==0) {
    printf(" [RES]: XML file is valid \n");
    fclose(yyin);
  } else {
    printf(" [RES]: XML file is not valid \n");
    fclose(yyin);
    
  }
  return 0;
}
