module Checker

extend analysis::typepal::TypePal;

import Syntax;
import ParseTree;
import List;
import Desambiguar;

data AType
  = intType() | boolType() | stringType() | unitType() | anyType() | rangeType()
  | tupleType(list[AType] ts)
  | fnType(list[AType] params, AType ret)
  | typeParamType(str name)
  | objType(str name, list[AType] args, list[str] tps, list[AType] sup, list[AType] ctor)
  | charType();

str prettyAType(charType()) = "Char";
str prettyAType(intType()) = "Int";
str prettyAType(boolType())    = "Bool";
str prettyAType(stringType())  = "String";
str prettyAType(unitType())    = "Unit";
str prettyAType(anyType())     = "?";
str prettyAType(rangeType())   = "Range";
str prettyAType(tupleType(_))  = "Tupla";
str prettyAType(fnType(_, _))  = "Metodo";
str prettyAType(typeParamType(n)) = n;
str prettyAType(objType(n, [], _, _, _)) = n;
str prettyAType(objType(n, xs, _, _, _)) = "<n>[<intercalate(", ", [prettyAType(x) | x <- xs])>]";

data IdRole = variableId() | objectId() | typeParamId() | methodId();

// ============================================================
// Subtipado con varianza
// ============================================================
str pname(str tp) = (tp[0..1] == "+" || tp[0..1] == "-") ? tp[1..] : tp;
str pvar(str tp)  = tp[0..1] == "+" ? "+" : (tp[0..1] == "-" ? "-" : "");

AType subst(AType t, map[str, AType] m) {
  switch (t) {
    case typeParamType(x): return m[x] ? t;
    case objType(n, xs, tps, sup, ctor): return objType(n, [subst(x, m) | x <- xs], tps, sup, ctor);
    default: return t;
  }
}

bool sub(AType l, AType r) {
  if (l == r) return true;
  if (anyType() := l || anyType() := r) return true;
  if (objType(ln, la, ltps, lsup, _) := l && objType(rn, ra, rtps, _, _) := r) {
    if (ln == rn) {
      if (size(la) != size(ra)) return false;
      for (i <- index(la)) {
        str v = i < size(rtps) ? pvar(rtps[i]) : "";
        bool ok = v == "+" ? sub(la[i], ra[i])
                : (v == "-" ? sub(ra[i], la[i])
                            : (sub(la[i], ra[i]) && sub(ra[i], la[i])));
        if (!ok) return false;
      }
      return true;
    }
    map[str, AType] m = (pname(ltps[i]) : la[i] | i <- index(ltps), i < size(la));
    return any(s <- lsup, sub(subst(s, m), r));
  }
  return false;
}

map[str, AType] unify(AType p, AType a, map[str, AType] m) {
  if (typeParamType(x) := p) {
    if (x notin m) m[x] = a;
    return m;
  }
  if (objType(pn, pxs, _, _, _) := p && objType(an, axs, _, _, _) := a && pn == an) {
    for (i <- index(pxs), i < size(axs)) m = unify(pxs[i], axs[i], m);
  }
  return m;
}

void tipoEsperado(Solver s, Tree nodo, AType esperado) {
  if (!sub(s.getType(nodo), esperado))
    s.report(error(nodo, "Se esperaba %t, se encontró %t", esperado, nodo));
}

// ============================================================
// Punto de entrada
// ============================================================
TModel modeloDesdeArbol(Tree arbol) {
    if (arbol has top) arbol = arbol.top;
    arbol = desambiguar(arbol);
    Collector c = newCollector("collectAndSolve", arbol, getTypePalConfig());
    collect(arbol, c);
    return newSolver(arbol, c.run()).run();
}

TypePalConfig getTypePalConfig() = tconfig(isSubType = sub);

// ============================================================
// Ayudantes
// ============================================================
void mismoTipo(Tree current, Tree hijo, Collector c) {
  c.calculate("tipo", current, [hijo], AType(Solver s) { return s.getType(hijo); });
  collect(hijo, c);
}

list[tuple[str, Ident]] tparamsOf(Atribute at) {
  list[tuple[str, Ident]] res = [];
  if ((Atribute)`[ <{Vari ","}+ vs> ]` := at)
    for (Vari v <- vs)
      if ((Vari)`<Nop? m> <Tipo t>` := v, (Tipo)`<Ident tp>` := t) res += <"<m>", tp>;
  return res;
}

