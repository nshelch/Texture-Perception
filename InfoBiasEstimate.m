%% Loading data
% Folder locations (Move this into a startup script)
hostEnv = getenv('computername');
if strcmpi(hostEnv, 'DESKTOP-LEG2SE6')
    pathLoc = 'C:/Users/nshel/Box/BensmaiaLab/';
elseif strcmpi(hostEnv, 'OBA-PC-01')
    pathLoc = 'C:/Users/somlab/Box/BensmaiaLab/';
elseif strcmpi(hostEnv, 'DESKTOP-FB47T9U')
    pathLoc = 'C:/Users/nshelch/Box/BensmaiaLab (Natalya Shelchkova)/';
end

dataLoc = fullfile(pathLoc, 'Texture Perception/Data/');

% Load Data
if exist(fullfile(dataLoc, 'cData.mat'), 'file')
    load(fullfile(dataLoc, 'cData.mat'))
    load(fullfile(dataLoc, 'InfoData_2024_2_15.mat'))
end
