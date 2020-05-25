(define (problem cooperation-problem)
	(:domain cooperation)
	(:objects
		dock1 - dock
		;x_1 x_5 x_6 x_10 x_16 - coordX ;; Coordenadas x siendo x_1 => x = 1; x_5 => x = 5; ...
		;y_1 y_2 y_9 y_10 y_13 - coordY ;; Coordenadas y siendo y_1 => y = 1; y_2 => y = 2; ...

        P0610 P0101 P1002 P0509 P1613 - point
		;; Tipos de vehículos no tripulados
		Leader - ugv 
		Follower0 - uav
		;; Modos de navegación
		N0 N1 - navmode
		P_0 P_45 P_90 P_135 P_180 P_225 P_270 P_315 - pan ;; Rotación pan (izquierda - derecha) teniendo la estructura P_x siendo x el número de grados
		T_0 T_45 T_90 T_270 T_315 - tilt ;; Rotación pan (arriba - abajo) teniendo la estructura T_x siendo x el número de grados
	)
	
	(:init
		;; Posición incial del embarcadero y de los vehículos no tripulados
		(at-position dock1 P0101)
		(at-position Leader P0610)
		(at-position Follower0 P1002)
		;; Modos de navegación de los distintos vehículos no tripulados
		(has-nav-mode Leader N0)
		(has-nav-mode Follower0 N0)
		;; Horientación inicial del pan y del tilt de los vehículos no tripulados
		(is-horizontal-pan Leader P_0)
		(is-horizontal-pan Follower0 P_0)
		(is-horizontal-tilt Leader T_0)
		(is-horizontal-tilt Follower0 T_0)
		;; Tiempo total usado inicial
		(= (total-time-use) 0)
		;; Velocidad del vehículo en cada modo de navegación
		(= (speed N0) 1)
		(= (speed N1) 2)
		;; Distancia entre las distancias posiciones en relación a las distintas coordenadas
		(= (distance P0101 P0509) 9)
		(= (distance P0101 P0610) 10)
		(= (distance P0101 P1002) 9)
		(= (distance P0101 P1613) 19)
		
		(= (distance P0509 P0101) 9)
		(= (distance P0509 P0610) 1)
		(= (distance P0509 P1002) 9)
		(= (distance P0509 P1613) 12)
		
		(= (distance P0610 P0101) 10)
		(= (distance P0610 P0509) 9)
		(= (distance P0610 P1002) 9)
		(= (distance P0610 P1613) 10)
		
		(= (distance P1002 P0101) 9)
		(= (distance P1002 P0509) 9)
		(= (distance P1002 P0610) 9)
		(= (distance P1002 P1613) 12)
		
		(= (distance P1613 P0101) 19)
		(= (distance P1613 P0509) 11)
		(= (distance P1613 P0610) 10)
		(= (distance P1613 P1002) 12)
	)
	(:goal
	;; El vehículo Leader toma una fotografía en las coordenadas x = 5 y y = 9 y las horientaciones pan = 0º y tilt = 0º y
	;; El vehículo Leader toma una fotografía en las coordenadas x = 16 y y = 13 y las horientaciones pan = 0º y tilt = 0º
		(and
			(is-taken-picture Leader P0509 P_0 T_0)
			(is-taken-picture Follower0 P1613 P_0 T_0)
		)
	)
	(:constraints
	;; Se tiene como preferencias que los vehículos no tripulados UAV nunca estén en cualquier embarcadero y que lo pueden a veces estar los UGV
		(and
			(preference OUT-DOCK-UAV (always (not(at-dock Follower0 dock1))))
			(preference OUT-DOCK-UGV (sometime (at-dock Leader dock1)))
		)
	)
	(:metric minimize
	;; Se busca el camino con el menor tiempo total usado para llegar a la meta y tratando de violar en la menor medida las preferencia considerados
	;; los pesos presentados a continuación
		(+ 	(* 20 (total-time-use))
			(* 10 (is-violated OUT-DOCK-UAV))
			(* 4 (is-violated OUT-DOCK-UGV))
		)
	)
)