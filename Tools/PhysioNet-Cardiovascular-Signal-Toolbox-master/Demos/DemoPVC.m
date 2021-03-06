%	OVERVIEW:
%       This is demo for the PVC detector included in the HRV PhysioNet 
%       Cardiovascular Signal Toolbox 
%
%       Provided data are a subset from the MIT Physionet Arrhythmia
%       dataset
%       It uses the default parameters in the configuration file using 
%       'demo_PVC' option : InitializeHRVparams('demoPVC').
%
%   OUTPUT:
%       HRV Metrics exported to .cvs files
%
%   DEPENDENCIES & LIBRARIES:
%       https://github.com/cliffordlab/PhysioNet-Cardiovascular-Signal-Toolbox
%   REFERENCE: 
%       Vest et al. "An Open Source Benchmarked HRV Toolbox for Cardiovascular 
%       Waveform and Interval Analysis" Physiological Measurement (In Press), 2018. 
%	REPO:       
%       https://github.com/cliffordlab/PhysioNet-Cardiovascular-Signal-Toolbox
%   ORIGINAL SOURCE AND AUTHORS:     
%       Giulia Da Poian   
%	COPYRIGHT (C) 2018 
%   LICENSE:    
%       This software is offered freely and without warranty under 
%       the GNU (v3 or later) public license. See license file for
%       more information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear; clc; close all;

run(['..' filesep 'startup.m'])

% Remove old files generated by this demo
OldFolder = ['OutputData' filesep 'Results_PVC'];
if exist(OldFolder, 'dir')
    rmdir(OldFolder, 's');
    fprintf('Old Demo Folder deleted \n \n');
end

sigName = '105';

% Initialize settings for demo
HRVparams = InitializeHRVparams('demoPVC');  

% load mat file, and use gain and baseline information from hea file

sig = load([HRVparams.readdata filesep sigName 'm']);
siginfo = readheader([HRVparams.readdata filesep sigName 'm.hea']);
% use first 5 minutes of the first channel
lead = 1;
ecg = (sig.val(lead,1:HRVparams.Fs*300)-siginfo.adczero(lead))./siginfo.gain(lead);

PVCs = PVC_detect(ecg',sigName,HRVparams);

figure(1)
plot(ecg,'LineWidth',1)
xlabel('Samples (@360 Hz)','FontSize',16)
ylabel('mV','FontSize',16)
hold on 
plot(PVCs, ecg(PVCs), 'o','MarkerSize',8);

% load annotations to compare PVCs from manually annotated by experts

[pos,type] = read_ann([HRVparams.readdata filesep sigName],'atr');
annotatedPVCs = pos(type=='V' & pos <= HRVparams.Fs*300);

plot(annotatedPVCs, ecg(annotatedPVCs), 'x','MarkerSize',8);
legend({'ECG signal', 'Detected PVCs', 'Annotations PVCs'},'FontSize',16)


% Compare generated output file with the reference one
currentFile = [HRVparams.writedata filesep 'Annotation' filesep '105.pvc'];
referenceFile = ['ReferenceOutput' filesep '105.pvc'];
testHRV = CompareOutput(currentFile,referenceFile);

if testHRV
    fprintf('\n ** Demo PVC: TEST SUCCEEDED ** \n ')
else
    fprintf('\n ** Demo PVC: TEST FAILED ** \n')
    fprintf('Error: generated output does not match reference \n') 
end
