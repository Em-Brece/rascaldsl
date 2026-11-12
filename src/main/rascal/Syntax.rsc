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

lexical Punt = "(" | ")" | "[" | "]" | ":" | "." | ",";

lexical Aop = "*" | "/" | "%" | "**";

lexical Ops = Aop | Nop;

lexical And = "and" !>> [a-zA-Z0-9_];

lexical Or = "or" !>> [a-zA-Z0-9_];

lexical In = "in" !>> [a-zA-Z0-9_];

lexical Eqs = "\<=" | "\>=" | "\<\>" | "=\>" | "\<" | "\>" | "=" | And | Or | In;

lexical Ident = (Letter(Letter|Digit|"_")* !>> [a-zA-Z0-9_]) \ Reserved;

keyword Reserved = "object" | "extends" | "method" | "val" | "var" | "new" | "override"
                 | "if" | "then" | "else" | "for" | "print" | "println"
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

syntax Inst = instArgs: "new" Tipo Args ("{" Ovri+ "}")?
            | instBare: "new" Tipo !>> [(] ("{" Ovri+ "}")?;

syntax Ovri = ovri: "override" Ident Firma? "=" "{" Program "}";

syntax Inv = invCall: Ident ("." Ident)* Args
           | invRef:  Ident ("." Ident)* !>> [(];

syntax Args = noArgs: "(" ")" | someArgs: "(" {Exp ","}+ ")";

syntax Tuple = tupla: "(" Ident ("," Ident)+ ")";

syntax Fobject = fobject: "." Ident "=" "method" "(" Params? ")" ":" Tipo ("{" Program "}")?;

syntax Program = program: Sentencia+;

syntax Asig = asig: Ident "=" Exp;

syntax Fnew = fnew: "method" Ident Firma? "{" Program "}";

syntax Firma = firma: "(" Params? ")" ":" Tipo;

syntax Rango = rango: ExpAtom "to" ExpAtom;

syntax Loop = loopIn: "for" "(" LoopVariable "\<-" LoopSource ")" Cuerpo 
            | loopArrow: "for" "(" Inv "-\>" Tuple ")" Cuerpo;

syntax LoopVariable = loopTuple: Tuple | loopIdent: Ident;

syntax LoopSource = loopInvocation: Inv | loopRange: Rango;

syntax Exp = exp: ExpAtom ExpTail*;

syntax ExpTail = expTail: Op ExpAtom;

syntax Op = opEqs: Eqs | opArith: Ops;

syntax ExpAtom = instanceExp: Inst | numberExp: Num | booleanExp: Bool | invocationExp: Inv 
               | conditionalExp: Cond | stringExp: String | tupleExp: Tuple | printExp: Impri 
               | negatedExp: "neg" ExpAtom
               | parenthesizedExp: "(" Exp ")";

syntax String = string: "\"" StringPart* "\"";

syntax StringPart = stringText: StringChars | stringInterpolation: Pstr;

lexical StringChars = ![\"$]+ !>> ![\"$];

syntax Pstr = interpolatedIdent: "$" Ident | interpolatedExp: "$" "{" Exp "}";

syntax Cond = cond: "if" Exp "then" Cuerpo "else" Cuerpo;

syntax Cuerpo = cuerpoBloque: "{" Program "}" | cuerpoExp: Exp;

syntax Impri = impri: PrintKind "(" Exp ")";

syntax PrintKind = printKind: "print" | printlnKind: "println";

lexical Nop = "+"|"-";
