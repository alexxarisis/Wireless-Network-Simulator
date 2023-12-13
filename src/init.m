function handles=init(wait_bar);

handles = struct();
% File found in 'that' dir... removed warning
warning ("off", "Octave:data-file-in-path");

x = load('Ray_PDP.mat');
handles.Ray_PDP = x.Ray_PDP;

% The rest takes only ~5 seconds to load
waitbar(0.7, wait_bar, 'Finishing asset loading.');

x = load('Ray_PDP_5.mat');
handles.Ray_PDP_5 = x.Ray_PDP_5;
x = load('ReceiveSphere.mat');
handles.ReceiveSphere = x.ReceiveSphere;
x = load('ReceiveSphere_5.mat');
handles.ReceiveSphere_5 = x.ReceiveSphere_5;
x = load('Transmit_Power_Aware.mat');
handles.Transmit_Power_Aware = x.Transmit_Power_Aware;

% Checkboxes positions
handles.Tx_Pos = [ ...
1 5.000000 5.000000 1.500000;
2 15.000000 5.000000 1.500000;
3 25.000000 5.000000 1.500000;
4 35.000000 5.000000 1.500000;
5 40.000000 5.000000 1.500000;
6 43.000000 5.000000 1.500000;
7 2.500000 10.000000 1.500000;
8 7.500000 10.000000 1.500000;
9 15.000000 10.000000 1.500000;
10 25.000000 10.000000 1.500000;
11 35.000000 10.000000 1.500000;
12 43.000000 10.000000 1.500000;
13 2.500000 15.000000 1.500000;
14 6.000000 15.000000 1.500000;
15 20.000000 15.000000 1.500000;
16 40.000000 15.000000 1.500000;
17 9.000000 17.500000 1.500000;
18 16.000000 17.500000 1.500000;
19 29.000000 17.500000 1.500000;
20 34.000000 17.500000 1.500000;
21 43.000000 17.500000 1.500000;
22 2.500000 22.500000 1.500000;
23 6.000000 22.500000 1.500000;
24 13.000000 22.500000 1.500000;
25 18.000000 22.500000 1.500000;
26 22.500000 22.500000 1.500000;
27 27.000000 22.500000 1.500000;
28 40.000000 22.500000 1.500000;
29 43.000000 22.500000 1.500000;
30 4.500000 40.000000 1.500000;
31 14.500000 40.000000 1.500000;
32 24.500000 40.000000 1.500000;
33 34.500000 40.000000 1.500000;
34 39.500000 40.000000 1.500000;
35 42.500000 40.000000 1.500000;
36 2.500000 35.000000 1.500000;
37 6.000000 35.000000 1.500000;
38 20.000000 35.000000 1.500000;
39 40.000000 35.000000 1.500000;
40 9.000000 32.000000 1.500000;
41 16.000000 32.000000 1.500000;
42 29.000000 32.000000 1.500000;
43 34.000000 32.000000 1.500000;
44 43.000000 32.000000 1.500000;
45 2.500000 28.000000 1.500000;
46 6.000000 28.000000 1.500000;
47 13.000000 28.000000 1.500000;
48 18.000000 28.000000 1.500000;
49 22.500000 28.000000 1.500000;
50 27.000000 28.000000 1.500000;
51 40.000000 28.000000 1.500000;
52 43.000000 28.000000 1.500000];

% Initial Variables
handles.TxIDS = [5 19]; % Active starting checkboxes
handles.TxPows = [-10 -10];
handles.TxGains = [2 2];

handles.interactions = 5;
% AXIS 1
%  Green cross
handles.tx_single = [9 13 1.500000];
%  Red cross
handles.rx_single = [14.5 25 1.5];
%  Red line
handles.line = [5.5811    5.5811   32.2159   10.9943]; % [X1 X2 Y1 Y2]

% SCENARIO 2, Setup Rx fields
handles.NoiseFig = 10;
handles.NoiseTemp = 300; %oK
handles.BW = 10.*10.^6; %Hz

% Generic Network
handles.SINRthresh = 5;

% OFDM Network
handles.NofSubcTotal = 1000;
handles.NofSubcPerUser = 250;
handles.Probability = 0.3;
handles.F_sampl = 11.*10.^6; % 11 MHz

% Monte Carlo
handles.minUsers = 2;
handles.maxUsers = 10;
handles.Runs = 1000;

% CDMA Network
handles.chirp = 3.84.*10.^6;
handles.bitrate = 64.*10.^3;
handles.Orthogonality_Factor = 0.6;
handles.Eb_I_Threshold = 6; %dB
handles.Tx_Power_User = mean(handles.TxPows)-9;

handles.figures_title = '';
end
