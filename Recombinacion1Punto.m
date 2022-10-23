function Hijos_Recombinados = Recombinacion1Punto(pos_Padres, Poblacion, nb, Genetico)
    % Esta funcion permite recombinar dos individuos en 1 punto
    % Para el punto de curce se usa una distribución normal centrada en 5
    % No todos los individuos son cruzados, dependen de la tasa de curzamiento
    Hijos_Recombinados = zeros(Genetico.TamPob, nb);
    for i=1:Genetico.TamPob
        if rand<Genetico.Tcruzamiento
            bloque = round(normrnd(nb/2,1));   %Aleatorio con distribuciónm normal, promedio de nb/2 (Bloque de la izquierda) y desviación estandar de 1
            while ((bloque<0) || (bloque>nb))   %La distribucion normal tiene una muy pequeña posibilidad de obtener valores negativos o por encima de nb, aseguro que eso nunca ocurra
                bloque = round(normrnd(nb/2,1));
            end
            Hijo = zeros(1,nb);
            Hijo(1:bloque) = Poblacion.Pob(pos_Padres(i,1), 1:bloque);
            Hijo((bloque+1):nb) = Poblacion.Pob(pos_Padres(i,2), (bloque+1):nb);
        else
            Hijo = Poblacion.Pob(pos_Padres(i,1),:);
        end
        Hijos_Recombinados(i,:) = Hijo;
    end
end