module Plugin

import IO;
import ParseTree;
import util::Reflective;
import util::IDEServices;
import util::LanguageServer;
import Relation;
import Message;

import Syntax;
import Checker;

PathConfig pcfg = getProjectPathConfig(|project://rascaldsl|);
Language objLang = language(pcfg, "Objectilang", {"ol"}, "Plugin", "contribs");

set[LanguageService] contribs() = {
    parsing(parser(#start[ObjModule])),
    builder(set[Message] (start[ObjModule] t) {
        return toSet(modeloDesdeArbol(t).messages);
    })
};

void main() {
    registerLanguage(objLang);
}
