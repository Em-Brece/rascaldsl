module Checker

extend analysis::typepal::TypePal;

import Syntax;
import ParseTree;


TModel modeloDesdeArbol(Tree arbol) {
    if (arbol has top) arbol = arbol.top;
    Collector c = newCollector("collectAndSolve", arbol, getTypePalConfig());
    collect(arbol, c);
    return newSolver(arbol, c.run()).run();
}


TypePalConfig getTypePalConfig() = tconfig();
