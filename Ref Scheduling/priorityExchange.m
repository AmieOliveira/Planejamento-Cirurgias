function [schedule,priorities] = priorityExchange(fileName)
    if nargin == 0
        fileName = 'table.mat';
        warning('Filename not defined, setting to table.mat');
    end
    load(fileName);
    
    % Primeira "tarefa periodica" e o servidor
    try
        server = ptable(1,:); %caracteristicas do servidor (tempo inicial, quantidade, periodo)
        pjobs = ptable(2:end,:);%caracteristicas das tarefas periodicas
    catch
        error('Variavel ptable n?o esta bem definida')
    end
    try
        ajobs = atable;%caracteristicas das tarefas aperiodicas
    catch
        error('Variavel atable n?o esta bem definida')
    end
    np = size(pjobs,1);
    na = size(ajobs,1);
    
    pactive = zeros(np+1,1);%Indicador de que uma tarefa periodica esta ativa
    cp = zeros(np,1);%Quantas etapas das tarefas periodicas ativas foram executadas
    aactive = zeros(na,1);%Indicador de que uma tarefa aperiodica esta ativa
    ca = zeros(na,1);%Quantas etapas das tarefas aperiodicas ativas foram executadas
    prioServ = zeros(np+1,1);%Prioridade definida do servidor para o servidor(o primeiro)...
                                %e para cada tarefa periodica i+1
    
    prior = zeros(np,1);%ordenacao das tarefas periodicas em prioridade
    
    %defini??o das prioridades das tarefas periodicas
    temp = pjobs(:,3);
    for i = 1:np
        [~,prior(i)]=min(temp);
        temp(prior(i)) = inf;
    end
    
    %defini??o do tempo maximo de execu??o do programa para uma execu??o periodica e
    %que execute todas as tarefas aperiodicas
    if length(pjobs(:,1))~=1
        mmc = lcm(pjobs(1,3),pjobs(2,3));
        for i = 3:np
            mmc = lcm(mmc,pjobs(i,3));
        end
    else
        mmc = pjobs(1,3);
    end
    %se o come?o de uma tarefa aperiodica for maior que um ciclo, deve-se
    %multiplicar o mesmo
    mmc = mmc*ceil(max((ajobs(:,1)+3)/mmc))+1;
    
    
    run = true;
    time = 1;
    schedule = zeros(1,mmc-1);
    priorities = zeros(np+1,mmc-1);
    
    while run
        %verifica se tem que ativar uma tarefa aperiodica
        for i = 1:na
            if time == ajobs(i,1)
                aactive(i) = 1;
            end
        end
        %verifica se tem que ativar uma tarefa periodica
        for i = 1:np
            if mod(time-1,pjobs(i,3))==mod(pjobs(i,1)-1,pjobs(i,3)) && pjobs(i,1) <= time
                if pactive(i) == 1 
                    %se a tarefa ja estiver ativa, o programa perdeu a
                    %deadline
                    warning('Missed deadline, returning current schedule');
                    return
                end
                pactive(i) = 1;
            end
        end
        %verifica se tem que adicionar prioridade ao servidor
        if mod(time-1,server(1,3))==server(1,1)-1
            prioServ(1) = prioServ(1)+server(1,2); 
        end
        priorities(:,time) = prioServ;
        %? verificado em todas as tarefas periodicas inativas se elas 
            %possuem alguma prioridade de servidor, caso positivo, esta 
            %cede uma prioridade de servidor para a tarefa periodica ativa
            %de maior prioridade, caso n?o tenha nenhuma tarefa periodica
            %ativa, a prioridade ? gasta sem ser cedida a nenhuma outra
            %tarefa
            for i = 1:np
                if (pactive(prior(i)) == 0) && (prioServ(prior(i)+1) > 0)
                    prioServ(prior(i)+1) = prioServ(prior(i)+1) - 1;
                    j = i + 1;
                    nfound = true;
                    while(j<= np && nfound)
                        if pactive(prior(j)) == 1
                            nfound = false;
                            prioServ(prior(j)+1) = prioServ(prior(j)+1) + 1;
                        end
                        j = j+1;
                    end
                end
            end
        %se aprun for verdadeiro, uma tarefa aperiodica foi executada nesse
        %tempo
        aprun = false;
        %se tiver alguma prioridade no servidor e tiver uma tarefa
        %aperiodica ativa, esta ser? executada nesse tempo, gastando uma
        %unidade de prioridade do servidor
        if(prioServ(1) > 0)
            [val, ind] = max(aactive);
            if val > 0
                ca(ind) = ca(ind)+1;
                schedule(time) = -1;
                aprun = true;
                prioServ(1) = prioServ(1) - 1;
                %se a tarefa terminar, ela deixa de ser ativada
                if ca(ind) == ajobs(ind,2)
                    aactive(ind) = 0;
                end
            else
                %caso n?o tenha nenhuma tarefa aperiodica ativa, o servidor
                %ir? ceder uma prioridade de servidor para a tarefa com maior
                %prioridade ativa, se nenhuma estiver ativa, o servidor
                %n?o cede nada
                i = 1;
                nfound = true;
                while(i<= np && nfound)
                    if pactive(prior(i)) == 1
                        nfound = false;
                        prioServ(1) = prioServ(1) - 1;
                        prioServ(prior(i)+1) = prioServ(prior(i)+1) + 1;
                    end
                    i = i+1;
                end
            end
        end
        %se nenhuma tarefa aperiodica foi executada
        if ~aprun
            i = 1;
            nfound = true;
            %encontra a tarefa periodica ativa de maior prioridade entre as
            %tarefas periodicas
            while(i<= np && nfound)
                if pactive(prior(i)) == 1
                    nfound = false;
                    [val, ind] = max(aactive);
                    %se ela tiver alguma prioridade de servidor e alguma
                    %tarefa aperiodica estiver ativa, a mesma ? executada
                    %no lugar da tarefa periodica, gastando uma prioridade,
                    %se n?o, a tarefa periodica ? executada
                    if val > 0 && prioServ(prior(i)+1) > 0
                        ca(ind) = ca(ind)+1;
                        schedule(time) = -1;
                        prioServ(prior(i)+1) = prioServ(prior(i)+1) - 1;
                        if ca(ind) == ajobs(ind,2)
                            aactive(ind) = 0;
                        end
                    else
                        schedule(time) = prior(i);
                        cp(prior(i)) = cp(prior(i)) + 1;
                        if cp(prior(i)) == pjobs(prior(i),2)
                            cp(prior(i)) = 0;
                            pactive(prior(i)) = 0;
                        end
                    end
                end
                i = i+1;
            end
            if nfound
                schedule(time) = NaN;
            end
            
        end

        time = time+1;
        if time == mmc
            run = false;
        end
    end
    
end