list[Tipo] tiposDeParams(Params ps) {
  list[Tipo] res = [];
  if ((Params)`<{Param ","}+ xs>` := ps)
    for (Param x <- xs, (Param)`<Modificador? _> <Ident _> : <Tipo t>` := x) res += t;
  return res;
}

list[Exp] expsDe(Args a) {
  if ((Args)`( <{Exp ","}+ xs> )` := a) return [x | x <- xs];
  return [];
}

void definirAny(Ident x, Collector c) { c.define("<x>", variableId(), x, defType(anyType())); }

// ============================================================
// Tipos escritos por el usuario
// ============================================================
void collect(current: (Tipo)`<Ident n>`, Collector c) {
  switch ("<n>") {
    case "Int":    c.fact(current, intType());
    case "Bool":   c.fact(current, boolType());
    case "String": c.fact(current, stringType());
    case "Char": c.fact(current, charType());
    default: {
      c.use(n, {objectId(), typeParamId()});
      c.calculate("tipo", current, [n], AType(Solver s) { return s.getType(n); });
    }
  }
}

void collect(current: (Tipo)`<Ident n> [ <{Vari ","}+ vs> ]`, Collector c) {
  c.use(n, {objectId()});
  list[Vari] args = [v | v <- vs];
  c.calculate("tipo generico", current, [n, *args], AType(Solver s) {
    d = s.getType(n);
    if (objType(nm, _, tps, sup, ctor) := d)
      return objType(nm, [s.getType(a) | a <- args], tps, sup, ctor);
    s.report(error(n, "%t no es un objeto genérico", n));
    return anyType();
  });
  collect(vs, c);
}

void collect(current: (Vari)`<Nop? _> <Tipo t>`, Collector c) { mismoTipo(current, t, c); }

// ============================================================
// Objetos: parametros de tipo, extends, constructor
// ============================================================

list[Atribute] atributosDe(Tree nodo) {
  list[Atribute] res = [];
  for (Tree ch <- nodo.args) {
    if (Atribute x := ch) { res = res + [x]; }
    else { for (Tree h <- ch.args) { if (Atribute y := h) { res = res + [y]; } } }
  }
  return res;
}

list[CtorParams] ctorParamsDe(Tree nodo) {
  list[CtorParams] res = [];
  for (Tree ch <- nodo.args) {
    if (CtorParams x := ch) { res = res + [x]; }
    else { for (Tree h <- ch.args) { if (CtorParams y := h) { res = res + [y]; } } }
  }
  return res;
}

