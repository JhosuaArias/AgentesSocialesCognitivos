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
  id-intermediario ;; identificacion del agente
  estado ;; buscando = 0 , negociando = 1, pidiendo ayuda = 2.
  haber-intermediario ;; riqueza del agente
  ofertas-intermediario ;;lista de ofertas tomadas de la pizarra
  demandas-intermediario ;; lista de demandas tomadas de la pizarra
  conocidos ;; lista de agentes conocidos con informacion acerca de ellos ;;[id,confianza,[[fecha,tipo,precio,resultado]...]]
  desconocidos ;; lista de agentes desconocidos para meter en la lista de conocidos alguno aleatorio

  subestado ;; Subestado cuando un intermediario está buscando ayuda;; primera vez = 0, conocidos = 1, desconocidos = 2
  indice-conocidos ;; Llevar un conteo de los conocidos a los cuales preguntarles si ocupan ayuda.
]

pizarras-own
[
  esAccesible ;; no accesible = false, accesible = true
  ofertas-pizarra
  demandas-pizarra
]

oferentes-own
[
  id-oferente ;; id del oferente
  haber-oferente ;; riqueza del oferente
  ofertas-oferente ;;lista de ofertas creadas
]

demandantes-own
[
  id-demandante ;; id del demandante
  haber-demandante ;; riqueza del demandante
  demandas-demandante ;; lista de demandas creadas
]

;; Métodos default de cada simulación
to setup
  clear-all
  set-mundo
  set-agentes
  reset-ticks
end

to go

  if-else esMercadoAbierto [
    ;; Por el momento nada
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

      imprimir-tick
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
    set id-intermediario who
    set estado 0
    ;; Los intermediarios tendrán un número aleatorio entre 0 y el porcentaje del haber maximo del oferente
    set haber-intermediario random (int haber-maximo * (haber-maximo-intermediarios / 100.0) )
    print (word "Intermediario " who ": " haber-intermediario " CRC")
    set ofertas-intermediario []
    set demandas-intermediario []
    set conocidos []
    set desconocidos [who] of intermediarios ;; Se insertan todos los ids de los intermediarios desconocidos
    set desconocidos remove id-intermediario desconocidos ;; Se quita el id del pripio agente (Yo me conozco a mi mismo)
  ]
end

to set-oferente
  set id-ofertas 0
  create-oferentes numero-oferentes
  ask oferentes [
    set id-oferente who
    set haber-oferente random haber-maximo-oferentes-demandantes * 1000000
    print (word "Oferente " who ": " haber-oferente " CRC")
    set ofertas-oferente []

    if-else esMercadoAbierto [
     ;; Por el momento nada
    ]
    [;;Esta es la version del mercado cerrado
     set-todas-ofertas ;id, precio, comision, fecha-creacion, fecha-publicacion, validez, id oferente
    ]
  ]
