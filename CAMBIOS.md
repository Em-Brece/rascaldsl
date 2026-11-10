# Proyecto 2 – Objectilang: cambios a la gramática del Proyecto 1

**Integrantes:** Daniel Tinjaca y Santiago Ortega

**Declaración de origen:** partimos de nuestra propia solución del Proyecto 1. No utilizamos la solución de otro grupo.

## 1. Criterio general

Conservamos la estructura y los nombres de los no terminales del documento del Proyecto 1. Los nombres son los mismos con la inicial en mayúscula, que Rascal exige para los no terminales (tipo → Tipo, inicializar → Inicializar). La única excepción es module, que es palabra reservada de Rascal y pasa a llamarse ObjModule.

## 2. No terminales que se agregaron o cambiaron

| Elemento | Proyecto 1 (Word) | Proyecto 2 (Rascal) | Por qué |
|---|---|---|---|
| Símbolo inicial | module | ObjModule | module es palabra reservada de Rascal. |
| inst | "new"? tipo (...) | instArgs/instBare: "new" obligatorio, Args y bloque de overrides opcional | Sin new, Foo(1) se podía leer como instancia y como invocación (Tipo e Inv empiezan igual): ambigüedad. Se separa la forma con argumentos de la forma sin argumentos (!>> [(]) para que new L(a) enganche los argumentos y no quede un (a) colgante. |
| inv | ident ("." ident)* (...)? | invCall/invRef, con invRef !>> [(] | Misma idea que en inst: la forma sin argumentos no puede ir seguida de "(", de modo que f(1) se lee como una sola llamada y no como f seguido de (1). |
| cond | ("else" cuerpo)? | else obligatorio | Con else opcional, if a then if b then x else y tiene dos lecturas (else colgante). |
| rango | num "to" num | ExpAtom "to" ExpAtom | Ampliación: los límites pueden ser cualquier átomo de expresión (un número o una invocación/variable), no solo un número. "to" no es palabra reservada. |
| Operadores de comparación/igualdad | ... == ... | ... = ... y se agrega => | La igualdad del lenguaje es "=", no "==" (== no pertenece al lenguaje). Se agrega el operador "=>" que faltaba. |
| neg | solo al inicio de la condición del if | operador de prefijo sobre un átomo (negatedExp) | neg debe poder usarse en cualquier expresión, no solo al comienzo de la condición de un if. |
| Argumentos (Args) | ("(" exp ("," exp)* ")")? (al menos un argumento) | Args = noArgs "(" ")" o someArgs "(" Exp ("," Exp)* ")" | Pieza única compartida por inst e inv. Separar "()" del caso con argumentos evita una lista separada anulable dentro de un opcional (que hacía ambigua toda llamada) y permite new Foo() y f(). |
| Tuple | "(" ident ("," ident)* ")" | "(" Ident ("," Ident)+ ")" (mínimo dos) | Una tupla de un solo elemento (a) chocaba con una expresión entre paréntesis. Una tupla siempre tiene al menos dos componentes. |
| String / interpolación | cadena con $ident y ${...} | StringChars = ![\"$]+ (máximo) más Pstr para $ident y ${ exp } | El conjunto de caracteres anterior era muy restrictivo y los print generaban cadenas que no pertenecían al lenguaje. Ahora el texto admite prosa y puntuación normales, y la interpolación acepta espacios: ${x} y $ { x }. |
| ident | letter (letter \| digit \| "_")* | Igual, pero sin las palabras reservadas (keyword Reserved) | Evita que if o object se lean como identificador. |
| Palabras clave y operadores de palabra (and, or, in, neg, val, var, print, println, true, false) | Sin restricción | Terminan donde no siga letra, dígito o _ (!>>) | Evita que index se lea como in + dex. |
| Espacios y comentarios | No se definían | layout: espacios, tabs, saltos de línea y comentarios // | Rascal necesita saber qué separa los símbolos entre sí. |

## 3. Decisiones de diseño

- ; y \n no son terminales: las sentencias no llevan separador.
- La forma sin argumentos de inst e inv no puede ir seguida de "(", para evitar la ambigüedad con una llamada y con una sentencia que empiece por "(".
- else es obligatorio en Cond (evita el else colgante).
- La igualdad es "=" (no "==") y existe el operador "=>".
- neg es un operador de prefijo que funciona en cualquier expresión.
- nop (+ / -) sigue reutilizado para el signo, la aritmética y la varianza de los genéricos, como en el Proyecto 1.
- La gramática se verificó sin ambigüedades sobre los cuatro ejemplos del enunciado (instance/snippet1..4.obj), tanto al parsear como al construir el AST con implode.

## 4. Decisiones del AST

- Las partes opcionales se representan como list[...] con 0 o 1 elemento.
- Los identificadores, números, booleanos y operadores se guardan como str.
- El texto de los strings se guarda por partes (texto literal e interpolaciones); los operadores se guardan como texto (por ejemplo "\>").
- Los nombres de los constructores del AST coinciden con las etiquetas de Syntax.rsc, que es lo que permite a implode emparejarlos automáticamente.
