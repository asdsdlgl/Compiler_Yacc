/*	Definition section */
%{
extern int yylineno;
extern int yylex();

void yyerror(char* msg);

#define TableSize
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
/* Symbol table function - you can add new function if need. */

char INT_TYPE = 0;
char FLOAT_TYPE = 1;
int test = 0;
int lineNumber = 0;
int IsFirst = 0;
int currentIndex = 0;
int keytype = 2;
int divbyzero = 0;
int blocknumber = 0;

int currentBlock = 0;


char inputID[100];
char StringID[100];
const char * keyword[] = {
	"int",
	"float32"
	""
};
typedef struct Symbol {
	int index;
	int type;
    int block;
    union {
        int number;
        double fnumber;
    };
	char name[100];
	struct Symbol *next;		
} symBol;

typedef struct hashTable {
	struct Symbol *head;
} Node;
Node table[300];
symBol *cur;

int entryNumber(char* key);
symBol* create_symbol(char* id,int type,double number);
symBol* currentSymbol(char* id);
void insert_symbol(char* id,int type,double number);
int lookup_symbol(char* id);
int lookup_symbolRe(char* id);
void dump_symbol();
void free_symbol();


%}

/* Using union to define nonterminal and token type */
%union {
    struct
    {
        union
        {
            int i_val;
            double f_val;
        };
        char type;
    } value;
    char* string;
}

/* Token without return */
%token PRINT PRINTLN 
%token IF ELSE FOR
%token VAR NEWLINE
%token INCREMENT DECREMENT GREATEQ LESSEQ EQUAL NOTEQUAL
%token ADDASSIGN SUBASSIGN MULASSIGN DIVASSIGN MODASSIGN
%token OR AND INT FLOAT END

/* Token with return, which need to sepcify type */
%token <value> I_CONST
%token <value> F_CONST
%token <string> STRING ID USEID

/* Nonterminal with return, which need to sepcify type */
%type <value> stat
%type <value> dlcs
%type <value> factor
%type <value> expr
%type <value> term
%type <value> bracket
%type <value> print_func
%type <value> declaration
%type <value> relation
%type <value> crement
%type <value> assignment
%type <value> selection
%type <value> iteration
%type <string> str
%type <value> logical


/* Yacc will start at this nonterminal */
%start program

/* Grammar section */
%%

program
    : program dlcs END { return 0;}
    |
;
dlcs
    : dlcs stat
    | stat
;
stat
    : declaration NEWLINE {
        divbyzero = 0;
     }
    | expr NEWLINE {
        divbyzero = 0;
     }
    | print_func NEWLINE {
        divbyzero = 0;
     }
    | relation NEWLINE {
        divbyzero = 0;
     }
    | assignment NEWLINE {
        divbyzero = 0;
        lineNumber++;
     }
    | selection NEWLINE {
        divbyzero = 0;
     }
    | iteration NEWLINE {
        divbyzero = 0;
     }
    | logical NEWLINE {
        divbyzero = 0;
     }
    | NEWLINE {
        divbyzero = 0;
     }
;
selection
    : IF '(' relation ')' '{' dlcs '}' { printf("IF\n");}
    | IF '(' relation ')' '{' dlcs '}' ELSE '{' dlcs '}' { printf("IF_ELSE\n");}
    | IF '(' relation ')' '{' dlcs '}' ELSE selection { printf("IF_ELSE\n");}
;
iteration
    : FOR '(' relation ')' '{' dlcs '}' {printf("For Function\n");}
;
logical
    : expr AND expr {printf("AND\n");}
    | expr OR expr {printf("OR\n");}
    | '!' expr {printf("NOT\n");}
