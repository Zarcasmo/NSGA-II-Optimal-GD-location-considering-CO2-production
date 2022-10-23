%Funcion que permite encontrar los individuos que pasaran de proceso
%generacional
function [Poblacion, Sistema, bandera, p_legend] = Reemplazo(Poblacion,Sistema, Genetico, bandera, gen, p_legend)
    
% Grafica de el frente P1 en la generación 100
    if bandera == 20
        bandera = 0;
        frente1 = Poblacion.Pareto.Frentes(1).Frente;
        plot( Poblacion.FO(frente1,1), Poblacion.FO(frente1,2), 'bd') ;
        p1 = plot(Poblacion.FO(frente1,1), Poblacion.FO(frente1,2), 'LineWidth',2.5, 'DisplayName',['gen: ', num2str(gen)]);
        p_legend = [p_legend, p1];
    end

    % Vector con la posicicón en los frentes de cada individuo
    Pareto = Poblacion.Pareto.Total;
    tamPob = Genetico.TamPob;

    %% Etapa para evitar individuos exactamente iguales
%     X_def = Poblacion.Pob;
%     reemplazo=0;
%     ok = 0;
%     for i=2:size(Pareto,1)
%         individuo_1 = Poblacion.Pob(i,:);
%         for j=i-1:-1:1
%             individuo_2 = Poblacion.Pob(j,:);
%             if individuo_1 == individuo_2
%                 X_def(i,:) = [];
%                 Pareto(i,:) = [];
%                 reemplazo = reemplazo +1;
%                 break;
%             end
%         end   
%         ok = ok + 1;
%         if (reemplazo == tamPob) || (ok == tamPob)    %Solo puedo eliminar tamPob individuos
%             break;
%         end
%     end
    
    %% Encontrar pareto de tama�o tamPob
    if Pareto(tamPob,2) ~=  Pareto(tamPob+1,2)
        % En caso de que tamPob se encuentre toda en un mismo frente
        Pareto_def = Pareto(1:tamPob,:);
        
    else
        %En caso de que los inviduos esten repartidos en varios frentes
        frente = Pareto(tamPob,2);
        Pareto_def = Pareto(Pareto(:,2) <= frente-1,:);
        Faltan = tamPob - length(Pareto_def);  %Numero de individuos faltantes en la nueva poblacion
        Pareto_aux = Pareto(Pareto(:,2) == frente,:);
        Pareto_aux = sortrows(Pareto_aux, 3, 'descend');
        Pareto_aux = Pareto_aux(1:Faltan,:);
        Pareto_def = [Pareto_def; Pareto_aux];

    end
    %% Elimino individuos sobrantes
    % Solo quedan individuos de mejores frentes
    Poblacion.Pob = Poblacion.Pob(Pareto_def(:,1),:);
    Poblacion.FO = Poblacion.FO(Pareto_def(:,1),:);
    Sistema.Sistemas = Sistema.Sistemas(Pareto_def(:,1));

    % Reordeno los valores del frente de pareto
    Pareto_def = sortrows(Pareto_def, 1, 'ascend');
    Pareto_def(:,1) = 1:tamPob;
    Poblacion.Pareto.Total = sortrows(Pareto_def, [2 3], {'ascend','descend'});
end