list[Tipo] padresDe(Tree nodo) {
  list[Tipo] res = [];
  for (Tree ch <- nodo.args) {
    if (Extiende x := ch) {
      for (Tree h <- x.args) { if (Tipo t := h) { res = res + [t]; } }
    } else {
      for (Tree h <- ch.args) {
        if (Extiende y := h) {
          for (Tree h2 <- y.args) { if (Tipo t2 := h2) { res = res + [t2]; } }
        }
      }
    }
  }
  return res;
}
void colectarHijos(Tree t, Collector c) {
  if (appl(_, list[Tree] hs) := t) {
    for (Tree h <- hs) {
      // saltar layout y literales: no tienen nada que recolectar
      if (appl(prod(\layouts(_), _, _), _) := h) { continue; }
      if (appl(prod(lit(_), _, _), _) := h) { continue; }
      collect(h, c);
    }
  }
}
void collect(Inicializar current, Collector c) {
  list[Tree] hijos = [ch | Tree ch <- current.args];

  // --- object Nombre[...](...) extends ... ---
    if (Obj objeto := hijos[0]) {
    Ident n = identsDirectos(objeto)[0];
    str nombre = "<n>";

    list[tuple[str, Ident]] tps = [];
    for (Atribute at <- atributosDe(current)) { tps = tparamsOf(at); }

    list[str] tpIds = [];
    list[str] tpNames = [];
    for (tuple[str, Ident] tp <- tps) {
      tpIds = tpIds + ["<tp[1]>"];
      tpNames = tpNames + ["<tp[0]><tp[1]>"];
    }

    list[CtorParams] ctors = ctorParamsDe(current);
    list[Tipo] ctorTipos = [];
    for (CtorParams cp <- ctors) {
      for (Tree h <- cp.args) {
        if (Params ps := h) { ctorTipos = tiposDeParams(ps); }
      }
    }

    list[Tipo] padres = padresDe(current);

    list[Tree] deps = [];
    for (Tipo t1 <- ctorTipos) { deps = deps + [t1]; }
    for (Tipo t2 <- padres)    { deps = deps + [t2]; }

    c.define(nombre, objectId(), n, defType(deps, AType(Solver s) {
      list[AType] params = [];
      for (str id <- tpIds) { params = params + [typeParamType(id)]; }
      list[AType] supers = [];
      for (Tipo t3 <- padres) { supers = supers + [s.getType(t3)]; }
      list[AType] ctor = [];
      for (Tipo t4 <- ctorTipos) { ctor = ctor + [s.getType(t4)]; }
      return objType(nombre, params, tpNames, supers, ctor);
    }));

    c.enterScope(current);
      for (tuple[str, Ident] tp2 <- tps) {
        c.define("<tp2[1]>", typeParamId(), tp2[1], defType(typeParamType("<tp2[1]>")));
      }
      for (Tipo unPadre <- padres) { collect(unPadre, c); }
      for (CtorParams cp2 <- ctors) { collect(cp2, c); }
    c.leaveScope(current);
    return;
  }

  // --- Cat.talk = method(...) : T { ... } ---
    if (Ident n2 := hijos[0]) {
    c.use(n2, {objectId()});
    c.enterScope(current);
        for (Tree ch <- hijos) {
        if (Fobject f := ch) { colectarHijos(f, c); }
        }
    c.leaveScope(current);
    return;
    }
    colectarHijos(current, c);
}

void collect(current: (Param)`<Ident n> : <Tipo t>`, Collector c) {
  c.define("<n>", variableId(), n, defType(t));
  collect(t, c);
}

void collect(current: (Param)`<Modificador m> <Ident n> : <Tipo t>`, Collector c) {
  c.define("<n>", variableId(), n, defType(t));
  collect(t, c);
}

// ============================================================
// Metodos
// ============================================================

list[Firma] firmasDe(Tree nodo) {
  list[Firma] res = [];
  if (appl(_, list[Tree] hijos) := nodo) {
    for (Tree ch <- hijos) {
      if (Firma f1 := ch) {
        res = res + [f1];
      }
      if (appl(_, list[Tree] nietos) := ch) {
        for (Tree h <- nietos) {
          if (Firma f2 := h) {
            res = res + [f2];
          }
        }
      }
    }
  }
  return res;
}

// Tipos de los parametros y tipo de retorno de una Firma
tuple[list[Tipo], list[Tipo]] infoFirma(Firma fi) {
  list[Tipo] ptipos = [];
  list[Tipo] rets = [];
  for (Tree ch <- fi.args) {
    if (Tipo t := ch) {
      rets = rets + [t];
    } else {
      for (Tree h <- ch.args) {
        if (Params pp := h) { ptipos = tiposDeParams(pp); }
      }
    }
  }
  return <ptipos, rets>;
}

list[Ident] identsDirectos(Tree nodo) {
  list[Ident] res = [];
  for (Tree ch <- nodo.args) { if (Ident x := ch) { res = res + [x]; } }
  return res;
}

list[Program] programasDirectos(Tree nodo) {
  list[Program] res = [];
  for (Tree ch <- nodo.args) { if (Program x := ch) { res = res + [x]; } }
  return res;
}


