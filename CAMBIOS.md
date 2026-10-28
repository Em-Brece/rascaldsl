# Proyecto 2 – Objectilang: cambios a la gramática del Proyecto 1

**Integrantes:** Daniel Tinjaca y Santiago Ortega

**Declaración de origen:** partimos de nuestra propia solución del Proyecto 1. No utilizamos la solución de otro grupo.

## 1. Criterio general

Conservamos la estructura y los nombres de los no terminales del documento del Proyecto 1. Los nombres son los mismos con la inicial en mayúscula, que Rascal exige para los no terminales (tipo → Tipo, inicializar → Inicializar). La única excepción es module, que es palabra reservada de Rascal y pasa a llamarse ObjModule.

## 2. No terminales que se agregaron o cambiaron

| Elemento | Proyecto 1 (Word) | Proyecto 2 (Rascal) | Por qué |
|---|---|---|---|
| Símbolo inicial | module | ObjModule | module es palabra reservada de Rascal. |
| inst | "new"? tipo (...) | "new" Tipo Args? Ovrs? (new obligatorio) | Sin new, Foo(1) se podía leer como instancia y como invocación (Tipo e Inv empiezan igual): ambigüedad. |
| cond | ("else" cuerpo)? | else obligatorio | Con else opcional, if a then if b then x else y tiene dos lecturas (else colgante). |
| rango | num "to" num | RangeBound "to" RangeBound, donde el límite es Num o Inv | Ampliación: los límites pueden ser una invocación (por ejemplo una variable), no solo un número. |
| Argumentos de inst | ("(" exp ("," exp)* ")")? (al menos un argumento) | Args = "(" {Exp ","}* ")" | Se reutiliza la misma pieza que en inv, por lo que new Foo() también se acepta. |
| ident | letter (letter \| digit \| "_")* | Igual, pero sin las palabras reservadas (keyword Reserved) | Evita que if o object se lean como identificador. |
| Palabras clave y operadores de palabra (and, or, in, neg, val, var, print, println, true, false) | Sin restricción | Terminan donde no siga letra, dígito o _ (!>>) | Evita que index se lea como in + dex. |
| Espacios y comentarios | No se definían | layout: espacios, tabs, saltos de línea y comentarios // | Rascal necesita saber qué separa los símbolos entre sí. |
| Sentencia que empieza con ( | program admitía cualquier exp como sentencia | ExpSent = ExpHead ExpTail*, y ExpHead no incluye tuple ni "(" exp ")" | Una sentencia que empezara con ( se confundía con una llamada de la sentencia anterior (ambigüedad). |

## 3. Decisiones de diseño

- ; y \n no son terminales: las sentencias no llevan separador.
- Una sentencia no puede empezar con (, para evitar la ambigüedad con una llamada.
- else es obligatorio en Cond.
- nop (+ / -) sigue reutilizado para el signo, la aritmética y la varianza de los genéricos, como en el Proyecto 1.

## 4. Decisiones del AST

- Las partes opcionales se representan como list[...] con 0 o 1 elemento.
- Los identificadores, números, booleanos y operadores se guardan como str.
- El texto de los strings se guarda tal cual aparece en el programa, con sus comillas; los operadores se guardan como texto (por ejemplo ">").
- Los nombres de los constructores del AST coinciden con las etiquetas de Syntax.rsc, que es lo que permite a implode emparejarlos automáticamente.