;
assignment
    : USEID '=' expr {
        symBol *current;
	    int tableindex = lookup_symbol($1);
    	if(tableindex == -1) {
    		printf("<<ERROR>> Undeclared Variables : %s  Line : %d\n",$1,yylineno);
            $$.type = INT_TYPE;
            $$.i_val = 0;
		} else {
            if(divbyzero == 1) {
                divbyzero = 0;
                break;
            }
            printf("Assign\n");
            current = currentSymbol($1);
            if(current->type==INT_TYPE) {
                if($3.type==INT_TYPE)
                    current->number = $3.i_val;
                else if($3.type==FLOAT_TYPE) {
                    current->number = $3.f_val;
                }
                $$.type = INT_TYPE;
                $$.i_val = current->number;
            }else if(current->type == FLOAT_TYPE) {
                if($3.type==INT_TYPE)
                    current->fnumber = $3.i_val;
                else if($3.type==FLOAT_TYPE) {
                    current->fnumber = $3.f_val;
                }
                $$.type = FLOAT_TYPE;
                $$.f_val = current->fnumber;
            }
        }
     }
    | USEID ADDASSIGN expr {
        symBol *current;
	    int tableindex = lookup_symbol($1);
    	if(tableindex == -1) {
    		printf("<<ERROR>> Undeclared Variables : %s  Line : %d\n",$1,yylineno);
            $$.type = INT_TYPE;
            $$.i_val = 0;
		} else {
            if(divbyzero == 1) {
                divbyzero = 0;
                break;
            }
            printf("ADDASSIGN\n");
            current = currentSymbol($1);
            if(current->type==INT_TYPE) {
                if($3.type==INT_TYPE)
                    current->number = current->number + $3.i_val;
                else if($3.type==FLOAT_TYPE) {
                    current->number = current->number + $3.f_val;
                }
                $$.type = INT_TYPE;
                $$.i_val = current->number;
            }else if(current->type == FLOAT_TYPE) {
                if($3.type==INT_TYPE)
                    current->fnumber = current->fnumber + $3.i_val;
                else if($3.type==FLOAT_TYPE) {
                    current->fnumber = current->fnumber + $3.f_val;
                }
                $$.type = FLOAT_TYPE;
                $$.f_val = current->fnumber;
            }
        }
     }
    | USEID SUBASSIGN expr {
        symBol *current;
	    int tableindex = lookup_symbol($1);
    	if(tableindex == -1) {
    		printf("<<ERROR>> Undeclared Variables : %s  Line : %d\n",$1,yylineno);
            $$.type = INT_TYPE;
            $$.i_val = 0;
		} else {
            if(divbyzero == 1) {
                divbyzero = 0;
                break;
            }
            printf("SUBASSIGN\n");
            current = currentSymbol($1);
            if(current->type==INT_TYPE) {
                if($3.type==INT_TYPE)
                    current->number = current->number - $3.i_val;
                else if($3.type==FLOAT_TYPE) {
                    current->number = current->number - $3.f_val;
                }
                $$.type = INT_TYPE;
                $$.i_val = current->number;
            }else if(current->type == FLOAT_TYPE) {
                if($3.type==INT_TYPE)
                    current->fnumber = current->fnumber - $3.i_val;
                else if($3.type==FLOAT_TYPE) {
                    current->fnumber = current->fnumber - $3.f_val;
                }
                $$.type = FLOAT_TYPE;
                $$.f_val = current->fnumber;
            }
        }
     }
    | USEID MULASSIGN expr {
        symBol *current;
	    int tableindex = lookup_symbol($1);
    	if(tableindex == -1) {
    		printf("<<ERROR>> Undeclared Variables : %s  Line : %d\n",$1,yylineno);
            $$.type = INT_TYPE;
            $$.i_val = 0;
		} else {
            if(divbyzero == 1) {
                divbyzero = 0;
                break;
            }
            printf("MULASSIGN\n");
            current = currentSymbol($1);
            if(current->type==INT_TYPE) {
                if($3.type==INT_TYPE)
                    current->number = current->number * $3.i_val;
                else if($3.type==FLOAT_TYPE) {
                    current->number = current->number * $3.f_val;
                }
                $$.type = INT_TYPE;
                $$.i_val = current->number;
            }else if(current->type == FLOAT_TYPE) {
                if($3.type==INT_TYPE)
                    current->fnumber = current->fnumber * $3.i_val;
                else if($3.type==FLOAT_TYPE) {
                    current->fnumber = current->fnumber * $3.f_val;
                }
                $$.type = FLOAT_TYPE;
                $$.f_val = current->fnumber;
            }
        }
     }
    | USEID DIVASSIGN expr {
        symBol *current;
	    int tableindex = lookup_symbol($1);
    	if(tableindex == -1) {
    		printf("<<ERROR>> Undeclared Variables : %s  Line : %d\n",$1,yylineno);
            $$.type = INT_TYPE;
            $$.i_val = 0;
		} else {
            if(($3.type == INT_TYPE && $3.i_val == 0)||($3.type == FLOAT_TYPE && $3.f_val == 0)) {
                printf("<<ERROR>> The divisor can't be 0  Line : %d\n",yylineno);
                divbyzero = 0;
                break;
            }
            if(divbyzero == 1) {
                divbyzero = 0;
                break;
            }
            printf("DIVASSIGN\n");
            current = currentSymbol($1);
            if(current->type==INT_TYPE) {
                if($3.type==INT_TYPE)
                    current->number = current->number / $3.i_val;
                else if($3.type==FLOAT_TYPE) {
                    current->number = current->number / $3.f_val;
                }
                $$.type = INT_TYPE;
                $$.i_val = current->number;
            }else if(current->type == FLOAT_TYPE) {
                if($3.type==INT_TYPE)
                    current->fnumber = current->fnumber / $3.i_val;
                else if($3.type==FLOAT_TYPE) {
                    current->fnumber = current->fnumber / $3.f_val;
                }
                $$.type = FLOAT_TYPE;
                $$.f_val = current->fnumber;
            }
        }
     }
    | USEID MODASSIGN expr {
        symBol *current;
	    int tableindex = lookup_symbol($1);
    	if(tableindex == -1) {
    		printf("<<ERROR>> Undeclared Variables : %s  Line : %d\n",$1,yylineno);
            $$.type = INT_TYPE;
            $$.i_val = 0;
		} else {
            if(divbyzero == 1) {
                divbyzero = 0;
                break;
            }
            current = currentSymbol($1);
            if(current->type==INT_TYPE) {
                if($3.type==INT_TYPE) {
                    current->number = current->number % $3.i_val;
                    printf("MODASSIGN\n");
                } else if($3.type==FLOAT_TYPE) {
                    printf("<<ERROR>> MOD with FLOAT type ERROR  Line : %d\n",yylineno);
                }
                $$.type = INT_TYPE;
                $$.i_val = current->number;
            }else if(current->type == FLOAT_TYPE) {
                printf("<<ERROR>> MOD with FLOAT type ERROR  Line : %d\n",yylineno);
            }
        }
     }
