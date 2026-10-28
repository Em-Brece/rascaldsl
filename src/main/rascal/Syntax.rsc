module Syntax

layout Layout = WhitespaceAndComment* !>> [\ \t\n\r] !>> "//";
lexical WhitespaceAndComment = [\ \t\n\r] | @category="Comment" "//" ![\n]* $;

start syntax ObjModule = objModule: Declaracion+;

syntax Declaracion = declInic: Inicializar | declFnew: Fnew;

syntax Sentencia = sentInic: Inicializar | sentFnew: Fnew | sentAsig: Asig | sentLoop: Loop | sentExp: ExpSent;

syntax ExpSent = expSent: ExpHead ExpTail*;

syntax ExpHead = headInst: Inst | headNum: Num | headBool: Bool | headInv: Inv | headCond: Cond | headString: String | headPrint: Impri;

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

lexical Eqs = "\<=" | "\>=" | "\<\>" | "==" | "\<" | "\>" | And | Or | In;

lexical Char = Letter | Digit | Punt | Ops | " ";

lexical Nop = "+" | "-";

lexical Neg = "neg" !>> [a-zA-Z0-9_];

lexical PrintKw = ("print" | "println") !>> [a-zA-Z0-9_];

lexical Modificador = ("val" | "var") !>> [a-zA-Z0-9_];

lexical Ident = (Letter (Letter|Digit|"_")* !>> [a-zA-Z0-9_]) \ Reserved;

keyword Reserved = "object" | "extends" | "method" | "val" | "var" | "new" | "override"
                 | "if" | "then" | "else" | "for" | "to" | "print" | "println"
                 | "true" | "false" | "and" | "or" | "neg" | "in";

syntax Ctor   = ctor: "(" Params ")";

syntax Ext    = ext: "extends" Tipo;

syntax Tipado = tipado: ":" Tipo;

syntax Bloque = bloque: "{" Program "}";

syntax Args   = args: "(" {Exp ","}* ")";

syntax Ovrs   = ovrs: "{" Ovri+ "}";

syntax Campo  = campo: "." Ident;

syntax Inicializar = inicializar: Obj Atribute? Ctor? Ext?
                   | varDecl: Vars
                   | memberDef: Ident Fobject;

syntax Obj = obj: "object" Ident;

syntax Atribute = atribute: "[" {Vari ","}+ "]";

syntax Vari = vari: Nop? Tipo;

syntax Tipo = tipo: Ident Atribute?;

syntax Params = params: {Param ","}+;

syntax Param = param: Modificador? Ident ":" Tipo;

syntax Vars = vars: Modificador Ident Tipado? "=" Exp;

syntax Inst = inst: "new" Tipo Args? Ovrs?;

syntax Ovri = ovri: "override" Ident Firma? "=" Bloque;

syntax Inv = inv: Ident Campo* Args?;

syntax Tuple = tupla: "(" Ident "," {Ident ","}+ ")";

syntax Fobject = fobject: "." Ident "=" "method" "(" Params? ")" ":" Tipo Bloque?;

syntax Program = program: Sentencia+;

syntax Asig = asig: Ident "=" Exp;

syntax Fnew = fnew: "method" Ident Firma? "{" Program "}";

syntax Firma = firma: "(" Params? ")" ":" Tipo;

syntax Cmp = cmp: CmpAtom CmpTail+;

syntax CmpAtom = cmpInv: Inv | cmpNum: Num | cmpString: String | cmpBool: Bool;

syntax CmpTail = cmpTail: Eqs CmpAtom;

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

lexical StrPiece = Char | "$" Ident;

lexical StringPlain = "\"" StrPiece* "\"";

lexical StringStart = "\"" StrPiece* "${";

lexical StringMid   = "}" StrPiece* "${";

lexical StringEnd   = "}" StrPiece* "\"";

syntax String = stringPlain: StringPlain | stringTemplate: StringStart Exp StringTail;

syntax StringTail = tailMid: StringMid Exp StringTail | tailEnd: StringEnd;

syntax Cond = cond: "if" Neg? Condition "then" Cuerpo "else" Cuerpo;

syntax Condition = conditionCmp: Cmp | conditionInv: Inv | conditionBool: Bool;

syntax Cuerpo = cuerpoBloque: "{" Program "}" | cuerpoExp: Exp;

syntax Impri = impri: PrintKw "(" Exp ")";
