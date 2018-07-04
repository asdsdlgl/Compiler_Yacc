/* Definition section */
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "y.tab.h"	/* header file generated by bison */
extern YYSTYPE yylval; //YYSTYPE

	int IsString = 0;
	int lineCount = 0;
	int CommentLine = 0;
	int IsVar = 0;
	int IsThesameLine = 0;
    char inputID[100];

%}

/* Define regular expression label */
newline		[\n]
digit		[0-9]
letter		[a-zA-Z]
number     {digit}+
float      {digit}+"."{digit}+
id			{letter}+({letter}|{digit})*
ws [ \t]+

%option yylineno

%x COMMENT STRING_STATE

/* Rules section */
%%

 /* Arithmetic */
"+"     { return yytext[0]; }
"-" 	{ return yytext[0]; }
"*" 	{ return yytext[0]; }
"/" 	{ return yytext[0]; }
"%"     { return yytext[0]; }
"++"    { return INCREMENT; }
"--"    { return DECREMENT; }

 /* Relational */
">"		{ return yytext[0]; }
"<"		{ return yytext[0]; }
">="	{ return GREATEQ; }
"<="	{ return LESSEQ; }
"=="	{ return EQUAL; }
"!="	{ return NOTEQUAL; }

 /* Assignment */
"="		{ return yytext[0]; }
"+="	{ return ADDASSIGN; }
"-="	{ return SUBASSIGN; }
"*="	{ return MULASSIGN; }
"/="	{ return DIVASSIGN; }
"%="	{ return MODASSIGN; }

 /* Logical */
"&&"	{ return AND; }
"||"	{ return OR; }
"!"		{ return yytext[0]; }

 /* Delimiters */
"("	{ return yytext[0]; }
")"	{ return yytext[0]; }
"{"	{ return yytext[0]; }
"}"	{ return yytext[0]; }
\"	{
		IsString = (IsString+1)%2;
		if(IsString == 0) {
			//printf("\t String \n");
		}
		//printf("%s \t Quotation \n", yytext);
        return yytext[0];
	}

 /* Print Keywords */	
"print"		{ return PRINT; }
"println"	{ return PRINTLN; }

 /* Condition and Loop Keywords */
"if"		{ return IF;}
"else"		{ return ELSE;}
"for"		{ return FOR;}

 /* Declaration Keywords */
"var"		{ IsVar = 1; return VAR;}
"void"		{ }
"int"		{ 
		if(IsVar == 1) {
//			keytype = 0;
			IsVar = 0;
//    		printf("%s \t int TYPE VAR\n",inputID);
//			insert_symbol(inputID,keytype);
//			keytype = 2;
            return INT;
		}
}
"float32"	{
        if(IsVar == 1) {
 //       keytype = 1;
        IsVar = 0;
 //       printf("%s \t float TYPE VAR\n",inputID);
    //    insert_symbol(inputID,keytype);
   //     keytype = 2;
        return FLOAT;
        }
}

 /* Number Constant */
{number} { 
				if(IsString == 0) {
					//printf("%s \t Number \n", yytext);
                    yylval.value.i_val = atoi(yytext); 
                    return I_CONST;
				}
				else {
					//printf("%s",yytext);
                    yylval.string = strdup(yytext);
                    return STRING;
                }
         }
{float} {
                if(IsString == 0) {
                    //printf("%s \t FloatNumber \n", yytext); 
                    yylval.value.f_val = atof(yytext);
                    return F_CONST;
                }
				else {
					//printf("%s",yytext);
                    yylval.string = strdup(yytext);
                    return STRING;
                }
        }

 /* Comment */
"//"("/"|"*"|[digit]|{id}|{number}|[ \t]|"("|")"|"+"|"-"|"["|"]"|"{"|"}"|","|";"|">"|"<"|"="|"?"|'.'|"'")* {
	CommentLine++;
	IsThesameLine++;
	printf("%s \t  C++ Comment \n",yytext);
	}
"/*"([^*]|[*]+[^*/])*[*]*"*/" {
	CommentLine++;
	IsThesameLine++;
	for(int i = 0; i<yyleng ; i++) {
		if((yytext[i]) == '\n') {
			lineCount++;
			CommentLine++;
		}
	}
	printf("%s \t  C Comment \n",yytext);
	}

 /* Variable ID */
 {id}       { 
		if(IsVar == 1) {
			strcpy(inputID,yytext);
            yylval.string = strdup(yytext);
            return ID;
		}
        else if(IsString == 0) {
//            printf("%s \t ID \n", yytext);
//			int tableindex = lookup_symbol(yytext);
//			if(tableindex == -1) {
//				printf("********** Undeclared variables : %s   {line} : %d **********\n",yytext,lineCount+1);
//			}
            yylval.string = strdup(yytext);
            return USEID;
		}
        else {
//            printf("%s ",yytext);
            yylval.string = strdup(yytext);
            return STRING;
        }
 }

 /* others */

\n	{ 
		lineCount++;
		if(IsThesameLine != 0)
			CommentLine = CommentLine - IsThesameLine + 1;
		IsThesameLine = 0;
        return NEWLINE;
	}
{ws}	{
		if(IsString == 0){}
		else {
//			printf("%s",yytext);
            yylval.string = strdup(yytext);
            return STRING;
        }
}
<<EOF>>     { return END; }

%%

int yywrap()
{
    return 1;
}