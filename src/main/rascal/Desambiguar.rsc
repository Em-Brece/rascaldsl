module Desambiguar

import ParseTree;
import List;
import Set;

int numTextos(Tree t) = size([x | /x:appl(prod(label("stringText", _), _, _), _) := t]);

Tree escoger(set[Tree] alts) {
  for (a <- alts, appl(prod(label("sentAsig", _), _, _), _) := a) return a;
  list[Tree] l = toList(alts);
  return sort(l, bool(Tree a, Tree b) { return numTextos(a) > numTextos(b); })[0];
}

Tree desambiguar(Tree t) = bottom-up visit(t) {
  case amb(set[Tree] alts) => escoger(alts)
};
