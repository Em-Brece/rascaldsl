module Parser

import ParseTree;
import Syntax;

Tree parsear(loc f) = parse(#start[ObjModule], f, allowAmbiguity=true).top;