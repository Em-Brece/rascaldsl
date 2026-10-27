module Syntax

layout Layout = WhitespaceAndComment* !>> [\ \t\n\r] !>> "//";
lexical WhitespaceAndComment = [\ \t\n\r] | @category="Comment" "//" ![\n]* $;

start syntax ObjModule = objModule: Declaracion+;

syntax Declaracion = declInic: Inicializar| declFnew: Fnew;

syntax Sentencia = sentInic: Inicializar | sentFnew: Fnew| sentAsig: Asig| sentLoop: Loop| sentExp: Exp;

lexical Letter = [a-zA-Z];

lexical Digit = [0-9];

lexical Num = Digit+ !>> [0-9];

lexical Bool = ("true"|"false") !>> [a-zA-Z0-9_];

lexical Ident = ( Letter ( Letter | Digit |"_")* !>> [a-zA-Z0-9_]) \ Reserved;

keyword Reserved = "object" | "extends" | "method" | "val" | "var" | "new" | "override"
                 | "if" | "then" | "else" | "for" | "to" | "print" | "println"
                 | "true" | "false" | "and" | "or" | "neg" | "in";


syntax Inicializar = inicializar: Obj Atribute? ("(" Params ")")? ("extends" Tipo)? | varDecl: Vars | memberDef: Ident Fobject;

syntax Obj = obj: "object" Ident;

syntax Atribute = atribute: "[" {Vari ","}+"]"; 

syntax Vari = vari: Nop? Tipo;

syntax Tipo = tipo: Ident Atribute?;

syntax Params = params: {Param ","}+;

syntax Param = param: Modificador? Ident ":" Tipo;

lexical Modificador = ("val" | "var") !>> [a-zA-Z0-9_];

syntax Vars = vars: Modificador Ident (":" Tipo)? "=" Exp;

syntax Fobject = fobject: "." Ident "=" "method" "(" Params? ")" ":" Tipo ("{" Program "}")?;

syntax Program = program: Sentencia+;

syntax Asig = asig: Ident "=" Exp;

syntax Fnew = fnew: "method" Ident Firma? "{" Program "}";

syntax Firma = firma: "(" Params? ")" ":" Tipo;

lexical Nop = "+"|"-";
syntax Exp = exp: Ident;
syntax Loop = loop: "for" Ident;