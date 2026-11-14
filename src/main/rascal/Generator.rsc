module Generator

import AST;
import Implode;
import Checker;
import List;
import String;
import IO;
import Message;

// ============================================================
// Punto de entrada
// ============================================================
// Carga el archivo .ol, construye el AST y muestra en consola el codigo generado.
void generar(loc archivo) {
    ObjModule ast = cargar(archivo);
    println(generate(ast));
}

// Igual que generar, pero primero corre el chequeo de tipos:
// si hay errores los imprime y NO genera codigo.
void generarConChequeo(loc archivo) {
    TModel modelo = modeloDesdeArbol(arbolLimpio(archivo));
    if (modelo.messages != []) {
        for (Message m <- modelo.messages) println(m);
        return;
    }
    println(generate(cargar(archivo)));
}

// ============================================================
// Ayudantes
// ============================================================
// Une una lista de cadenas sin separador
str concatLista(list[str] partes) = intercalate("", partes);

// Sangra cada linea del texto con dos espacios
str sangrar(str texto) = intercalate("\n", [ "  " + l | str l <- split("\n", texto) ]);

// Bloque "{ ... }" con el programa sangrado
str bloque(Program p) = "{\n" + sangrar(generate(p)) + "\n}";

// Une las partes no vacias con un separador
str unir(str sep, list[str] partes) = intercalate(sep, [ p | str p <- partes, p != "" ]);

// ============================================================
// Modulo y declaraciones
// ============================================================
str generate(objModule(list[Declaracion] decls)) =
    intercalate("\n", [ generate(d) | Declaracion d <- decls ]);

str generate(declInic(Inicializar ini)) = generate(ini);
str generate(declFnew(Fnew f)) = generate(f);

// ============================================================
// Objetos, tipos y parametros
// ============================================================
// object Nombre[T](params) extends Padre
str generate(inicializar(Obj ob, list[Atribute] atrs, list[CtorParams] ps, list[Extiende] ext)) =
    generate(ob)
  + concatLista([ generate(a) | Atribute a <- atrs ])
  + concatLista([ generate(p) | CtorParams p <- ps ])
  + concatLista([ generate(e) | Extiende e <- ext ]);

str generate(varDecl(Vars v)) = generate(v);

// Cat.talk = method(...): T { ... }
str generate(memberDef(str name, Fobject fo)) = name + generate(fo);

str generate(obj(str name)) = "object " + name;

str generate(ctorParams(Params p)) = "(" + generate(p) + ")";
str generate(extiende(Tipo t)) = " extends " + generate(t);

// Nombre o Nombre[+A, B]
str generate(tipo(str name, list[Atribute] atrs)) =
    name + concatLista([ generate(a) | Atribute a <- atrs ]);

str generate(atribute(list[Vari] vs)) =
    "[" + intercalate(", ", [ generate(v) | Vari v <- vs ]) + "]";

str generate(vari(list[str] varianza, Tipo t)) =
    concatLista(varianza) + generate(t);

str generate(params(list[Param] ps)) =
    intercalate(", ", [ generate(p) | Param p <- ps ]);

str generate(param(list[str] modif, str name, Tipo t)) =
    concatLista([ m + " " | str m <- modif ]) + name + ": " + generate(t);

// val x: T = e   |   var x = e
str generate(vars(str modif, str name, list[Tipo] tipado, Exp e)) =
    modif + " " + name
  + concatLista([ ": " + generate(t) | Tipo t <- tipado ])
  + " = " + generate(e);

// ============================================================
// Metodos
// ============================================================
str generate(fnew(str name, list[Firma] firma, Program cuerpo)) =
    "method " + name
  + concatLista([ generate(f) | Firma f <- firma ])
  + " " + bloque(cuerpo);

str generate(firma(list[Params] ps, Tipo t)) =
    "(" + concatLista([ generate(p) | Params p <- ps ]) + "): " + generate(t);

// .talk = method(params): T { ... }
str generate(fobject(str name, list[Params] ps, Tipo t, list[Program] cuerpo)) =
    "." + name + " = method("
  + concatLista([ generate(p) | Params p <- ps ])
  + "): " + generate(t)
  + concatLista([ " " + bloque(pr) | Program pr <- cuerpo ]);

// ============================================================
// Programas y sentencias
// ============================================================
str generate(program(list[Sentencia] sents)) =
    intercalate("\n", [ generate(s) | Sentencia s <- sents ]);

str generate(sentInic(Inicializar i)) = generate(i);
str generate(sentFnew(Fnew f)) = generate(f);
str generate(sentAsig(Asig a)) = generate(a);
str generate(sentLoop(Loop l)) = generate(l);
str generate(sentExp(Exp e)) = generate(e);

str generate(asig(str name, Exp e)) = name + " = " + generate(e);

// ============================================================
// Instancias, invocaciones, tuplas y rangos
// ============================================================
str generate(instArgs(Tipo t, Args a, list[Ovri] ovs)) =
    "new " + generate(t) + generate(a) + concatOverrides(ovs);

str generate(instBare(Tipo t, list[Ovri] ovs)) =
    "new " + generate(t) + concatOverrides(ovs);

str generate(ovri(str name, list[Firma] firma, Program cuerpo)) =
    "override " + name + concatLista([ generate(f) | Firma f <- firma ])
  + " = " + bloque(cuerpo);

