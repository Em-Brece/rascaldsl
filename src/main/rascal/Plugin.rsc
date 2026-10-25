module Plugin

import IO;
import ParseTree;
import util::Reflective;
import util::IDEServices;
import util::LanguageServer;
import Relation;

import Syntax;

PathConfig pcfg = getProjectPathConfig(|project://rascaldsl|);
Language objLang = language(pcfg, "Objectilang", {"obj"}, "Plugin", "contribs");

set[LanguageService] contribs() = {
    parsing(parser(#start[ObjModule]))
};

void main() {
    registerLanguage(objLang);
}
