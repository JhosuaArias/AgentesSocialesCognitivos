globals
[
  id-ofertas ;; Ids para las ofertas existentes
  id-demandas ;; Ids para las demandas existentes
]

;; Declarando los diferentes tipos de agentes que existen
breed[intermediarios intermediario]

breed[pizarras pizarra]

breed[oferentes oferente]

breed[demandantes demandante]


;; Declarando las variables de cada agente
intermediarios-own
[
  id ;; identificacion del agente
  estado ;; buscando = 0 , negociando = 1, pidiendo ayuda = 2.
  haber-intermediario ;; riqueza del agente
  ofertas-intermediario ;;lista de ofertas tomadas de la pizarra
  demandas-intermediario ;; lista de demandas tomadas de la pizarra
  conocidos ;; lista de agentes conocidos con informacion acerca de ellos ;;[id,confianza,[[fecha,tipo,precio,resultado]...]]
  desconocidos ;; lista de agentes desconocidos para meter en la lista de conocidos alguno aleatorio

  subestado ;; Subestado cuando un intermediario está buscando ayuda;; primera vez = 0, conocidos = 1, desconocidos = 2
  indice-conocidos ;; Llevar un conteo de los conocidos a los cuales preguntarles si ocupan ayuda.
  ganas-negociar ;; es 1 si quiere negociar, 0 si no quiere negociar
]

pizarras-own
[
  esAccesible ;; no accesible = false, accesible = true
  ofertas-pizarra
  demandas-pizarra
]

oferentes-own
[
  haber-oferente ;; riqueza del oferente
  ofertas-oferente ;;lista de ofertas creadas
]

demandantes-own
[
  haber-demandante ;; riqueza del demandante
  demandas-demandante ;; lista de demandas creadas
]

;; Métodos default de cada iteración
to setup
  clear-all
  set-mundo
  set-agentes
  reset-ticks
end

to go

  if-else esMercadoAbierto [
    ;; Por el momento nada
    ;;Voy a usar esto para pruebas
    iteracion-prueba
  ]
  [
    let todas-ofertas [ofertas-oferente] of oferentes
    let todas-demandas [demandas-demandante] of demandantes

    set todas-ofertas remove [] todas-ofertas
    set todas-demandas remove[] todas-demandas

    if not((empty? todas-ofertas) and (empty? todas-demandas)) [

      iteracion-oferente-mercado-cerrado
      iteracion-demandante-mercado-cerrado
      iteracion-intermediario-mercado-cerrado

      ;imprimir-ofertas-oferentes
      ;imprimir-demandas-demandantes
      imprimir-pizarra

      tick
    ]
  ]
end


;; Definiendo los agentes con sus respectivas variables
to set-agentes
  set-pizarra
  set-oferente
  set-demandante
  set-intermediarios
end

to set-intermediarios

  create-intermediarios cantidad-intermediarios
  let haber-maximo max [haber-oferente] of oferentes

  ask intermediarios [
    set id who
    set estado 0
    ;; Los intermediarios tendrán un número aleatorio entre 0 y el porcentaje del haber maximo del oferente
    set haber-intermediario random (int haber-maximo * (haber-maximo-intermediarios / 100.0) )
    print (word "Intermediario " who ": " haber-intermediario " CRC")
    set ofertas-intermediario []
    set demandas-intermediario []
    set conocidos []
    set desconocidos [who] of intermediarios ;; Se insertan todos los ids de los intermediarios desconocidos
    set desconocidos remove id desconocidos ;; Se quita el id del pripio agente (Yo me conozco a mi mismo)
    print (word "Intermediario: " id ": " desconocidos)
  ]
end

to set-oferente
  set id-ofertas 0
  create-oferentes numero-oferentes ;; Un solo oferente, esto puede ser cambiado con slider en un futuro
  ask oferentes [
    set haber-oferente random haber-maximo-oferentes-demandantes * 1000000
    print (word "Oferente " who ": " haber-oferente " CRC")
    set ofertas-oferente []

    if-else esMercadoAbierto [
     ;; Por el momento nada
    ]
    [;;Esta es la version del mercado cerrado
     set-todas-ofertas ;id, precio, comision, fecha-creacion, fecha-publicacion, validez
    ]
  ]
