module Generator

import AST;
import Implode;
import List;
import IO;

// Carga el archivo .ol, lo pasa en AST y muestra en consola el codigo generado
void generar(loc archivo) {
    ObjModule ast = cargar(archivo);
    println(generate(ast));
}

// Genera todo el modulo
str generate(objModule(list[Declaracion] decls)) =
    intercalate("\n", [ generate(d) | Declaracion d <- decls ]);

// Genera init o fnew
str generate(declInic(Inicializar ini)) = generate(ini);
str generate(declFnew(Fnew f)) = generate(f);

// Genera una definicion de objeto
str generate(inicializar(Obj ob, list[Atribute] atrs, list[Params] ps, list[Tipo] ext)) =
    generate(ob) + concatLista([ generate(a) | Atribute a <- atrs ])
  + concatLista([ "(" + generate(p) + ")" | Params p <- ps ])
  + concatLista([ " extends " + generate(t) | Tipo t <- ext ]);

// Genera la declaracion de variable
str generate(varDecl(Vars v)) = generate(v);

// Genera la definicion de un miembro de clase
str generate(memberDef(str name, Fobject fo)) = name + generate(fo);

// Genera un object
str generate(obj(str name)) = "object " + name;

// Genera un tipo con atributos genericos si tiene
str generate(tipo(str name, list[Atribute] atrs)) =
    name + concatLista([ generate(a) | Atribute a <- atrs ]);

// Genera atributos
str generate(atribute(list[Vari] vs)) =
    "[" + intercalate(", ", [ generate(v) | Vari v <- vs ]) + "]";

// Genera la variante de valor
str generate(vari(list[str] varianza, Tipo t)) =
    concatLista(varianza) + generate(t);

// Genera una lista de parametros
str generate(params(list[Param] ps)) =
    intercalate(", ", [ generate(p) | Param p <- ps ]);

// Genera un parametro
str generate(param(list[str] modif, str name, Tipo t)) =
    concatLista([ m + " " | str m <- modif ]) + name + ": " + generate(t);

// Genera una declaracion de variable
str generate(vars(str modif, str name, list[Tipo] tipado, Exp e)) =
    modif + " " + name
  + concatLista([ ": " + generate(t) | Tipo t <- tipado ])
  + " = " + generate(e);

// Genera un metodo
str generate(fnew(str name, list[Firma] firma, Program cuerpo)) =
    "method " + name
  + concatLista([ generate(f) | Firma f <- firma ])
  + " {\n" + generate(cuerpo) + "\n}";

// Genera una firma de metodo
str generate(firma(list[Params] ps, Tipo t)) =
    "(" + concatLista([ generate(p) | Params p <- ps ]) + "): " + generate(t);

// Genera la definicion de un miembro
str generate(fobject(str name, list[Params] ps, Tipo t, list[Program] cuerpo)) =
    "." + name + " = method("
  + concatLista([ generate(p) | Params p <- ps ])
  + "): " + generate(t)
  + concatLista([ " {\n" + generate(pr) + "\n}" | Program pr <- cuerpo ]);

// Genera un programa
str generate(program(list[Sentencia] sents)) =
    intercalate("\n", [ generate(s) | Sentencia s <- sents ]);

// Genera cada forma de sentencia
str generate(sentInic(Inicializar i)) = generate(i);
str generate(sentFnew(Fnew f)) = generate(f);
str generate(sentAsig(Asig a)) = generate(a);
str generate(sentLoop(Loop l)) = generate(l);
str generate(sentExp(Exp e)) = generate(e);

// Genera una asignacion
str generate(asig(str name, Exp e)) = name + " = " + generate(e);

// Genera una instanciacion con argumentos
str generate(instArgs(Tipo t, Args a, list[Ovri] ovs)) =
    "new " + generate(t) + generate(a) + concatOverrides(ovs);

// Genera una instanciacion sin argumentos
str generate(instBare(Tipo t, list[Ovri] ovs)) =
    "new " + generate(t) + concatOverrides(ovs);

