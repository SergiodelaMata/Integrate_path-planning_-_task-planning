(define (domain cooperation)
	(:requirements :strips :typing :equality :negative-preconditions :fluents 
		:durative-actions :preferences :constraints)
	(:types
		dock - object ;; Objeto embarcadero
		;coordX coordY - object ;; Objeto coordenadas
		unmanned-vehicle - object ;; Objeto vehículo no tripulado
        uav ugv - unmanned-vehicle ;; Tipos de vehículos no tripulados
        navmode - object ;; Objeto modo de navegación
        pan - object ;; Objeto para la rotación del vehículo hacia arriba y/o hacia abajo
        tilt - object ;; Objeto para la rotación del vehículo hacia la derecha y/o hacia la izquierda
        point - object
	)
	(:predicates 
        ;;Cambio al objeto point
		(at-position ?elem - (either dock unmanned-vehicle) ?point - point) ;; Predicado para conocer la posición de un embarcadero o vehículo no tripulado
		(at-dock ?uv - unmanned-vehicle ?d - dock) ;; Predicado para conocer si un vehículo no tripulado está en un embarcadero
		(has-nav-mode ?uv - unmanned-vehicle ?m - navmode) ;; Predicado para saber si un vehículo no tripulado tiene un modo de navegación 
        ;;Cambio al objeto point
		(is-taken-picture ?uv - unmanned-vehicle ?point - point ?p - pan ?t - tilt) ;; Predicado para saber si ha tomado una imagen un vehículo no tripulado
        ;;Cambio al objeto point
		(is-picture-sent ?uv - unmanned-vehicle ?point - point  ?p - pan ?t - tilt) ;; Predicado para saber si ha transmitido una imagen un vehículo no tripulado
        
		(is-horizontal-pan ?uv - unmanned-vehicle ?p - pan) ;; Predicado para saber la rotación pan de un vehículo no tripulado
		(is-horizontal-tilt ?uv - unmanned-vehicle ?t - tilt) ;; Predicado para saber la rotación tilt de un vehículo no tripulado
	)
	(:functions 
		(speed ?m - navmode) ;; Función para saber la velocidad de un vehículo no tripulado cuando tiene un modo de navegación
        ;;Cambio al objeto point
		(distance ?point1 - point ?point2 - point) ;; Función para conocer la distancia entre dos posiciones
		(total-time-use) ;; Función para conocer el tiempo total usado para llegar a la meta
		
	)
	;; Acción para aterrizar en una base un vehículo no tripulado
    ;;Cambio al objeto point
	(:durative-action dock
	   :parameters(?d - dock ?uv -unmanned-vehicle ?point - point)
	   :duration(= ?duration 1)
       :condition(and
	   ;; Ha de conocerse si las coordenadas tanto del embarcadero como del vehículo son las mismas
					(at start (at-position ?d ?point))
					(at start (at-position ?uv ?point))
				)
	   :effect(and
	   ;; Se tiene en cuenta que ahora en vez de estar el vehículo en las coordenadas del embarcadero, se encuentra en el embarcadero y que ha aumentado el tiempo total usado
					(at start (not(at-position ?uv ?point)))
					(at end (at-dock ?uv ?d))
					(at end (increase (total-time-use) 1))
				)
	)
	;; Acción para despegar de una base un vehículo no tripulado
    ;;Cambio al objeto point
	(:durative-action undock
	   :parameters(?d - dock ?uv -unmanned-vehicle ?point - point)
	   :duration(= ?duration 1)
       :condition(and 
	   ;; Ha de conocerse si el vehículo se encuentra en embarcadero y el embarcadero se encuentra en la posición estudiada
					(at start (at-dock ?uv ?d))
					(at start (at-position ?d ?point))
				)
	   :effect(and 
	   ;; Se tiene en cuenta que ahora el vehículo ya no está en el dock y se encuentra en posición del dock y que el tiempo total usado ha aumentado
					(at start (not(at-dock ?uv ?d)))
					(at end (at-position ?uv ?point))
					(at end (increase (total-time-use) 1))
				)
	)
	;; Acción para cambio de posición de un vehículo no tripulado
	(:durative-action move
		:parameters(?uv - unmanned-vehicle ?fromPoint1 - point ?toPoint2 - point ?mode - navmode)
		:duration(= ?duration (/(speed ?mode)(distance ?fromPoint1 ?toPoint2)))
        :condition(and
		;; Ha de conocerse si el vehículo tiene un modo de navegación, éste se encuentra en la posición de origen
					(at start (has-nav-mode ?uv ?mode))
					(at start (at-position ?uv ?fromPoint1))
				)
        :effect (and
		;; Se tiene en cuenta que el vehículo inicialmente ya no está en la posición de origen y finalmente se encuentra en la posición final y aumenta 
		;; el tiempo total de uso en relación a la velocidad del vehículo y la distancia entre la posición de origen y la de destino
					(at start (not(at-position ?uv ?fromPoint1)))
					(at end (at-position ?uv ?toPoint2))
					(at end (increase (total-time-use) (/(speed ?mode)(distance ?fromPoint1 ?toPoint2))))
				)
    )
	;; Acción para que un vehículo no tripulado tome una fotografía en una posición
    ;;Cambio al objeto point
	(:durative-action take_picture
        :parameters(?uv - unmanned-vehicle ?point - point  ?p - pan ?t - tilt)
		:duration(= ?duration 1)
        :condition(and
		;; Ha de conocerse si el vehículo tiene ajustados el pan y el tilt estudiados y el vehículo se encuentra en una posición
					(at start (is-horizontal-pan ?uv ?p))
					(at start (is-horizontal-tilt ?uv ?t))
					(at start (at-position ?uv ?point))
        )
		:effect (and 
		;; Se tiene en cuenta que el vehículo ya ha tomado una fotografía y que el tiempo total de uso ha aumentado
					(at end (is-taken-picture ?uv ?point ?p ?t))
					(at end (increase (total-time-use) 1))
				)
    )
	;; Acción para realizar la rotación del pan de un vehículo no tripulado
	(:durative-action rotation-pan
		:parameters(?uv - unmanned-vehicle ?pan1 ?pan2 - pan)
		:duration(= ?duration 1)
		;; Ha de conocerse si el vehículo tiene la horizontación pan inicial
 		:condition(at start (is-horizontal-pan ?uv ?pan1))
		:effect(and
		;; Se tiene en cuenta que inicialmente ya no tiene el vehículo la horizontación pan inicial y finalmente tiene la horizontación pan final además de
		;; haber aumentado el tiempo total usado
					(at start (not(is-horizontal-pan ?uv ?pan1)))
					(at end (is-horizontal-pan ?uv ?pan2))
					(at end (increase (total-time-use) 1))
				)
	)
	;; Acción para realizar la rotación del tilt de un vehículo no tripulado
	(:durative-action rotation-tilt
		:parameters(?uv - unmanned-vehicle ?tilt1 ?tilt2 - tilt)
		:duration(= ?duration 1)
		;; Ha de conocerse si el vehículo tiene la horizontación tilt inicial
		:condition(at start (is-horizontal-tilt ?uv ?tilt1))
		:effect(and
		;; Se tiene en cuenta que inicialmente ya no tiene el vehículo la horizontación tilt inicial y finalmente tiene la horizontación pan final además de
		;; haber aumentado el tiempo total usado
					(at start (not(is-horizontal-tilt ?uv ?tilt1)))
					(at end (is-horizontal-tilt ?uv ?tilt2))
					(at end (increase (total-time-use) 1))
				)
	)
	;; Acción para realizar el cambio de modo de navegación de un vehículo no tripulado
	(:durative-action change-nav-mode
		:parameters(?uv - unmanned-vehicle ?mode1 ?mode2 - navmode)
		:duration(= ?duration 1)
		;; Ha de conocerse si el vehículo tiene un modo de navegación inicial
		:condition(at start (has-nav-mode ?uv ?mode1))
		:effect(and
		;; Se tiene en cuenta que inicialmente ya no tiene el vehículo el modo de navegación inicial y finalmente tiene el modo de navegación final además de
		;; haber aumentado el tiempo total usado
					(at start (not(has-nav-mode ?uv ?mode1)))
					(at end (has-nav-mode ?uv ?mode2))
					(at end (increase (total-time-use) 1))
				)
	)
	;; Acción para realizar la transmisión de un imagen hecha por un vehículo no tripulado
    ;;Cambio al objeto point
	(:durative-action transmit-image
		:parameters(?uv - unmanned-vehicle  ?point - point ?p - pan ?t - tilt)
		:duration(= ?duration 1)
		:condition(and 
		;; Ha de conocerse si el vehículo está en la posición estudiada, tiene unas horientaciones pan y tilt además de haber tomado un fotografía en dicha posición con las horientaciones previamente indicadas 
						(at start (at-position ?uv ?point))
						(at start (is-horizontal-pan ?uv ?p))
						(at start (is-horizontal-tilt ?uv ?t))
						(at start (is-taken-picture ?uv ?point ?p ?t))
					)
		:effect(and
		;; Se tiene en cuenta que finalmente ya se ha enviado la fotografía y que el tiempo total de uso ha aumentado
					(at end(is-picture-sent ?uv ?point ?p ?t))
					(at end (increase (total-time-use) 1))
				)
	)
)