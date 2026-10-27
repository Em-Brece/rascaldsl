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

data Exp = exp(str name);

data Loop = loop(str name);

data Inicializar = inicializar(Obj objet, list[Atribute] atributos, list[Params] posparams, list[Tipo] tipado) | varDecl(Vars variableini) | memberDef(str name, Fobject funcion);

data Program = program(list[Sentencia] sentencias);

data Sentencia = sentInic(Inicializar inicia) | sentFnew(Fnew funcion)| sentAsig(Asig asigna) | sentLoop(Loop loops) | sentExp(Exp expresion);

data ObjModule = objModule(list[Declaracion] declaraciones);

data Declaracion = declInic(Inicializar inicia) | declFnew(Fnew funcion);



