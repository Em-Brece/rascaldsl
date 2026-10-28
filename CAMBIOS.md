# Proyecto 2 – Objectilang: cambios a la gramática del Proyecto 1

**Integrantes:** Daniel [apellido] y Santiago Ortega

**Declaración de origen:** partimos de nuestra propia solución del Proyecto 1. No utilizamos la solución de otro grupo.

## 1. Criterio general

Conservamos la estructura y los nombres de los no terminales del documento de la gramática del Proyecto 1, y solo cambiamos lo necesario para que la gramática fuera ejecutable en Rascal y para poder construir el AST con implode.

## 2. No terminales que se agregaron o cambiaron

| No terminal | Antes | Después | Por qué |
|---|---|---|---|
| Declaracion | (Inicializar \| Fnew)+ en el símbolo inicial | declInic: Inicializar \| declFnew: Fnew | Un grupo con alternativas mezcla dos tipos en una lista. Con la regla propia, la lista del AST tiene un solo tipo. |
| Sentencia | (Inicializar \| Fnew \| Asig \| Loop \| Exp)+ en Program | Una alternativa etiquetada por cada caso | Mismo motivo: cinco tipos distintos en una lista. |
| ExpSent, ExpHead | La sentencia-expresión era una Exp cualquiera | ExpSent empieza por ExpHead, que no admite ( como primer símbolo | Una sentencia que empezara con ( se confundía con una llamada de la sentencia anterior (ambigüedad). |
| ExpTail | ExpAtoms | ExpTail con eqsTail y opsTail | Cambio de nombre para que coincida con el AST. La estructura es la misma. |
| Ctor | ("(" Params ")")? en línea | ctor: "(" Params ")" | El grupo opcional con literales pasa a ser una pieza con nombre. |
| Ext | ("extends" Tipo)? en línea | ext: "extends" Tipo | Igual que Ctor. |
| Tipado | (":" Tipo)? en línea | tipado: ":" Tipo | Igual que Ctor. |
| Bloque | "{" Program "}" repetido en varias producciones | bloque: "{" Program "}" | Una sola pieza reutilizable en Ovri y Fobject. |
| Args | ("(" Exp ("," Exp)* ")")? | args: "(" {Exp ","}* ")" | La lista con separador se entrega a implode como una sola lista de expresiones. |
| Ovrs | ("{" Ovri+ "}")? en Inst | ovrs: "{" Ovri+ "}" | El grupo opcional pasa a ser una pieza con nombre. |
| Campo | ("." Ident)* en Inv | campo: "." Ident | Cada acceso .nombre es un elemento de la lista. |
| Firma | ("(" Params? ")" ":" Tipo)? repetido en Fnew y Ovri | firma: "(" Params? ")" ":" Tipo | Se escribe una sola vez y se usa como Firma? en ambos sitios. |
| Modificador | ("val" \| "var")? en línea | lexical Modificador = ("val" \| "var") !>> [a-zA-Z0-9_] | La palabra importa (distingue val de var), así que debe llegar al AST como texto. |
| Neg | "neg"? en línea | lexical Neg = "neg" !>> [a-zA-Z0-9_] | Igual que Modificador. |
| PrintKw | ("print" \| "println") en línea | lexical PrintKw = ("print" \| "println") !>> [a-zA-Z0-9_] | Igual: hay que saber cuál de las dos se usó. |
| CmpAtom, CmpTail | (Inv \| Num \| String \| Bool) (Eqs (...))+ en línea | CmpAtom con cuatro alternativas etiquetadas y CmpTail = Eqs CmpAtom | Los grupos en línea no tienen constructor del AST al que corresponder. |
| RangeBound | (Num \| Inv) "to" (Num \| Inv) | Regla con rangeNum y rangeInv | Mismo motivo. |
| LoopVariable, LoopSource | (Tuple \| Ident) y (Inv \| Rango) en línea | Reglas con alternativas etiquetadas | Mismo motivo. |
| Condition | (Cmp \| Inv \| Bool) en línea dentro de Cond | conditionCmp, conditionInv, conditionBool | Mismo motivo. |
| StrPiece, StringPlain, StringStart, StringMid, StringEnd, StringTail | Un único string con ${ ... } | Un string con interpolación se divide en trozos léxicos | Un token léxico no puede contener una Exp en su interior. Se separa el texto de las expresiones y se unen en String / StringTail. |

## 3. Decisiones de diseño

- ; y \n no son terminales: las sentencias no llevan separador.
- Una sentencia no puede empezar con (, para evitar la ambigüedad con una llamada.
- else es obligatorio en Cond.
- Char solo admite letras, dígitos, ( ) [ ] : . ,, los operadores aritméticos y el espacio. Por ejemplo, ! no cabe dentro de un string.

## 4. Decisiones del AST

- Las partes opcionales se representan como list[...] con 0 o 1 elemento.
- Los identificadores, números, booleanos y operadores se guardan como str.
- El texto de los strings se guarda tal cual aparece en el programa, con sus comillas; los operadores se guardan como texto (por ejemplo ">").
- Los nombres de los constructores del AST coinciden con las etiquetas de Syntax.rsc, que es lo que permite a implode emparejarlos automáticamente.