;
relation
    : expr '<' expr {
        if($1.type == INT_TYPE && $3.type == INT_TYPE) {
            if($1.i_val < $3.i_val)
                printf("true\n");
            else
                printf("false\n");
        } else if($1.type == FLOAT_TYPE && $3.type == FLOAT_TYPE) {
            if($1.f_val < $3.f_val)
                printf("true\n");
            else
                printf("false\n");
        } else if($1.type == INT_TYPE && $3.type == FLOAT_TYPE) {
            if($1.i_val < $3.f_val)
                printf("true\n");
            else
                printf("false\n");
        } else if($1.type == FLOAT_TYPE && $3.type == INT_TYPE) {
            if($1.f_val < $3.i_val)
                printf("true\n");
            else
                printf("false\n");
        }
     }
    | expr '>' expr {
        if($1.type == INT_TYPE && $3.type == INT_TYPE) {
            if($1.i_val > $3.i_val)
                printf("true\n");
            else
                printf("false\n");
        } else if($1.type == FLOAT_TYPE && $3.type == FLOAT_TYPE) {
            if($1.f_val > $3.f_val)
                printf("true\n");
            else
                printf("false\n");
        } else if($1.type == INT_TYPE && $3.type == FLOAT_TYPE) {
            if($1.i_val > $3.f_val)
                printf("true\n");
            else
                printf("false\n");
        } else if($1.type == FLOAT_TYPE && $3.type == INT_TYPE) {
            if($1.f_val > $3.i_val)
                printf("true\n");
            else
                printf("false\n");
        }
     }
    | expr LESSEQ expr {
        if($1.type == INT_TYPE && $3.type == INT_TYPE) {
            if($1.i_val <= $3.i_val)
                printf("true\n");
            else
                printf("false\n");
        } else if($1.type == FLOAT_TYPE && $3.type == FLOAT_TYPE) {
            if($1.f_val <= $3.f_val)
                printf("true\n");
            else
                printf("false\n");
        } else if($1.type == INT_TYPE && $3.type == FLOAT_TYPE) {
            if($1.i_val <= $3.f_val)
                printf("true\n");
            else
                printf("false\n");
        } else if($1.type == FLOAT_TYPE && $3.type == INT_TYPE) {
            if($1.f_val <= $3.i_val)
                printf("true\n");
            else
                printf("false\n");
        }
     }
    | expr GREATEQ expr {
        if($1.type == INT_TYPE && $3.type == INT_TYPE) {
            if($1.i_val >= $3.i_val)
                printf("true\n");
            else
                printf("false\n");
        } else if($1.type == FLOAT_TYPE && $3.type == FLOAT_TYPE) {
            if($1.f_val >= $3.f_val)
                printf("true\n");
            else
                printf("false\n");
        } else if($1.type == INT_TYPE && $3.type == FLOAT_TYPE) {
            if($1.i_val >= $3.f_val)
                printf("true\n");
            else
                printf("false\n");
        } else if($1.type == FLOAT_TYPE && $3.type == INT_TYPE) {
            if($1.f_val >= $3.i_val)
                printf("true\n");
            else
                printf("false\n");
        }
     }
    | expr EQUAL expr {
        if($1.type == INT_TYPE && $3.type == INT_TYPE) {
            if($1.i_val == $3.i_val)
                printf("true\n");
            else
                printf("false\n");
        } else if($1.type == FLOAT_TYPE && $3.type == FLOAT_TYPE) {
            if($1.f_val == $3.f_val)
                printf("true\n");
            else
                printf("false\n");
        } else if($1.type == INT_TYPE && $3.type == FLOAT_TYPE) {
            if($1.i_val == $3.f_val)
                printf("true\n");
            else
                printf("false\n");
        } else if($1.type == FLOAT_TYPE && $3.type == INT_TYPE) {
            if($1.f_val == $3.i_val)
                printf("true\n");
            else
                printf("false\n");
        }
     }
    | expr NOTEQUAL expr {
        if($1.type == INT_TYPE && $3.type == INT_TYPE) {
            if($1.i_val != $3.i_val)
                printf("true\n");
            else
                printf("false\n");
        } else if($1.type == FLOAT_TYPE && $3.type == FLOAT_TYPE) {
            if($1.f_val != $3.f_val)
                printf("true\n");
            else
                printf("false\n");
        } else if($1.type == INT_TYPE && $3.type == FLOAT_TYPE) {
            if($1.i_val != $3.f_val)
                printf("true\n");
            else
                printf("false\n");
        } else if($1.type == FLOAT_TYPE && $3.type == INT_TYPE) {
            if($1.f_val != $3.i_val)
                printf("true\n");
            else
                printf("false\n");
        }
     }
