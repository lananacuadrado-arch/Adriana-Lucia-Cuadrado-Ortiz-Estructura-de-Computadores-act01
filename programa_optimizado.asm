# Laboratorio: Estructura de Computadores
# Actividad: Optimizacion de Pipeline en Procesadores MIPS
# Objetivo: Calcular Y[i] = A * X[i] + B, eliminando el stall Load-Use
#           mediante reordenacion de instrucciones (instruction scheduling).

.data
    vector_x: .word 1, 2, 3, 4, 5, 6, 7, 8
    vector_y: .space 32          # Espacio para 8 enteros (8 * 4 bytes)
    const_a:  .word 3            # Constate A = 3
    const_b:  .word 5            # Constante B = 5
    tamano:   .word 8            # Tamaño del vector = 8

.text
.globl main

main:
    # --- Inicializacion ---
    la $s0, vector_x      # Direccion base de X
    la $s1, vector_y      # Direccion base de Y
    lw $t0, const_a       # Cargar constante A
    lw $t1, const_b       # Cargar constante B
    lw $t2, tamano        # Cargar el tamano del vector
    li $t3, 0             # Indice i = 0

loop:
    # --- Condicion de salida ---
    beq $t3, $t2, fin     # Si i == tamano, salir del bucle

    # --- Calculo de direccion de memoria ---
    sll $t4, $t3, 2       # Desplazamiento: t4 = i * 4
    addu $t5, $s0, $t4    # t5 = direccion de X[i]

    # --- Carga de dato ---
    lw $t6, 0($t5)        # Leer X[i]

    # --- Instrucciones independientes reubicadas ---
    # Ninguna de estas dos usa $t6, por lo que "rellenan" el hueco
    # que antes generaba la burbuja de Load-Use frente a 'mul'.
    addu $t9, $s1, $t4    # t9 = direccion de Y[i]  (antes iba despues del mul)
    addi $t3, $t3, 1      # i = i + 1               (antes iba al final del loop)

    # --- Operacion aritmetica ---
    # $t6 ya esta disponible: no hay stall de Load-Use aqui.
    mul $t7, $t6, $t0     # t7 = X[i] * A
    addu $t8, $t7, $t1    # t8 = t7 + B  (dependencia EX->EX, resuelta por forwarding)

    # --- Almacenamiento de resultado ---
    sw $t8, 0($t9)        # Guardar resultado en Y[i]

    # --- Salto al inicio del bucle ---
    j loop                # Volver al inicio del bucle

fin:
    # --- Finalizacion del programa ---
    li $v0, 10            # Syscall para terminar ejecucion
    syscall               # Finalizar la ejecución del programa
