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

// Relational/equality/boolean operators per the language spec:
//   <  >  <=  >=  <>  =  =>  and  or  in
// Note: "==" is NOT part of the language (equality is "="), and "=>" is required.
lexical Eqs = "\<=" | "\>=" | "\<\>" | "=\>" | "\<" | "\>" | "=" | And | Or | In;

lexical Ident = (Letter(Letter|Digit|"_")* !>> [a-zA-Z0-9_]) \ Reserved;

// "to" is NOT a reserved word of the language, so it is deliberately omitted here.
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

// Like Inv, instantiation is split so the no-argument form cannot be directly
// followed by "(". This makes "new L(a)" bind the argument list to the
// instantiation greedily instead of leaving a dangling "(a)". Requiring "new"
// also removes the instance-vs-invocation ambiguity (Tipo and Inv both start
// with an identifier).
syntax Inst = instArgs: "new" Tipo Args ("{" Ovri+ "}")?
            | instBare: "new" Tipo !>> [(] ("{" Ovri+ "}")?;

syntax Ovri = ovri: "override" Ident Firma? "=" "{" Program "}";

// An invocation is either a plain reference/field-access, or that followed by
// an argument list. The no-argument form forbids a directly following "(" so
// that "f(1)" binds the arguments to f greedily, instead of splitting into a
// bare reference "f" and a separate parenthesized-expression statement "(1)".
syntax Inv = invCall: Ident ("." Ident)* Args
           | invRef:  Ident ("." Ident)* !>> [(];

// A single, unambiguous argument-list non-terminal shared by constructor
// instantiation (Inst) and invocation (Inv). Writing "()" and the non-empty
// case separately avoids a nullable separated-list inside an optional group,
// which otherwise made every call ambiguous and broke empty-argument calls.
syntax Args = noArgs: "(" ")" | someArgs: "(" Exp ("," Exp)* ")";

// A tuple always has at least two components. A single parenthesized element
// like "(a)" is a parenthesized expression, not a tuple; requiring the comma
// here removes the Tuple-vs-parenthesizedExp ambiguity.
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

// A single expression grammar is reused everywhere an atomic value or a
// comparison can appear. This removes the former parallel CmpAtom/RangeAtom
// definitions that duplicated Inv/Num/Bool/String atoms.
syntax Exp = exp: ExpAtom ExpTail*;

// Equality/relational and arithmetic tails share the same shape, so they are a
// single alternative instead of the former identical eqsTail/opsTail pair.
syntax ExpTail = expTail: Op ExpAtom;

syntax Op = opEqs: Eqs | opArith: Ops;

// "neg" is a general prefix operator on an atom, so it works anywhere an
// expression is valid (not only at the start of an "if" condition).
syntax ExpAtom = instanceExp: Inst | numberExp: Num | booleanExp: Bool | invocationExp: Inv 
               | conditionalExp: Cond | stringExp: String | tupleExp: Tuple | printExp: Impri 
               | negatedExp: "neg" ExpAtom
               | parenthesizedExp: "(" Exp ")";

syntax String = string: "\"" StringPart* "\"";

syntax StringPart = stringText: StringChars | stringInterpolation: Pstr;

// A maximal run of characters that are neither the closing quote nor the
// start of an interpolation ("$"). The follow restriction (!>>) forces the
// run to be as long as possible, which removes the ambiguity of splitting
// text into several adjacent StringChars tokens, and lets ordinary prose and
// punctuation appear inside string literals / print arguments.
lexical StringChars = ![\"$]+ !>> ![\"$];

// Interpolation accepts "$ident" and "${ exp }" with optional spaces around
// the braces, so "${x}" and "$ { x }" both parse.
syntax Pstr = interpolatedIdent: "$" Ident | interpolatedExp: "$" "{" Exp "}";

// "else" is mandatory: making it optional would introduce the classic
// dangling-else ambiguity.
syntax Cond = cond: "if" Exp "then" Cuerpo "else" Cuerpo;

syntax Cuerpo = cuerpoBloque: "{" Program "}" | cuerpoExp: Exp;

syntax Impri = impri: PrintKind "(" Exp ")";

syntax PrintKind = printKind: "print" | printlnKind: "println";

lexical Nop = "+"|"-";
