function [] = createPlots(fileName, schedule, priorities)
    load(fileName)
    if nargin < 3
        priorities = NaN;
        server = false;
    else
        table = ptable(2:end,:);
        server = true;
    end

    colors = ['r' 'c' 'g' 'm' 'b' 'y'];
    priorColor = [.5 .5 .5];
    serverColor = [.6 .1 .4];
    activeBarSize = 1;
    if server
        activeBarSize = 1.3;
    end
    N = size(table,1);
    if server
        N = N+1;
    end

    fig = figure;
    % title('Cronograma de execu??o de tarefas')
    fig.Name = ('Cronograma de execucao de tarefas');
    
    if server
        iapP = 1; % conta as inicializacoes
        iapA = 1; % conta a tarefa atual (a ser executada)
        iapE = 0; % conta o tempo de execucao ja utilizado em iapA
        atlim = [NaN, NaN];
    end

    for i=1:N
        subplot(N,1,i)
        hold on
        axis([1 length(schedule) -.5 1.5])
        if server
            axis([1 length(schedule) -.5 max(max(priorities))+.5])
        end
        %daspect([1 1 1])
        set(gca,'YTickLabel',[]);
        ylabel(sprintf('Tarefa %d',i))
        if server && (i == N)
            ylabel('Server')
        end

        tlim = [NaN, NaN];
        for t=1:length(schedule)
            if ~server || (i< N)
                if (( mod(t-1,table(i,3)) == mod(table(i,1)-1,table(i,3)) ) ...
                        && ( table(i,1) <= t ))
                    plot([t t],[0 activeBarSize], 'k')
                end
                if schedule(t) == i
                    if isnan(tlim(1))
                        tlim = [t, t+1];
                    else
                        tlim(2) = t+1;
                    end
                else
                    if ~isnan(tlim(1))
                        x = [tlim(1) tlim(2) tlim(2) tlim(1)];
                        y = [0 0 .5 .5];
                        fill(x,y,colors(mod(i-1,6)+1))
                        tlim = [NaN, NaN];
                    end
                end
            end
            if server && (i == N)
                if (( mod(t-1,ptable(1,3)) == mod(ptable(1,1)-1, ptable(i,3)) )...
                        && ( ptable(i,1) <= t ))
                    plot([t t t+ptable(1,2)],[0 1 0],'Color', priorColor)
                    plot([t t],[0 activeBarSize], 'k')
                end
                try
                    if atable(iapP,1) == t
                        plot([t t],[0 1], 'k')
                        arrow = [t 1;
                                 t+.1 0.8;
                                 t-.1 0.8];
                        fill(arrow(:,1),arrow(:,2),'k')
                        iapP = iapP + 1;
                    end
                catch ME
                    if ME.message == 'Index exceeds matrix dimensions.'
                        fprintf('No more aperiodic jobs on list\n',NaN)
                    else
                        rethrow(ME)
                    end
                end
                if schedule(t) == -1
                    iapE = iapE + 1;
                    if isnan(atlim(1))
                        atlim = [t, t+1];
                    else
                        atlim(2) = t+1;
                    end
                else
                    if ~isnan(atlim(1))
                        x = [atlim(1) atlim(2) atlim(2) atlim(1)];
                        y = [0 0 .5 .5];
                        fill(x, y, serverColor)
                        atlim = [NaN, NaN];
                    end
                end
                try
                    if iapE == atable(iapA,2)
                        iapA = iapA + 1;
                        iapE = 0;
                    end
                catch ME
                    if ME.message == 'Index exceeds matrix dimensions.'
                        % fprintf('No more aperiodic jobs on list\n',NaN)
                    else
                        rethrow(ME)
                    end
                end
            end
        end
        
        if server && (i < N)
            plot(1:length(schedule),priorities(i+1,:),'Color', priorColor)
        end
        plot([1 length(schedule)], [0 0], 'k')
    end
    
    %currentFigure = gcf;
    %title(currentFigure.Children(end), 'blah');
    
    %suptitle('Cronograma de execucao de tarefas')
end