clear
clc
close all


%%
% This script downloads the data from the repository "Spinal mobility data"
% and plots spinal mobility in flexion/extension, axial rotation and
% lateral bending.
% VERGARI, Claudio; Merat, Ulyss; Crezé, Maud; Pillet, Hélène, 2026, "Spinal mobility data", 
% DOI: https://doi.org/10.57745/HKPJO1 

download_url = 'https://entrepot.recherche.data.gouv.fr/api/access/datafile/:persistentId?persistentId=doi:';
repository_DOI  = '10.57745';
% These are the DOIs associated with each subject CSV file
data_DOIs = {'JOISHA','NHNQWG', '9UEJK8','5GHNZF','QFGPQ3','LHRHDX',...
    'WSNCQY','DESVZB','NZXBCG','4VQCRN','CKBOCG','QSFHKN','KN4RWM','HHNY1Y','UHEEDS'};


Nsubjects = length(data_DOIs);

% Helper function to retrieve coordinates of a specific landmark
retrieveCoords = @(N, landmark) [data.([landmark, '_x'])(N), data.([landmark, '_y'])(N), data.([landmark, '_z'])(N)];

% Local folder to download data
folder = [fileparts(mfilename('fullpath')) '\'];

f = figure;
colors = lines(15);

for nSubject = 1:Nsubjects
    
    % Download data for nSubject
    disp(['Downloading and processing subject ' num2str(nSubject)])
    file_url = [download_url, repository_DOI, '/', data_DOIs{nSubject}];
    websave([folder 'repository_data.csv'], file_url);

    % Read data
    data = readcell([folder 'repository_data.csv']);

    % Flexion-extension
    make_plots(data(2:8, 2:end), colors(nSubject,:), 1)
    
    % Axial rotation
    make_plots(data(9:15, 2:end), colors(nSubject,:), 4)
    
    % Lateral bending
    make_plots(data(16:22, 2:end), colors(nSubject,:), 7)
    
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