end
to set-demandante
  set id-demandas 0
  create-demandantes numero-demandantes  ;; Un solo demandante, esto puede ser cambiado con slider en un futuro
  ask demandantes [
    set haber-demandante random haber-maximo-oferentes-demandantes * 1000000
    print (word "Demandante " who ": " haber-demandante " CRC")
    set demandas-demandante []

    if-else esMercadoAbierto [
     ;; Por el momento nada
    ]
    [
       set-todas-demandas ;id, rango-precios, fecha-creacion, fecha-publicacion, validez
    ]
  ]
end
to set-pizarra
  create-pizarras 1 ;; Una sola pizarra
  ask pizarras [
    set esAccesible true
    set ofertas-pizarra []
    set demandas-pizarra []
  ]
end

to set-todas-ofertas
  let indice 0
  while [indice < numero-valores-a-crear] [
    let oferta-temporal []
     ;; id, precio, comision, fecha-creacion, fecha-publicacion, validez
    set oferta-temporal lput id-ofertas oferta-temporal ;;Pone el id de la oferta
    set oferta-temporal lput random 101 oferta-temporal ;; Pone el precio de la oferta
    set oferta-temporal lput random 4 oferta-temporal ;; Pone la comision de la oferta
    set oferta-temporal lput 1 oferta-temporal ;; Pone la fecha de creacion de la oferta
    set oferta-temporal lput random 10 oferta-temporal ;; Pone la validez, un numero random entre 0 - 9
    set ofertas-oferente lput oferta-temporal ofertas-oferente ;; agrega la oferta a la lista de ofertas
    set id-ofertas id-ofertas + 1 ;;Aumenta el id general de las ofertas

    set indice  ( indice + 1 )
  ]
  print word "Todas las ofertas: " ofertas-oferente
end
to set-todas-demandas
  let indice 0
  while [indice < numero-valores-a-crear] [
    let demanda-temporal [];;Vacia el espacio temporal de ofertas
     ;; id, precio-menor, precio-mayor, fecha-creacion, fecha-publicacion, validez
    set demanda-temporal lput id-demandas demanda-temporal;;Pone el id de la demanda
    set demanda-temporal lput random 99 demanda-temporal ;; Pone el precio menor de la demanda
    set demanda-temporal lput (1 + (random (99 - item 1 demanda-temporal) + item 1 demanda-temporal)) demanda-temporal ;; Pone el precio mayor de la demanda
    set demanda-temporal lput 1 demanda-temporal ;; Pone la fecha de creacion de la demanda
    set demanda-temporal lput random 10 demanda-temporal ;; Pone la validez, un numero random entre 0 - 9
    set demandas-demandante lput demanda-temporal demandas-demandante ;; agrega la demanda a la lista de demandas
    set id-ofertas id-ofertas + 1 ;;Aumenta el id general de las ofertas
    set indice  ( indice + 1 )
  ]
  print word "Todas las demandas: " demandas-demandante
end


to set-mundo ;; Método en caso de que se quiera implementar la parte gráfica de la simulación

end
;;Métodos para publicar ofertas y demandas

to publicar-ofertas

    let cantidad-a-publicar random publicaciones-por-tick ;; Se crea un número aleatorio de la cantidad de ofertas a publicar
    let indice 0

    while [(indice < cantidad-a-publicar) and (not empty? ofertas-oferente)] [
      let indice-oferta random (length ofertas-oferente) ;; Se define un número aleatorio que será la oferta a publicar

      let oferta-temporal item indice-oferta ofertas-oferente

      ask pizarras [
        set ofertas-pizarra lput oferta-temporal ofertas-pizarra
      ]

      set ofertas-oferente remove-item indice-oferta ofertas-oferente
      set indice indice + 1
    ]
end

to publicar-demandas

   let cantidad-a-publicar random publicaciones-por-tick ;; Se crea un número aleatorio de la cantidad de ofertas a publicar
   let indice 0

   while [(indice < cantidad-a-publicar) and (not empty? demandas-demandante)] [
      let indice-demanda random (length demandas-demandante) ;; Se define un número aleatorio que será la demanda a publicar

      let demanda-temporal item indice-demanda demandas-demandante

      ask pizarras [
        set demandas-pizarra lput demanda-temporal demandas-pizarra
      ]

      set demandas-demandante remove-item indice-demanda demandas-demandante
      set indice indice + 1
  ]
end

;;Métodos de las acciones que realizarán los agentes cada iteración

to iteracion-oferente-mercado-cerrado
  ask oferentes [
    publicar-ofertas
  ]
end

to iteracion-demandante-mercado-cerrado
  ask demandantes [
    publicar-demandas
  ]