void collect(Fnew current, Collector c) {
  Ident n = identsDirectos(current)[0];
  Program p = programasDirectos(current)[0];
  list[Firma] firmas = firmasDe(current);

  list[Tipo] ptipos = [];
  list[Tipo] rets = [];
  for (Firma fi <- firmas) {
    tuple[list[Tipo], list[Tipo]] info = infoFirma(fi);
    ptipos = info[0];
    rets = info[1];
  }

  list[Tree] deps = [];
  for (Tipo tp <- ptipos) { deps = deps + [tp]; }
  for (Tipo tr <- rets)   { deps = deps + [tr]; }

  c.define("<n>", methodId(), n, defType(deps, AType(Solver s) {
    AType ret = unitType();
    if (rets != []) { ret = s.getType(rets[0]); }
    return fnType([s.getType(x) | x <- ptipos], ret);
  }));

  c.enterScope(current);
    for (Firma fi2 <- firmas) { collect(fi2, c); }
    collect(p, c);
  c.leaveScope(current);
}

void collect(Ovri current, Collector c) {
  Program p = programasDirectos(current)[0];
  c.enterScope(current);
    for (Firma fi <- firmasDe(current)) { collect(fi, c); }
    collect(p, c);
  c.leaveScope(current);
}

// ============================================================
// Instanciacion: new T(args) { overrides }, con inferencia de argumentos de tipo
// ============================================================
void inst(Inst current, Tipo t, list[Exp] es, Collector c) {
  c.calculate("new", current, [t, *es], AType(Solver s) {
    ty = s.getType(t);
    if (objType(nm, targs, tps, sup, ctor) := ty) {
      bool crudo = size(tps) > 0 && targs == [typeParamType(pname(x)) | x <- tps];
      map[str, AType] m = ();
      if (crudo) {
        for (i <- index(ctor), i < size(es)) m = unify(ctor[i], s.getType(es[i]), m);
        targs = [m[pname(x)] ? anyType() | x <- tps];
      }
      map[str, AType] env = (pname(tps[i]) : targs[i] | i <- index(tps), i < size(targs));
      if (size(es) != size(ctor))
        s.report(error(current, "El constructor de %v espera %v argumento(s) y recibió %v", nm, size(ctor), size(es)));
      else
        for (i <- index(ctor)) {
          AType esperado = subst(ctor[i], env);
          if (!sub(s.getType(es[i]), esperado))
            s.report(error(es[i], "Se esperaba %t, se encontró %t", esperado, es[i]));
        }
      return objType(nm, targs, tps, sup, ctor);
    }
    s.report(error(t, "%t no es un objeto que se pueda instanciar", t));
    return anyType();
  });
  collect(t, c);
  for (Exp x <- es) collect(x, c);
}

list[Ovri] ovrisDe(Tree t) {
  if (Ovri ov := t) { return [ov]; }
  list[Ovri] res = [];
  if (appl(_, list[Tree] hs) := t) {
    for (Tree h <- hs) { res = res + ovrisDe(h); }
  }
  return res;
}

void collect(Inst current, Collector c) {
  list[Tipo] tipos = [];
  list[Exp] es = [];
  list[Ovri] ovs = [];

  if (appl(_, list[Tree] hs) := current) {
    for (Tree h <- hs) {
      if (Tipo t := h) { tipos = tipos + [t]; }
      else if (Args a := h) { es = expsDe(a); }
      else { ovs = ovs + ovrisDe(h); }
    }
  }

  inst(current, tipos[0], es, c);
  for (Ovri ov <- ovs) { collect(ov, c); }
}
// ============================================================
// Invocaciones: x, f(a), a.b.c, a.b(x)
// ============================================================
void collect(Inv current, Collector c) {
  list[Ident] ids = [];
  list[Args] args = [];
  for (Tree ch <- current.args) {
    if (Ident x := ch) ids += x;
    if (Args a := ch) args += a;
  }
  Ident first = ids[0];
  bool punteado = size(current.args[2].args) > 0;
  list[Exp] es = args == [] ? [] : expsDe(args[0]);

  if (!punteado && args == []) {
    c.use(first, {variableId()});
    c.calculate("ref", current, [first], AType(Solver s) { return s.getType(first); });
  } else if (!punteado) {
    c.use(first, {methodId()});
    c.calculate("llamada", current, [first, *es], AType(Solver s) {
      f = s.getType(first);
      if (fnType(ps, r) := f) {
        if (size(ps) != size(es)) s.report(error(current, "Se esperaban %v argumento(s) y se recibieron %v", size(ps), size(es)));
        else for (i <- index(ps)) if (!sub(s.getType(es[i]), ps[i]))
          s.report(error(es[i], "Se esperaba %t, se encontró %t", ps[i], es[i]));
        return r;
      }
      return anyType();
    });
  } else {
    // acceso a campos / metodos de un objeto: se valida la base y no se tipa el resto
    c.use(first, {variableId()});
    c.fact(current, anyType());
  }
  for (Exp x <- es) collect(x, c);
}