;
print_func
    : PRINT '(' expr ')' {
        if($3.type == INT_TYPE)
            printf("Print : %d     block :   %d\n",$3.i_val,blocknumber);
        else if($3.type == FLOAT_TYPE) 
            printf("Print : %f     block :   %d\n",$3.f_val,blocknumber);
     }
    | PRINTLN '(' expr ')' {
        if($3.type == INT_TYPE)
            printf("Println : %d     block :   %d\n",$3.i_val,blocknumber);
        else if($3.type == FLOAT_TYPE) 
            printf("Println : %f     block :   %d\n",$3.f_val,blocknumber);
     }
    | PRINT '(' '"' str '"' ')' {printf("Print : %s\n",$4);}
    | PRINTLN '(' '"' str '"' ')' {printf("Println : %s\n",$4);}
;
str
    : STRING str {strcat($$,$2);}
    | STRING {strcpy($$,$1);}
;
declaration
    : VAR ID type '=' expr {
        strcpy(inputID,$2);
        if($5.type==INT_TYPE)
            insert_symbol(inputID,keytype,$5.i_val);
        else
            insert_symbol(inputID,keytype,$5.f_val);
        keytype = 2;
      }
    | VAR ID type {
        strcpy(inputID,$2);
        insert_symbol(inputID,keytype,0);
        keytype = 2;
      }