// a.b.c(args)  (los campos ya traen el "." del lexer)
str generate(invCall(str name, list[str] campos, Args a)) =
    name + concatLista(campos) + generate(a);

// a.b.c  (los campos ya traen el ".")
str generate(invRef(str name, list[str] campos)) =
    name + concatLista(campos);

str generate(noArgs()) = "()";
str generate(someArgs(list[Exp] args)) =
    "(" + intercalate(", ", [ generate(e) | Exp e <- args ]) + ")";

// (a, b, c)  (los elementos de resto ya traen la "," del lexer: se quita para reunir)
str generate(tupla(str primero, list[str] resto)) =
    "(" + intercalate(", ", [primero] + [ r[1..] | str r <- resto ]) + ")";

str generate(rango(ExpAtom ini, ExpAtom fin)) =
    generate(ini) + " to " + generate(fin);

// ============================================================
// Ciclos
// ============================================================
str generate(loopIn(LoopVariable v, LoopSource fuente, Cuerpo cuerpo)) =
    "for (" + generate(v) + " \<- " + generate(fuente) + ") " + generate(cuerpo);

str generate(loopArrow(Inv i, Tuple t, Cuerpo cuerpo)) =
    "for (" + generate(i) + " -\> " + generate(t) + ") " + generate(cuerpo);

str generate(loopTuple(Tuple t)) = generate(t);
str generate(loopIdent(str id)) = id;

str generate(loopInvocation(Inv i)) = generate(i);
str generate(loopRange(Rango r)) = generate(r);

// ============================================================
// Expresiones
// Los parentesis del programa original se conservan como parenthesizedExp,
// por eso no hace falta calcular precedencias al imprimir.
// ============================================================
str generate(expAtom(ExpAtom a)) = generate(a);

str generate(expPow(Exp l, Exp r)) = generate(l) + " ** " + generate(r);
str generate(expMul(Exp l, Exp r)) = generate(l) + " * " + generate(r);
str generate(expDiv(Exp l, Exp r)) = generate(l) + " / " + generate(r);
str generate(expMod(Exp l, Exp r)) = generate(l) + " % " + generate(r);
str generate(expAdd(Exp l, Exp r)) = generate(l) + " + " + generate(r);
str generate(expSub(Exp l, Exp r)) = generate(l) + " - " + generate(r);

str generate(expLt(Exp l, Exp r)) = generate(l) + " \< " + generate(r);
str generate(expGt(Exp l, Exp r)) = generate(l) + " \> " + generate(r);
str generate(expLe(Exp l, Exp r)) = generate(l) + " \<= " + generate(r);
str generate(expGe(Exp l, Exp r)) = generate(l) + " \>= " + generate(r);
str generate(expNe(Exp l, Exp r)) = generate(l) + " \<\> " + generate(r);
str generate(expEq(Exp l, Exp r)) = generate(l) + " = " + generate(r);

str generate(expIn(Exp l, Exp r)) = generate(l) + " in " + generate(r);
str generate(expInRango(Exp l, Rango rg)) = generate(l) + " in " + generate(rg);

str generate(expNeg(Exp e)) = "neg " + generate(e);
str generate(expAnd(Exp l, Exp r)) = generate(l) + " and " + generate(r);
str generate(expOr(Exp l, Exp r)) = generate(l) + " or " + generate(r);
str generate(expImp(Exp l, Exp r)) = generate(l) + " =\> " + generate(r);

// ============================================================
// Atomos
// ============================================================
str generate(instanceExp(Inst i)) = generate(i);
str generate(numberExp(str n)) = n;
str generate(booleanExp(str b)) = b;
str generate(charExp(str c)) = c;          // el lexico Char ya trae sus comillas simples
str generate(invocationExp(Inv i)) = generate(i);
str generate(conditionalExp(Cond c)) = generate(c);
str generate(stringExp(String s)) = generate(s);
str generate(tupleExp(Tuple t)) = generate(t);
str generate(printExp(Impri p)) = generate(p);
str generate(parenthesizedExp(Exp e)) = "(" + generate(e) + ")";

// ============================================================
// Cadenas: texto literal, $ident y ${exp}
// ============================================================
str generate(emptyString(str vacio)) = vacio;

str generate(string(list[StringPart] partes)) =
    "\"" + concatLista([ generate(p) | StringPart p <- partes ]) + "\"";

str generate(stringText(str texto)) = texto;
str generate(stringInterpolation(Pstr p)) = generate(p);

str generate(interpolatedIdent(str nombre)) = "$" + nombre;
str generate(interpolatedExp(Exp e)) = "${" + generate(e) + "}";

// ============================================================
// Control
// ============================================================
str generate(cond(Exp c, Cuerpo ent, Cuerpo sino)) =
    "if " + generate(c) + " then " + generate(ent) + " else " + generate(sino);

str generate(cuerpoBloque(Program p)) = bloque(p);
str generate(cuerpoExp(Exp e)) = generate(e);

str generate(impri(PrintKind k, Exp e)) = generate(k) + "(" + generate(e) + ")";
str generate(printKind()) = "print";
str generate(printlnKind()) = "println";

// ============================================================
// Overrides de una instancia: new T(...) { override ... }
// ============================================================
str concatOverrides([]) = "";
default str concatOverrides(list[Ovri] ovs) =
    " {\n" + sangrar(intercalate("\n", [ generate(ov) | Ovri ov <- ovs ])) + "\n}";
