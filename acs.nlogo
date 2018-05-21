;;
;; acs.nlogo -- Agentes Cognitivos Sociales (Social Cognitive Agents)
;;

;; NOTAS:
;;    1. (*): partes en las que es necesario hacer cambios o extensiones
;;    2. Los agentes toman todas las ofertas en la pizarra. Debe modificarse para que tomen solo una a la vez (PRIORITARIO)
;;    3. URGENTE Y VITAL: para la experimentación, en unas corridas los agentes DEBEN utilizar su TdM para modular las interacciones con otros
;;                                                 y en otras NO (estos sirven de grupo de control), de manera de poder luego comparar


;; el agente busca demandantes para las ofertas puestas en el mercado por los oferentes (en una pizarra)

;; los agentes interactúan en y se mueven por un espacio físico (cuadrícula)
;; en cada ciclo hacen algo que depende de sus propias reglas de acción, y luego se mueven uno o más paso saleatoriamiente en uno de los 8 sentidos disponibles
;; por qué: resolvemos el problema de la búsqueda de agentes para realizar transacciones
;;
;; estado 0: inicio, preparación para intearctuar en el mercado
;;
;;    -> el agente prepara su plan de inversión
;;
;;     prepara su plan de inversión
;;        concatena la lista de ofertas en la pizarra con su lista de ofertas iniciales
;;        estima la ganancia posible para cada una de las ofertas en la lista resultante
;;        ordena la lista resultante por la ganancia posible estimada
;;        toma los primeros N elementos de la lista ordenada, donde N es tal que el monto acumulado de las ganancias es el mínimo mayor a la META del agente
;;
;;     DISEÑO: el agente es creado con una META (económica) y con una lista de VALORES para ofrecer en el mercado
;;
;;    -> el agente pasa al estado 1, está listo para comenzar a negociar en el mercado
;;
;; estado 1: activo, el agente ya tiene un plan de inversión
;;
;;    -> el agente se mueve
;;    -> el agente elige un agente con el que interactuar
;;    -> el agente envia un mensaje al otro agente seleccionado
;;
;;    protocolo del agente en estado activo
;;       si su haber es una fracción menor al 25% de su meta: VENDER (PARÁMETRO: 25% límite para decidir si se vende o se compra)
;;       en caso contrario COMPRAR
;;
;;    VENDER
;;       tomar el valor de mi lista con la mayor ganancia posible estimada
;;       enviarle un mensaje al otro agente con el valor con el precio igual a su valor más la ganancia
;;          poner el par (otro agente, oferta) en la lista de ventas esperadas
;;
;;    COMPRAR
;;       tomar el primer valor en mi plan de inversión
;;       enviarle un mensaje al otro agente con el valor con el precio igual a su valor menos un 10% (PARÁMETRO, arbitrario?)
;,          poner el par (otro agente, demanda) en la lista de compras esperadas
;;
;; cuando se le acaban las ofertas en su plan de inversión Y no ha llegado a su META
;;    -> toma una oferta de la pizarra
;;
;;            problema: al inicio todos se dirigen a la pizarra, podrían eventualmente agotarla y algunos agentes no logran tomar una oferta
;;            posible solución: le damos inicialmente al agente una cantidad aleatoria de valores para transar (vender) (entre 0!! y cantidad total de agentes en el entorno?)
;;            observación: considerar 0 garantiza la posibilidad de que un agente no obtenga al inicio un valor para transar
;;            solución: los agentes son creados aleatoriamente con valores para transar, que bien pueden ser ninguno

;;     DISEÑO: el agente es creado en una POSICIÓN (parcela) x,y específica, (el entorno es una cuadrícula de tamaño arbitrario, digamos 20 x 20)

;;    -> se mueve (una cantidad aleatoria de pasos en sentido elegido también aleatoriamente)

;;            problema: cuál es la cantidad ideal de pasos?
;;            posible solución: un máximo de la mitad de la distancia entre su posición y el final del entorno en el sentido elegido

;;            problema: hay un sentido en el que "tenga sentido" que se mueva el agente, o cualquiera debería estar bien
;;            posible solución: cualquier sentido debe ser bueno

;;    -> pasa al estado 2

;;     toma una oferta de la pizarra
;;        toma la lista completa
;;        la ordena por INTERES (variable POR DEFINIR)
;;        saca la primera de la lista (deja el resto en la pizarra, ¡¡¡ en el orden original !!!)