// ============================================================
// Literales, envoltorios y strings
// ============================================================
void collect(current: (ExpAtom)`<Num _>`,  Collector c) { c.fact(current, intType()); }
void collect(current: (ExpAtom)`<Bool _>`, Collector c) { c.fact(current, boolType()); }
void collect(current: (ExpAtom)`<String k>`, Collector c) {
  c.fact(current, stringType());
  colectarHijos(current, c);
}
void collect(current: (Pstr)`$<Ident n>`, Collector c) { c.use(n, {variableId()}); }

void collect(current: (Exp)`<ExpAtom a>`,         Collector c) { mismoTipo(current, a, c); }
void collect(current: (ExpAtom)`( <Exp e> )`,     Collector c) { mismoTipo(current, e, c); }
void collect(current: (ExpAtom)`<Inv i>`,         Collector c) { mismoTipo(current, i, c); }
void collect(current: (ExpAtom)`<Inst i>`,        Collector c) { mismoTipo(current, i, c); }
void collect(current: (ExpAtom)`<Cond k>`,        Collector c) { mismoTipo(current, k, c); }
void collect(current: (ExpAtom)`<Impri p>`,       Collector c) { mismoTipo(current, p, c); }
void collect(current: (Cuerpo)`<Exp e>`,          Collector c) { mismoTipo(current, e, c); }

void collect(current: (Cuerpo)`{ <Program p> }`, Collector c) {
  c.fact(current, unitType());
  c.enterScope(current);
    collect(p, c);
  c.leaveScope(current);
}

void collect(current: (ExpAtom)`<Tuple t>`, Collector c) {
  list[Ident] ids = [x | /Ident x := t];
  for (Ident x <- ids) c.use(x, {variableId()});
  c.calculate("tupla", current, ids, AType(Solver s) { return tupleType([s.getType(x) | x <- ids]); });
}

void collect(current: (Rango)`<ExpAtom a> to <ExpAtom b>`, Collector c) {
  c.calculate("rango", current, [a, b], AType(Solver s) {
    tipoEsperado(s, a, intType());
    tipoEsperado(s, b, intType());
    return rangeType();
  });
  collect(a, b, c);
}

void collect(current: (Impri)`<PrintKind _> ( <Exp e> )`, Collector c) { c.fact(current, unitType()); collect(e, c); }

// ============================================================
// Operadores
// ============================================================
void binario(Exp current, Exp l, Exp r, AType operando, AType resultado, Collector c) {
  c.calculate("operador", current, [l, r], AType(Solver s) {
    tipoEsperado(s, l, operando);
    tipoEsperado(s, r, operando);
    return resultado;
  });
  collect(l, r, c);
}

void comparable(Exp current, Exp l, Exp r, Collector c) {
  c.calculate("comparacion", current, [l, r], AType(Solver s) {
    if (!(sub(s.getType(l), s.getType(r)) || sub(s.getType(r), s.getType(l))))
      s.report(error(current, "No se pueden comparar %t y %t", l, r));
    return boolType();
  });
  collect(l, r, c);
}

void collect(current: (Exp)`<Exp l> + <Exp r>`,  Collector c) { binario(current, l, r, intType(), intType(), c); }
void collect(current: (Exp)`<Exp l> - <Exp r>`,  Collector c) { binario(current, l, r, intType(), intType(), c); }
void collect(current: (Exp)`<Exp l> * <Exp r>`,  Collector c) { binario(current, l, r, intType(), intType(), c); }
void collect(current: (Exp)`<Exp l> / <Exp r>`,  Collector c) { binario(current, l, r, intType(), intType(), c); }
void collect(current: (Exp)`<Exp l> % <Exp r>`,  Collector c) { binario(current, l, r, intType(), intType(), c); }
void collect(current: (Exp)`<Exp l> ** <Exp r>`, Collector c) { binario(current, l, r, intType(), intType(), c); }