// Genera un override
str generate(ovri(str name, list[Firma] firma, Program cuerpo)) =
    "override " + name + concatLista([ generate(f) | Firma f <- firma ])
  + " = {\n" + generate(cuerpo) + "\n}";

// Genera una invocacion con argumentos
str generate(invCall(str name, list[str] campos, Args a)) =
    name + concatLista(campos) + generate(a);

// Genera una referencia a campos
str generate(invRef(str name, list[str] campos)) =
    name + concatLista(campos);

// Genera la lista de argumentos
str generate(noArgs()) = "()";
str generate(someArgs(list[Exp] args)) =
    "(" + intercalate(", ", [ generate(e) | Exp e <- args ]) + ")";

// Genera una tupla
str generate(tupla(str primero, list[str] resto)) =
    "(" + primero + concatLista(resto) + ")";

// Genera un rango
str generate(rango(ExpAtom ini, ExpAtom fin)) =
    generate(ini) + " to " + generate(fin);

// Genera un for
str generate(loopIn(LoopVariable v, LoopSource fuente, Cuerpo cuerpo)) =
    "for (" + generate(v) + " \<- " + generate(fuente) + ") " + generate(cuerpo);

// Genera un for con flecha
str generate(loopArrow(Inv i, Tuple t, Cuerpo cuerpo)) =
    "for (" + generate(i) + " -\> " + generate(t) + ") " + generate(cuerpo);

// Genera la variable del bucle
str generate(loopTuple(Tuple t)) = generate(t);
str generate(loopIdent(str id)) = id;

// Genera la fuente del bucle
str generate(loopInvocation(Inv i)) = generate(i);
str generate(loopRange(Rango r)) = generate(r);

// Genera exp
str generate(exp(ExpAtom primero, list[ExpTail] colas)) =
    generate(primero) + concatLista([ generate(c) | ExpTail c <- colas ]);

// Genera la cola de exp
str generate(expTail(Op op, ExpAtom operando)) =
    " " + generate(op) + " " + generate(operando);

// Genera el operador
str generate(opEqs(str txt)) = txt;
str generate(opArith(str txt)) = txt;

// Genera cada atom de exp
str generate(instanceExp(Inst i)) = generate(i);
str generate(numberExp(str n)) = n;
str generate(booleanExp(str b)) = b;
str generate(invocationExp(Inv i)) = generate(i);
str generate(conditionalExp(Cond c)) = generate(c);
str generate(stringExp(String s)) = generate(s);
str generate(tupleExp(Tuple t))= generate(t);
str generate(printExp(Impri p)) = generate(p);
str generate(negatedExp(ExpAtom a)) = "neg " + generate(a);
str generate(parenthesizedExp(Exp e)) = "(" + generate(e) + ")";

// Genera una cadena
str generate(string(list[StringPart] partes)) =
    "\"" + concatLista([ generate(p) | StringPart p <- partes ]) + "\"";

// Genera una parte de cadena
str generate(stringText(str t)) = t;
str generate(stringInterpolation(Pstr p)) = generate(p);

// Genera una interpolacion
str generate(interpolatedIdent(str nombre)) = "$" + nombre;
str generate(interpolatedExp(Exp e)) = "${" + generate(e) + "}";

// Genera condicional
str generate(cond(Exp c, Cuerpo ent, Cuerpo sino)) =
    "if " + generate(c) + " then " + generate(ent) + " else " + generate(sino);

// Genera el cuerpo
str generate(cuerpoBloque(Program p)) = "{\n" + generate(p) + "\n}";
str generate(cuerpoExp(Exp e)) = generate(e);

// Genera una print
str generate(impri(PrintKind k, Exp e)) = generate(k) + "(" + generate(e) + ")";
str generate(printKind()) = "print";
str generate(printlnKind()) = "println";

// Une una lista de cadenas sin separador
str concatLista(list[str] partes) = intercalate("", partes);

// Genera el bloque de overrides
str concatOverrides([]) = "";
default str concatOverrides(list[Ovri] ovs) =
    " {\n" + intercalate("\n", [ generate(ov) | Ovri ov <- ovs ]) + "\n}";
