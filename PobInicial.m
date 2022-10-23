%% Población inicial para el NSGAII
% Esta función permite crear una población inicial a partir de los parametros del problema

%% Condiciones
% Población inicial de 30 individuos 
%La población se crea de aleatorios puros

% ---------------------------Funcion-------------------------------------------------------------------------------------
function [X,FO, Sistema]=PobInicial(Sistema, Genetico, Estocastico)

% Población inicial de 30 individuos 
X = zeros(Genetico.TamPob, Sistema.nb);
%% Aleatorios puros
%Genero población aletoria que idnica si lleva o no GD
for pob=1:Genetico.TamPob   % este for generara los individuos 
    X(pob,:)=rand(1,Sistema.nb)>0.85;    %Individuo aletaorio de tamaño numBarras
    %Proceso para verificar diversidad, se siguen tirando aleatorios hasta que se obtenga un individuo diferente al resto
    bandera=0;
    while bandera==0
        bandera=1;      %La bandera se pone en 1, en caso de que X(i,:) no se igual a ningun individuo de la poblacion y pueda salir del while
        for j=1:pob-1
            if X(pob,:)==X(j,:)
                bandera=0;  %Encontro un individuo igual en la poblacion, repite el random
                X(pob,:)=rand(1,Sistema.nb)>0.8;
                break
            end
        end
    end
end
% Se le asigna un tipo de GD de manera a leatoria (Distribucion normal) a los nodos que tienen GD
X = X.*randi(Sistema.TiposGD, Genetico.TamPob, Sistema.nb);
%Aseguro que no se modifique el slack y los nodos que no permiten GD
X(:,Sistema.slack) = 0;
pos_sinGD = Sistema.bus_original(:,14)==0;
X(:,pos_sinGD) = 0;

%% Calculo de la FO
[FO, ~, ~,Sistema] =  Calculo_FO(Sistema,Estocastico, X);
      
end


