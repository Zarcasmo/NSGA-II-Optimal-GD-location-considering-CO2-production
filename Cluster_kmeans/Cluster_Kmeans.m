%% Generacion de escenarios para el problema de GD usando k-means
clc; clear all; close all;
[Datos_original, ~] = xlsread('Data_set_cartagena', 'DataFull');
for h=0:23
   idx = find(Datos_original(:,1)==h);
   Datos.PV(:,h+1) = Datos_original(idx,2);
   Datos.WT(:,h+1) = Datos_original(idx,3);
   Datos.Load(:,h+1) = Datos_original(idx,4);
   Datos.Price(:,h+1) = Datos_original(idx,5);
end

%% Normalizar las variables
% Las variables se encuentra normalizadas desde data full
% campos = fieldnames(Datos_original);
% Datos = Datos_original;
% Recorro cada una de las variables
% for i=1:4
%     fn = campos(i);
%     %Recorro las 24h del día
%     for j=1:365
%         Datos.(fn{1})(j,:) = Datos_original.(fn{1})(j,:)/max(Datos_original.(fn{1})(j,:));
%     end
%     Datos.(fn{1})(isnan(Datos.(fn{1})))=0;
% end

%% Determinar número de k para el k-means por evalclusters de Matlab
% figure;
% title('Núm cluster por evalclusters - hora 1-12')
% for i=1:24
%     data = [Datos.Load(:,i), Datos.PV(:,i), Datos.WT(:,i), Datos.Price(:,i)]; %Datos de la hora i, de los 365 días del año
%     eva = evalclusters(data,'kmeans','silhouette','KList',1:20);
%     if i<13
%         subplot(4,3,i);
%         plot(eva);
%     elseif i==13
%         figure    
%         title('Núm cluster por evalclusters - hora 13-24')
%         subplot(4,3,i-12);
%         plot(eva);
%     else 
%         subplot(4,3,i-12);
%         plot(eva);
%     end
% end

%% Determinar número de k para el k-means por elbow method
% m = 20; %Número de k que se van a probar
% figure;
% for i=1:24  %Num horas
%     data = [Datos.Load(:,i), Datos.PV(:,i), Datos.WT(:,i), Datos.Price(:,i)]; %Datos de la hora i, de los 365 días del año
%     for k=1:m  
%         [~, ~, sumd, D] = kmeans(data, k, 'Replicates',5);
%         sumD(k,i) = sum(sumd);
%     end
%     if i<13
%         subplot(4,3,i);
%     elseif i==13
%         figure    
%         subplot(4,3,i-12);
%     else 
%         subplot(4,3,i-12);
%     end
%     plot(linspace(1,m,m),sumD(:,i))
%     hold on
%     scatter(linspace(1,m,m),sumD(:,i),'.')
%     xlabel('values of k'); 
%     ylabel(['Sum Dist hora: ', int2str(i)]); 
% end

%% Kmeans:
k = 4;
idx = zeros(365,24);    %tamaño 365 días x 24h
Cd = zeros(k,4,24);     %tamaño k x num variables x 24h
Horas = zeros(k, 24);   %tamaño k x 24h
for i=1:24
    data = [Datos.Load(:,i), Datos.PV(:,i), Datos.WT(:,i), Datos.Price(:,i)]; %Datos de la hora i, de los 365 días del año
    [idx(:,i), Cd(:,:,i), sumd, D] = kmeans(data, k, 'Replicates',5);
    for j=1:k
        Prob(j,i) = length (find(idx(:,i)==j))/365;
    end
end
Estocastico.Cd = Cd;
Estocastico.Prob = Prob;
Estocastico.k = k;
Estocastico.Deterministico.GD(:,:,1) = Datos.PV;
Estocastico.Deterministico.GD(:,:,2) = Datos.WT;
Estocastico.Deterministico.Load = Datos.Load;
Estocastico.Deterministico.Price = Datos.Price;
save('Centroides', 'Estocastico');


% %% Mean Shift Clustering
% idx2 = zeros(365,24);    %tamaño 365 días x 24h
% Cd2 = zeros(k,4,24);     %tamaño k x num variables x 24h
% Horas2 = zeros(k, 24);   %tamaño k x 24h
% bandwidth = .75;
% for i=1:24
%     data = [Datos.Load(:,i), Datos.PV(:,i), Datos.WT(:,i), Datos.Price(:,i)]; %Datos de la hora i, de los 365 días del año
%     [Cd2,idx2,clustMembsCell] = MeanShiftCluster(data',0.2);
%     largo(i,:) = size(Cd2);
% end


%% Visualización de 3 variables y sus centroides en la hora h
%(En total son 4 variables, imposible ver en 4d)
hora = 12;
figure;
h1 = scatter3(Datos.Load(:,hora), Datos.PV(:,hora), Datos.WT(:,hora), 15*ones(365,1), idx(:,hora),'filled');
xlabel('Carga [p.u]'); 
ylabel('Generacion PV [p.u]'); 
zlabel('Generacion eolica [p.u]');
hold on;
h2 = scatter3(Cd(:,1,hora),Cd(:,2,hora),Cd(:,3,hora),200*ones(k,1),[1:k]', 'p','filled');
legend([h1,h2], {'Grupos', 'Centroides'});
title('Visualización de 3 variables y sus centroides en espacio 3N - hora 12')

%% Visualización de todas las variables en 2N, hora h
figure
for hora=1:24
    data =Cd(:,:,hora);
    data = [data; Datos.Load(:,hora), Datos.PV(:,hora), Datos.WT(:,hora), Datos.Price(:,i)];
    Y = tsne(data,'Algorithm','exact');
    if hora<13
        subplot(4,3,hora);
    elseif hora==13
        figure    
        subplot(4,3,hora-12);
    else 
        subplot(4,3,hora-12);
    end
    hold on
    scatter(Y((k+1):end,1),Y((k+1):end,2),12*ones(365,1), idx(:,hora),'filled');
    scatter(Y(1:k,1),Y(1:k,2),200*ones(k,1),'p','filled');
    ylabel(['hora: ', int2str(hora)]);
end

%% Visualización de todas las variables en 3N, hora h
hora = 12;
data =Cd(:,:,hora);
data = [data; Datos.Load(:,hora), Datos.PV(:,hora), Datos.WT(:,hora), Datos.Price(:,i)];
Y = tsne(data,'Algorithm','exact','NumDimensions',3);
figure;
h1 = scatter3(Y((k+1):end,1),Y((k+1):end,2),Y((k+1):end,3),20*ones(365,1), idx(:,hora),'filled');
hold on;
h2 = scatter3(Y(1:k,1),Y(1:k,2),Y(1:k,3),200*ones(k,1),[1:k]','p','filled');
legend([h1,h2], {'Grupos', 'Centroides'});
title('Visualización de 4 variables en un espacio 3N - hora 12')

%% Graficos de las curvas con los centorides
figure
titulo = {['Curva de demanda k=', int2str(k)], ['curva de generación PV k=', int2str(k)], ['Curva de generación WT k=', int2str(k)], ['Curva de precio kWh k=', int2str(k)]};
for i=1:4               %Recorro las 4 variables
    subplot(2,2,i);
    hold on;
    for j=1:k           %Recorro los k centroides
        var_plot = reshape(Cd(j,i,:),1,24);
        plot(1:24, var_plot);
    end
    ylabel('Valor en p.u');
    xlabel('Horas')
    title(titulo(i));
 end