end

to iteracion-intermediario-mercado-cerrado
  ask intermediarios [
    decidir-si-negociar
    if-else haber-intermediario <= 0 [die] [
      if-else estado = 0  [intermediario-buscar-mercado-cerrado] [
        if-else estado = 1  [intermediario-negociar-mercado-cerrado][
          if estado = 2  [intermediario-pedir-ayuda-mercado-cerrado]
        ]
      ]
    ]
  ]
end

;;Métodos de apoyo para las iteraciones
;;To-do
to intermediario-buscar-mercado-cerrado ;;Estado 0
  print (word "Intermediario " who " entro al estado 0")

  let idPizarra one-of [who] of pizarras
  let estaAccesible [esAccesible] of pizarra idPizarra

  if  estaAccesible [

    ask pizarra idPizarra [set esAccesible false] ;; Reservamos la pizarra solo para un intermediario
    ;;Se adquieren las ofertas y demandas de la pizarra

    let lista-ofertas [ofertas-pizarra] of pizarra idPizarra
    let lista-demandas [demandas-pizarra] of pizarra idPizarra
    ;;Se ordenan según una heuristica escogida

    if not(empty? lista-ofertas) [
      set lista-ofertas ordenar-ofertas-precio-comision lista-ofertas
      ;;Se escoge una oferta
      let oferta-escogida item 0 lista-ofertas
      ;;Se borra de la pizarra
      ask pizarra idPizarra [
        set ofertas-pizarra remove oferta-escogida ofertas-pizarra
        ;;set demandas-pizarra remove-item demanda-escogida ofertas-pizarra
      ]
      ;;Se inserta la nueva oferta en todas mis ofertas
      set ofertas-intermediario lput oferta-escogida ofertas-intermediario
    ]
    ;;To-do
    if not(empty? lista-demandas) [
      set lista-demandas ordenar-demandas-precios lista-demandas
      ;;Se escoge una demanda
      ;;let demanda-escogida item 0 lista-demandas
      ;;Se borra de la pizarra
    ]

    ;;Si las listas no son vacías entonces pasamos a otro estado, si no, seguimos buscando
    if (not((empty? ofertas-intermediario)and(empty? demandas-intermediario)))[
      if-else (buscar-coincidencias-ofertas-demandas ofertas-intermediario demandas-intermediario) [
        ;;Si hay coincidencias se pasa a estado de negociando
        set estado 1
      ]
      [
        ;; Si no hay coincidencias se pasa a estado de pidiendo ayuda
        set estado 2
      ]
    ]

    ask pizarra idPizarra [set esAccesible true] ;; Desbloqueamos la pizarra para que cualquier otro pueda agarrarla
  ]
end

;;To-do
to intermediario-negociar-mercado-cerrado ;;Estado 1

  print (word "Intermediario " who " entro al estado 1")

  ;;Se busca una coincidencia entre oferta y demanda
  if (not((empty? ofertas-intermediario)and(empty? demandas-intermediario)))[
    if-else (buscar-coincidencias-ofertas-demandas ofertas-intermediario demandas-intermediario) [
      let oferta-demanda (devolver-ofertas-demandas-con-concidencia ofertas-intermediario demandas-intermediario)
      let precio-oferta item 1 (item 0 oferta-demanda)
      let comision item 2 (item 0 oferta-demanda)
      ;;Se actualiza el haber del intermediario (Haber+(Precio_Oferta*Comision))
      set haber-intermediario haber-intermediario + (precio-oferta * comision)
      ;;Se actualiza el haber del oferente (Haber+(Precio_Oferta -(Precio_Oferta*Comision)))
      ask oferentes[
        set haber-oferente haber-oferente + ( precio-oferta - (precio-oferta * comision))
      ]
      ;; Se actualiza el haber del demandante (Haber-Precio_Oferta)
      ask demandantes[
        set haber-demandante haber-demandante - precio-oferta
      ]
      ;;Se cambia el estado a buscando

      set estado 0
    ]
    [
      ;; Si no hay coincidencias se pasa a estado de pidiendo ayuda
      set estado 2
    ]
  ]
end

