# code-review-demo

Repo de prueba para comparar cómo distintas herramientas de code review
automatizado analizan el mismo PR.

## Escenario

`lib/order_discount_calculator.rb` calcula el total de una orden aplicando
códigos de descuento. La rama `main` tiene la versión limpia. La rama
`feature/bulk-discount-codes` simula un PR que agrega soporte para descuentos
"bulk" (por volumen) e introduce, a propósito, problemas típicos que un
reviewer humano apurado podría dejar pasar.

## Cómo correr la demo

```
git checkout feature/bulk-discount-codes
```

Corré la herramienta de code review que quieras comparar (bot de PR,
extensión de editor, o CLI) apuntando al diff `main..feature/bulk-discount-codes`.

## Checklist de referencia

Lista para comparar contra lo que cada herramienta efectivamente encuentra:

1. **Bug crítico de visibilidad**: los métodos de aplicación de descuento
   quedaron declarados como privados, pero el despacho dinámico solo puede
   invocar métodos públicos — la función entera rompe en cualquier camino
   feliz, no es un edge case.
2. **Bug aritmético**: la fórmula del nuevo descuento "bulk" multiplica por
   el valor equivocado — el resultado no tiene ninguna semántica de
   descuento válida.
3. División por cero / nil no controlada en una cantidad de items.
4. **Manejo de errores perdido** (Chesterton's Fence): el `case/when`
   original tenía un `raise` explícito y descriptivo para tipos de
   descuento desconocidos; el refactor lo elimina sin que quede claro por
   qué estaba ahí, dejando un error genérico y una clase de excepción
   muerta.
5. **Complejidad injustificada**: todo el mecanismo de despacho dinámico fue
   sobre-ingeniería para agregar lo que solo requería una rama nueva en un
   `case/when` explícito — y esa complejidad extra fue la que introdujo los
   bugs #1 y #2.
6. **Costo de eficiencia**: el despacho dinámico asigna un string y resuelve
   el método por nombre en cada iteración, evitable con el `case/when`
   original.
7. Un nombre de variable que no coincide con lo que la fórmula realmente
   hace, lo que esconde el bug aritmético a simple vista.
