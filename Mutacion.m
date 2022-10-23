function HijosMutados = Mutacion(Hijos, Sistema, Genetico)
    % Esta funcion genera un aleatorio para cada una de la posiciones de los hijos
    % si el aleatorio es menor o igual a la Tmutacion, se modifica la posicion correspondiente
    % Equivalente a tirar un dado de 100 caras para cada posicion
    HijosMutados = Hijos;
    for i=1:Genetico.TamPob
        Mutados = rand(Sistema.nb,1) <= Genetico.Tmutacion;  %Genero vector con nb aletorios, si alguno es menor a Tmutacion se modifica
        if sum(Mutados)>0    %Si se modifica algun gen del individuo (Caso menos probable)
            Pos = find(Mutados>0);          %Encuentro las posiciones que se van a mutar
            for j=1:size(Pos,1)             %Recorro el vector de posiciones y cambio uno a uno su valores con randi
                if Sistema.bus_original(Pos(j),14)~=0    %No puedo modificar el slack, ni los nodos que no permiten GD
                    HijosMutados(i,Pos(j)) = randi([0 Sistema.TiposGD]);
                end
            end
        end
    end
    
end