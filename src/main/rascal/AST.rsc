module AST

data ObjModule = objModule(list[Declaracion] declaraciones);

data Declaracion = declInic(Inicializar inicia) | declFnew(Fnew funcion);

data Sentencia = sentInic(Inicializar inicia) | sentFnew(Fnew funcion) | sentAsig(Asig asigna) | sentLoop(Loop loops) | sentExp(ExpSent expresion);

data ExpSent = expSent(ExpHead primero, list[ExpTail] restantes);

data ExpHead = headInst(Inst instancia) | headNum(str numero) | headBool(str booleano) | headInv(Inv invocacion) | headCond(Cond condicional) | headString(String cadena) | headPrint(Impri impresion);

data Program = program(list[Sentencia] sentencias);

data Ctor   = ctor(Params parametros);

data Ext    = ext(Tipo tipo);

data Tipado = tipado(Tipo tipo);

data Bloque = bloque(Program programa);

data Args   = args(list[Exp] valores);

data Ovrs   = ovrs(list[Ovri] overrides);

data Campo  = campo(str name);

data Inicializar = inicializar(Obj objet, list[Atribute] atributos, list[Ctor] posparams, list[Ext] extiende)
                 | varDecl(Vars variableini)
                 | memberDef(str name, Fobject funcion);

data Obj = obj(str name);

data Atribute = atribute(list[Vari] variantes);

data Vari = vari(list[str] varianza, Tipo tipo);

data Tipo = tipo(str name, list[Atribute] atributos);

data Params = params(list[Param] parametros);

data Param = param(list[str] modificador, str name, Tipo tipo);

data Vars = vars(str modificador, str name, list[Tipado] tipado, Exp expresion);

data Inst = inst(Tipo tipo, list[Args] argumentos, list[Ovrs] overrides);

data Ovri = ovri(str name, list[Firma] firma, Bloque cuerpo);

data Inv = inv(str name, list[Campo] fields, list[Args] argumentos);

data Tuple = tupla(str primero, list[str] restantes);

data Fobject = fobject(str name, list[Params] parametros, Tipo tipo, list[Bloque] instruc);

data Asig = asig(str name, Exp expresion);

data Fnew = fnew(str name, list[Firma] firma, Program instruc);

data Firma = firma(list[Params] parametros, Tipo tipo);

data Cmp = cmp(CmpAtom primero, list[CmpTail] restantes);

data CmpAtom = cmpInv(Inv invocacion) | cmpNum(str numero) | cmpString(String cadena) | cmpBool(str booleano);

data CmpTail = cmpTail(str operador, CmpAtom operando);

data Rango = rango(RangeBound inicio, RangeBound fin);

data RangeBound = rangeNum(str numero) | rangeInv(Inv invocacion);

data Loop = loopIn(LoopVariable variable, LoopSource fuente, Cuerpo cuerpo)
          | loopArrow(Inv inv, Tuple tupla, Cuerpo cuerpo);

data LoopVariable = loopTuple(Tuple tupla) | loopIdent(str ident);

data LoopSource = loopInvocation(Inv inv) | loopRange(Rango rango);

data Exp = exp(ExpAtom primero, list[ExpTail] restantes);

data ExpTail = eqsTail(str operador, ExpAtom operando) | opsTail(str operador, ExpAtom operando);

data ExpAtom = instanceExp(Inst instancia) | numberExp(str numero) | booleanExp(str booleano)
             | invocationExp(Inv invocacion) | conditionalExp(Cond condicional) | stringExp(String cadena)
             | tupleExp(Tuple tuplaValor) | printExp(Impri impresion) | parenthesizedExp(Exp agrupada);

data String = stringPlain(str texto) | stringTemplate(str inicio, Exp expresion, StringTail cola);

data StringTail = tailMid(str medio, Exp expresion, StringTail cola) | tailEnd(str fin);

data Cond = cond(list[str] negacion, Condition condicion, Cuerpo entonces, Cuerpo sino);

data Condition = conditionCmp(Cmp comparacion) | conditionInv(Inv invocacion) | conditionBool(str valor);

data Cuerpo = cuerpoBloque(Program programa) | cuerpoExp(Exp expresion);

data Impri = impri(str kind, Exp expresion);