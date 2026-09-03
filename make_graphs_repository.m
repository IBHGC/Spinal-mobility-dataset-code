clear
clc
close all

% This function loads the full spinal mobility data and plots some example
% graphs.

% Local folder with data
folder = [fileparts(mfilename('fullpath')) '\Data\'];

f = figure;
colors = lines(15);

for nSubject = 1 : 15
    file = [folder '\Subject_' sprintf('%02d',nSubject) '.xlsx'];
    assert(exist(file, 'file'))

    % Read from excel file
    data = readcell(file);

    % Flexion-extension
    make_plots(data(3:9, 2:end), colors(nSubject,:), 1)
    
    % Axial rotation
    make_plots(data(11:17, 2:end), colors(nSubject,:), 4)
    
    % Lateral bending
    make_plots(data(19:25, 2:end), colors(nSubject,:), 7)
    
end


% Add axes labels and limits
titles = {'Flexion-extension', 'Axial rotation', 'Lateral Bending'};
ylabs = {'Relative mobility of T1-L1 [°]', ...
         'Relative mobility of L1-S1 [°]', ...
         'Absolut mobility of sacrum [°]'};

ylims = {[0 100 -65 82], ...
         [0 100 -100 100], ...
         [0 100 -60 45]};

for row = 1:3
    for col = 1:3
        subplot(3,3,(row-1)*3 + col)  % 

        title(titles{row}) % Rows have same title and limits
        axis(ylims{row})

        ylabel(ylabs{col}) % Columns have same Y axis labels
    end
end




function make_plots(X, color, subplotN)
% make_plots(X, color, subplotN) plots the data from the raw excel files

    X = cell2mat(X);
    if all(ismissing(X(:)))
        % Skip if missing data
        return
    end

    % Fix slope for consistency. Some excercises were left-to-right or the
    % other way around.
    X = fix_slope(X);    

    % T1-L1 mobility
    y = X(1,:) - X(5,:);  % Mobility of T1 minus L1
    subplot(3,3,subplotN)
    make_plot(y, color);

    % L1-S1 mobility
    y = X(5,:) - X(end,:);
    subplot(3,3,subplotN+1)
    make_plot(y, color);
    
    % Sacrum absolute mobility
    y = X(end,:);
    subplot(3,3,subplotN+2)
    make_plot(y, color);

end



function make_plot(y, color)
    % make_plot(y, color) makes a plot after translating the mobility curve
    % so that the middle point (rest position) is zero.

    x = linspace(0,100,21);  % X axis as percentage of movement. The mid point is "rest"

    % Zero in the middle of movement, for convenience
    y = y - y(11);

    plot(x, y, 'Color',  color);
    hold on;

end



function y = fix_slope(y)
    % Makes all plots positive for readability

    y1 = y(1,:)';
    f = fit((1:length(y1))', y1, 'poly1');

    if f.p1 < 0
        y = -y;
    end

end