void collect(current: (Exp)`<Exp l> \< <Exp r>`,  Collector c) { binario(current, l, r, intType(), boolType(), c); }
void collect(current: (Exp)`<Exp l> \> <Exp r>`,  Collector c) { binario(current, l, r, intType(), boolType(), c); }
void collect(current: (Exp)`<Exp l> \<= <Exp r>`, Collector c) { binario(current, l, r, intType(), boolType(), c); }
void collect(current: (Exp)`<Exp l> \>= <Exp r>`, Collector c) { binario(current, l, r, intType(), boolType(), c); }

void collect(current: (Exp)`<Exp l> = <Exp r>`,    Collector c) { comparable(current, l, r, c); }
void collect(current: (Exp)`<Exp l> \<\> <Exp r>`, Collector c) { comparable(current, l, r, c); }

void collect(current: (Exp)`<Exp l> in <Exp r>`, Collector c) { c.fact(current, boolType()); collect(l, r, c); }
void collect(current: (Exp)`<Exp l> in <Rango r>`, Collector c) {
  c.calculate("in", current, [l, r], AType(Solver s) { tipoEsperado(s, l, intType()); return boolType(); });
  collect(l, r, c);
}

void collect(current: (Exp)`<Exp l> and <Exp r>`,  Collector c) { binario(current, l, r, boolType(), boolType(), c); }
void collect(current: (Exp)`<Exp l> or <Exp r>`,   Collector c) { binario(current, l, r, boolType(), boolType(), c); }
void collect(current: (Exp)`<Exp l> =\> <Exp r>`,  Collector c) { binario(current, l, r, boolType(), boolType(), c); }

void collect(current: (Exp)`neg <Exp e>`, Collector c) {
  c.calculate("neg", current, [e], AType(Solver s) { tipoEsperado(s, e, boolType()); return boolType(); });
  collect(e, c);
}

// ============================================================
// if, variables, asignaciones, ciclos
// ============================================================
void collect(current: (Cond)`if <Exp g> then <Cuerpo a> else <Cuerpo b>`, Collector c) {
  c.calculate("if", current, [g, a, b], AType(Solver s) {
    tipoEsperado(s, g, boolType());
    ta = s.getType(a);
    tb = s.getType(b);
    if (sub(tb, ta)) return ta;
    if (sub(ta, tb)) return tb;
    s.report(error(current, "Las ramas tienen tipos incompatibles: %t y %t", a, b));
    return anyType();
  });
  collect(g, a, b, c);
}

void collect(current: (Vars)`<Modificador m> <Ident n> : <Tipo t> = <Exp e>`, Collector c) {
  c.define("<n>", variableId(), n, defType(t));
  c.require("declaracion", current, [e, t], void(Solver s) {
    if (!sub(s.getType(e), s.getType(t)))
      s.report(error(e, "Se esperaba %t, se encontró %t", t, e));
  });
  collect(t, e, c);
}

void collect(current: (Vars)`<Modificador m> <Ident n> = <Exp e>`, Collector c) {
  c.define("<n>", variableId(), n, defType(e));
  collect(e, c);
}

void collect(current: (Asig)`<Ident n> = <Exp e>`, Collector c) {
  c.use(n, {variableId()});
  c.require("asignacion", current, [n, e], void(Solver s) {
    if (!sub(s.getType(e), s.getType(n)))
      s.report(error(e, "No se puede asignar %t a una variable de tipo %t", e, n));
  });
  collect(e, c);
}

void collect(current: (Loop)`for ( <LoopVariable v> \<- <LoopSource src> ) <Cuerpo b>`, Collector c) {
  c.enterScope(current);
    for (/Ident x := v) definirAny(x, c);
    collect(src, b, c);
  c.leaveScope(current);
}

void collect(current: (Loop)`for ( <Inv i> -\> <Tuple t> ) <Cuerpo b>`, Collector c) {
  c.enterScope(current);
    for (/Ident x := t) definirAny(x, c);
    collect(i, b, c);
  c.leaveScope(current);
}

void collect(current: (ExpAtom)`<Char k>`, Collector c) { c.fact(current, charType()); }

default void collect(Tree current, Collector c) { colectarHijos(current, c); }
