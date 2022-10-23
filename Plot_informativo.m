%Funcion que permite hacer graficas co ndifernete información

function Plot_informativo(Critico_deter, pob_grafo)
    % Graficos de potencia
    figure;
    demanda = sum(Critico_deter.Tension.FP(pob_grafo).bus(:,3))*1e3;
    pot_slack = Critico_deter.Tension.FP(pob_grafo).gen(1,2)*1e3;
    pot_GD = 0;
    if size(Critico_deter.Tension.FP(pob_grafo).gen,1) > 1
        pot_GD = sum(Critico_deter.Tension.FP(pob_grafo).gen(2:end,2))*1e3;
    end
    leyenda = {'P Demandada','P Slack','P GD'};
    X = categorical(leyenda);
    X = reordercats(X,leyenda);
    Y = [demanda; pot_slack; pot_GD];
    subplot(1,2,1);
    b = bar(X,Y);
    titulo = "Potencias en sistema 33 barras - dia " + int2str(Critico_deter.Tension.d(pob_grafo)) + " - hora " +  int2str(Critico_deter.Tension.h(pob_grafo));
    title(titulo);
    ylabel('Potencia [kW]');
    % Grafico de torta
    subplot(1,2,2);
    pie(Y);
    legend(leyenda,'Location','southeast');

end