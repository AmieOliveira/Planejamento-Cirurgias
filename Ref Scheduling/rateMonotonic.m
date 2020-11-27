function schedule = rateMonotonic(fileName)
    if nargin == 0
        fileName = 'table.mat';
        warning('Filename not defined, setting to table.mat');
    end
    load(fileName);
    
    run = true;
    time = 1;
    try 
        n = length(table(:,1));%caracteristicas das tarefas
    catch
        error('Variavel table não esta bem definida')
    end
    active = zeros(n,1);%Indicador de que uma tarefa esta ativa
    prior = zeros(n,1);%ordenacao das tarefas em prioridade(cada elemento é o indice da tarefa)
    c = zeros(n,1);%Quantas etapas das tarefas ativas foram executadas
    
    %definição das prioridades das tarefas periodicas
    temp = table(:,3);
    for i = 1:n
        [~,prior(i)]=min(temp);
        temp(prior(i)) = inf;
    end
    
    %definição do tempo maximo de execução do programa para uma execução periodica
    if length(table(:,1)) ~= 1
        mmc = lcm(table(1,3),table(2,3));
        for i = 3:n
            mmc = lcm(mmc,table(i,3));
        end
    else
        mmc = table(1,3);
    end
    mmc = mmc+1;
    schedule = zeros(1,mmc);
    
    
    while run
        %verifica se tem que ativar uma tarefa periodica
        for i = 1:n
            if mod(time-1,table(i,3))==mod(table(i,1)-1,table(i,3)) && table(i,1) <= time
                if active(i) == 1 
                    %se a tarefa ja estiver ativa, o programa perdeu a
                    %deadline
                    warning('Missed deadline, returning current schedule');
                    return
                end
                active(i) = 1;
            end
        end
        
        %Aqui é verificado, na ordem do vetor com as tarefas ordenadas por
        %prioridade, se cada tarefa está ativa, caso o loop encontre uma
        %ativa, a mesma é executada e o loop acaba
        i = 1;
        nfound = true;
        while(i<= n && nfound)
            if active(prior(i)) == 1
                nfound = false;
                schedule(time) = prior(i);
                c(prior(i)) = c(prior(i)) + 1;
                %Se a tarefa executou o que tinha que executar, ela deixa
                %de estar ativa
                if c(prior(i)) == table(prior(i),2)
                    c(prior(i)) = 0;
                    active(prior(i)) = 0;
                end
            end
            i = i+1;
        end
        %Caso nenhuma tarefa tenha sido encontrada, nenhuma tarefa é
        %encontrada
        if nfound
            schedule(time) = NaN;
        end
        
        %O loop continua até que o tempo atinga o mmc
        time = time+1;
        if time == mmc
            run = false;
        end
    end
end
        