%% Función que permite hacer un grafo orientado para observar el sistema y la GD instalada
function  Grafo(Sistema, Critico, pob_grafo)
    figure
    nodosS = Sistema.Sistemas(pob_grafo).curva(1,1).branch(:,1);
    nodosT = Sistema.Sistemas(pob_grafo).curva(1,1).branch(:,2);
    G = graph(nodosS,nodosT);
    
    %% Legend del grafo (Es necesario hacerle la judia a Matlab para que permita hacer un legend ficticio)
    scatter([NaN NaN], [NaN NaN],1,[178,34,34]/256,'s','filled')
    hold on;
    scatter([NaN NaN], [NaN NaN],1,[255,165,0]/256,'s','filled')
    scatter([NaN NaN], [NaN NaN],1,[30,144,255]/256,'s','filled')
    scatter([NaN NaN], [NaN NaN],5,[255,165,0]/256,'o','filled')
    scatter([NaN NaN], [NaN NaN],5,[30,144,255]/256,'o','filled')
    set(gca, 'ColorOrderIndex', 1) % Reset the default color to the beginning

    %% Graficar las tensiones de las barras
    Tensiones = Critico.Tension.FP(pob_grafo).bus(:,8);
    % Plot and highlight the graph
    for i=1:Sistema.nb
       nLabel(i) = {strcat(int2str(i), ': ', sprintf(' %.3f',Tensiones(i)), 'p.u')};
    end
    
    %% Plot del grafo con los nodos
    p = plot(G, 'NodeLabel',nLabel);
    
    %% Añadimos la leyenda al grafico para los datos ficiticios
    %El legen es realmente del scatter, se ploteron datos Nan para engañar al matlab
    legend('Nodo Slack', 'N habilitado GD solar', 'N habilitado GD eolica', 'GD solar instalada','GD eolica instalada','Location','southeast')

    %% Acondicionamiento del grafo
    % Marcadores, colores y tamaños
    p.EdgeColor = [0 0 0];                          %tramos de red color negro
    marker = repmat({'square'},1,Sistema.nb);       %Todos los marcadores cuadrados
    size_graph = ones(1,Sistema.nb)*4;              %Todos los marcadores tamaño 4
    color = repmat([128,128,128]/256,Sistema.nb,1); %Todos los marcadores grises
    size_graph(Sistema.slack) = 8;                 
    color(Sistema.slack,:) = [178,34,34]/256;       %Slack rojo
    
    %% Acondicionamiento de los nodos segun lo que permiten instalar
    pos = find(Sistema.Sistemas(pob_grafo).curva(1,1).bus(:,14)==1);   %posicion de los buses solares
    for i=1:length(pos)
        color(pos(i),:) = [255,165,0]/256;
    end
    pos = find(Sistema.Sistemas(pob_grafo).curva(1,1).bus(:,14)==2);   %posicion de los buses eolicos
    for i=1:length(pos)
        color(pos(i),:) = [30,144,255]/256;
    end
    
    %% Acondicionamiento de los nodos con GD
    if size(Sistema.Sistemas(pob_grafo).curva(1,1).gen,1)>1
        pos = Sistema.Sistemas(pob_grafo).curva(1,1).gen(2:end,1);  %Cambio el marker de los nodos con GD
        marker(pos) = {'o'};
        size_graph(pos) = 12;
    end
    p.Marker = marker;
    p.MarkerSize = size_graph;
    p.NodeColor = color;
    title('Grafo orientado - Sistema 33 barras - Caso Deterministico mas critico en tension');
       
end