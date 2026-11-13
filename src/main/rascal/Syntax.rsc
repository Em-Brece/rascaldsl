module Syntax

layout Layout = WhitespaceAndComment* !>> [\ \t\n\r] !>> "//";
lexical WhitespaceAndComment = [\ \t\n\r] | @category="Comment" "//" ![\n]* $;

start syntax ObjModule = objModule: Declaracion+;

syntax Declaracion = declInic: Inicializar | declFnew: Fnew;

syntax Sentencia = sentInic: Inicializar | sentFnew: Fnew | sentAsig: Asig | sentLoop: Loop | sentExp: Exp;

lexical Letter = [a-zA-Z];
lexical Digit = [0-9];
lexical Num = Digit+ !>> [0-9];
lexical Bool = ("true" | "false") !>> [a-zA-Z0-9_];
lexical Nop = "+" | "-";
lexical Modificador = ("val" | "var") !>> [a-zA-Z0-9_];

lexical Char = "\'" [a-zA-Z0-9\ ()\[\]:.,*/%+\-] "\'";

lexical Ident = (Letter (Letter | Digit | "_")* !>> [a-zA-Z0-9_]) \ Reserved;

keyword Reserved = "object" | "extends" | "method" | "val" | "var" | "new" | "override"
                 | "if" | "then" | "else" | "for" | "print" | "println"
                 | "true" | "false" | "and" | "or" | "neg" | "in";

syntax Inicializar
  = inicializar: Obj Atribute? CtorParams? Extiende?
  | varDecl: Vars
  | memberDef: Ident Fobject;

syntax CtorParams = ctorParams: "(" Params ")";
syntax Extiende   = extiende: "extends" !>> [a-zA-Z0-9_] Tipo;

syntax Obj = obj: "object" !>> [a-zA-Z0-9_] Ident;

syntax Atribute = atribute: "[" {Vari ","}+ "]";
syntax Vari = vari: Nop? Tipo;
syntax Tipo = tipo: Ident Atribute?;

syntax Params = params: {Param ","}+;
syntax Param = param: Modificador? Ident ":" Tipo;

syntax Vars = vars: Modificador Ident (":" Tipo)? "=" Exp;

syntax Inst = instArgs: "new" !>> [a-zA-Z0-9_] Tipo Args ("{" Ovri+ "}")?
            | instBare: "new" !>> [a-zA-Z0-9_] Tipo !>> [(] ("{" Ovri+ "}")?;

syntax Ovri = ovri: "override" !>> [a-zA-Z0-9_] Ident Firma? "=" "{" Program "}";

syntax Inv = invCall: Ident ("." Ident)* Args
           | invRef:  Ident ("." Ident)* !>> [(];

syntax Args = noArgs: "(" ")" | someArgs: "(" {Exp ","}+ ")";

syntax Tuple = tupla: "(" Ident ("," Ident)+ ")";

syntax Fobject = fobject: "." Ident "=" "method" !>> [a-zA-Z0-9_] "(" Params? ")" ":" Tipo ("{" Program "}")?;

syntax Program = program: Sentencia+;
syntax Asig = asig: Ident "=" !>> [\>] Exp;

syntax Fnew = fnew: "method" !>> [a-zA-Z0-9_] Ident Firma? "{" Program "}";
syntax Firma = firma: "(" Params? ")" ":" Tipo;

syntax Rango = rango: ExpAtom "to" !>> [a-zA-Z0-9_] ExpAtom;

syntax Loop = loopIn: "for" !>> [a-zA-Z0-9_] "(" LoopVariable "\<-" LoopSource ")" Cuerpo
            | loopArrow: "for" !>> [a-zA-Z0-9_] "(" Inv "-\>" Tuple ")" Cuerpo;

syntax LoopVariable = loopTuple: Tuple | loopIdent: Ident;
syntax LoopSource = loopInvocation: Inv | loopRange: Rango;

// ---------------- Expresiones (con precedencia) ----------------
// "=" es la igualdad (el enunciado no trae "=="); "x = 3" como sentencia es ambiguo
// con la asignacion y se resuelve a favor de la asignacion en Desambiguar.rsc.
syntax Exp
  = expAtom: ExpAtom
  > right expPow: Exp l "**" Exp r
  > left ( expMul: Exp l "*" !>> [*] Exp r
         | expDiv: Exp l "/" Exp r
         | expMod: Exp l "%" Exp r )
  > left ( expAdd: Exp l "+" Exp r
         | expSub: Exp l "-" !>> [\>] Exp r )
  > non-assoc ( expLt: Exp l "\<" !>> [=\>\-] Exp r
              | expGt: Exp l "\>" !>> [=] Exp r
              | expLe: Exp l "\<=" Exp r
              | expGe: Exp l "\>=" Exp r
              | expNe: Exp l "\<\>" Exp r
              | expEq: Exp l "=" !>> [\>] Exp r
              | expIn: Exp l "in" !>> [a-zA-Z0-9_] Exp r
              | expInRango: Exp l "in" !>> [a-zA-Z0-9_] Rango r )
  > expNeg: "neg" !>> [a-zA-Z0-9_] Exp e
  > left expAnd: Exp l "and" !>> [a-zA-Z0-9_] Exp r
  > left expOr:  Exp l "or" !>> [a-zA-Z0-9_] Exp r
  > right expImp: Exp l "=\>" Exp r 
  ;

syntax ExpAtom = instanceExp: Inst | numberExp: Num | booleanExp: Bool | invocationExp: Inv | charExp: Char
               | conditionalExp: Cond | stringExp: String | tupleExp: Tuple | printExp: Impri
               | parenthesizedExp: "(" Exp ")";

// ---------------- Cadenas ----------------
// Solo caracteres del lenguaje: letras, digitos, punt ( ) [ ] : . , operadores * / % + - y espacio.
// "$" solo aparece como interpolacion: "$ident" o "${exp}" (el "${" va pegado).
syntax String = string: "\"" StringPart+ "\""
              | emptyString: EmptyStr;

lexical EmptyStr = "\"\"";

syntax StringPart = stringText: StringChars | stringInterpolation: Pstr;

lexical StringChars = [\ ] !<< [a-zA-Z0-9\ ()\[\]:.,*/%+\-]+ !>> [a-zA-Z0-9\ ()\[\]:.,*/%+\-];

syntax Pstr = interpolatedIdent: "$" !>> [\ \t\n\r] Ident
            | interpolatedExp: "${" Exp "}";

// ---------------- Control ----------------
syntax Cond = cond: "if" !>> [a-zA-Z0-9_] Exp "then" !>> [a-zA-Z0-9_] Cuerpo "else" !>> [a-zA-Z0-9_] Cuerpo;

syntax Cuerpo = cuerpoBloque: "{" Program "}" | cuerpoExp: Exp;

syntax Impri = impri: PrintKind "(" Exp ")";

syntax PrintKind = printKind: "print" !>> [a-zA-Z0-9_]
                 | printlnKind: "println" !>> [a-zA-Z0-9_];
