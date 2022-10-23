%Procedimiento que permite obtener los frentes no dominados

function [FrentesOrd, FrentesTotal] = Frente_Pareto(Poblacion)

%Parametros
TipoOpt =[0 0];                     %X1 X2 0=min 1=max
M_Fobj = Poblacion.FO;
NumFobj= size(M_Fobj , 2) ;
M_FobjAux=M_Fobj ;
%hold on;
%plot( M_Fobj(:,1), M_Fobj(:,2), 'bd') ;

% Se ordena la FO1
if TipoOpt(1)==1 %si fobjt1 es de maximizacion
    [~,P]= dsort(M_Fobj(:,1)); %Orden Fobj1 descedente 
else %si fobjt1 es de maximizacion
    [~,P]= sort(M_Fobj(:,1)) ;
end

%% Rutina que obtiene todos los frentes
X =1;
FrentesTotal = [];
while isempty(P) == 0 %Si P tiene elementos haga
    [FrentesOrd(X).Frente] = FrentesNDordenados(P, M_FobjAux, TipoOpt, NumFobj);
    k=1;
    for i=1:size(P,1)
        for j=1:size(FrentesOrd(X).Frente, 1)
            if P(i,1)==FrentesOrd(X).Frente(j,1)
                BorrarPos(k)=i;
                k=k+1;
            end
        end
    end
    P(BorrarPos) = [];
    BorrarPos = zeros(1);
    % Vector con los frentes ordenados
    tam = size(FrentesOrd(X).Frente,1);
    FrentesTotal = [FrentesTotal; FrentesOrd(X).Frente, ones(tam,1)*X];
    X=X+1;
end
% if NumFobj
%     for i=1:size(FrentesOrd,2)
%         if i==1
%             plot(M_Fobj(FrentesOrd(i).Frente,1), M_Fobj(FrentesOrd(i).Frente,2), 'LineWidth',2.5);
%         else
%             plot(M_Fobj(FrentesOrd(i).Frente,1), M_Fobj(FrentesOrd(i).Frente,2));
%         end
%     end
% end

%% Obtener frentes no dominados
function [FrentesOrd] = FrentesNDordenados(P,M_Fobj, TipoOpt, M)
    %Obtiene los frentes no dominados y los ordena
    %M= num funciones objetivo a comparar

    for i=2:M
        [P]=FrenteNoDominado(P,M_Fobj,i,TipoOpt);
        k=1;
        L=1;
        %Es necesario una ultima revisisón para sacar los dominados
        if TipoOpt(i)==0
            for j=1: size(P,1)-1
                %si la solucion j domina la j+1, la j+1 debe salir
                if M_Fobj(P(L,1),M)<=M_Fobj(P(j+1,1),M)
                    borrar(k,1) = j+1;
                    k=k+1;
                else
                    L=j+1;
                end
            end
        else
            for j=1: size(P,1)-1
                %si la solucion j domina la j+1, la j+1 debe salir
                if M_Fobj(P(L,1),M)>=M_Fobj(P(j+1,1),M)
                    borrar(k,1) = j+1;
                    k=k+1;
                else
                    L=j+1;
                end
            end
        end
        if k >1   %Si "Borrar" tiene elementos haga
            P(borrar) = [];
        end
    end
    FrentesOrd=P;
end

%% Obtener soluciones del conjunto P que pertenecen al frente no dominado
function [Fnd] = FrenteNoDominado(P,M_V_fobj, SegundaFuncion, TipoOpt)
    %Obtiene las solcuiones del conjunto P que pertenecen al frente no dominado
    %M_V_fobj = matriz de valores de las diferentes funciones objetivo de cada
    %uno de los individuos de la poblacion
    N = size(P,1);
    PosDividir = round(N/2);
    if N>1
        [I] = FrenteNoDominado(P(1:PosDividir,:),M_V_fobj,SegundaFuncion, TipoOpt);
        [S] = FrenteNoDominado(P([PosDividir+1:N],:),M_V_fobj,SegundaFuncion, TipoOpt);
        %Se verifica la dominancia respecto a la segunda FO
        if TipoOpt(SegundaFuncion)==0
            if M_V_fobj(S(size(S,1)), SegundaFuncion)<=M_V_fobj(I(size(I,1)), SegundaFuncion)
                %Dominancia fuerte
                M=[I;S];
            else
                M=I;
            end
        end
        if TipoOpt(SegundaFuncion)==1
            if M_V_fobj(S(size(S,1)), SegundaFuncion)>=M_V_fobj(I(size(I,1)), SegundaFuncion)
                %Dominancia fuerte
                M=[I;S];
            else
                M=I;
            end
        end
        Fnd=M;
    else
        Fnd=P;
    end
end 

end