end
to set-demandante
  set id-demandas 0
  create-demandantes numero-demandantes  ;; Un solo demandante, esto puede ser cambiado con slider en un futuro
  ask demandantes [
    set id-demandante who
    set haber-demandante random haber-maximo-oferentes-demandantes * 1000000
    print (word "Demandante " who ": " haber-demandante " CRC")
    set demandas-demandante []

    if-else esMercadoAbierto [
     ;; Por el momento nada
    ]
    [
       set-todas-demandas ;id, rango-precios, fecha-creacion, fecha-publicacion, validez, id demandante
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

;;Metodo para crear nuevas ofertas
to set-todas-ofertas
  let indice 0
  while [indice < numero-valores-a-crear] [
    let oferta-temporal []
     ;; id, precio, comision, fecha-creacion, fecha-publicacion, validez, id del oferente
    set oferta-temporal lput id-ofertas oferta-temporal ;;Pone el id de la oferta
    set oferta-temporal lput ((random 101) * 100000) oferta-temporal ;; Pone el precio de la oferta
    set oferta-temporal lput ((random 3) + 1) oferta-temporal ;; Pone la comision de la oferta
    set oferta-temporal lput 1 oferta-temporal ;; Pone la fecha de creacion de la oferta
    set oferta-temporal lput random 10 oferta-temporal ;; Pone la validez, un numero random entre 0 - 9
    set oferta-temporal lput id-oferente oferta-temporal ;; El id del oferente que lo crea
    set ofertas-oferente lput oferta-temporal ofertas-oferente ;; agrega la oferta a la lista de ofertas
    set id-ofertas id-ofertas + 1 ;;Aumenta el id general de las ofertas

    set indice  ( indice + 1 )
  ]
  print word "Todas las ofertas: " ofertas-oferente
end

;;Metodo para crear nuevas demandas
to set-todas-demandas
  let indice 0
  while [indice < numero-valores-a-crear] [
    let demanda-temporal [];;Vacia el espacio temporal de ofertas
     ;; id, precio-menor, precio-mayor, fecha-creacion, fecha-publicacion, validez, id del demandante
    set demanda-temporal lput id-demandas demanda-temporal;;Pone el id de la demanda
    set demanda-temporal lput ((random 99) * 100000 ) demanda-temporal ;; Pone el precio menor de la demanda
    set demanda-temporal lput (((random (99) * 100000 ) + item 1 demanda-temporal)) demanda-temporal ;; Pone el precio mayor de la demanda
    set demanda-temporal lput 1 demanda-temporal ;; Pone la fecha de creacion de la demanda
    set demanda-temporal lput random 10 demanda-temporal ;; Pone la validez, un numero random entre 0 - 9
    set demanda-temporal lput id-demandante demanda-temporal ;; El id del demandante que lo crea
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
      ]
      ;;Se inserta la nueva oferta en todas mis ofertas
      set ofertas-intermediario lput oferta-escogida ofertas-intermediario
    ]
    ;;Ahora intentamos agarrar ofertas
    if not(empty? lista-demandas) [
      set lista-demandas ordenar-demandas-precios lista-demandas ofertas-intermediario
      ;;Se escoge una demanda
      let demanda-escogida item 0 lista-demandas
      ;;Se borra de la pizarra
      ask pizarra idPizarra [
        set demandas-pizarra remove demanda-escogida demandas-pizarra
      ]
      ;;Se inserta la nueva demanda en todas mis ofertas
      set demandas-intermediario lput demanda-escogida demandas-intermediario
    ]

    ;; Aquí se puede poner una heurística para decidir a que estado pasar en vez de este if
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


to intermediario-negociar-mercado-cerrado ;;Estado 1

  print (word "Intermediario " who " entro al estado 1")

  ;;Se busca una coincidencia entre oferta y demanda
  if (not((empty? ofertas-intermediario)and(empty? demandas-intermediario)))[
    if-else (buscar-coincidencias-ofertas-demandas ofertas-intermediario demandas-intermediario) [
      let oferta-demanda (devolver-ofertas-demandas-con-coincidencia ofertas-intermediario demandas-intermediario)
      let precio-oferta item 1 (item 0 oferta-demanda)
      let comision ((item 2 (item 0 oferta-demanda)) / 100)

      let id-del-oferente item 5 (item 0 oferta-demanda)
      let id-del-demandante item 5 (item 1 oferta-demanda)
      ;;Se actualiza el haber del intermediario (Haber+(Precio_Oferta*Comision))
      set haber-intermediario (haber-intermediario + (precio-oferta * comision))
      ;;Se actualiza el haber del oferente (Haber+(Precio_Oferta -(Precio_Oferta*Comision)))
      ask oferente id-del-oferente[
        set haber-oferente (haber-oferente + ( precio-oferta - (precio-oferta * comision)))
      ]
      ;; Se actualiza el haber del demandante (Haber-Precio_Oferta)
      ask demandante id-del-demandante[
        set haber-demandante (haber-demandante - precio-oferta)
      ]

      ;;Hay que quitar la oferta y demanda de mis listas
      set ofertas-intermediario remove (item 0 oferta-demanda) ofertas-intermediario
      set demandas-intermediario remove (item 1 oferta-demanda) demandas-intermediario

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
  let respuesta-ayuda []
  if-else subestado = 0[ ;; Primera vez que el intermediario entra en este estado, se ordenará la lista de conocidos según una heurística y se le preguntará al primero si quiere hacer un trato
    print (word "Intermediario " id-intermediario " está en subestado 0")
    ordenar-lista-conocidos
    set subestado 1
  ]
  [
    if-else subestado = 1[ ;; Si algún conocido no estaba disponible para hacer un trato o lo declinó, se le pregunta al siguiente en la lista
      print (word "Intermediario " id-intermediario " está en subestado 1")
      set respuesta-ayuda preguntar-intermediario-conocido
    ]
    [
      if subestado = 2[ ;; Si ya no tengo más conocidos a los cuales preguntarle, le preguntaré a un desconocido...
        print (word "Intermediario " id-intermediario " está en subestado 2")
        set respuesta-ayuda preguntar-intermediario-desconocido
      ]
    ]
  ]

  ;;Si la respuesta no es vacía y la respuesta no fue mala
  procesar-respuesta respuesta-ayuda
end

;;métodos para Subestados del estado Pidiendo ayuda

to ordenar-lista-conocidos
  if not(empty? conocidos) [
    set conocidos sort-with-dsc[l -> item 1 l] conocidos
  ]
  set indice-conocidos 0

end

;;Falta poner las experiencias que se han tenido con los que he interactuado
to-report preguntar-intermediario-conocido
  let respuesta [] ;;un par de [id,respuesta] 0: no hubo contacto, 1: hubo contacto y si quiere negociar, 2: hubo contacto y no quiere negociar
  if-else(indice-conocidos < (length conocidos))[;;Tengo conocidos a los que les puedo preguntar si quieren negociar
    let conocido-temporal item indice-conocidos conocidos ;;saca el siguiente conocido de la lista
    set indice-conocidos (indice-conocidos + 1) ;;aumenta el indice de la lista de conocidos
    ;;Guardo mi id para darselo al otro agente para saber si quiere negociar conmigo
    let id-intermediario-pregunta id-intermediario
    let id-conocido (item 0 conocido-temporal)
    ask intermediario id-conocido [
      if-else estado = 2 [;;Está pidiendo ayuda tambien
        if-else decidir-si-negociar[ ;; Quiere negociar
          set respuesta (list id-conocido 1)
        ]
        [;;No quiere negociar
           set respuesta (list id-conocido 2)
        ]
      ]
      [ ;; No hubo respuesta, para este caso se puede agarrar este conocido y meter al final de la cola para preguntarle de nuevo luego
        set respuesta (list id-conocido 0)
      ]
    ]
  ]
  [;;Ya no tengo conocidos a los cuales preguntarles
    set indice-conocidos 0
    set subestado 2
  ]
  report respuesta
end

;;Aquí tambien falta poner experiencias con los que he interactuado
to-report preguntar-intermediario-desconocido
  let respuesta [] ;;un par de [id,respuesta] 0: no hubo contacto, 1: hubo contacto y si quiere negociar, 2: hubo contacto y no quiere negociar
  let mi-id id-intermediario
  if-else not(empty? desconocidos) [
    let conocido-intermedio item (random length desconocidos) desconocidos
    ask intermediario conocido-intermedio[
      if-else estado = 2 [
        ;;Se conocieron, hay que removerlo de los desconocidos
        set desconocidos remove mi-id desconocidos
        if-else decidir-si-negociar[;;Quiere negociar
          set conocidos lput (list mi-id 1 [] ) conocidos
          set respuesta (list conocido-intermedio 1)
        ]
        [;;No quiere negociar
          set conocidos lput (list mi-id 0 [] ) conocidos
          set respuesta (list conocido-intermedio 2)
        ]
      ]
      [;;no hubo contacto
        set respuesta (list conocido-intermedio 0 )
      ]
    ]

    if-else ((item 1 respuesta) = 1) [;; Quiere negociar
      set desconocidos remove mi-id desconocidos
      set conocidos lput (list mi-id 1 [] ) conocidos
    ]
    [
      if ((item 1 respuesta) = 2)  [;; No quiere negociar
        set conocidos lput (list mi-id 0 [] ) conocidos
        set desconocidos remove mi-id desconocidos
      ]
    ]
  ]
  [
    set estado 0
  ]
  report respuesta
end

to procesar-respuesta [respuesta]
  if (not(empty? respuesta)) [
    if-else ((item 1 respuesta) = 0) [;; No hubo respuesta
      ;;Se puede poner a esta persona al final de mi lista de conocidos y preguntarle luego
    ]
    [
      if-else ((item 1 respuesta) = 1) [;;Hubo respuesta y quiere negociar
        ;;Subir confianza y poner esta experiencia en mi lista de conocidos
        let oferta-demanda buscar-coincidencia-entre-intermediario (item 0 respuesta)
        if-else not(empty? oferta-demanda) [ ;; Significa que se encontró una coincidencia
          ;;Vendemos las acciones y cada uno adquiere la mitad de la comision
          vender-accion oferta-demanda

          set subestado 0
          set estado 0

        ]
        [;; No se encontraron coincidencias
         ;;Por el momento nada
        ]
      ]
      [
        if ((item 1 respuesta) = 2) [;; Hubo respuesta y no quiere negociar
          ;;Bajar confianza y poner esta experiencia en mi lista de conocidos
        ]
      ]
    ]
  ]
end

to vender-accion [oferta-demanda] ;; oferta y demanda tiene el formato [[id-inter [oferta]] [id-otro-inter [demanda]]]

  print oferta-demanda

  let precio-oferta item 1 (item 1 (item 0 oferta-demanda))
  let comision ((item 2 (item 1 (item 0 oferta-demanda))) / 100)

  let id-del-oferente item 5 (item 1 (item 0 oferta-demanda))
  let id-del-demandante item 5 (item 1 (item 1 oferta-demanda))

  let id-intermediario1 item 0 (item 0 oferta-demanda)

  print word "Intermediario1: " id-intermediario1

  let id-intermediario2 item 0 (item 1 oferta-demanda)

  print word "Intermediario2: " id-intermediario2

  ;;Se actualiza el haber del oferente (Haber+(Precio_Oferta -(Precio_Oferta*Comision)))
  ask oferente id-del-oferente[
    set haber-oferente (haber-oferente + ( precio-oferta - (precio-oferta * comision)))
  ]
  ;; Se actualiza el haber del demandante (Haber-Precio_Oferta)
  ask demandante id-del-demandante[
    set haber-demandante (haber-demandante - precio-oferta)
  ]

  if-else id-intermediario = id-intermediario1 [; Yo puse la oferta
    ;;Aumento mi dinero
    set haber-intermediario (haber-intermediario + ((precio-oferta * comision) / 2))
    ;;Otro intermediario
    ask intermediario id-intermediario2 [
      ;;Aumento el dinero del otro
      set haber-intermediario (haber-intermediario + ((precio-oferta * comision) / 2))
      ;;Quito la demanda del otro
      set demandas-intermediario remove (item 1 (item 1 oferta-demanda)) demandas-intermediario

      set estado 0
      set subestado 0
    ]
    ;;Quitar oferta de mi lista
      set ofertas-intermediario remove (item 1 (item 0 oferta-demanda)) ofertas-intermediario
  ]
  [;;Yo puse la demanda
    ;;Aumento mi dinero
    set haber-intermediario (haber-intermediario + ((precio-oferta * comision) / 2))
    ;;Otro intermediario
    ask intermediario id-intermediario1 [
      ;;Aumento el dinero del otro
      set haber-intermediario (haber-intermediario + ((precio-oferta * comision) / 2))
      ;;Quito la oferta del otro
      set ofertas-intermediario remove (item 1 (item 1 oferta-demanda)) ofertas-intermediario

      set estado 0
      set subestado 0
    ]
    ;;Quitar demanda de mi lista
     set demandas-intermediario remove (item 1 (item 1 oferta-demanda)) demandas-intermediario
  ]




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
    ;;Ponermos el indice para ponerlo en la otra lista ordenada
    set oferta-temporal lput i oferta-temporal
    ;; Poner en la lista de ofertas
    set ofertas-precio-comision lput oferta-temporal ofertas-precio-comision

    set oferta-temporal []

    set i (i + 1)
  ]

  ;;Se ordena esta lista temporal por comisión más alta
  set ofertas-precio-comision sort-with-dsc[l -> item 1 l] ofertas-precio-comision
  ;;Se crea una lista nueva para agregar las ofertas ordenadas por comisión
  let ofertas-ordenadas []
  set i 0
  ;;Este while ordena las ofertas originales por comisión más alta
  while [ i < lista-size] [

    set ofertas-ordenadas lput ( item ( item  2 (item i  ofertas-precio-comision ) ) lst ) ofertas-ordenadas

    set i (i + 1)
  ]


  report ofertas-ordenadas
end

to-report ordenar-demandas-precios [lst ofertas]

  ;;Ordenamos las demandas con mayores precios primero
  let demandas-ordenadas-precio sort-with-asc[l -> item 2 l] lst
  let demandas-escogidas []
  let demanda-encontrada false

  if not (empty? ofertas) [
  ;;Se intenta encontrar una de ella si hace match
    let oferta one-of ofertas
    let i 0
    while[ (i < length demandas-ordenadas-precio)] [

      if ((item 1 oferta) <= (item 1 (item i demandas-ordenadas-precio))) and ((item 1 oferta) >= ((item 2 (item i demandas-ordenadas-precio)))) [
        set demanda-encontrada true
        set demandas-escogidas lput (item i demandas-ordenadas-precio) demandas-escogidas
      ]

      set i (i + 1)
    ]
  ]

  ;;En caso de que no haya ningún match, se agarran todas
  if not demanda-encontrada [
    set demandas-escogidas demandas-ordenadas-precio
  ]

  report demandas-escogidas
end

to-report buscar-coincidencias-ofertas-demandas [ ofertas demandas ]

  let hayCoincidencia false

  if not( (empty? ofertas) or (empty? demandas) ) [
    let i 0
    let j 0

    let ofertas-size length ofertas
    let demandas-size length demandas

    let repetir true

    while [ (i < ofertas-size ) and repetir] [
      while[ (j < demandas-size) and repetir] [

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

;;Solo devuelve un par oferta-demanda
to-report devolver-ofertas-demandas-con-coincidencia [ ofertas demandas ]

  let hayCoincidencia false
  let oferta-demanda []

  if not( (empty? ofertas) or (empty? demandas) ) [
    let i 0
    let j 0

    let ofertas-size length ofertas
    let demandas-size length demandas

    while [ (i < ofertas-size ) and not(hayCoincidencia)] [
      while[ j < demandas-size and not(hayCoincidencia)] [

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

;;Heuristica mala para decidir si negociar o no con algún agente
;;Es necesario hacer una heuristica que mande como parámetro el id de un agente y a partir de quien quiera negociar conmigo y las experiencias que he tenido con esa persona, decidir si negociar o no
to-report decidir-si-negociar
  let numero-random random 101
  if-else (numero-random <= probabilidad-negociar)[report true][report false]
end

;;Metodo que busca una coincidencia entre las ofertas y demandas de 2 intermediarios para que las puedan negociar
to-report buscar-coincidencia-entre-intermediario [id-segundo-intermediario]

  let mis-ofertas ofertas-intermediario
  let mis-demandas demandas-intermediario
  let mi-id id-intermediario

  let coincidencia-oferta-demanda [];; Aquí se pondran las coincidencias
  let ids-coincidencia [] ;;Aquí se pondran las conindicencias con ofertas y demandas con id respectivo [[id , oferta] [id , demanda]]

  ask intermediario id-segundo-intermediario [
    ;; Aquí se intenta buscar un match entre mis ofertas y las demandas del otro intermediario
    set coincidencia-oferta-demanda devolver-ofertas-demandas-con-coincidencia mis-ofertas demandas-intermediario
    ;;Si no se encontró un match, vamos a probar al reves
    if-else (empty? coincidencia-oferta-demanda) [;;No hubo coincidencias
      set coincidencia-oferta-demanda devolver-ofertas-demandas-con-coincidencia ofertas-intermediario mis-demandas

      ;;Si tampoco hay coincidencias pues no podemos hacer trato
      if-else (empty? coincidencia-oferta-demanda) [;;No hubo coindicencias tampoco, no hay nada que hacer
        set ids-coincidencia []
      ]
      [;;Hubo coincidencias
       ;; [[id-segundo [oferta]] [mi-id [demanda]]]
        set ids-coincidencia (list (list id-segundo-intermediario (item 0 coincidencia-oferta-demanda) ) (list mi-id (item 1 coincidencia-oferta-demanda)))
      ]
    ]
    [;;Hubo coincidencias
     ;; [[mi-id [oferta]] [id-segundo [demanda]]]
       set ids-coincidencia (list (list mi-id (item 0 coincidencia-oferta-demanda) ) (list id-segundo-intermediario (item 1 coincidencia-oferta-demanda)))
    ]
  ]

  report ids-coincidencia

end

;;Métodos para imprimir datos

to imprimir-tick
      print "------------------------------------------------------------"
      ;;Imprimir para debug
      ;imprimir-ofertas-oferentes
      ;imprimir-demandas-demandantes
      imprimir-pizarra
      imprimir-intermediarios
      print "------------------------------------------------------------"
end

to imprimir-pizarra
  ask pizarras [
    print word "Pizarra: " who
    print word "Ofertas: " ofertas-pizarra
    print word "Demandas: " demandas-pizarra
    print ""
  ]
end

to imprimir-ofertas-oferentes
  ask oferentes [
    print word "Oferente: " who
    print word "Ofertas: " ofertas-oferente
    print ""
  ]
end

to imprimir-demandas-demandantes
  ask demandantes [
    print word "Demandante: " who
    print word "Demandas: " demandas-demandante
    print ""
  ]
end

to imprimir-intermediarios
  ask intermediarios [
    print word "Intermediario: " who
    print word "Haber: " haber-intermediario
    print word "Ofertas: " ofertas-intermediario
    print word "Demandas: " demandas-intermediario
    print ""
  ]
end

;; Métodos de ordenamiento de lista con una llave

to-report sort-with-asc [ key lst ] ;; Ordena una lista según una llave, se utiliza de esta forma sort-with [ l -> item n l ] my-list
  report sort-by [ [a b] -> (runresult key a) < (runresult key b) ] lst
end

to-report sort-with-dsc [ key lst ] ;; Ordena una lista según una llave, se utiliza de esta forma sort-with [ l -> item n l ] my-list
  report sort-by [ [a b] -> (runresult key a) > (runresult key b) ] lst
end
@#$#@#$#@
GRAPHICS-WINDOW
1229
132
1538
442
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
2
100
15.0
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
5.0
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
1
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
30.0
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
26
426
198
459
probabilidad-negociar
probabilidad-negociar
0
100
30.0
1
1
NIL
HORIZONTAL

PLOT
377
28
743
278
Haber-Promedio-Intermediarios
Tiempo
Haber
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"Promedio-Haber" 1.0 0 -10899396 true "" "plot mean [haber-intermediario] of intermediarios"

PLOT
377
280
743
528
Haber-Promedio-Oferentes
Tiempo
Haber
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"Haber-Promedio" 1.0 0 -13345367 true "" "plot mean [haber-oferente] of oferentes"

PLOT
750
29
1114
277
Haber-Promedio-Demandantes
Tiempo
Haber
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"Haber-Promedio" 1.0 0 -2674135 true "" "plot mean [haber-demandante] of demandantes"

@#$#@#$#@
## QUE ES EL MODELO?

En el mercado de intermediación participan tres clases de agente: oferentes, que ofrecen valores a la venta, demandantes, que buscan valores para comprar, e intermediarios, que negocian una comisión de intermediación por realizar la transacción de compra-venta asociada a una oferta y una demanda que coinciden.

Clases y cantidad de agentes: Los agentes oferentes y demandantes son representados por
la clase cliente, y esta es representada por un único agente. Por otro lado, en cada simulación se crean N agentes intermediarios. El número N es un parámetro de la simulación, que puede ser implementado mediante un slider en NetLogo.

Entorno de la simulación: El espacio de transacción de valores en el mercado es representado por una pizarra de acceso publico no concurrente, que tiene dos posible estados: accesible y bloqueada, que solo afectan el acceso de los agentes intermediarios. Las acciones del agente cliente son independientes del estado de la pizarra.

Acceso no concurrente de intermediarios: Para que cualquier agente intermediario acceda
a la pizarra, su estado debe ser accesible. En ese caso, el agente debe cambiar el estado de la pizarra a bloqueada, realizar una acción sobre la pizarra, y volver a poner su estado en accesible. El propósito de limitar las acciones de los agentes intermediarios sobre la pizarra a solo una es evitar el "secuestro" de la pizarra por un solo intermediario.

Acciones del agente cliente: El agente cliente solamente accede a la pizarra para realizar una de dos posible acciones: publicar ofertas o publicar demandas.

Acciones de los intermediarios: Los intermediarios acceden a la pizarra para buscar coincidencias entre ofertas y demandas; su propósito es realizar la transacción de compra-venta representada en cada coincidencia encontrada, y cobrar la comisión correspondiente. Los agentes intermediarios pueden estar en uno de los estados siguientes:

-Buscando
-Negociando
-Pidiendo ayuda

## COMO FUNCIONA

El modelo genera valores (por el momento aleatorios) de ofertas y demandas y los publica en la pizarra con la tasa de velocidad que le definamos al principio, posteriormente los agentes intermediarios pasan uno por uno a la pizarra a buscar ofertas y demandas que hagan match, si encuentran una pareja, entonces toman ambos valores de la pizarra y cambian al estado negociando para concretar la transaccion y "cerrar el trato", si no encuentran una pareja que calce, entonces toman alguna oferta o demanda y pasan al estado de Pidiendo Ayuda para ver si algun otro intermediario quiere hacer negocios y compartir la comisión 50/50

## COMO SE UTILIZA

Se puede modificar el haber inicial tanto de los intermediarios como de los oferentes asi como la cantidad de los intermediarios. Tambien se puede modificar la cantidad de valores (ofertas y demandas) que se crean en el inicio de la simulación, asi como la cantidad que se publican en la pizarra en cada Tick.

Las opciones de mercado abierto, asi como variar la cantidad de oferentes y demandantes no estan 100% implementadas por lo que variar estos valores puede provocar un mal funcionamiento del sistema o no habrian cambios significativos en los resultados de la simulación.

## EXTENDIENDO EL MODELO

El modelo fue diseñado de manera modular para que pueda ser extendido de manera sencilla agregando diferentes heuristica a las tomas de desiciones de los intermediarios. 

Se puede implementar la versión de un mercado abierto.

Se puede implementar un sistema de “egresos externos” los intermediarios tienen que pagar otras cosas ajenas al mercado. Esto puede afectar varios valores cuando uno esté sin dinero.

La Teoría de la Mente no está totalmente implementada. Falta ponerle a los intermediarios sus experiencias pasadas con otros intermediarios. Y decidir a partir de estas experiencias si negociar con un intermediario específico o no en un futuro.

Actualmente la simulación solo cuenta con el factor confianza para la toma de decisiones. Es importante ampliar esto a una lista más variada, con factores como: Deseos, metas, egoísmo, obligaciones, creencias, intenciones, etc.

Los factores para cada agente no siempre tienen el mismo peso, esto es, para un agente es más importante obtener un bien individual (egoísmo)  antes que forjar alianzas con otras personas (confianza). Y para otro agente lo contrario.

Actualmente todos los agentes se rigen por la misma “técnica” para comprar valores en el mercado, puede ser útil implementar más formas.

La única información que pueden compartir los agentes entre ellos son ofertas y demandas. Sería útil poder compartir otro tipo de información, por ejemplo, que un agente le recomiende a otro utilizar una técnica específica para comprar valores en el mercado. El agente receptor puede decidir si seguir tal consejo o no, según la ToM y experiencias anteriores con el agente emisor.

Implementar un algoritmo para realizar inferencias, el cual permita ver si una técnica sirve o no, si esta fue recomendada por otro agente, el algoritmo puede cambiar el nivel de confianza que se le tiene.


## CREDITOS Y AGRADECIMIENTOS

Nuestros agradecimientos al Dr. Álvaro de la Ossa por ayudarnos a diseñar un modelo para la implementación de la  simulación.
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
