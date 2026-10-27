module Syntax

layout Layout = WhitespaceAndComment* !>> [\ \t\n\r] !>> "//";
lexical WhitespaceAndComment = [\ \t\n\r] | @category="Comment" "//" ![\n]* $;

start syntax ObjModule = objModule: (Inicializar|Fnew)+;

lexical Letter = [a-zA-Z];

lexical Digit = [0-9];

lexical Num = Digit+ !>> [0-9];

lexical Bool = ("true"|"false") !>> [a-zA-Z0-9_];

lexical Punt = "(" | ")" | "[" | "]" | ":" | "." | ",";

lexical Nop = "+" | "-";

lexical Aop = "*" | "/" | "%" | "**";

lexical Ops = Aop | Nop;

lexical And = "and" !>> [a-zA-Z0-9_];

lexical Or = "or" !>> [a-zA-Z0-9_];

lexical In = "in" !>> [a-zA-Z0-9_];

lexical Eqs = "\<=" | "\>=" | "\<\>" | "==" | "\<" | "\>"| And | Or | In;

lexical Char = Letter | Digit | Punt | Ops | " ";

lexical Ident = (Letter(Letter|Digit|"_")* !>> [a-zA-Z0-9_]) \ Reserved;

keyword Reserved = "object" | "extends" | "method" | "val" | "var" | "new" | "override"
                 | "if" | "then" | "else" | "for" | "to" | "print" | "println"
                 | "true" | "false" | "and" | "or" | "neg" | "in";


syntax Inicializar = objDecl: Obj Atribute? ("(" Params ")")? ("extends" Tipo)? | varDecl: Vars | memberDef: Ident Fobject;

syntax Obj = obj: "object" Ident;

syntax Atribute = atribute: "[" {Vari ","}+"]"; 

syntax Vari = vari: Nop? Tipo;

syntax Tipo = tipo: Ident Atribute?;

syntax Params = params: {Param ","}+;

syntax Param = param: ("val"| "var")? Ident ":" Tipo;

syntax Vars = vars: ("val"| "var") Ident (":" Tipo)? "=" Exp;

syntax Inst = inst: "new" Tipo ("(" Exp ("," Exp)* ")")? ("{" Ovri+ "}")?;

syntax Ovri = ovri: "override" Ident ("(" Params? ")" ":" Tipo)? "=" "{" Program "}";

syntax Inv = inv: Ident ("." Ident)* ("(" (Exp ("," Exp)*)? ")")?;

syntax Tuple = tupla: "(" Ident ("," Ident)* ")";

syntax Fobject = fobject: "." Ident "=" "method" "(" Params? ")" ":" Tipo ("{" Program "}")?;

syntax Program = program: (Inicializar|Fnew|Asig|Loop|Exp)+;

syntax Asig = asig: Ident "=" Exp;

syntax Fnew = fnew: "method" Ident ("(" Params? ")"":"Tipo)?"{" Program "}";

syntax Exp = exp: (Inst | Num | Bool | Inv | Cond | String | Tuple | Impri | "(" Exp ")")
            ((Eqs | Ops) (Inst | Num | Bool | Inv | Cond | String | Tuple | Impri | "(" Exp ")"))*;

syntax Cmp = cmp: (Inv | Num | String | Bool) (Eqs (Inv | Num | String | Bool))+;

lexical StringChars = Char+;

syntax String = string: "\"" (StringChars | Pstr)* "\"";

//syntax Pstr = pstr: "$" (Ident | "{"  Exp "}");
syntax Pstr = pstr: $"{" Exp "}";

syntax Rango = rango: (Num | Inv) "to" (Num | Inv);

syntax Loop = loop: "for" Ident name;