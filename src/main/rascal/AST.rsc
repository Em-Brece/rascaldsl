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

data Inst = inst(Tipo tipo, list[Exp] argumentos, list[Ovri] overrides);

data Ovri = ovri(str name, list[Firma] firma, Program cuerpo);

data Inv = inv(str name, list[str] fields, list[Exp] argumentos);

data Tuple = tupla(str primero, list[str] restantes);

data Cmp = cmp(CmpAtom primero, list[CmpTail] restantes);

data CmpAtom = cmpInv(Inv valor) | cmpNum(str valor) | cmpString(String valor) | cmpBool(str valor);

data CmpTail = cmpTail(str operador, CmpAtom operando);

data RangeBound = rangeNum(str valor) | rangeInv(Inv valor);

data Rango = rango(RangeBound inicio, RangeBound fin);

data LoopVariable = loopTuple(Tuple tupla) | loopIdent(str ident);

data LoopSource = loopInvocation(Inv inv) | loopRange(Rango rango);

data Loop = loopIn(LoopVariable variable, LoopSource fuente, Cuerpo cuerpo) 
          | loopArrow(Inv inv, Tuple tupla, Cuerpo cuerpo);

data Exp = exp(ExpAtom primero, list[ExpTail] restantes);

data ExpTail = eqsTail(str operador, ExpAtom operando) | opsTail(str operador, ExpAtom operando);

data ExpAtom = instanceExp(Inst valor) | numberExp(str valor) | booleanExp(str valor) 
             | invocationExp(Inv valor) | conditionalExp(Cond valor) | stringExp(String valor)
             | tupleExp(Tuple valor) | printExp(Impri valor) | parenthesizedExp(Exp valor);

data String = string(list[StringPart] partes);

data StringPart = stringText(str texto) | stringInterpolation(Pstr interpolacion);

data Pstr = interpolatedIdent(str nombre) | interpolatedExp(Exp expresion);

data Cond = cond(CondTest condtest, Cuerpo entonces, Cuerpo sino);

data CondTest = condNegated(Condition condicion)
              | condPlain(Condition condicion);

data Condition = conditionCmp(Cmp comparacion) | conditionInv(Inv invocacion) | conditionBool(str valor);

data Cuerpo = cuerpoBloque(Program programa) | cuerpoExp(Exp expresion);

data Impri = impri(PrintKind kind, Exp expresion);

data PrintKind = printKind() | printlnKind();

data Inicializar = inicializar(Obj objet, list[Atribute] atributos, list[Params] posparams, list[Tipo] tipado) 
                 | varDecl(Vars variableini) | memberDef(str name, Fobject funcion);

data Program = program(list[Sentencia] sentencias);

data Sentencia = sentInic(Inicializar inicia) | sentFnew(Fnew funcion)| sentAsig(Asig asigna) 
               | sentLoop(Loop loops) | sentExp(Exp expresion);

data ObjModule = objModule(list[Declaracion] declaraciones);

data Declaracion = declInic(Inicializar inicia) | declFnew(Fnew funcion);