;;To-do
to intermediario-pedir-ayuda-mercado-cerrado ;;Estado 2
  ;;Esto tiene varios subestados, se tiene que hacer en varios ticks
  print (word "Intermediario " who " entro al estado 2")
  let respuesta-ayuda false
  if subestado = 0[ ;; Primera vez que el intermediario entra en este estado, se ordenará la lista de conocidos según una heurística y se le preguntará al primero si quiere hacer un trato
    ordenar-lista-conocidos
    set subestado 1
  ]
  if subestado = 1[ ;; Si algún conocido no estaba disponible para hacer un trato o lo declinó, se le pregunta al siguiente en la lista
    set respuesta-ayuda preguntar-intermediario-conocido
  ]
  if subestado = 2[ ;; Si ya no tengo más conocidos a los cuales preguntarle, le preguntaré a un desconocido...
    set respuesta-ayuda preguntar-intermediario-desconocido
  ]

end

;;métodos para Subestados del estado Pidiendo ayuda

to ordenar-lista-conocidos
  if not(empty? conocidos) [
    set conocidos sort-with-dsc[l -> item 1 l] conocidos
  ]
  set subestado 1
  set indice-conocidos 0

end

to-report preguntar-intermediario-conocido
  let respuesta false
  if-else(indice-conocidos < (length conocidos))[
    let conocido-temporal item indice-conocidos conocidos ;;saca el siguiente conocido de la lista
    set indice-conocidos (indice-conocidos + 1) ;;aumenta el indice de la lista de conocidos
    ask intermediario (item 0 conocido-temporal) [
      if estado = 2 [
        if ganas-negociar = 1 [
          set respuesta true
        ]
      ]
    ]
  ][
    set subestado 2
  ]
  report respuesta
end

to-report preguntar-intermediario-desconocido
  let se-conocieron false
  let respuesta false
  if-else not(empty? desconocidos) [
    let conocido-intermedio item (random length desconocidos) desconocidos
    ask intermediario conocido-intermedio[
      if estado = 2 [
        set se-conocieron true
        if ganas-negociar = 1 [
          set respuesta true
        ]
      ]
    ]
    if se-conocieron [
      set desconocidos remove conocido-intermedio desconocidos
      set conocidos lput conocido-intermedio conocidos;;Pone el id de la demanda
    ]
  ][set estado 0]
  report respuesta
end

;;Métodos heurísticos para toma de decisiones

to-report ordenar-ofertas-precio-comision [lst]
  ;;Para cada oferta en la lista creo una nueva solo con us id y precio*comision
  let ofertas-precio-comision []
  let oferta-temporal []

  let i 0
  let lista-size length lst

  while [ i < lista-size] [

    ;; Poner el id de la oferta
    set oferta-temporal lput ( item 0 (item i lst) ) oferta-temporal
    ;; Calcular la ganancia Precio * Comision
    let ganancia ( ( item 1 (item i lst) )*( item 2 (item i lst) ) / 100 )
    ;;Poner la ganancia
    set oferta-temporal lput ganancia oferta-temporal
    ;;Poner el indice donde se encontraba dicha lista, esto para eliminarla más adelante
    set oferta-temporal lput i oferta-temporal
    ;; Poner en la lista de ofertas
    set ofertas-precio-comision lput oferta-temporal ofertas-precio-comision

    set oferta-temporal []

    set i (i + 1)
  ]
  set ofertas-precio-comision sort-with-dsc[l -> item 1 l] ofertas-precio-comision

  let ofertas-ordenadas []
  set i 0

  while [ i < lista-size] [

    set ofertas-ordenadas lput ( item ( item  2 (item i  ofertas-precio-comision ) ) lst ) ofertas-ordenadas

    set i (i + 1)
  ]


  report ofertas-ordenadas
end

to-report ordenar-demandas-precios [lst]
  report []
end

to-report buscar-coincidencias-ofertas-demandas [ ofertas demandas ]

  let hayCoincidencia false

  if not( (empty? ofertas) or (empty? demandas) ) [
    let i 0
    let j 0

    let ofertas-size length ofertas
    let demandas-size length demandas

    let repetir true

    while [ (i < ofertas-size ) or repetir] [
      while[ j < demandas-size or repetir] [

        let precio-oferta item 1 (item i ofertas)
        let menor-precio-demanda item 1 (item i demandas)
        let mayor-precio-demanda item 2 (item i demandas)

        if ( (precio-oferta > menor-precio-demanda) and (precio-oferta < mayor-precio-demanda) ) [
          set hayCoincidencia true
          set repetir false
        ]

        set j (j + 1)
      ]
      set i (i + 1)
    ]
  ]
  report hayCoincidencia
end

