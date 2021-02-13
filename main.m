% brainlife.io App for Brainstorm MEEG data analysis
%
% Author: Guiomar Niso
%
% Copyright (c) 2020 brainlife.io 
%
% Indiana University

%% Add submodules
% Submodules: libraries necessary to run the code
% Added to this App GitHub repository and automatically downloaded with the App 
% Need to add them MatLab path:
addpath(genpath(pwd))
addpath(genpath('/Users/guiomar/Documents/SOFTWARE/brainstorm3'))

%% Load config.json
% Load inputs from config.json
% Inputs are stored in config.input1, config.input2, etc
config = loadjson('config.json','ParseStringArray',1); % requires submodule to read JSON files in MatLab

%% Parameters
% Subject name
SubjectName = 'Subject01';
ProtocolName = 'Protocol01'; % The protocol name has to be a valid folder name (no spaces, no weird characters...)
AnatDir = fullfile(config.output);
ReportsDir = 'out_dir/';
DataDir = 'out_data/';

%% START BRAINSTORM
% Start brainstorm without the GUI
if ~brainstorm('status')
%   brainstorm nogui
    brainstorm server
end

%% CREATE PROTOCOL 
disp([10 '> Step #1: Create protocol' 10]);

% Find existing protocol
p = bst_get('Protocol', ProtocolName);
if ~isempty(p)
    % Delete existing protocol
    gui_brainstorm('DeleteProtocol', ProtocolName);
end

% Create new protocol
gui_brainstorm('CreateProtocol', ProtocolName, 0, 0);

% Start a new report
bst_report('Start');
% Reset colormaps
bst_colormaps('RestoreDefaults', 'meg');

%BrainstormDbDir = gui_brainstorm('SetDatabaseFolder');
BrainstormDbDir = bst_get('BrainstormDbDir');

%% IMPORT ANATOMY 
disp([10 '> Step #2: Import anatomy' 10]);
% Process: Import FreeSurfer folder
bst_process('CallProcess', 'process_import_anatomy', [], [], ...
    'subjectname', SubjectName, ...
    'mrifile',     {AnatDir, 'FreeSurfer'}, ...
    'nvertices',   15000, ...
    'nas', [0, 0, 0], ...
    'lpa', [0, 0, 0], ...
    'rpa', [0, 0, 0], ...
    'ac',  [0, 0, 0], ...
    'pc',  [0, 0, 0], ...
    'ih',  [0, 0, 0]);
% This automatically calls the SPM registration procedure because the AC/PC/IH points are not defined

% //// FUTURE: load fiducial points from file if available: nas, lpa, rpa

%% EXPLORE ANATOMY
% disp([10 '> Step #3: Explore anatomy' 10]);
% % Get subject definition
% sSubject = bst_get('Subject', SubjectName);
% % Get MRI file and surface files
% MriFile    = sSubject.Anatomy(sSubject.iAnatomy).FileName;
% CortexFile = sSubject.Surface(sSubject.iCortex).FileName;
% HeadFile   = sSubject.Surface(sSubject.iScalp).FileName;
% % Display MRI
% hFigMri1 = view_mri(MriFile);
% hFigMri3 = view_mri_3d(MriFile, [], [], 'NewFigure');
% hFigMri2 = view_mri_slices(MriFile, 'x', 20); 
% pause();
% % Close figures
% close([hFigMri1 hFigMri2 hFigMri3]);
% % Display scalp and cortex
% hFigSurf = view_surface(HeadFile);
% hFigSurf = view_surface(CortexFile, [], [], hFigSurf);
% hFigMriSurf = view_mri(MriFile, CortexFile);
% % Figure configuration
% iTess = 2;
% panel_surface('SetShowSulci',     hFigSurf, iTess, 1);
% panel_surface('SetSurfaceColor',  hFigSurf, iTess, [1 0 0]);
% panel_surface('SetSurfaceSmooth', hFigSurf, iTess, 0.5, 0);
% panel_surface('SetSurfaceTransparency', hFigSurf, iTess, 0.8);
% figure_3d('SetStandardView', hFigSurf, 'left');
% pause();
% % Close figures
% close([hFigSurf hFigMriSurf]);

%% SAVE REPORT
% Save and display report
ReportFile = bst_report('Save', []);
if ~isempty(ReportsDir) && ~isempty(ReportFile)
    bst_report('Export', ReportFile, ReportsDir);
else
    bst_report('Open', ReportFile);
end

%% SAVE DATA
copyfile([BrainstormDbDir,'/',ProtocolName], DataDir);

%% DONE
disp([10 '> Done.' 10]);