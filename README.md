[![Review Assignment Due Date](https://classroom.github.com/assets/deadline-readme-button-22041afd0340ce965d47ae6ef1cefeee28c7c493a6346c4f15d667ab976d596c.svg)](https://classroom.github.com/a/sEFmt2_p)
[![Open in Visual Studio Code](https://classroom.github.com/assets/open-in-vscode-2e0aaae1b6195c2367325f4f02e2d04e9abb55f0b24a779b69b11b9e10269abc.svg)](https://classroom.github.com/online_ide?assignment_repo_id=20900494&assignment_repo_type=AssignmentRepo)

# Lab02 - Unidad Aritmético-Lógica.

En este repositorio se presenta la información correspondiente al procedimiento, desarrollo y aplicación de una Unidad Aritmético-Lógica (ALU), abarcando desde el diseño del diagrama de bloques del sistema hasta su respectiva simulación e implementación física en la FPGA [__Zybo Z7__](https://digilent.com/reference/programmable-logic/zybo-z7/reference-manual).

# Integrantes

- Daniel Sepúlveda Suárez <br> </br>
- Juan Felipe Gaitán Nocua <br> </br>
- Samuel Mahecha Arango <br> </br>
# Informe

Indice:

1. [Diseño implementado](#diseño-implementado)
2. [Simulaciones](#simulaciones)
3. [Implementación](#implementación)
4. [Conclusiones](#conclusiones)
5. [Referencias](#referencias)

## Diseño implementado

### Descripción

Una ALU (Unidad Aritmético-Lógica) es un bloque fundamental de los sistemas digitales que realiza operaciones aritméticas y lógicas sobre datos binarios. Combina funciones como suma, resta, operaciones lógicas (AND, OR, NOT, entre otras), comparaciones y desplazamientos, controladas por una señal de control que indica qué operación ejecutar. Recibe dos entradas de N bits (A y B), junto con señales de control que determinan la función a realizar, y produce una salida Y también de N bits, además de posibles señales adicionales como Cout (acarreo) o **banderas de estado** (flags), que proporcionan información adicional sobre el resultado. Por ejemplo, una bandera de **overflow** flag indica que ocurrió un desbordamiento en la operación aritmética, mientras que una bandera de **zero** señala que el resultado obtenido fue cero. [1]

Con respecto a la ALU implementada en la práctica, esta cuenta con cinco operaciones posibles: **suma**, **resta**, **multiplicación**, **desplazamiento** (a la izquierda) y la operación lógica **AND**. En la siguiente sección se profundizará en la codificación de estas operaciones según el selector de un multiplexor de 3 bits de entrada.

Las entradas de la ALU corresponden a los dos números a operar, **A** y **B**, cada uno de 4 bits, un **selector** de 3 bits para determinar la operación a realizar, un bit de **init**, que cumple la función de reset y además inicia el algoritmo de multiplicación, y un **carry in**, encargado de controlar si se realiza una suma o una resta mediante el full adder, además de un *clock* utilizado en las operaciones secuenciales de la ALU. En la sección posterior se indicará como trabajan las operaciones de forma más detallada.

En cuanto a las salidas, se tienen 7 bits destinados a presentar el **resultado** de la operación, un bit de **carry out** (empleado cuando el resultado de una suma requiere más de 4 bits), un bit de **overflow** (para indicar que el resultado de la multiplicación excede los 7 bits disponibles), y un bit para la bandera **zero**, que se activa cuando el resultado es cero. Esta bandera también se activa cuando no se selecciona ninguna operación, es decir, cuando el selector no corresponde a ninguna de las operaciones codificadas, permitiendo así indicar al usuario que debe elegir una operación válida. Finalmente, se añadió una salida **done**, que señala que la operación seleccionada por el usuario ha finalizado correctamente.


### Diagrama

 - ### Diagrama de flujo

<p align="center">
<img width="900" height="830" alt="Diagrama en blanco" src="https://github.com/user-attachments/assets/ebdd80a7-63c1-4660-8e33-8b2769341ed0" />
</p> 

El diagrama de flujo presentado en la imagen anterior muestra el funcionamiento general de la ALU. Inicialmente se cargan las entradas **A** y **B**, y se inicializan todos los demás registros, tales como **result**, **done**, **zero** y **overflow**, en cero. Luego, dependiendo de la entrada proporcionada por el selector de un multiplexor, el resultado de la **operación** (op) se almacenará en el registro **result**.
En caso de que el selector op cumpla la condición *op = 000 | 100 | 101 | 110*, el sistema permanecerá en su estado original, sin realizar ninguna operación, independientemente del valor de las entradas. A continuación, se detalla el comportamiento de cada una de las operaciones implementadas.

a. __Suma/Resta (001):__ Cuando el selector de operación cumpla *op = 001*, el valor que se almacenará en el registro result proviene directamente de la operación efectuada por el *full adder*. Dado que este módulo emplea únicamente lógica combinacional, no requiere la señal de *init*, por tanto, una vez seleccionada la operación mediante el selector, el sistema procederá inmediatamente a realizar la suma o resta sin necesidad de una señal adicional de control.

Posteriormente, se verificará el valor de *Cin*, ya que de él depende si se realiza una suma (Cin = 0) o una resta (Cin = 1). Una vez completada la operación, se comprobará si todos los bits del registro *result* son cero para activar la bandera *zero* (result = 0). Además, si durante la suma el quinto bit del resultado es 1, deberá activarse la salida *carry out*. Finalmente, al obtener el resultado correcto en su registro correspondiente, se asignará un valor alto a la señal *done* para indicar la finalización del proceso.

b. __Multiplicación (010):__ En cuanto a la multiplicación, esta se ejecuta cuando se cumple que *op = 010*. En este caso, la entrada *init* debe tener un valor lógico alto para iniciar el algoritmo de multiplicación, el cual es igual al implementado en la práctica previa [_"Multiplicador de 3 bits usando máquina de Estados"_](https://github.com/digital-electronics-UNAL/lab01-g2-e1-1/tree/main), pero extendido a 4 bits de entrada tanto en A como en B.

Durante esta operación, se activa la bandera *zero* de la misma forma descrita en la operación de suma/resta, y la bandera *overflow* se activa si el bit más significativo del registro de resultado es igual a 1 (result[7] = 1), ya que esto indica que el producto obtenido requiere un bit adicional más allá de los 7 disponibles en el registro result. Finalmente, la señal *done* se activa una vez finaliza correctamente la operación de multiplicación.

c. __Desplazamiento a la izquierda (011):__ Continuando con las operaciones, cuando *op = 011*, la función ejecutada por la ALU corresponde al desplazamiento. En este caso, la entrada de 4 bits A representa el número binario que se desea desplazar, mientras que la entrada B indica la cantidad de posiciones **hacia la izquierda** que se realizará dicho desplazamiento. Una vez completada la operación, las banderas *zero* y *done* se comportan de la misma manera que en las operaciones previamente descritas, activándose si el resultado es igual a cero o si la operación finaliza correctamente, respectivamente.

d. __Operación lógica *AND* (111):__ Finalmente, cuando el selector toma el valor *op = 111*, la ALU ejecuta la operación lógica AND bit a bit entre los 4 bits de A y los de B. Tras realizar esta operación, se verifica nuevamente la condición de la bandera *zero* en el registro de resultado y se activa la señal *done* para indicar la finalización exitosa de la operación.

- ### Tabla de operaciones 

La tabla a continuación muestra la operación realizada a través de la Unidad Aritmético-Lógica, en donde el selector corresponde a un multiplexor que brindará la salida de la operación seleccionada por el usuario:

| Número del selector | Operación realizada |
|:----------:|:----------:|
| 000, 100, 101, 110     | Nada     |
| 001    | Suma (Cin = 0) / Resta (Cin = 1) |
| 010     | Multiplicación    |
| 011     | Desplazamiento (Izquierda)     |
| 111    | Operación lógica (AND)    |

 - ### Diagrama de caja negra (RTL)

## Simulaciones 

Las simulaciones realizadas se presentan en las siguientes imagenes, en donde a través de GTKWave evidencia el comportamiento de la de las distintas operaciones de la ALU con el respectivo [testbench](scr/alu_tb.v).


a. **Simulación: Suma (Carry Out)**
<p align="center">
<img width="1635" height="305" alt="SImulacion1" src="https://github.com/user-attachments/assets/21e547e1-94cb-4cb8-9de6-f272c1f2ab58" />
</p> 

En esta primera sección del testbench, se observa que, todas las entradas se encuentran en 0 (A, B, OP, etc), además de que las salidas no cuentan con un valor definido, esto durante el primer ciclo de reloj. 

Luego, se seleccionó la operación **Suma** ($\text{C}_{\text{in}}$ = 0, OP = 001), entre A = 8 (1000) y B = 9 (1001). Se obtuvo un resultado de 10001, correspondiente al número 17 en formato binario, además de obtener salida de nivel lógico alto para **Carry**, dado que el resultado es de 5 bits y las entradas son de 4 bits, es decir que la la operación se realizó correctamente. 

Adicionalmente, las salidas DONE, OVERFLOW Y ZERO  se mantuvieron con un valor lógico de cero, ya que estas no se encuentran dispobiles al realizar la suma (ZERO se activa mientras se realiza la operación pero una vez se tiene el resultado vuelve a ser cero).

b. **Simulación: Multiplicación (Con Overflow)**
<p align="center">
<img width="1629" height="312" alt="SImulacion2" src="https://github.com/user-attachments/assets/bf417acd-6f8d-45a8-8e2d-175944c11a0f" />
</p> 

Posteriormente, se muestra la Multiplicación (OP = 010), en donde, al asignar INIT = 1, se fija un valor de 0 para las salidas de resultado, carry, zero y overflow. La multiplicación máxima que puede realizarse con las entradas de 4 bits es 15 × 15 (1111 tanto en A como en B), cuyo resultado normal sería 225 (11100001 en binario). 

Sin embargo, al tener una salida de máximo 7 bits, esta no puede ser representada correctamente por la ALU, por lo que el resultado obtenido es 11100001, junto con la activación de la bandera de Overflow. Aún así, si se toma este bit de Overflow como el MSB de la salida, esta corresponderia a 225, tal como se esperaba. 

Es importante mencionar que, una vez obtenido el resultado, también se desactivó el Zero y se activó el Done.

c. **Simulación: Suma y Resta**
<p align="center">
<img width="1473" height="313" alt="SImulacion3" src="https://github.com/user-attachments/assets/d1d36d16-007d-42f8-85ee-0dc350825ed0" />
</p> 

Luego, se verificó nuevamente el comportamiento de la **Suma** al estar precedida por la multiplicación, en donde al adicionar A = 12 (1100) con B = 13 (1101), se obteiene un 25 (11001) de forma inmediata al seleccionar la operación con OP  = 001, ya que la suma en es netamente combinacional en la ALU implementada. 

Para la **Resta**, simplemente se cambió el valor de $\text{C}_{\text{in}}$ de 0 a 1, en donde se restó 9 (1001) y 4 (0100), consiguiendo un resultado de 5 (0101), como debe ser.

d. **Simulación: Operación lógica (AND), Desplazamiento y Multiplicación (Bandera "Zero")**
<p align="center">
<img width="1644" height="309" alt="SImulacion4" src="https://github.com/user-attachments/assets/b01a274d-1df1-4de8-a631-d455abf3f205" />
</p> 

Consecutivamente, se probó el funcionamiento de la operación AND (OP = 111), en donde, al tener entradas de 1011 y 1110 para A y B, respectivamente, la salida corresponde a 1010, siendo coherente con el comportamiento esperado.

Por otro lado, para la operación Desplazamiento (OP = 011), se desplazó hacia la izquierda 1011 (A) una cantidad de 8 veces (1000 en B). Esto generó que la salida fuera cero, ya que, al tener una salida de 8 bits y desplazarse esa misma cantidad de veces, no hay posibilidad de que permanezca algún número distinto de cero. 

Esto último causó que la bandera de **ZERO** se activara, siguiendo el comportamiento requerido.

e. **Simulación: Resta (Resultado negativo) y Operación lógica (AND)**
<p align="center">
<img width="1644" height="317" alt="SImulacion5" src="https://github.com/user-attachments/assets/a4d26578-7974-4c93-ab99-59f9981a2e9e" />
</p> 

Luego, se verificó el funcionamiento de la ALU al realizar una resta cuyo resultado fuera un **número negativo** en formato decimal. En este caso, al restar 0010 (2) de 0011 (3), el resultado obtenido es 1111. Esto ocurre porque la salida se encuentra representada en complemento a dos, ya que corresponde a un número negativo.

Si no se analiza este comportamiento con detalle, podría parecer que la ALU presenta fallos en la operación de resta. Adicionalmente, se ejecutó la operación **AND** entre 1010 y 0101, obteniendo como resultado 0000 y, por tanto, activando la bandera de **Zero**, tal como se planteó en el diseño de la ALU.

f. **Simulación: Multiplicación (Sin Overflow)**
<p align="center">
<img width="1636" height="318" alt="SImulacion6" src="https://github.com/user-attachments/assets/b6f9198d-b34c-43fc-b8ad-88f471e6c23f" />
</p> 

A continuación, se verificó el comportamiento de la bandera de **Overflow** para asegurar que respondiera correctamente ante los límites de operación. Teóricamente, el valor máximo que puede representarse sin activar esta bandera es 127 (1111111). 

Por ello, se realizó la operación 12 × 10, obteniendo un resultado cercano pero inferior a 127, lo que impidió la activación de Overflow.

g. **Simulación: Multiplicación (Con Overflow) y desplazamiento**
<p align="center">
<img width="1636" height="315" alt="SImulacion7" src="https://github.com/user-attachments/assets/2c0b0f7d-80b9-4aab-a2e4-095acb9f5554" />
</p> 

Posteriormente, al efectuar la operación 13 × 10, la bandera de Overflow se activó, en contraste con el caso anterior, confirmando así que su funcionamiento es el esperado.

Finalmente, se muestra el desplazamiento del número binario 1011, una cantidad de 3 veces (0011 en B), presentando una salida de 101100. Así, se concluyó que cada una de las salidas se comporta correctamente acorde a las entradas y la operación seleccionada por el usuario.

## Implementación

<p align="center">
<img width="400" height="750" alt="Circuito" src="https://github.com/user-attachments/assets/e3aed127-1049-4b81-ae1a-627e4cc47ca8" />
</p> 

Para acceder a la explicación del [funcionamiento de la Unidad Aritmético-Lógica](https://www.youtube.com/watch?v=V0nhHHJUcUA) en YouTube, haga clic en el siguiente enlace en la miniatura del video:

<p align="center">
  <a href="https://www.youtube.com/watch?v=V0nhHHJUcUA">
    <img src="https://img.youtube.com/vi/V0nhHHJUcUA/0.jpg" alt="Ver video en YouTube">
  </a>
</p>

## Conclusiones

## Referencias
[1] D. M. Harris and S. L. Harris, Digital Design and Computer Architecture, 2nd ed., Chapter 5, Section 5.2.4, Morgan Kaufmann, 2012.