;
type
    : INT {keytype = 0;}
    | FLOAT {keytype = 1;}
    /*| VOID { $$ = $1; }*/
;
expr
    : term { $$ = $1; }
    | expr '+' term {
        printf("Add\n");
        if($1.type == INT_TYPE && $3.type == INT_TYPE) {
            $$.type = INT_TYPE;
            $$.i_val = $1.i_val + $3.i_val;
        } else if($1.type == FLOAT_TYPE && $3.type == FLOAT_TYPE) {
            $$.type = FLOAT_TYPE;
            $$.f_val = $1.f_val + $3.f_val;
        } else if($1.type == INT_TYPE && $3.type == FLOAT_TYPE) {
            $$.type = FLOAT_TYPE;
            $$.f_val = $1.i_val + $3.f_val;
        } else if($1.type == FLOAT_TYPE && $3.type == INT_TYPE) {
            $$.type = FLOAT_TYPE;
            $$.f_val = $1.f_val + $3.i_val;
        }
    }
    | expr '-' term {
        printf("Sub\n");
        if($1.type == INT_TYPE && $3.type == INT_TYPE) {
            $$.type = INT_TYPE;
            $$.i_val = $1.i_val - $3.i_val;
        } else if($1.type == FLOAT_TYPE && $3.type == FLOAT_TYPE) {
            $$.type = FLOAT_TYPE;
            $$.f_val = $1.f_val - $3.f_val;
        } else if($1.type == INT_TYPE && $3.type == FLOAT_TYPE) {
            $$.type = FLOAT_TYPE;
            $$.f_val = $1.i_val - $3.f_val;
        } else if($1.type == FLOAT_TYPE && $3.type == INT_TYPE) {
            $$.type = FLOAT_TYPE;
            $$.f_val = $1.f_val - $3.i_val;
        }
    }
    | expr '%' term {
        printf("Mod\n");
        if($1.type == INT_TYPE && $3.type == INT_TYPE) {
            $$.type = INT_TYPE;
            $$.i_val = $1.i_val % $3.i_val;
        } else {
            divbyzero = 1;
            printf("<<ERROR>> MOD with Float ERROR  Line : %d\n",yylineno);
        }
    }
;

term
    : crement { $$ = $1; }
    | term  '*' crement {
        printf("Mul\n");
        if($1.type == INT_TYPE && $3.type == INT_TYPE) {
            $$.type = INT_TYPE;
            $$.i_val = $1.i_val * $3.i_val;
        } else if($1.type == FLOAT_TYPE && $3.type == FLOAT_TYPE) {
            $$.type = FLOAT_TYPE;
            $$.f_val = $1.f_val * $3.f_val;
        } else if($1.type == INT_TYPE && $3.type == FLOAT_TYPE) {
            $$.type = FLOAT_TYPE;
            $$.f_val = $1.i_val * $3.f_val;
        } else if($1.type == FLOAT_TYPE && $3.type == INT_TYPE) {
            $$.type = FLOAT_TYPE;
            $$.f_val = $1.f_val * $3.i_val;
        }
      }
    | term  '/' crement {
        if(($3.type == INT_TYPE && $3.i_val == 0)||($3.type == FLOAT_TYPE && $3.f_val == 0)) {
            printf("<<ERROR>> The divisor can't be 0  Line : %d\n",yylineno);
            divbyzero = 1;
        } else {
            printf("Div\n");
            if($1.type == INT_TYPE && $3.type == INT_TYPE) {
                $$.type = INT_TYPE;
                $$.i_val = $1.i_val / $3.i_val;
            } else if($1.type == FLOAT_TYPE && $3.type == FLOAT_TYPE) {
                $$.type = FLOAT_TYPE;
                $$.f_val = $1.f_val / $3.f_val;
            } else if($1.type == INT_TYPE && $3.type == FLOAT_TYPE) {
                $$.type = FLOAT_TYPE;
                $$.f_val = $1.i_val / $3.f_val;
            } else if($1.type == FLOAT_TYPE && $3.type == INT_TYPE) {
                $$.type = FLOAT_TYPE;
                $$.f_val = $1.f_val / $3.i_val;
            }
        }
      }
