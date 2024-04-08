def cambiar_palabra_impares(texto, palabra_original, palabra_nueva):
    palabras = texto.split('"')
    contar_ocurrencias = 0

    for i, palabra in enumerate(palabras):
        if palabra == palabra_original:
            contar_ocurrencias += 1

            # Cambiar la palabra si el número de ocurrencias es impar
            if contar_ocurrencias % 2 != 0:
                palabras[i] = palabra_nueva

    return '"'.join(palabras)

def main():
    archivo_entrada = 'AMS_out.txt'
    palabra_original = 'content'
    palabra_nueva = 'reference'
    
    with open(archivo_entrada, 'r') as archivo:
        contenido = archivo.read()

    contenido_modificado = cambiar_palabra_impares(contenido, palabra_original, palabra_nueva)

    archivo_salida = 'records.json'
    with open(archivo_salida, 'w') as archivo:
        archivo.write(contenido_modificado)

if __name__ == "__main__":
    main()

