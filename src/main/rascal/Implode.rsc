module Implode

import ParseTree;
import Parser;
import AST;

ObjModule cargar(loc f) = implode(#ObjModule, parsear(f));