;;     se mueve
;;        hace una lista de las parcelas alrededor suyo que están libres
;;        si n = parcelas-libre.tamaño > 0
;;           i = número aleatorio entre 1 y n
;;           pasa a parcelas-libres[i]
;;        fin si

;; estado 2: listo para vender, en busca de un comprador
;;    -> le pregunta a (uno de los 8 posible alrededor suyo)

;; puede preguntar
;;     hacerle una oferta al agente (ofrecerle en venta un valor)
;;     preguntarle si sabe de otro agente que quiera comprar un cierto valor
;;     preguntarle si sabe de otro agente que quiera vender un cierto valor
;;        pero para esto necesita tener una meta, y conocimiento del mercado que le permita elaborar un PLAN de inversión
;;        un plan de inversión es una lista de valores que le gustaría comprar
;;        PROBLEMA: cómo proveer ese plan de inversión sin tener que construir agentes planificadores???
;;        POSIBLE SOLUCIÓN:
;;           1. Darles a todos los agentes un machote de plan que ellos pueden llenar con los valores que ven en la pizarra (qué de eso les gustaría) -- DESEOS
;;              Que un agente SE ENTERE DE que otro tiene un DESEO, hace que lo incorpore en su TdM de ese otro agente
;;           2.
;; SOLUCIÖN AL PROBLEMA DEL PLAN DE INVERSIÖN:
;; Cada agente tiene una LISTA DE VALORES PARA TRANSAR
;; Cada agente tiene una META ECONÖMICA QUE CUMPLIR
;; Construye una lista que es la UNIÓN DE SUS VALORES INICIALES Y TODOS LOS VALORES EN LA PIZARRA
;;    Para cada item estima su posible ganancia
;;    Ordena la lista de mayor a menor posible ganancia
;;    Toma todos los que sean necesarios para sumar la menor ganancia mayor o igual a su META ECONÓMICA
;;    Esa lista es su plan de inversión, PERO:
;;       Las que estaban en su lista inicial que no están en el plan, son valores para la venta
;;       Las que no estaban en su lista inicial que sí están en el plan, son su lista de DESEOS (para comprar)
;;       Las que
;;
;; Los agentes son bien informados de lo que pasa, en el sentido de que CONOCEN (MUCHOS DE) LOS VALORES QUE SE TRANSAN en el mercado (los que estaban inicialmente en la pizarra)
;;    pero no conocen lo que tenían otros agentes incialmente
;;    esto crea las condiciones necesarias de incertidumbre en el mercado, pero permite a los agentes construir un plan de inversión




;; en el siguiente ciclo determinan si hay un agente vecino al que puedan preguntarle
;;    hace una lista de los agentes alrededor suyo (máximo 8)
;;    ordena la lista por la confianza en esos agentes (los conocidos tienen la propia, para los desconocidos se usa la confianza default)
;;    pregunta

;; Variables globales del modelo

globals
   [precio-promedio-total       ;; precio promedio de todos los valores transados (volumen) [relevante para que el agente correlacione
                                ;; su confianza en otro agente con lo transado con él]
    valores-comerciados-totales ;; cantidad de valores transados [para calcular el precio-promedio-total]
    confianza-promedio-total    ;; promedio de las confianzas individuales con respecto a los agentes conocidos
                                ;; [relevante como indicador de la actitud general del agente hacia los otros]
    agentes-conocidos-totales   ;; cantidad de agentes conocidos [relevante como indicador de la capacidad de socialización del agente]
    contador-ofertas            ;; contador para generar el ID de las ofertas []
    ofertas]                    ;; lista de todas las ofertas en el mercado, aún no transadas [¿corresponde siempre con el contenido
                                ;; actual de la pizarra?]

;; Clases de agentes

breed [agentes agente]          ;; agentes intermediarios

