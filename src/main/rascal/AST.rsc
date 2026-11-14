module AST

data Obj = obj(str name);

data Tipo = tipo(str name, list[Atribute] atributos);

data Atribute = atribute(list[Vari] variantes);

data Vari = vari(list[str] varianza, Tipo tipo);

data Params = params(list[Param] parametros);

data Param = param(list[str] modificador, str name, Tipo tipo);

data Vars = vars(str modificador, str name, list[Tipo] tipado, Exp expresion);

data Fobject = fobject(str name, list[Params] parametros, Tipo tipo, list[Program] instruc);

data Asig = asig(str name, Exp expresion);

data Fnew = fnew(str name, list[Firma] firma, Program instruc);

data Firma = firma(list[Params] parametros, Tipo tipo);

data Inst = instArgs(Tipo tipo, Args argumentos, list[Ovri] overrides)
         | instBare(Tipo tipo, list[Ovri] overrides);

data Ovri = ovri(str name, list[Firma] firma, Program cuerpo);

data Inv = invCall(str name, list[str] fields, Args argumentos)
         | invRef(str name, list[str] fields);

data Args = noArgs() | someArgs(list[Exp] argumentos);

data Tuple = tupla(str primero, list[str] restantes);

data Rango = rango(ExpAtom inicio, ExpAtom fin);

data LoopVariable = loopTuple(Tuple tupla) | loopIdent(str ident);

data LoopSource = loopInvocation(Inv inv) | loopRange(Rango rango);

data Loop = loopIn(LoopVariable variable, LoopSource fuente, Cuerpo cuerpo)
          | loopArrow(Inv inv, Tuple tupla, Cuerpo cuerpo);

// Expresiones con precedencia (ya no hay ExpTail / Op)
data Exp = expAtom(ExpAtom atomo)
         | expPow(Exp l, Exp r)
         | expMul(Exp l, Exp r) | expDiv(Exp l, Exp r) | expMod(Exp l, Exp r)
         | expAdd(Exp l, Exp r) | expSub(Exp l, Exp r)
         | expLt(Exp l, Exp r) | expGt(Exp l, Exp r) | expLe(Exp l, Exp r) | expGe(Exp l, Exp r)
         | expNe(Exp l, Exp r) | expEq(Exp l, Exp r)
         | expIn(Exp l, Exp r) | expInRango(Exp l, Rango rango)
         | expNeg(Exp e)
         | expAnd(Exp l, Exp r) | expOr(Exp l, Exp r) | expImp(Exp l, Exp r);

data ExpAtom = instanceExp(Inst instancia) | numberExp(str numero) | booleanExp(str booleano)
             | invocationExp(Inv invocacion) | conditionalExp(Cond condicional) | stringExp(String cadena)
             | tupleExp(Tuple tupla) | printExp(Impri impresion) | charExp(str caracter)
             | parenthesizedExp(Exp agrupada);

data String = string(list[StringPart] partes) | emptyString(str vacio);

data StringPart = stringText(str texto) | stringInterpolation(Pstr interpolacion);

data Pstr = interpolatedIdent(str nombre) | interpolatedExp(Exp expresion);

data Cond = cond(Exp condicion, Cuerpo entonces, Cuerpo sino);

data Cuerpo = cuerpoBloque(Program programa) | cuerpoExp(Exp expresion);

data Impri = impri(PrintKind kind, Exp expresion);

data PrintKind = printKind() | printlnKind();

data CtorParams = ctorParams(Params params);
data Extiende = extiende(Tipo tipo);

data Inicializar = inicializar(Obj objet, list[Atribute] atributos, list[CtorParams] posparams, list[Extiende] padre)
                 | varDecl(Vars variableini) | memberDef(str name, Fobject funcion);

data Program = program(list[Sentencia] sentencias);

data Sentencia = sentInic(Inicializar inicia) | sentFnew(Fnew funcion) | sentAsig(Asig asigna)
               | sentLoop(Loop loops) | sentExp(Exp expresion);

data ObjModule = objModule(list[Declaracion] declaraciones);

data Declaracion = declInic(Inicializar inicia) | declFnew(Fnew funcion);
