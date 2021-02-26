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

%pathBst = '/Users/guiomar/Documents/SOFTWARE/brainstorm3';
pathBst = '/media/data/guiomar/app-brainstorm-1_import_anatomy/brainstorm3';

if ~isdeployed
    addpath(genpath('jsonlab'));
    addpath(genpath(pathBst));
end

%% Load config.json
% Load inputs from config.json
% Inputs are stored in config.input1, config.input2, etc
% config = loadjson('config.json','ParseStringArray',1); % requires submodule to read JSON files in MatLab
%fid = fopen('config.json')
%config_json = char(fread(fid)')
%fclose(fid)
config = jsondecode(fileread('config.json'))

%% Some paths

% BrainstormDbDir = '/Users/guiomar/Projects/brainstorm_db';
BrainstormDbDir = '/media/data/guiomar/brainstorm_db';

% AnatDir = fullfile(config.output);
AnatDir = '/media/data/guiomar/data/anat/';
ReportsDir = 'out_dir/';
DataDir = 'out_data/';

%% START BRAINSTORM
% Start Brainstorm
if ~brainstorm('status')
    brainstorm server
end
% Set Brainstorm database directory
bst_set('BrainstormDbDir',BrainstormDbDir)
% Set Brainstorm database directory interactively
% BrainstormDbDir = gui_brainstorm('SetDatabaseFolder');
% Get Brainstorm database directory
% BrainstormDbDir = bst_get('BrainstormDbDir');

%% CREATE PROTOCOL 
disp(['1) Create protocol']);

ProtocolName = 'Protocol01'; % The protocol name has to be a valid folder name (no spaces, no weird characters...)
SubjectName = 'Subject01';

% sProtocol.Comment = ProtocolName;
% sProtocol.SUBJECTS = [home 'anat'];
% sProtocol.STUDIES = [home 'data'];
% db_edit_protocol('load',sProtocol);

% Find existing protocol
iProtocol = bst_get('Protocol', ProtocolName);

% SELECT CURRENT PROTOCOL
% if isempty(iProtocol)
%     error(['Unknown protocol: ' ProtocolName]);
% end
% % Select the current procotol
% gui_brainstorm('SetCurrentProtocol', iProtocol);

% CREATE NEW PROTOCOL
if ~isempty(iProtocol)
    % Delete existing protocol
    gui_brainstorm('DeleteProtocol', ProtocolName);
end
% Create new protocol
gui_brainstorm('CreateProtocol', ProtocolName, 0, 0);


%% Start report
% Start a new report
bst_report('Start');
% Reset colormaps
bst_colormaps('RestoreDefaults', 'meg');

%% IMPORT ANATOMY
disp(['2) Import anatomy']);
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
disp(['> Done!']);
