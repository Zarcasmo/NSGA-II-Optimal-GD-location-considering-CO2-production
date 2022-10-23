%% Algoritmo NSGAII
%% Elaboro
%Alejandro LÃ³pez Aguirre
%13-abril-2022

%% informacion
%Este algortimo resuelve el problema de la ubicacion optima de GD en
%sistemas competidos, donde agentes externos pueden ubicar GD en un SDL 
clear all
dbstop if error

%% Parametros genetico
N=200;               %Tam de la poblacion
torneo=3;           %Numero de padres seleccionados para el torneo
tcruzamiento=0.9;   %Tasa de cruzamiento
tmutacion=0.04;     %Tasa de mutacion
gen=200;            %Numero de generaciones del algoritmo
rng(33);             %Semilla en caso de querer obtener los mismo resultados (Para efectos de seguimiento)
Genetico=struct('TamPob', N, 'Torneo', torneo, 'Tcruzamiento', tcruzamiento, 'Tmutacion', tmutacion, 'Generaciones', gen);
clear N torneo tcruzamiento tmutacion gen;

%% Estocasticidad
% Reordenar datos de los centroides
%Orden filas: 1.PD   2.PV   3.WT   4.Price
load('Centroides');
Sistema.CurvaGen = zeros(24,2,Estocastico.k);
for k =1:Estocastico.k
    Sistema.CurvaDemanda(:,:,k) = Estocastico.Cd(k,1,:);
    Sistema.CurvaGen(:,1,k) = Estocastico.Cd(k,2,:);
    Sistema.CurvaGen(:,2,k) = Estocastico.Cd(k,3,:);
    Sistema.Price(:,:,k) = Estocastico.Cd(k,4,:);
end
prob = Estocastico.Prob;
Estocastico.Prob = [];
for i=1:Estocastico.k
    Estocastico.Prob(:,1,i) = prob(i,:)';
end
clear prob;

%% Sistema
Sistema.CostokW = 0.2276;
for i=1:Genetico.TamPob
    for k=1:Estocastico.k
        for j=1:size(Sistema.CurvaDemanda,1)
            Sistema.Sistemas(i).curva(j,k) =case70_DC;
            % Perdidas case33bw del sistema original con potenica 1p.u las 24h los 365 días: 1778280 [kW]
        end
    end
end
clear i j;
Sistema.slack = find(Sistema.Sistemas(1).curva(1).bus(:,2)==3);
Sistema.bus_original = Sistema.Sistemas(1).curva(1).bus;
Sistema.gen_original = Sistema.Sistemas(1).curva(1).gen;
Sistema.gencost_original = Sistema.Sistemas(1).curva(1).gencost;
Sistema.nb = size(Sistema.Sistemas(1).curva(1).bus,1);      %Numero de barras
Sistema.nl = size(Sistema.Sistemas(1).curva(1).branch,1);   %Numero de lineas
Sistema.Min_GD = 0;                                         %Numero minimo de GD en el sistema 
Sistema.Max_GD = 33;                                        %Numero maximo de GD en el sistema
Sistema.Min_porcentaje_GD = 0;                              % (%) minimo de generación respecto a la demanda maxima en el sistema
Sistema.Max_porcentaje_GD = 0.4;                            % (%) maximo de generación Estocastica respecto a la demanda maxima en el sistema
Sistema.Max_porcentaje_GD_Deter = 1;                        % (%) maximo de generación Determinisitico respecto a la demanda maxima en el sistema
Sistema.TiposGD = 3;                                        %Tipos de GD  (Tipo 1: 0.2MW, Tipo 2: 0.5MW, Tipo 3: 1MW)
%Capacidades de potencia en cada tipo de GD de acuerdo a codificacion
                 %clase %tipo %potencia
Sistema.CodeGD =   [1	1	0.05		%Solar tipo 1
                    1	2	0.1         %Solar tipo 2
                    1	3	0.15		%Solar tipo 3
                    2	1	0.05  		%eolico tipo 1
                    2	2	0.1 		%eolioc tipo 2
                    2	3	0.15];		%eolioc tipo 3

Sistema_original = Sistema;
Sistema_deter = Sistema;
Sistema_deter = rmfield(Sistema_deter,'Sistemas');
for i=1:Genetico.TamPob
       Sistema_deter.Sistemas(i) =case70_DC;
       % Perdidas case33bw del sistema original con potenica 1p.u las 24h: 222285
end


%% Poblacion inicial
Poblacion=struct('Pob', 0, 'FO', 0);
% Creacion de la poblacion  inicial
[Poblacion.Pob, Poblacion.FO, Sistema]=PobInicial(Sistema, Genetico, Estocastico);
[Poblacion.Pareto.Frentes, Poblacion.Pareto.Total] = Frente_Pareto(Poblacion);
[Poblacion.Pareto.Total(:,3)] = Apilamiento(Poblacion);

