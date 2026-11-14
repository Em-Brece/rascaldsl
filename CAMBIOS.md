# Cómo ejecutar el proyecto en VS Code

## 1. Generar el código de un ejemplo (ejecución del lenguaje)

En la terminal de Rascal, importar el generador y pasarle la ubicación de un `.ol`:

```
import Generator;
generar(|project://rascaldsl/instance/snippet1.ol|);
```

Se repite cambiando el número para `snippet2`, `snippet3` y `snippet4`. No hay que "cargar"
el ejemplo aparte: la función lee el archivo, construye el AST y muestra el código generado.


Para generar los cuatro ejemplos de una vez existe un punto de entrada en `Main`:

```
import Main;
main([]);
```

## 3. Chequear los tipos de un ejemplo

En la misma terminal se importa el chequeador y se inspeccionan los mensajes:

```
import Checker;
import Parser;
modeloDesdeArbol(parsear(|project://rascaldsl/instance/snippet1.ol|)).messages;
```

---

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

---

# Proyecto 3

## 1. Preparar la gramática para que el lenguaje funcione

Antes de poder ejecutar o tipar, se corrigió la gramática para que aceptara exactamente el
lenguaje del enunciado y sin ambigüedades:

- Se ajustaron los operadores al conjunto real del Proyecto 1 (la igualdad es `=`, se
  agregó `=>`) y `neg` pasó a ser un operador de prefijo general.
- Las cadenas y su interpolación (`$ident`, `${exp}`) se ajustaron al alfabeto del lenguaje.
- Se eliminaron las ambigüedades restantes separando producciones que empezaban igual
  (instancia vs. invocación, llamada vs. referencia, tupla vs. paréntesis). La gramática se
  verificó sin ambigüedades sobre los cuatro ejemplos, tanto al parsear como al construir el
  AST con `implode`.

## 2. Ejecución mediante generación de código

- Se definió una familia de funciones `generate(...)` sobrecargadas, una por tipo de nodo,
  que recorren el AST y producen el texto correspondiente. Rascal elige la variante por el
  tipo del nodo, igual que en el ejemplo del tutorial.
- Para unir las partes se usaron únicamente operaciones del vocabulario del tutorial
  (concatenación e `intercalate`), evitando utilidades ajenas a él.
- `Main` expone un punto de entrada que genera y muestra en consola los cuatro ejemplos,
  conservando solo lo necesario para ejecutarlos.

## 3. Tipos y chequeo con TypePal

El chequeo de tipos se delega a **TypePal**. Se instaló la versión compatible con la versión
de Rascal del proyecto y se declaró como dependencia. Sobre ella se definió:

- **Tipos básicos del lenguaje** (Int, Bool, String y Char) y los tipos de objeto, que
  llevan sus parámetros genéricos. Char se incorporó en esta fase porque el lenguaje lo
  requiere a nivel de literales.
- **Reglas de recolección** (`collect`/`define`/`use`) que registran dónde se declara cada
  nombre y dónde se usa, y **reglas de tipo** para expresiones, operadores, condicionales,
  declaraciones y asignaciones, comprobando que los tipos encajen con lo declarado.
- **Genéricos con varianza.** El subtipado respeta los modificadores `+` (covarianza) y `-`
  (contravarianza) de los parámetros de tipo, tal como se describe en el enunciado, además
  de inferir los argumentos de tipo al instanciar (`new`).

## 5. "Lo que se usa debe existir"

Como regla de validación adicional, toda referencia a una variable, objeto, método o
parámetro de tipo debe estar declarada previamente. Si no lo está, el chequeador reporta un
error de elemento indefinido. Esta regla cae de forma natural de las reglas `use` de TypePal.

## 6. Decisiones y limitación conocida

- Los nombres de los constructores del AST coinciden con las etiquetas de `Syntax.rsc`, lo
  que permite a `implode` emparejarlos automáticamente, y una pasada de desambiguación
  resuelve los casos límite (por ejemplo, asignación frente a igualdad) antes del chequeo.
- **Limitación conocida:** cuando un método se declara **fuera del cuerpo del objeto** y
  referencia los parámetros genéricos de ese objeto (como `Transformer.transform = method(input: In): Out`
  en el Snippet 3), esos parámetros no quedan en el alcance del método, por lo que el
  chequeador los reporta como indefinidos. Los métodos externos sin genéricos y los
  genéricos declarados dentro del cuerpo del objeto sí se verifican correctamente. Nótese
  además que el propio enunciado del Proyecto 1 escribe este ejemplo de forma inconsistente
  (define `object Transformer` pero luego `Transform.transform`); en los ejemplos se usó el
  nombre coherente `Transformer`.
