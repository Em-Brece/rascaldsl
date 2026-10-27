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

lexical Eqs = "\<=" | "\>=" | "\<\>" | "==" | "\<" | "\>"| And | Or | In;

lexical Char = Letter | Digit | Punt | Ops | " ";

lexical StringChars = ![$"\"\"\\n\r]+;

lexical Ident = (Letter(Letter|Digit|"_")* !>> [a-zA-Z0-9_]) \ Reserved;

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

syntax Inst = inst: "new" Tipo ("(" {Exp ","}+ ")")? ("{" Ovri+ "}")?;

syntax Ovri = ovri: "override" Ident Firma? "=" "{" Program "}";

syntax Inv = inv: Ident ("." Ident)* ("(" {Exp ","}* ")")?;

syntax Tuple = tupla: "(" Ident ("," Ident)* ")";

syntax Fobject = fobject: "." Ident "=" "method" "(" Params? ")" ":" Tipo ("{" Program "}")?;

syntax Program = program: Sentencia+;

syntax Asig = asig: Ident "=" Exp;

syntax Fnew = fnew: "method" Ident Firma? "{" Program "}";

syntax Firma = firma: "(" Params? ")" ":" Tipo;

//syntax Exp = exp: (Inst | Num | Bool | Inv | Cond | String | Tuple | Impri | "(" Exp ")")
//            ((Eqs | Ops) (Inst | Num | Bool | Inv | Cond | String | Tuple | Impri | "(" Exp ")"))*;

syntax Cmp = cmp: CmpAtom CmpTail+;

syntax CmpAtom = cmpInv: Inv | cmpNum: Num | cmpString: String | cmpBool: Bool;

syntax CmpTail = cmpTail: Eqs CmpAtom;

//lexical StringChars = Char+;

//syntax Pstr = pstr: "$" (Ident | "{" Exp "}" );

syntax Rango = rango: RangeBound "to" RangeBound;

syntax RangeBound = rangeNum: Num | rangeInv: Inv;

syntax Loop = loopIn: "for" "(" LoopVariable "\<-" LoopSource ")" Cuerpo 
            | loopArrow: "for" "(" Inv "-\>" Tuple ")" Cuerpo;

syntax LoopVariable = loopTuple: Tuple | loopIdent: Ident;

syntax LoopSource = loopInvocation: Inv | loopRange: Rango;

syntax Exp = exp: ExpAtom ExpTail*;

syntax ExpTail = eqsTail: Eqs ExpAtom | opsTail: Ops ExpAtom;

syntax ExpAtom = instanceExp: Inst | numberExp: Num | booleanExp: Bool | invocationExp: Inv 
               | conditionalExp: Cond | stringExp: String | tupleExp: Tuple | printExp: Impri 
               | parenthesizedExp: "(" Exp ")";

syntax String = string: "\"" StringPart* "\"";

syntax StringPart = stringText: StringChars | stringInterpolation: Pstr;

syntax Pstr = interpolatedIdent: "$" Ident | interpolatedExp: "$" "{" Exp "}";

syntax Cond = cond: "if" CondTest "then" Cuerpo "else" Cuerpo;

syntax CondTest = condNegated: "neg" Condition | condPlain: Condition;

syntax Condition = conditionCmp: Cmp | conditionInv: Inv | conditionBool: Bool;

syntax Cuerpo = cuerpoBloque: "{" Program "}" | cuerpoExp: Exp;

syntax Impri = impri: PrintKind "(" Exp ")";

syntax PrintKind = printKind: "print" | printlnKind: "println";

lexical Nop = "+"|"-";