agentes-own
   [id                          ;; entero (incremental), sirve de identificador único para cada agente
    estado                      ;; entero entre 0 y 3
                                ;;    0 : en espera (no se hace nada durante un ciclo (tick)
                                ;;    1 : comprar [buscar ofertas y decidir si la compra]
                                ;;    2 : hacer ofertas [cuando los activos del agente estan por debajo de cierto limite arbitrario minimo,
                                ;;        el agente decide vender, es decir, publicar una oferta en la pizarra; habra otras
                                ;;    3 : buscar ofertas (estado inicial)
    riesgo                      ;; entero entre 0 y riesgo-maximo, representa el riesgo que el agente está dispuesto
                                ;;    a asumir. (*) Debe aumentar si las transacciones han sido beneficiosas,
                                ;;    disminuir en caso contrario
    confianza                   ;; entero entre 0 y confianza-maxima-inicial, representa la confianza inicial del
                                ;;    agente en otros agentes. Nota: la confianza en c/agente conocido se registra
                                ;;    como el segundo elemento de cada par en agentes-conocidos
    dinero                      ;; número, representa el haber del agente
    valores                     ;; entero, cantidad de valores que posee el agente
    valores-comerciados         ;; entero, cantidad de valores transados por el agente (comprados y vendidos)
    precio-promedio             ;; número, precio promedio de los valores transados por el agente
    ofertas-conocidas           ;; lista de las ofertas vigentes (e.d., aún no transadas) tomadas de la pizarra o
                                ;;    comunicadas por otros agentes
    agentes-conocidos           ;; lista de los otros agentes conocidos. Nota: cada elemento de la lista es un par:
                                ;;    el agente y su confianza
    informacion-recibida]       ;; cantidad de ofertas recibidas de otros agentes. (*) Esta cantidad debe ser
                                ;;    registrada en agentes-conocidos, como el 3er elemento de cada par.

;; OTRAS-OFERTAS     (id-oferente id-oferta precio valores)
;; AGENTES-CONOCIDOS (id confianza)

breed [pizarras pizarra]
pizarras-own
   [ofertas-conocidas]          ;; lista de las ofertas publicadas en la pizarra por los agentes. (*) Cada oferta
                                ;;    depositada debe ser acompañada del id del agente que la publicó.

;; Nota importante: No se incluyen en el modelo explicitamente los agentes oferentes o demandantes de valores. En
;;    su lugar, los agentes (todos intermediarios) "representan" a sus clientes oferentes o demandantes y son los
;;    que publican sus ofertas en la pizarra. Para dar más realismo al modelo, podría acompañarse cada oferta con
;;    un identificar del oferente o del demandante que la delegó en un agente intermediario.

;; -------

;; INICIALIZAR LA SIMULACION

;; Nota importante: Por el momento la vista del modelo no es utilizada. Esta inicializacion se realiza solo para
;;    mantener el modelo estable. La vista debe cambiar de la siguiente forma:
;;
;;       * cada vez que un agente toma una oferta, se establece un enlace (en la vista) entre este agente y el
;;         agente que publicó la oferta
;;       * si la transacción es exitosa, debería aumentar la confianza entre los agentes, lo que puede ser
;;         representado en el modelo con enlaces más o menos "fuertes" o gruesos. (*) ¿Cómo representar esto?
;;
;; (*) La pregunta de investigación tiene que ver con las condiciones bajo las cuales dos agentes deciden
;;         compartir información; es necesario entonces extender el modelo para "generar" situaciones en las que
;;         un agente toma la decisión de compartir información con otro; luego, el registro de esas situaciones
;;         puede ser "minado" para intentar dar respuesta a la pregunta de investigación.

to setup
  clear-all
  resize-world -10 10 -10 10
  ask patches [set pcolor 9]
  create-agentes cantidad-agentes [
    setxy random-xcor random-ycor
    set shape "person"
    set color 1]
  create-pizarras 1 [
    setxy 0 0
    set shape "square 2"
    set color brown]
  iniciar-datos
  reset-ticks
  file-open "acs-datos.txt"
  ask turtles [ file-write xcor file-write ycor ]
  file-close
end

;; INICIALIZAR LOS DATOS

to iniciar-datos
  ask agentes  [
    set id who
    set estado 3
    set riesgo random riesgo-maximo
    set confianza random confianza-maxima-inicial
    set dinero dinero-inicial
    set valores cantidad-valores-iniciales
    set valores-comerciados 0
    set precio-promedio 10 ;; futuro: slider
    set ofertas-conocidas []
    set agentes-conocidos []
    set informacion-recibida 0]
  ask pizarras [
    set ofertas-conocidas []]
  set valores-comerciados-totales 0
  set precio-promedio-total 0
  set agentes-conocidos-totales 0
  set confianza-promedio-total 0
  set contador-ofertas 0
  set ofertas []
end

;; ITERACION

;; oferta: (ID de la oferta, ID del oferente, cantidad de valores ofrecidos, precio)

to go

  ;Recibir nuevos valores?
  ask agentes[
    let nuevo-valor random 100000 ;; futuro: slider 0-100 mult. por 1000
    if nuevo-valor = 1 [set valores valores + 1]]
    ;; futuro: la posibilidad de que entren y salgan agentes del entorno,
    ;; y de que salgan valores del mercado

  actualizar-ofertas ;; compara ofertas conocidas con ofertas globales y elimiinas las que ya no estan en la pizarra (ya fueron transadas)

  ;Comprar, vender, intermediar, esperar
  ask agentes[

    ;Esperar
    if estado = 0
    [set estado (random 3) + 1] ;; en cada tic cambia a un nuevo estado

    ;Comprar
    if estado = 1
    [
      if length ofertas-conocidas > 0
      [
        let ofertas-externas   []
        let ofertas-comprables []
        let ofertas-aceptables []

        foreach ofertas-conocidas[ [?1] ->
          if item 0 ?1 != id[ ;; si la oferta no es mia, la pone en la lista de ofertas externas
            set ofertas-externas lput ?1 ofertas-externas
          ]
        ]

        if length ofertas-externas > 0[

          foreach ofertas-externas[ [?1] ->
            if item 2 ?1 <= dinero[ ;; si el precio de la oferta es menor a mi haber, la puedo comprar
              set ofertas-comprables lput ?1 ofertas-comprables
            ]
          ]

          if length ofertas-comprables > 0[
            foreach ofertas-comprables[ [?1] -> ;; determina si el precio unitario de cada valor en la oferta es aceptable de acuerdo con el riesgo asumido
              if ((item 2 ?1) / (item 3 ?1)) <= round (precio-promedio + ((riesgo * precio-promedio) / 100))[
                set ofertas-aceptables lput ?1 ofertas-aceptables
              ]
            ]

            ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            ;;
            ;;
            ;;
            ;;
            ;; heuristica de rankeo de las ofertas
             foreach ofertas-aceptables [ [?1] ->
                if (not member? (item 1 ?1) map first agentes-conocidos)[
                  set agentes-conocidos lput (list (item 1 ?1) confianza) agentes-conocidos
                ]
              ]
              set ofertas-aceptables sort-by [[?1 ?2] -> (item 1 (item (position (item 1 ?1) map first agentes-conocidos) agentes-conocidos) ) > ((item 1 (item (position (item 1 ?2) map first agentes-conocidos) agentes-conocidos) ))] ofertas-aceptables
            ;; heuristica de rankeo de las ofertas
            ;;
            ;;
            ;;
            ;;
            ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

            if length ofertas-aceptables > 0[
              if member? item 0 ofertas-aceptables ofertas[

                ;; aquí se realiza la compra (parte del comprador)

                let mi-oferta item 0 ofertas-aceptables
                set ofertas remove mi-oferta ofertas
                actualizar-ofertas ;; hace que todos los agentes saquen esta oferta de su lista, y la saca de la pizarra

                set dinero dinero - item 2 mi-oferta

                set precio-promedio (((precio-promedio * valores-comerciados) + (item 2 mi-oferta)) / (valores-comerciados + item 3 mi-oferta))

                set valores valores + item 3 mi-oferta
                set valores-comerciados valores-comerciados + item 3 mi-oferta

                let posicion-agente false ;; si el agente no era conocido, lo incluye, y si lo era reemplaza su par por uno nuevo con un nunevo valor de onfianza
                foreach agentes-conocidos[ [?1] ->
                  if item 0 ?1 = item 0 mi-oferta[
                    set posicion-agente position ?1  agentes-conocidos
                  ]
                ]

                ifelse posicion-agente != false[
                  set agentes-conocidos lput (list item 0 item posicion-agente agentes-conocidos item 1 item posicion-agente agentes-conocidos) agentes-conocidos
                  set agentes-conocidos remove-item posicion-agente agentes-conocidos
                ]
                ;else
                [
                  set agentes-conocidos lput (list (item 0 mi-oferta) (confianza + 1)) agentes-conocidos
                ]

                ;; parte del vendedor

                ask turtle item 0 mi-oferta[
                  set dinero dinero + item 2 mi-oferta

                  set precio-promedio (((precio-promedio * valores-comerciados) + (item 2 mi-oferta)) / (valores-comerciados + item 3 mi-oferta))

                  set valores valores + item 3 mi-oferta
                  set valores-comerciados valores-comerciados + item 3 mi-oferta

                  set posicion-agente false
                  foreach agentes-conocidos[ [?1] ->
                    if item 0 ?1 = [who] of myself[
                      set posicion-agente position ?1  agentes-conocidos
                    ]
                  ]

                  ifelse posicion-agente != false[
                    set agentes-conocidos lput (list item 0 item posicion-agente agentes-conocidos item 1 item posicion-agente agentes-conocidos) agentes-conocidos
                    set agentes-conocidos remove-item posicion-agente agentes-conocidos
                  ]
                  ;else
                  [
                    set agentes-conocidos lput (list ([who] of myself) (confianza + 1)) agentes-conocidos
                  ]

                ]

              ]
            ]
          ]
        ]
      ]
      set estado 0 ;; al terminar la transaccion, el agente vuelve al estado de espera
      ;; cambio: si el agente esta en espera y no conoce ofertas, no deberia ir a comprar
    ]

    ;Generar Oferta
    if estado = 2
    [
      ifelse valores > 0
      [
        let valores-a-vender (floor (random valores)) + 1 ;; no hace falta el floor, random genera solo enteros

        set valores valores - valores-a-vender

        let precio-unitario precio-promedio

        let caro-o-barato random 2

        ifelse caro-o-barato = 0
        [set precio-unitario round (precio-unitario + ((random riesgo * precio-promedio) / 100))]
        ;else
        [set precio-unitario round (precio-unitario - ((random riesgo * precio-promedio) / 100))]

        let nueva-oferta (list who contador-ofertas (precio-unitario * valores-a-vender) valores-a-vender )

        set contador-ofertas contador-ofertas + 1

        set ofertas lput nueva-oferta ofertas

        set ofertas-conocidas lput nueva-oferta ofertas-conocidas

        ifelse length agentes-conocidos = 0
        [ ;; si no conoce agentes, coloca la oferta en la pizarra
          ask pizarras [set ofertas-conocidas lput nueva-oferta ofertas-conocidas]
        ]
        [ ;; en caso contrario decide si en la pizarra o se lo guarda en espera que otro agente pregunte
          let pizarra-o-no random 2
          if pizarra-o-no = 0
          [
            ask pizarra cantidad-agentes [set ofertas-conocidas lput nueva-oferta ofertas-conocidas]
          ]
        ]

        ;; futuro: que el agente decida a que otro agente le comunica la oferta, en lugar de publicarla

        set estado 0

      ]
      ;else
      [set estado 0]
    ]

    ;Buscar ofertas
    if estado = 3
    [
      let pizarra-o-no random 2 ;; para seleccionar si busca en la pizarra o le pregunta a un agente conocido

      if pizarra-o-no = 1
      [ ;; decide preguntar a un agente conocido
        ifelse length agentes-conocidos > 0
        [
          ;ordenar agentes conocidos segun la confianza
          set agentes-conocidos sort-by [ [?1 ?2] -> (item 1 ?1) > (item 1 ?2) ] agentes-conocidos

          ;si el agente confía en mi
          let ofertas-agente []
          let ofertas-desconocidas []

          ;; revisar la confianza de los demas agentes en mi
          ask turtle item 0 item 0 agentes-conocidos[
            foreach agentes-conocidos[ [?1] ->
              if item 0 ?1 = [who] of myself[
                if item 1 ?1 > 70[ ;; este valor de confianza podria ser un slider
                  set ofertas-agente ofertas-conocidas ;; crea una lista con todas las ofertas
                  ;; aqui debe incluirse la heuristica del agente para decidir que ofertas compartir con otros
                  ;; futuro: filtras ofertas-agente con heuristica de cuales quiero compartir
                ]
              ]
            ]
          ]

          ifelse length ofertas-agente > 0[ ;; si me dio ofertas: aumenta la confianza, actualiza la confianza
            set agentes-conocidos lput (list item 0 item 0 agentes-conocidos (((item 1 item 0 agentes-conocidos) + 1) mod 100)) agentes-conocidos
            ;; futuro: no sumar 1 sino un valor estimado heuristicamente
            set agentes-conocidos remove-item 0 agentes-conocidos
            set informacion-recibida informacion-recibida + 1
          ]
          ;else
          [ ;; no me presento ofertas: disminuye la confianza
            set agentes-conocidos lput (list item 0 item 0 agentes-conocidos (((item 1 item 0 agentes-conocidos) - 1) mod 100)) agentes-conocidos
            ;; futuro: no restar 1 sino un valor estimado heuristicamente
            set agentes-conocidos remove-item 0 agentes-conocidos
          ]

          foreach ofertas-agente[ [?1] -> ;; para eliminar duplicados de las ofertas
          if not member? ?1 ofertas-conocidas[
            set ofertas-desconocidas lput ?1 ofertas-desconocidas
          ]

          ifelse length ofertas-desconocidas > 0[
            set ofertas-conocidas lput item 0 ofertas-desconocidas ofertas-conocidas
            ;; no tomar solo la primera, sino todas (foreach)

          ]
          ;else (no me compartieron ninguna oferta nueva)
          [set pizarra-o-no 0]
        ]

        ]
        ;else (no conocia ningun agente)
        [set pizarra-o-no 0]
      ]

      if pizarra-o-no = 0 ;; copia todas la ofertas desconocidas en la lista de conocidas de la pizarra
      [
        let ofertas-pizarra []
        ask pizarra cantidad-agentes[
          foreach ofertas-conocidas[ [?1] ->
            set ofertas-pizarra lput ?1 ofertas-pizarra
          ]
        ]
        foreach ofertas-pizarra[ [?1] ->
          if not member? ?1 ofertas-conocidas[
            set ofertas-conocidas lput ?1 ofertas-conocidas
          ]
        ]
      ]

      set estado 0
    ]
  ]

  actualizar-estadisticas

  tick

end

;; -------

to actualizar-ofertas
  ask agentes[
    foreach ofertas-conocidas[ [?1] ->
      if not member? ?1 ofertas[
        set ofertas-conocidas remove ?1 ofertas
      ]
    ]
  ]

  ask pizarras[
    foreach ofertas-conocidas[ [?1] ->
      if not member? ?1 ofertas[
        set ofertas-conocidas remove ?1 ofertas
      ]
    ]
  ]
end

;; -------

to actualizar-estadisticas
    set valores-comerciados-totales 0
    set precio-promedio-total 0

    set agentes-conocidos-totales 0
    set confianza-promedio-total 0

  ask agentes[
    set valores-comerciados-totales valores-comerciados-totales + valores-comerciados
    set precio-promedio-total precio-promedio-total + precio-promedio

    set agentes-conocidos-totales agentes-conocidos-totales + length agentes-conocidos
    foreach agentes-conocidos[ [?1] ->
      set confianza-promedio-total confianza-promedio-total + item 1 ?1
    ]
  ]

  ifelse valores-comerciados-totales = 0[
    set precio-promedio-total 0
  ]
  ;else
  [
    set precio-promedio-total precio-promedio-total / valores-comerciados-totales
  ]

  ifelse agentes-conocidos-totales = 0[
    set confianza-promedio-total 0
  ]
  ;else
  [
    set confianza-promedio-total confianza-promedio-total / agentes-conocidos-totales
  ]

;; faltó actualizar la vista

end

;; registro de datos

;; búsqueda de agentes (con fines de interacción: vender o comprar)

;; interacciones (X,Y)
;;    razón de la interacción: X -> Y / Y -> X, solicitud de info / respuesta de solicitud
;;    relación de la respuesta (sí o no da información) a
;;       confianza y riesgo del que responde
;;       confianza y riesgo del otro
;;       las TdM de ambos

;; cada agente
;;    inicia con una cantidad arbitraria (aleatoria) de valores en su poder
;;    puede en todo momento (***)
;;       poner valores en la pizarra u ofrecerlos directamente a otros agentes (?)
;;       tomar un valor de la pizarra (luego de ordenarlos de acuerdo a algún criterio (?))
;;       solicitar info a otro agente (acerca de su confianza en otros, por ejemplo)
;;          info acerca de su confianza en otros agentes
;;          info acerca de sus valores (para comprarlos)
;;          info acerca de los valores transados con otros
;;          ...

;; los agentes responden a solicitudes de otros
;;    "sí" y la información solicitada
;;       el agente que recibe la respuesta aumenta su confianza en el otro
;;    "no" (desconfianza)
;;       el agente que recibe la respuesta disminuye su confianza en el otro (¿cómo anota que el otro no confía en él?
;;    "sí" e información falsa (mentira) -- este caso no se considera, se deja para una versión futura


;; ***
;;    el agente necesita un "plan de trabajo o de acción", un protocolo a seguir
;;       opciones
;;          tomar un valor de la pizarra para buscar un comprador
;;
@#$#@#$#@
GRAPHICS-WINDOW
210
10
491
292
-1
-1
13.0
1
10
1
1
1
0
1
1
1
-10
10
-10
10
1
1
1
ticks
30.0

BUTTON
31
14
94
47
setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
111
14
175
48
go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

PLOT
500
11
700
161
Precio promedio
Tiempo
Precio
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot mean [precio-promedio] of agentes"

PLOT
500
163
700
313
Confianza promedio
Tiempo
Confianza
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot confianza-promedio-total"

SLIDER
15
122
193
155
cantidad-agentes
cantidad-agentes
0
100
20.0
1
1
NIL
HORIZONTAL

SLIDER
15
173
193
206
dinero-inicial
dinero-inicial
0
1000
200.0
10
1
NIL
HORIZONTAL

SLIDER
15
222
193
255
riesgo-maximo
riesgo-maximo
1
100
100.0
1
1
NIL
HORIZONTAL

SLIDER
15
270
193
303
confianza-maxima-inicial
confianza-maxima-inicial
1
100
100.0
1
1
NIL
HORIZONTAL

SLIDER
15
74
193
107
cantidad-valores-iniciales
cantidad-valores-iniciales
0
100
10.0
1
1
NIL
HORIZONTAL

PLOT
701
11
1009
313
Intercambio de información promedio
NIL
NIL
0.0
1.0
0.0
1.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "if ticks > 0 [plot mean [informacion-recibida] of agentes / ticks]"

@#$#@#$#@
## ¿Qué es este modelo?

Este es un modelo de interacción entre agentes cognitivos sociales, es decir, agentes autónomos con (1) capacidad de modelado de otros agentes y (2) una arquitectura de CDI (creencias, deseos e intenciones).

## ¿Cómo funciona el modelo?

El modelo presupone que los agentes son intermediarios en un mercado de bienes y servicios (que pueden ser, por ejemplo, valores en una bolsa financiera, propiedades en el mercado de bienes raíces, o conocimiento en un centro de investigaciones). Los agentes realizan operaciones de intermediación entre oferentes y demandantes de bienes y servicios. Los agentes intermediarios pueden (1) colaborar con otros, con los que comparten sus ingresos económicos por la realización de una intermediación, o (2) competir con otros, para la realización de una intermediación. El modelo registro las interacciones entre agentes intermediarios. Con la información registrada se pretende responder a la pregunta acerca de las condiciones en las que dos agentes intermediarios deciden intercambiar o compartir información.

## ¿Cómo se usa el modelo?

(how to use the model, including a description of each of the items in the Interface tab)

## Observaciones y comentarios

(suggested things for the user to notice while running the model)

## Sugerencias

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## ¿Cómo extender el modelo?

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## Características de NetLogo

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## Modelos similares

(models in the NetLogo Models Library and elsewhere which are of related interest)

## Créditos y referencias

1. La primera versión de este modelo fue desarrollada por los estudiantes William Soto y Giancarlo Longhi, de la Escuela de Ciencias de la Computación e Informática, como parte de su proyecto del curso CI-1441 Paradigmas computacionales, en el segundo semestre de 2017. Un resumen de su trabajo se presente en su informa del curso: Longhi, G. y Soto, W. (2017). Agentes cognitivos sociales. Informe del proyecto del curso, II semestre de 2017, Prof. Dr. Alvaro de la Ossa O. Noviembre de 2016.

2.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

person business
false
0
Rectangle -1 true false 120 90 180 180
Polygon -13345367 true false 135 90 150 105 135 180 150 195 165 180 150 105 165 90
Polygon -7500403 true true 120 90 105 90 60 195 90 210 116 154 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 183 153 210 210 240 195 195 90 180 90 150 165
Circle -7500403 true true 110 5 80
Rectangle -7500403 true true 127 76 172 91
Line -16777216 false 172 90 161 94
Line -16777216 false 128 90 139 94
Polygon -13345367 true false 195 225 195 300 270 270 270 195
Rectangle -13791810 true false 180 225 195 300
Polygon -14835848 true false 180 226 195 226 270 196 255 196
Polygon -13345367 true false 209 202 209 216 244 202 243 188
Line -16777216 false 180 90 150 165
Line -16777216 false 120 90 150 165

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240
@#$#@#$#@
NetLogo 6.0.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
