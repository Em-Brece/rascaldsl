module Main

import Generator;

// Genera y muestra en consola el codigo de un archivo .ol.
void correr(loc archivo) {
    generar(archivo);
}

// Punto de entrada del runner de Rascal: genera el codigo de los ejemplos .ol.
int main(list[str] args) {
    for (str n <- ["snippet1", "snippet2", "snippet3", "snippet4"]) {
        correr(|cwd:///instance/<n>.ol|);
    }
    return 0;
}
