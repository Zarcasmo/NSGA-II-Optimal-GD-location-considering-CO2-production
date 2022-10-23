function [Padres] = SeleccionTorneo(Poblacion, Genetico)
%% Selección por torneo
    Pareto = Poblacion.Pareto.Total;
    %Columna 1: Posición del individuo en la poblacion
    %Columna 2: Frente de pareto al que pertenece
    %Columna 3: Distancia de apilamiento del individuo
    Padres = zeros(Genetico.TamPob, 2);
    
    for i=1:Genetico.TamPob     
        %Selecciono N individuos de manera aletaroia para el torneo
        seleccion = randi([1 Genetico.TamPob],2,Genetico.Torneo);
        %Escoge el padre 1 
        candidatos = Pareto(seleccion(1,:),:);
        Pos1_select = find(candidatos(:,2) == min(candidatos(:,2)));    %Escogo los individuos del mejor frente
        [~,Pos2_select] = max(candidatos(Pos1_select,3));               %Escogo el individuo con mayor distancia de apilamiento
        Padre1 = candidatos(Pos1_select(Pos2_select),1);                %Traigo la posicicon del individuo
        
        %Escoge el padre 2       
        candidatos = Pareto(seleccion(2,:),:);
        Pos1_select = find(candidatos(:,2) == min(candidatos(:,2)));    %Escogo los individuos del mejor frente
        [~,Pos2_select] = max(candidatos(Pos1_select,3));               %Escogo el individuo con mayor distancia de apilamiento
        Padre2 = candidatos(Pos1_select(Pos2_select),1);                %Traigo la posicicon del individuo
        
        %Ubico los padres dentro del vector de pareto
        Padres(i,:) = [Padre1 Padre2];
    end
    
end