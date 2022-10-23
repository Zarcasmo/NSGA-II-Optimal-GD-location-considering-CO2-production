function [Hijos, Sistema] = MejoriaLocal(Hijos, Sistema, Genetico, Estocastico)
  
    index = 1:Sistema.nb;
    Sistema_prueba = Sistema;
    for i=1:Genetico.TamPob
        
        HijoMejorado = Hijos.HijosMutados(i,:);
        FO_HijoMejorado = Hijos.FO(i,:);

        %De manera aleatoria retiro o pongo GD con heuristica
        if rand<0.6 %Mayor probabilidad de retirar
            Configuracion = [index' Hijos.HijosMutados(i,:)'];
            Configuracion_Ordenado = sortrows(Configuracion, 2, 'descend');
            Configuracion_Desordenada = Configuracion_Ordenado(Configuracion_Ordenado(:,2)>0,:);

            %Eliminar GD de manera aletoria que encarecen y solo empeoran la FO        
            if ~isempty(Configuracion_Desordenada)
                Configuracion_Desordenada= Configuracion_Desordenada(randperm(size(Configuracion_Desordenada,1)),:);
                % Retiro 1 GD que empeoran la FO
                for j=1:1 %size(Configuracion_Desordenada,1)
                        %Eliminar GD
                        aux_GD = HijoMejorado(Configuracion_Desordenada(j,1));
                        aux_FO = FO_HijoMejorado;
                        HijoMejorado(Configuracion_Desordenada(j,1)) = 0;
        
                        %Calcular la FO
                        Sistema_prueba.Sistemas = Sistema.Sistemas(i);
                        [FO_HijoMejorado,~,~, Sistema_prueba] =  Calculo_FO(Sistema_prueba, Estocastico, HijoMejorado);
        
                
                        %En caso de empeorar la funcion objetivo, regreso el GD
                        if (FO_HijoMejorado(1,1) > aux_FO(1,1)) && (FO_HijoMejorado(1,2) > aux_FO(1,2))
                            HijoMejorado(Configuracion_Desordenada(j,1))=aux_GD;
                            FO_HijoMejorado = aux_FO;
                        else
                            % En caso de mejorar, dejo el sistema modificado
                            Sistema.Sistemas(i) = Sistema_prueba.Sistemas(1);
                        end
                end
            end
        %Agregar GD a los nodos con mayor carga    
        else
            Carga = [Sistema.bus_original(:,1),  Sistema.bus_original(:,3), Sistema.bus_original(:,14)];
            Carga = Carga(Carga(:,3)~=0,1:2);                 %Descarto los nodos que no permiten GD
            Carga_ordenada = sortrows(Carga, 2, 'descend');
            Carga_ordenada = Carga_ordenada(1:10,:);   %Tomo los N+2 nodos con mayor carga
            pos = Carga_ordenada(randi([1 size(Carga_ordenada,1)]),1);  %Escogo uno aletorio para poner GD
            j=1;
            while ((HijoMejorado(pos)>0) || (Sistema.bus_original(pos,14)==0)) && (j<8) %En caso de tener GD instalado o un nodo que no permite GD, escogo otro nodo
                pos = Carga_ordenada(randi([1 size(Carga_ordenada,1)]),1);  
                j=j+1;
            end
            
            %Agrego el GD
            aux_GD = HijoMejorado(pos);
            aux_FO = FO_HijoMejorado;
            HijoMejorado(pos) = randi([1 Sistema.TiposGD]);

            %Calcular la FO
            Sistema_prueba.Sistemas = Sistema.Sistemas(i);
            [FO_HijoMejorado, ~,~, Sistema_prueba] =  Calculo_FO(Sistema_prueba, Estocastico, HijoMejorado);

            %En caso de empeorar la funcion objetivo, regreso el GD
            if (FO_HijoMejorado(1,1) > aux_FO(1,1)) && (FO_HijoMejorado(1,2) > aux_FO(1,2))
                HijoMejorado(pos)=aux_GD;
                FO_HijoMejorado = aux_FO;
            else
                % En caso de mejorar, dejo el sistema modificado
                Sistema.Sistemas(i) = Sistema_prueba.Sistemas(1);
            end
        end

        Hijos.HijosMejorados(i,:) = HijoMejorado;
        Hijos.FO(i,:) = FO_HijoMejorado;
    end
end