to-report devolver-ofertas-demandas-con-concidencia [ ofertas demandas ]

  let hayCoincidencia false
  let oferta-demanda []

  if not( (empty? ofertas) or (empty? demandas) ) [
    let i 0
    let j 0

    let ofertas-size length ofertas
    let demandas-size length demandas

    while [ (i < ofertas-size ) or not(hayCoincidencia)] [
      while[ j < demandas-size or not(hayCoincidencia)] [

        let precio-oferta item 1 (item i ofertas)
        let menor-precio-demanda item 1 (item j demandas)
        let mayor-precio-demanda item 2 (item j demandas)

        if ( (precio-oferta > menor-precio-demanda) and (precio-oferta < mayor-precio-demanda) ) [
          ;;Tomo la oferta escogida
          let oferta-escogida item i ofertas
          ;; Se quita la oferta de mi lista
          set ofertas remove oferta-escogida ofertas
          ;;Guardo la oferta para devolverla en la tupla
          set oferta-demanda lput oferta-escogida oferta-demanda
          ;; Tomo la demanda escogida
          let demanda-escogida item i demandas
          ;;Quito la demanda de la lista
          set demandas remove oferta-escogida demandas
          ;;Guardo la demanda para devolverla en la tupla
          set oferta-demanda lput demanda-escogida oferta-demanda
          ;;Me salgo del while
          set hayCoincidencia true
        ]
        set j (j + 1)
      ]
      set i (i + 1)
    ]
  ]
  report oferta-demanda
end

;; Metodo que se realiza cada tick para definir si el intermediario quiere negociar
;; ganas-negociar es 1 si quiere negociar, 0 si no quiere negociar
to decidir-si-negociar
  let numero-random random 101
  if-else (numero-random < probabilidad-negociar)[set ganas-negociar 1][set ganas-negociar 0]
end

;;Métodos para imprimir datos

to imprimir-pizarra
  ask pizarras [
    print word "Ofertas: " ofertas-pizarra
    print word "Demandas: " demandas-pizarra
  ]
end

to imprimir-ofertas-oferentes
  ask oferentes [
    print word "Oferente: " who
    print word "Ofertas: " ofertas-oferente
  ]
end

to imprimir-demandas-demandantes
  ask demandantes [
    print word "Demandante: " who
    print word "Demandas: " demandas-demandante
  ]
end

;; Métodos de ordenamiento de lista con una llave

to-report sort-with-asc [ key lst ] ;; Ordena una lista según una llave, se utiliza de esta forma sort-with [ l -> item n l ] my-list
  report sort-by [ [a b] -> (runresult key a) < (runresult key b) ] lst
end

to-report sort-with-dsc [ key lst ] ;; Ordena una lista según una llave, se utiliza de esta forma sort-with [ l -> item n l ] my-list
  report sort-by [ [a b] -> (runresult key a) > (runresult key b) ] lst
end

to iteracion-prueba
  i
end
@#$#@#$#@
GRAPHICS-WINDOW
410
62
719
372
-1
-1
9.121212121212123
1
10
1
1
1
0
1
1
1
-16
16
-16
16
1
1
1
ticks
30.0

SLIDER
29
76
208
109
cantidad-intermediarios
cantidad-intermediarios
0
100
5.0
1
1
NIL
HORIZONTAL

BUTTON
34
25
99
58
SetUp
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
133
27
196
60
Go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
29
115
308
148
haber-maximo-oferentes-demandantes
haber-maximo-oferentes-demandantes
0
25
25.0
1
1
M
HORIZONTAL

SWITCH
28
290
208
323
esMercadoAbierto
esMercadoAbierto
0
1
-1000

SLIDER
28
160
264
193
haber-maximo-intermediarios
haber-maximo-intermediarios
0
100
1.0
1
1
%
HORIZONTAL

BUTTON
223
28
300
61
go-once
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
28
207
253
240
numero-valores-a-crear
numero-valores-a-crear
100
10000
100.0
1
1
valores
HORIZONTAL

SLIDER
28
248
200
281
publicaciones-por-tick
publicaciones-por-tick
1
100
7.0
1
1
NIL
HORIZONTAL

SLIDER
27
335
199
368
numero-oferentes
numero-oferentes
1
10
1.0
1
1
NIL
HORIZONTAL

SLIDER
26
375
198
408
numero-demandantes
numero-demandantes
1
10
1.0
1
1
NIL
HORIZONTAL

SLIDER
795
164
967
197
probabilidad-negociar
probabilidad-negociar
0
100
50.0
1
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0.3
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