;

crement
    : USEID INCREMENT {
        printf("INCREMENT\n");
	    int tableindex = lookup_symbol($1);
    	if(tableindex == -1) {
    		printf("<<ERROR>> Undeclared Variables : %s  Line : %d\n",$1,yylineno);
            divbyzero = 1;
            $$.type = INT_TYPE;
            $$.i_val = 0;
		} else {
            if(divbyzero == 1) {
                divbyzero = 0;
                break;
            }
            if(cur->type == INT_TYPE) {
                cur->number = cur->number + 1;
                $$.type = INT_TYPE;
                $$.i_val = cur->number;
            } else if(cur->type == FLOAT_TYPE) {
                cur->fnumber = cur->fnumber + 1;
                $$.type = FLOAT_TYPE;
                $$.f_val = cur->fnumber;
            }
            blocknumber = cur -> block;
            cur = NULL;
        }
     }
    | USEID DECREMENT {
        printf("DECREMENT\n");
	    int tableindex = lookup_symbol($1);
    	if(tableindex == -1) {
    		printf("<<ERROR>> Undeclared Variables : %s  Line : %d\n",$1,yylineno);
            divbyzero = 1;
            $$.type = INT_TYPE;
            $$.i_val = 0;
		} else {
            if(divbyzero == 1) {
                divbyzero = 0;
                break;
            }
            if(cur->type == INT_TYPE) {
                cur->number = cur->number - 1;
                $$.type = INT_TYPE;
                $$.i_val = cur->number;
            } else if(cur->type == FLOAT_TYPE) {
                cur->fnumber = cur->fnumber - 1;
                $$.type = FLOAT_TYPE;
                $$.f_val = cur->fnumber;
            }
            blocknumber = cur -> block;
            cur = NULL;
        }
     }
    | bracket { $$ = $1; }
;
bracket
    : '(' expr ')' { $$ = $2; }
    | '{' {currentBlock++;}
    | '}' {
        free_symbol();
        currentBlock--;
     }
    | factor { $$ = $1; }
;

factor
    : I_CONST {
        $$.type = INT_TYPE;
        $$.i_val = $1.i_val; 
      }
    | F_CONST {
        $$.type = FLOAT_TYPE;
        $$.f_val = $1.f_val;
      }
    | USEID {
	    int tableindex = lookup_symbol($1);
    	if(tableindex == -1) {
    		printf("<<ERROR>> Undeclared Variables : %s  Line : %d\n",$1,yylineno);
            divbyzero = 1;
            $$.type = INT_TYPE;
            $$.i_val = 0;
		} else {
            if(cur->type == INT_TYPE) {
                $$.type = INT_TYPE;
                $$.i_val = cur->number;
            } else if(cur->type == FLOAT_TYPE) {
                $$.type = FLOAT_TYPE;
                $$.f_val = cur->fnumber;
            }
            blocknumber = cur -> block;
            cur = NULL;
        }
     }
;

%%

void yyerror(char* msg)
{
    printf("%s\n",msg);
    exit(1);
}


/* C code section */
int main(int argc, char** argv)
{
    yylineno = 0;

    yyparse();
    printf("\n\n Total Line : %d\n\n",yylineno);
    dump_symbol();
    return 0;
}

