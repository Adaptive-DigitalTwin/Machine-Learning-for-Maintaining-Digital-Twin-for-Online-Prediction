function [graph_data,fmin, min_out_pos] = plot_objective_with_surrogates(ax,bounds, surrogates, meas_data, obj_fun,  involved_data, data_counts, weightage_constant, discrete_size)

lower_limits= bounds(:,1);
upper_limits = bounds(:,2);

if strcmp(obj_fun, 'nmsq')
    f = @(x) obj_from_surrogate(x,1:size(bounds,1), x, bounds, surrogates, involved_data, data_counts, meas_data, weightage_constant);

elseif strcmp(obj_fun, 'ccr')
    f = @(x) Objectives_ROMs_corcoef(x, meas_data, surrogates);
end
%}

x = lower_limits(1):discrete_size(1):upper_limits(1);
y = lower_limits(2):discrete_size(2):upper_limits(2);


if isequal(size(bounds,1),2)
    [X,Y] = meshgrid(x,y);
    f_val = zeros(size(X));

    [lz, bz] = size(f_val);
    fmin = 1000;
    min_out_pos = [X(1,1), Y(1,1)];
    for i = 1:lz
        for j = 1:bz
            f_val(i,j) = f([X(i,j), Y(i,j)]);
            if f_val(i,j) < fmin
                fmin = f_val(i,j);
                min_out_pos = [X(i,j), Y(i,j)];
            end
        end
    end
    %figure1 = figure('visible','on');
    graph_data = {X,Y,f_val};
    %surf(ax, X,Y,Z);
elseif isequal(size(bounds,1),3)
    z = lower_limits(3):discrete_size(3):upper_limits(3);
    [X,Y,Z ] = meshgrid(x,y,z);
    f_val = zeros(size(X));
    
    [lz, bz, hz] = size(f_val);
    coordintaes_axis = zeros(sum([lz, bz, hz]), 3);
    fval_at_cod = zeros(sum([lz, bz, hz]), 1);
    fmin = 1000;
    min_out_pos = [X(1,1,1), Y(1,1,1), Z(1,1,1)];
    min_idx = [1,1,1];
    cum_search_point = 0;
    for i = 1:lz
        for j = 1:bz
            for k = 1:hz
                cum_search_point = cum_search_point + 1;
                coordintaes_axis(cum_search_point,:) = [X(i,j,k), Y(i,j,k), Z(i,j,k)];
                %f_val(i,j,k) = fval_at_cod(cum_search_point,:);
                f_val(i,j,k) = f([X(i,j,k), Y(i,j,k), Z(i,j,k)]);
                fval_at_cod(cum_search_point,:) = f_val(i,j,k);
                if f_val(i,j,k) < fmin
                    fmin = f_val(i,j,k);
                    min_out_pos = [X(i,j,k), Y(i,j,k), Z(i,j,k)];
                    min_idx = [i,j,k];
                end
            end
        end
    end
    disp(min_idx);
    %figure1 = figure('visible','on');
    %graph_data = {X(:,:,min_idx(3)),Y(:,:,min_idx(3)), f_val(:,:,min_idx(3))};
    graph_data = {X, Y, Z, f_val};
    
end
%figure1 = figure('visible','on');
%surf(ax, X,Y,Z);
if isequal(size(bounds,1),2)
    surf(ax, graph_data{1},graph_data{2},graph_data{end});
    %xlabel('STxx p value');
    %ylabel('SBxx p value');
    zlabel('Objective function (NMSE)');
    title('Surrogate Assisted Objective function plot');
elseif isequal(size(bounds,1),3)
    %subplot(2,1,1);
    %{
    surf(ax, X(:,:,min_idx(3)),Y(:,:,min_idx(3)), f_val(:,:,min_idx(3)));
    xlabel('STxx p value');
    ylabel('SBxx p value');
    zlabel('Objective function (NMSE)');
    %}
    scatter3(ax, coordintaes_axis(:,1), coordintaes_axis(:,2), coordintaes_axis(:,3), 20, fval_at_cod, 'filled');
    xlabel('STxx p value');
    ylabel('SBxx p value');
    zlabel('Zone 2 conductivity');
    cb = colorbar;    
    % create and label the colorbar
    %caxis([-20 20]);

    cb.Label.String = 'Objective function';
    
    %subplot(2,1,2);

    %{
    surf(Y(min_idx(1),:,:),Z(min_idx(1),:,:), f_val(min_idx(1),:,:));
    xlabel('STxx p value');
    ylabel('Zone 2 conductivity');
    zlabel('Objective function (NMSE)');
    title('Surrogate Assisted Objective function plot');
    %}
    %scatter3(ax, X(:,1),Y(:,2),Z(:,3),40,f_val, 'filled')    % draw the scatter plot

end
colorbar

     


