function [FO, V_barras] = FlujoPotencia_GD(Sistema, GD_vector)



Barras = Sistema.Barras.Barra;
PD = Sistema.Barras.PD;
QD = Sistema.Barras.QD;
QC = Sistema.Barras.QC;
Ni_Renumerado = Sistema.Lineas.Ni_Renumerado;
Nj_Renumerado = Sistema.Lineas.Nj_Renumerado;
R = Sistema.Lineas.R;
X = Sistema.Lineas.X;


Max_Error = 1e-9;           %Error maximo
Delta_Error = 1e6;          %Delta de error
iter=0;                     %Iteraciones
nb = length(Barras(:,1));   %Número de barras
nl = length(Ni_Renumerado(:,1));       %Número de lineas
Sia = PD - (100/Sistema.Sb)*GD_vector + 1i*QD - 1i*QC ;            %Potencia aparente
Zaa = R + 1i*X;              %Impedancia de las lineas


%%Definición de variables
Via = ones(nb,1);           %Tensión en barras
JIa = zeros(nl,1);          %Corrientes de linea
ILa = zeros(nl,1);          %Corrientes de linea
DeltaSa = zeros(nb,1);      %Error potencia nodal

%% Ciclo del barrido

while Delta_Error >= Max_Error
    %% Paso 1: Calcular las corrientes nodales
    Ina = conj(Sia./Via);
        
    %% Paso 2: Calcular corrientes de linea
    JIa = Ina;
    ILa = zeros(nl,1); %Corrientes de linea
    for  k = nl:-1:1
        envio = Ni_Renumerado(k);
        recibo = Nj_Renumerado(k);
        ILa(k) = ILa(k) + JIa(recibo);
        JIa(envio) = JIa(envio) + ILa(k);
    end
    
    %% Paso 3: Tension en las barras 
    for k = 1:nl
       envio = Ni_Renumerado(k); 
       recibo = Nj_Renumerado(k);
       Via(recibo) = Via(envio) - Zaa(k)*ILa(k);
    end
    
    %% Delta de error
    Delta_Sia = abs(Via.*conj(Ina) - Sia);
    Delta_Error = max(Delta_Sia);
    iter = iter +1;
end

%% Resultado  
% Tensiones
V_barras = Via;
% Perdidas
Perdidas = R .* ILa.^2;
PerdidasActivas = abs(Perdidas);
PerdidasActivas_totales = sum(PerdidasActivas)*100e6/1000;
FO(1,1)= PerdidasActivas_totales;

end

