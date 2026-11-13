module Implode

import Desambiguar;
import ParseTree;
import Parser;
import AST;

Tree arbolLimpio(loc f) = desambiguar(parsear(f));

ObjModule cargar(loc f) = implode(#ObjModule, arbolLimpio(f));