int entryNumber(char* key) {
	int entry = 0;
	int i = 0;
	while(key[i]!='\0') {
		entry = ( ( entry<<4 ) + key[i]) % 300;
		i++;
	}
	return entry;
}

symBol* create_symbol(char* id,int type,double number) {
	if(IsFirst == 0) {
		memset(table,0,sizeof(table));
		printf("Create a symbol table with TableSize %d\n",300);
		IsFirst = 1;
	}
	symBol *current = (symBol *)malloc(sizeof(symBol));
	strcpy(current->name,id);
	current->type = type;
    if(type == INT_TYPE)
        current->number = number;
    else
        current->fnumber = number;
    
    current->block = currentBlock;
	current->next = NULL;
	return current;
}
void insert_symbol(char* id,int type,double number) {
	symBol* current = create_symbol(id,type,number);

	currentIndex = entryNumber(id);

	if(lookup_symbolRe(id)!=-1) {
		printf("<<ERROR>> Redefined variables : %s  Line : %d\n",id,yylineno);
		free(current);
		return;
	}

    if(current->block==0)
    	printf("Insert a symbol number : %s\n",id);

	symBol* last;
	if(table[currentIndex].head==NULL) {
		current->index = currentIndex;
		table[current->index].head = current;
		return;
	}
	else {
		for(last=table[currentIndex].head;last->next!=NULL;last=last->next) {
		}
		last->next = current;
		current->index = currentIndex;
	}
	return;
}
int lookup_symbol(char* id) {
    int blocktemp = currentBlock;
	symBol *current;
	int tableindex = entryNumber(id);
    for(blocktemp = currentBlock;blocktemp >= 0;blocktemp--) {
        for(current = table[tableindex].head;current!=NULL;current=current->next) {
		    if(strcmp(current->name,id)==0&&current->block==blocktemp) {
                cur = current;
			    return current->index;
		    }
        }
    }
	return -1;
}
int lookup_symbolRe(char* id) {
	symBol *current;
	int tableindex = entryNumber(id);
	for(current = table[tableindex].head;current!=NULL;current=current->next) {
	    if(strcmp(current->name,id)==0&&current->block==currentBlock) {
            cur = current;
		    return current->index;
		}
	}
	return -1;
}
void dump_symbol() {
	symBol *current;
	printf("\nThe Symbol Table Dump:\n");
	printf("Index	ID	Type      Data\n");
	for(int i = 0;i<300;i++) {
		for(current = table[i].head ; current!=NULL ; current=current->next) {
            if(current->type == INT_TYPE)
			    printf("%2d	%s	%s       %d \n",current->index,current->name,keyword[current->type],current->number);
            else if(current->type == FLOAT_TYPE) {
                printf("%2d	%s	%s   %f\n",current->index,current->name,keyword[current->type],current->fnumber);
            }
		}
	}
	return;
}
symBol* currentSymbol(char* id) {
	symBol *current;
    int blocktemp;
	int tableindex = entryNumber(id);
	
    for(blocktemp = currentBlock;blocktemp >= 0;blocktemp--) {
    	for(current = table[tableindex].head;current!=NULL;current=current->next) {
        	if(strcmp(current->name,id)==0&&current->block==blocktemp) {
			    return current;
		    }
        }
	}
    return NULL;
}
void free_symbol() {
	symBol *current;
    symBol *nextcurrent;
    symBol *last;
    int fir = 0;
	for(int i = 0;i<300;i++) {
        last = table[i].head;
        for(current = table[i].head ; current!=NULL ; current=current->next) {
            if(current->block == currentBlock) {
                if(current == table[i].head) {
                    table[i].head = NULL;
                } else {
                    last->next = NULL;
                    for(nextcurrent = current; nextcurrent != NULL ;) {
                        nextcurrent = current->next;
                        free(current);
                        current = nextcurrent;
                    }
                }
                break;
            }
            last = current;
        }
	}
	return;
}