%% Nube de puntos
figure;
hold on;
title('Nuve de puntos - Primer frente')
ylabel('CO2 producido [Tons CO2]') 
xlabel('Costo instalación GD + Costo operacional [$]') 
p_legend = [];
frente1 = Poblacion.Pareto.Frentes(1).Frente;                                         %Posiciones del frente 1
frentes = Poblacion.Pareto.Total(Poblacion.Pareto.Total(:,2) >= 2,1);           %Posiciones del resto de frentes
scatter(Poblacion.FO(frentes,1), Poblacion.FO(frentes,2))
plot( Poblacion.FO(frente1,1), Poblacion.FO(frente1,2), 'bd') ;
p1 = plot(Poblacion.FO(frente1,1), Poblacion.FO(frente1,2), 'LineWidth',2.5, 'DisplayName',['gen: ', num2str(0)]);
p_legend = [p_legend, p1];

%% Grafico del proceso generacional
figure;
hold on;
title('Frente optimo de Pareto - generacional')
ylabel('CO2 producido [Tons CO2]') 
xlabel('Costo instalación GD + Costo operacional [$]') 
p_legend = [];
frente1 = Poblacion.Pareto.Frentes(1).Frente;
plot( Poblacion.FO(frente1,1), Poblacion.FO(frente1,2), 'bd') ;
p1 = plot(Poblacion.FO(frente1,1), Poblacion.FO(frente1,2), 'LineWidth',2.5, 'DisplayName',['gen: ', num2str(0)]);
p_legend = [p_legend, p1];
conta = 1;

%% Proceso generacional 
tic
for gen=1:Genetico.Generaciones
    %[floor(gen) min(Poblacion.Anfitness)]
    
    %% Seleccion por torneo
    [pos_Padres] = SeleccionTorneo(Poblacion, Genetico);
    
    %% Recombinacion 
    [Hijos.Hijos_Recombinados] = Recombinacion1Punto(pos_Padres, Poblacion, Sistema.nb, Genetico); 
    
    %% Mutacion
    [Hijos.HijosMutados] = Mutacion(Hijos.Hijos_Recombinados, Sistema, Genetico);
    
    %% Calculo de las F.O
    Sistema_Hijos = Sistema_original; %Utilizo un Sistema limpio para ingresar los hijos
    [Hijos.FO, ~, ~, Sistema_Hijos] =  Calculo_FO(Sistema_Hijos, Estocastico, Hijos.HijosMutados);
  
    %% Etapa de mejoria local 
    [Hijos, Sistema_Hijos] = MejoriaLocal(Hijos, Sistema_Hijos, Genetico, Estocastico);
    
    %% Etapa de reemplazo
    % Ordenamiento en frentes de pareto
    Poblacion.Pob = [Poblacion.Pob; Hijos.HijosMejorados];
    Poblacion.FO = [Poblacion.FO; Hijos.FO];
    Sistema.Sistemas = [Sistema.Sistemas,  Sistema_Hijos.Sistemas];
    [Poblacion.Pareto.Frentes, Poblacion.Pareto.Total] = Frente_Pareto(Poblacion);
    [Poblacion.Pareto.Total(:,3)] = Apilamiento(Poblacion);
    % Elimino los individuos de los peores frentes
    [Poblacion, Sistema, conta, p_legend] = Reemplazo(Poblacion,Sistema, Genetico, conta, gen, p_legend);
    
    %[FO_prueb, FO_extended, ~] =  Calculo_FO(Sistema, Estocastico, Poblacion.Pob);
    %[FO_deter, Sistema_deter] = Calculo_FO_Deterministico(Sistema_deter,Estocastico, Poblacion.Pob);
    
    clear Hijos Sistema_Hijos;
    Poblacion_total(gen) = Poblacion;
    conta = conta +1;
    disp(gen);
end
legend(p_legend);

%% Grafica final
figure;
hold on;
title('Frente optimo de Pareto - generacional')
ylabel('CO2 producido [Tons CO2]') 
xlabel('Costo instalación GD + Costo operacional [$]') 
p_legend = [];
for i=1:gen-1:gen
    [Poblacion_total(i).Pareto.Frentes, ~] = Frente_Pareto(Poblacion_total(i));
    frente1 = Poblacion_total(i).Pareto.Frentes(1).Frente;
    plot( Poblacion_total(i).FO(frente1,1), Poblacion_total(i).FO(frente1,2), 'bd') ;
    p1 = plot(Poblacion_total(i).FO(frente1,1), Poblacion_total(i).FO(frente1,2), 'LineWidth',2.5, 'DisplayName',['gen: ', num2str(i)]);
    p_legend = [p_legend, p1];
end
legend(p_legend);
tiempo_genetico = toc

%% Comparación Estocasticidad vs Deterministico
tic
[FO_estocast, S_estocast, FO_extended, ~] =  Calculo_FO(Sistema, Estocastico, Poblacion.Pob);
[FO_deter, S_deter, Sistema_deter, Critico_deter] = Calculo_FO_Deterministico(Sistema_deter,Estocastico, Poblacion.Pob, FO_estocast, FO_extended);
FO_estocast = round(FO_estocast);
FO_deter = round(FO_deter);
Error = 100*(FO_estocast-FO_deter)./FO_estocast;
tiempo_deterministico = toc

%% Grafo del sistema 33bw
pob_grafo = 10;
Grafo(Sistema, Critico_deter, pob_grafo);

%% Plot informativos
Plot_informativo(Critico_deter,pob_grafo)

