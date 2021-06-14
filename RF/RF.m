%Conditions:
%0 show typical center-surround cell using display mode
%1 Cell is hidden. Locate achromatic center/surround cell (on-center)
%2 Cell is hidden. Locate achromatic center/surround cell (off-center)
%3 Cell is hidden. Locate simple cell
%4 Cell is hidden. Locate simple cell
%5 Cell is visible. On-center cell. Test different spot sizes and bar
%orientations, noting activation at each
%6 Cell is visible. Simple cell. Test different spot sizes and bar
%orientations, noting activation at each
%7 Cell is visible. L cone. ~8 discrete stimuli colors - include fundamentals
%8 Cell is visible. M cone. ~8 discrete stimuli colors - include fundamentals
%9 Cell is visible. +L-M center/surround. ~8 discrete stimulus colors.
%Test how each affects center and surround using point/spot.
%10 Cell is visible. -L+M center/surround. ~8 discrete stimulus colors.
%Test how each affects center and surround using point/spot.
%include fundamentals
%25 to 75 impulses/sec???

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Receptive Field Demo %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Version 1.0
% Features:
% Show white field, with animated AP spikes, moving over the
% cell will read and (optionally) display the RGB values. RGB values(x3):
% 255 = background. 128 = inhibit. 0 = excite.
%
% Program notes:
% This program is written in base MATLAB code, with no paid/free toolboxes
% required. Additionally, it uses the built-in GUIDE functionality for GUI
% design.
% Required files:
% RF.m - main code, viewable plaintext
% RF.fig - GUI layout of UI controls initially present. More controls may
%     be created through code in the main .m file
% stim out.png - image created of the receptive fields in certain
%     conditions. It will be created each time, or created again if lost.
% blank.png - blank white screen 600x800 (default). Currently recreated if
%     missing
%
% Functionlist:
% RF: built-in
% RF_OpeningFcn: built-in, run commands on form load
% make_onoff: generate an on or off cell, save the image
% make_point: create a small uniform receptive field selective for a given
%     wavelength and no response to wrong wavelength.
% make_ColorOpponent: create a chromatic opponent cell, using given HSV
%     colors and passing through gray.
% create_map: create a colormap from 2 HSV values and return the RGB
%     equivalent. If HSV is identical, create a gray color map.
% RF_OutputFcn: built-in.
% togShow_Callback: toggles whether cells are hidden (default) or shown.
% popCellType_CreateFcn: when cell type is chosen?
% btnStart_Callback: load either startDemo or startExperiment based on popDemo value
% startDemo: start program, hide stuff, show AP, get popCellType value
% startExperiment: run fixed experiments
% RF_CloseRequestFcn: built-in, run commands on form close
% update_display: formerly a timer, now shows .avi of AP
% gaussian2d: create a 2D Gaussian image. Run twice with differing SDs and
%     amplitudes then subtract to make Difference of Gaussians stimulus.
% lineicon: change icon to reflect orientation of stimulus (incomplete)
% gabor: create a Gabor. Output x,y meshgrid, F gabor. Input multiple
%     arguments for size, etc.
%%% createSF: create gratings etc. (off temporarily)
% --- Executes on selection change in listColors.
% listColors_Callback: unused currently
% listColors_CreateFcn: unused currently
% sliOrientation_CreateFcn: unused currently
% sliOrientation_Callback: unused currently
% popStimulus_Callback: mainly, change font colors when popup changed
% popStimulus_CreateFcn: unused currently
% lookup_Cones: input a wavelength, will return [l,m,s] activation at wl
% mean_response: get mean of rgb values under cursor, multiply by current
% moveMouse: pick up RGB under cursor when mouse moves.
% drag: when mouse button is down, make moveMouse work
% release: when mouse button is up, remove links to moveMouse

%How variables work in GUIDE GUI:
%Examples of each are in the program.
%1) You may it global by declaring it as such in each function that uses
%     it. This is usually considered poor form to overdo.
%
%2) Use setappdata to save and getappdata to load.
%     setappdata(0, 'somedata', [5 15 20]); Saves this to a variable called 'somedata'
%     thedata = getappdata(0,'somedata');   Retrieves somedata and saves it as thedata
%     The 0 can be replaced with a more local handle, or getappdata(0) will
%     get all variables stored.
%
%3) The "right" (and annoying) way is to use GUIDATA. At the start of a
%     function, use a): handles = guidata(hObject) to get a list of handles, and
%     use: handles.objectname to access. The same list of handles should be
%     accessable no matter what hObject is, as long as they are in the same
%     parent relationship. But sometimes this is difficult. To add new handles,
%     use the syntax b): handles.img = myImage. Now handles.img will reference the
%     image. Finally, to permanently store the handles, use c):
%     guidata(hObject,handles). That means that this must occur in a certain
%     order, e.g.:
%
%     function myfunction(hObject)
%     handles = guidata(hObject);
%     avogadro = 6.022e+23;
%     handles.avo = avogadro;
%     guidata(hObject,handles);
%     handles.pi = 3.14159;
%     retrieve(hObject)
%     end
%
%     function retrieve(hObject)
%     %%     avogadro >> error!         %Called before retrieval
%     myHandles = guidata(hObject);     %handles can be named anything allowable
%     avogadro >> error!                %need to use handles.avo
%     %%     myHandles.avogadro >> 6.022e+23
%     %%     handles.pi >> error!       %It was added to handles but not saved
%     myHandles.avogadro = [];          %Without call to guidata, will ==[] inside retrieve, and 6.022e+23 elsewhere
%     %%     myHandles.pi >> error!     %Wasn't saved
%     end

%% Input and output functions - not altered much
function varargout = RF(varargin)
% RF MATLAB code for RF.fig
%      RF, by itself, creates a new RF or raises the existing
%      singleton*.
%
%      H = RF returns the handle to a new RF or the handle to
%      the existing singleton*.
%
%      RF('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RF.M with the given input arguments.
%
%      RF('Property','Value',...) creates a new RF or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before RF_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to RF_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help RF

% Last Modified by GUIDE v2.5 30-Jan-2015 16:35:59

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @RF_OpeningFcn, ...
    'gui_OutputFcn',  @RF_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end

% End initialization code - DO NOT EDIT
end

function varargout = RF_OutputFcn(hObject, eventdata, handles)
% --- Outputs from this function are returned to the command line.
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
% %Maxmize Screen
% screensize = get(0,'ScreenSize');
% set(1,'Position',[1+6 1+16 screensize(3)-6 screensize(4)-16-30]);
varargout{1} = handles.output;
end

function RF_CloseRequestFcn(hObject, eventdata, handles)
% --- Executes when user attempts to close figure1.

handles = guidata(hObject);
if isfield(handles,'timer')
    if strcmp(get(handles.timer, 'Running'), 'on')
        stop(handles.timer);
    end
    % Destroy timer
    delete(handles.timer)
end
% END USER CODE
% Hint: delete(hObject) closes the figure
delete(hObject);
clear all
close all
end

%% Stuff that runs on start, e.g. initialization
function RF_OpeningFcn(hObject, eventdata, handles, varargin)
% --- Executes just before RF is made visible.
% Choose default command line output for RF
%Do not close all/clear all at beginning, only end!
c = computer;   %Type of system
if strcmp(c,'PCWIN64') || strcmp(c,'PCWIN32') || strcmp(c,'PCWIN')   %Windows
    colorpath = sprintf('%s\\Color Conversion\\',pwd);       %Double backslash = read as single backslash, not escape character
elseif strcmp(c,'MACI64')
    colorpath = sprintf('%s//Color Conversion//',pwd);       %Double backslash = read as single backslash, not escape character
elseif strcmp(c,'GLNXA64') || strcmp(c,'GLNX32') || strcmp(c,'GLNX86')
    disp('Untested in Linux')
    colorpath = sprintf('%s//Color Conversion//',pwd);       %Double backslash = read as single backslash, not escape character
else
    disp('Computer type undetermined.')
end
movegui('northwest')

addpath(colorpath)               %Path to conversion functions for color opponent cells
handles.output = hObject;

%%%%% This turns on DataCursorMode, which shows x,y position and rgb(0<>1)
%%%%% on click. It is off by default because custom functions deal with it
%%%%% better.
% % % h=datacursormode;
% % % set(h,'SnapToDataVertex','on');
%%%%%
%clearvars marks
%clear marks
global fieldSize stimSize barSize spotSize pix map
global fireRate fireRest fireExcite fireInhib  %Current fire rate and preset levels
global angle
angle = 0;
pix = [];
map = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%  CONSTANTS - CHANGE ONLY IF NECESSARY  %%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fieldSize = [600 800];  %Size of display area, should be < GUI size (for buttons)
%Low for compatibility, could also normalize
stimSize = [120 120];
barSize = [20 100];
spotSize = 20;
%Action Potential graph
fireRest = 0.25;
fireExcite = 0.75;
fireInhib = 0.10 ;
fireRate = double(fireRest);           %This should be the only one that changes value
handles.fireRate = fireRate;
%global gbr;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

axes(handles.f)
% Create blank.png if it was deleted/removed
if ~exist('blank.png') %exists = returns 2
    tfig = figure(9);
    blank = ones(fieldSize(1),fieldSize(2));
    imwrite(blank,'blank.png','PNG');
    close(tfig)
end
img = imread('blank.png','PNG');
image(img)
axis('fill');
axis('xy');
axis('equal');
axis('off');
set(handles.overlay,'XTickLabel',[],'YTickLabel',[],'XTick',[],'YTick',[]);
set(handles.f,'XTickLabel',[],'YTickLabel',[],'XTick',[],'YTick',[]);
set(handles.figAP,'XTickLabel',[],'YTickLabel',[],'XTick',[],'YTick',[]);

%Set up the timer
handles.timer = timer(...
    'ExecutionMode', 'fixedRate', ...       % Run timer repeatedly
    'Period', 1, ...                        % Initial period is 1 sec.
    'TimerFcn', {@update_display,hObject}); % Specify callback function   %or hObject!
set(gcf,'CloseRequestFcn',@RF_CloseRequestFcn);   %Override the default close function so that timer etc. is cleanly closed
%System-defined functions:
%WindowButtonMotionFcn calls @moveMouse when mouse is moved (get info from figure)
%WindowButtonDownFcn calls @onClick when figure is clicked on (add mark)
%WindowKeyPressFcn calls @button_press

set (gcf, 'WindowKeyPressFcn', @button_press);
set (gcf, 'WindowButtonUpFcn', @release);
set (gcbf, 'Callback', @togShow_Callback);
handles.fieldSize = fieldSize;
setappdata(0, 'appMarks', {});

global mid err
mid = 87;
mid = mid / 255;
err = 10;
err = err / 255;

t = get(handles.figure1,'Position');
screenSize = t([4 3]);          %Swap for consistency

set(handles.f,'Position',[0 screenSize(1)-fieldSize(1) fieldSize(2) fieldSize(1)]);
regular_cursor()
guidata(handles.figure1,handles);                       % Save handles to hObject
end

%% Cursor functions
function regular_cursor()
%Makes the cursor a custom "crosshairs" type
%NaN = invisible, 1 = black, 2 = white
p=NaN(16, 16);
p(7:10,:) = 1;
p(:,7:10) = 1;
p(8:9,2:15) = 2;
p(2:15,8:9) = 2;
set(gcf,'Pointer','custom','PointerShapeCData',p,'PointerShapeHotSpot',[9 9])         %setptr(gcf,'datacursor','modifiedfleur')
end

function invisible_cursor()
%Cursor disappears when dragging
p = NaN(16,16);
set(gcf,'Pointer','custom','PointerShapeCData',p,'PointerShapeHotSpot',[9 9])         %setptr(gcf,'datacursor','modifiedfleur')
end

function arrow_cursor(th)
spot = [9 9]; %Default
p=NaN(16,16);
if th == 0 || th == 360 || th == 180
    %Horizontal line
    p(7:10,2:15) = 1;
    p(8:9,2:15) = 2;
    if th == 0 || th == 360
        %Right
        %p(16,:) = NaN;      %Clear right
        p(7:10,1) = 1;
        p(5:12,12:13) = 1;
        p(6:11,14) = 1;
        p(7:10,15) = 1;
        p(8:9,16) = 1;
        p(8:9,12) = 2;
        p(6:11,13) = 2;
        p(7:10,14) = 2;
        p(8:9,15) = 2;
        spot = [9 16];
    elseif th == 180
        %Left
        %p(1,:) = NaN;      %Clear left
        p(7:10,16) = 1;
        p(5:12,4:5) = 1;
        p(6:11,3) = 1;
        p(7:10,2) = 1;
        p(8:9,1) = 1;
        p(8:9,5) = 2;
        p(6:11,4) = 2;
        p(7:10,3) = 2;
        p(8:9,2) = 2;
        spot = [9 1];
    end
elseif th == 90 || th == 270
    %Vertical line
    p(2:15,7:10) = 1;
    p(2:15,8:9) = 2;
    if th == 90
        p(16,7:10) = 1;
        p(4:5,5:12) = 1;
        p(3,6:11) = 1;
        p(2,7:10) = 1;
        p(1,8:9) = 1;
        p(5,8:9) = 2;
        p(4,6:11) = 2;
        p(3,7:10) = 2;
        p(2,8:9) = 2;
        spot = [1 9];
    elseif th == 270
        p(1,7:10) = 1;
        p(12:13,5:12) = 1;
        p(14,6:11) = 1;
        p(15,7:10) = 1;
        p(16,8:9) = 1;
        p(12,8:9) = 2;
        p(13,6:11) = 2;
        p(14,7:10) = 2;
        p(15,8:9) = 2;
        spot = [16 9];
    end
elseif th == 45 || th == 225
    %Forward slash /
    p(1,15:16) = 1;
    p(2,14:16) = 1;
    p(3,13:15) = 1;
    p(4,12:14) = 1;
    p(5,11:13) = 1;
    p(6,10:12) = 1;
    p(7,9:11) = 1;
    p(8,8:10) = 1;
    p(9,7:9) = 1;
    p(10,6:8) = 1;
    p(11,5:7) = 1;
    p(12,4:6) = 1;
    p(13,3:5) = 1;
    p(14,2:4) = 1;
    p(15,1:3) = 1;
    p(16,1:2) = 1;
    %p(1,16) = 2;
    p(2,15) = 2;
    p(3,14) = 2;
    p(4,13) = 2;
    p(5,12) = 2;
    p(6,11) = 2;
    p(7,10) = 2;
    p(8,9) = 2;
    p(9,8) = 2;
    p(10,7) = 2;
    p(11,6) = 2;
    p(12,5) = 2;
    p(13,4) = 2;
    p(14,3) = 2;
    p(15,2) = 2;
    %p(16,1) = 2;
    if th == 45
        p(1,11:16) = 1;
        p(1:6,16) = 1;
        spot = [1 16];
    elseif th == 225
        p(11:16,1) = 1;
        p(16,1:6) = 1;
        spot = [16 1];
    end
elseif th == 135 || th == 315
    %Backslash \
    p(15:16,16) = 1;
    p(14:16,15) = 1;
    p(13:15,14) = 1;
    p(12:14,13) = 1;
    p(11:13,12) = 1;
    p(10:12,11) = 1;
    p(9:11,10) = 1;
    p(8:10,9) = 1;
    p(7:9,8) = 1;
    p(6:8,7) = 1;
    p(5:7,6) = 1;
    p(4:6,5) = 1;
    p(3:5,4) = 1;
    p(2:4,3) = 1;
    p(1:3,2) = 1;
    p(1:2,1) = 1;
    %p(16,1) = 2;
    p(15,15) = 2;
    p(14,14) = 2;
    p(13,13) = 2;
    p(12,12) = 2;
    p(11,11) = 2;
    p(10,10) = 2;
    p(9,9) = 2;
    p(8,8) = 2;
    p(7,7) = 2;
    p(6,6) = 2;
    p(5,5) = 2;
    p(4,4) = 2;
    p(3,3) = 2;
    p(2,2) = 2;
    %p(1,16) = 2;
    if th == 135
        p(1:6,1) = 1;
        p(1,1:6) = 1;
    elseif th == 315
        p(16,11:16) = 1;
        p(11:16,16) = 1;
    end
end
set(gcf,'Pointer','custom','PointerShapeCData',p,'PointerShapeHotSpot',spot);
end

%% Color functions. Conversions and such
function [L,C,H] = LabLuv_to_LCH(triplet)
%Converts CIE1976 Lab opponent space to LCHab cylindrical space
%                             OR
%Converts CIE1976 Lu'v' space to LCHu'v' cylindrical space
%Input:
%L range (identical in Lab and Lub): 0:100
%Output:
%0:1 (or 0:100), range based on input, 0:359

L = triplet(1);
C = sqrt(triplet(2).^2+triplet(3).^2);
H = atan2(triplet(3),triplet(2));
H = H/pi*180;   %Change to degrees
if H < 0
    H = H + 360;
elseif H >= 360
    H = H - 360;
end
end
%Check for these two: degrees vs. radians

function [L,x,y] = LCH_to_LabLuv(triplet)
%Converts cylindrical LCHab, LCHu'v' to normal forms
L = triplet(1);
x = triplet(2) * cos(triplet(3)*pi/180);
y = triplet(2) * sin(triplet(3)*pi/180);
end

function [H,S,V] = RGB_to_HSV(triplet)
%Convert hue, saturation, value to red, green, blue
%Input is: [0:255,0:255,0:255] integers (might have to add one to get 1:256)
%Output is: [0:360,  0:1,  0:1]
r = triplet(1);
g = triplet(2);
b = triplet(3);
lo = min(triplet);
hi = max(triplet);
delta = hi - lo;
%Check that it's not black
if hi~=0
    S = delta/hi;   %0<>1
else
    S = 0;
    H = -1;     %Undefined
    return
end
%Calculate hue
if r == hi
    H = (g - b)/delta;
elseif g == hi
    H = 2 + (b - r)/delta;
else %Therefore blue is high
    H = 4 + (r - g)/delta;
end
H = H * 60;
if H<0
    H = H + 360;
end
V = hi/255;        %0<>1
end

function [R,G,B] = HSV_to_RGB(triplet)
%Convert red, green, blue to hue, saturation, value
%Input is: [0:360,  0:1,  0:1]
%Output is: [0:255,0:255,0:255] integers (might have to add one to get 1:256)
%Angles:
%Red = 360 (or 0 but that is reserved for achromatic)
%Green = 120
%Blue = 240
%Cyan = 180
%Magenta = 300
%Yellow = 60

h = triplet(1);
s = triplet(2);
v = triplet(3);
if h == 0       %Grey
    R = v*255;
    G = v*255;
    B = v*255;
    return
end
h = h/60;
sector = floor(h);
factor = h - sector;
p = v*(1-s);
q = v*(1-s*factor);
t = v*(1-s*(1-factor));

%Results depend on range of hues
switch sector
    case {0,6}  %So we can specify 360 as 0 gives errors
        R = v;
        G = t;
        B = p;
    case 1
        R = q;
        G = v;
        B = p;
    case 2
        R = p;
        G = v;
        B = t;
    case 3
        R = p;
        G = q;
        B = v;
    case 4
        R = t;
        G = p;
        B = v;
    case 5
        R = v;
        G = p;
        B = q;
    otherwise
        disp('Invalid hue input')
end
% R = round(R*255);  %0:255. Change if 1:256 is required, or add 1 outside function
% G = round(G*255);
% B = round(B*255);
end

function [R,G,B] = HSL_to_RGB(triplet)%,isratio)
%Alternate hue, saturation, lightness. Not implemented.
H = triplet(1);
S = triplet(2)/100;
L = triplet(3)/100;
C = (1-abs(2*L-1))*S;
H = H/60;
sector = floor(H);
X = C*(1-abs(mod(sector,2)-1));
switch sector
    case {0,6}  %So we can specify 360 as 0 gives errors
        R = C;
        G = X;
        B = 0;
    case 1
        R = X;
        G = C;
        B = 0;
    case 2
        R = 0;
        G = C;
        B = X;
    case 3
        R = 0;
        G = X;
        B = C;
    case 4
        R = X;
        G = 0;
        B = C;
    case 5
        R = C;
        G = 0;
        B = X;
    otherwise
        disp('Invalid hue input')
end
m = L-C/2;
R = (R + m)*255;
G = (G + m)*255;
B = (B + m)*255;
end

function [lms,scot] = lookup_Cone(light, pos)
%Returns l,m,s activation given stimulus light and position
global pix fieldSize
handles = guidata(gca);
pos = get(handles.f,'CurrentPoint');
rgb=[0 0 0];
x = round(pos(1,1));
y = round(pos(1,2));
if pos(1,1) > 1 && pos(1,1) < fieldSize(1) && pos(1,2) > 1 && pos(1,2) < fieldSize(2)
    rgb = [(pix(round(y),round(x),1)) ...
        (pix(round(y),round(x),1)) ...
        (pix(round(y),round(x),1))];            %Not technically RGB yet... 0<>1, round to index
    rgb = round(rgb.*255);                                  % scale so that 1 = 255, 0.5 = 128 etc., round to whole number
end
cones = [420 .0234 .0273 .463; ...
    448 .0631 .104 .984; ...
    480 .208 .355 .350; ...
    498 .368 .564 .111; ...
    530 .789 .962 .00717; ...
    542 .908 1.00 .00234; ...
    570 1.00 .777 .000156; ...
    580 .958 .612 .0000605; ...
    600 .803 .304 .0000101; ...
    630 .369 .0555 0];

scotfunc = [420 .0966; 448 .431; 480 .793; 498 .97; 530 .811; 542 .616; 570 .2076; 580 0.1212; 600 .03315; 630 .003335];    %Scotopic function ~ rod fundamental

refs = cones(:,1);

if sum(cones(:,1)==light) <= 0     %If cone is not found in data
    disp('Invalid wavelength input')
    return
else
    [r c] = find(cones==light);
    row = cones(r,:);
    lms = [row(2),row(3),row(4)];
    row2 = scotfunc(r,:);
    scot = row2(2);
    % lms = repmat(lms,256,1);
end
end

%% Stimulus creation functions

function make_onoff (hObject)
%Creates an on-center cell by generating two 2D Gaussians of different
%amplitude and variance, and subtracting to obtain a
%Difference-of-Gaussians/Mexican hat/Ricker wavelet. To create off-center
%cell, the colormap should be swapped using e.g. colormap flipud(gray(256))
handles = guidata(gcbf);
gaussian = true; % False = binary on/off regions
global fieldSize pix map
state = get(handles.popCellType,'Value');
centSize = [25 25];     %Circular/square if equal
surrSize = [50 50];

if gaussian == false
    %Obsolete: 2 discrete regions, no taper
    [cols,rows]=meshgrid(1:fieldSize(2),1:fieldSize(1));            %Grid containing rows and columns
    surrPixels = (rows - centroid(1)).^2 ./ surrSize(1).^2 ...
        + (cols - centroid(2)).^2 ./ surrSize(2).^2 <= 1;           %Create larger spot
    centerPixels = (rows - centroid(1)).^2 ./ centSize(1).^2 ...
        + (cols - centroid(2)).^2 ./ centSize(2).^2 <= 1;
    global pix;
    pix = (centerPixels./2)+(surrPixels./2);
    pix = repmat(pix,[1,1,3]);                      % Triple it to be grayscale
elseif gaussian == true
    gSize = [25, 50];
    centroid = rand(1,2);
    ran = 0;
    while (ran - gSize(2)/fieldSize(1) < 0) || (ran + gSize(2)/fieldSize(1) >= 1)
        %y/rows
        ran = rand(1);
    end
    %         br
    centroid(1) = ran;  %Ran is sufficient value, break loop and set center.
    %E.g. gSsize(2)=50,fieldSize=[600 800]: ran must be in range of:
    %50/600 to 1-(50/600) and 50/800 to 1-(50/800) or 0.083 to 0.917
    %and 0.0625 to 0.9375
    ran = 0;
    while (ran - gSize(2)/fieldSize(2) < 0) || (ran + gSize(2)/fieldSize(2) >= 1)
        %x/columns
        ran = rand(1);
    end
    
    centroid(2) = ran;
    
    g1 = gaussian2d('sd',gSize(1),'xpos',centroid(2),'ypos',centroid(1),'amplitude',1);   %0.587amp = 0.53 mean
    g2 = gaussian2d('sd',gSize(2),'xpos',centroid(2),'ypos',centroid(1),'amplitude',0.5); %if sd==50, range==~145, or 3x
    pix=g1-g2;          %DIFFERENCE of Gaussians
end
pix = ((256-1).*(pix - min(pix(:)))/(max(pix(:)) - min(pix(:)))) + 1;

axes(handles.f);                                %This makes it plot in the right figure
celltype = get(handles.popCellType,'String');
if strcmp(celltype(get(handles.popCellType,'Value')),'Off-center cell')
    pix = abs(max(pix(:)) - pix);   %Flip pix colors
end
map = gray_map(mode(pix(:))/256);
imwrite(pix,map,'stim out.png','PNG');      %Save to file, updated every time it runs
img = imread('blank.png');                      %Show initial blank screen
image(img);
set(handles.f,'XTickLabel',[],'YTickLabel',[],'XTick',[],'YTick',[]);
axis('fill');
axis('xy');
axis('equal');
axis('off');
axis([0 fieldSize(2) 0 fieldSize(1)]);
% hold on
% axis('fill');
% axis('xy');
% axis('equal');
% axis('off');
%set(gca,'YDir','reverse')
guidata(handles.figure1,handles);
end

function make_point(hObject, color, centroid)
%Create a circular field with no opponency, only "on" area (cone or rod cell)
global fieldSize pix
handles = guidata(hObject);
handles = guihandles(hObject);
centSize = [25 25];
if nargin == 2          %If centroid not specified
    centroid = [0 0];       %1x2 for point, should be within surrSize
    centroid = rand(1,2) .* fieldSize;
    
    % Create cells based on given size parameters, then place
    % them without overlapping the sides.
    ran = 0;
    while (ran < centSize(1)) || (ran > (fieldSize(1) - centSize(1)))
        %y/rows
        ran = rand(1)*fieldSize(1);
    end
    centroid(1) = ran;
    ran = 0;
    
    while (ran < centSize(2)) || (ran > (fieldSize(2) - centSize(2)))
        %x/columns
        ran = rand(1)*fieldSize(2);
    end
    centroid(2) = ran;
end
[cols,rows]=meshgrid(1:fieldSize(2),1:fieldSize(1));            %Grid containing rows and columns
centerPixels = (rows - centroid(1)).^2 ./ centSize(1).^2 ...
    + (cols - centroid(2)).^2 ./ centSize(2).^2 <= 1;
centerPixels = centerPixels./1;     %Changes from type "logical" that was improperly inferred by MATLAB

pix = centerPixels;
pix = repmat(pix,[1,1,3]);                      % Triple it to be grayscale
pix(:,:,1) = pix(:,:,1) .* color(1)*256;            % Make colored
pix(:,:,2) = pix(:,:,2) .* color(2)*256;
pix(:,:,3) = pix(:,:,3) .* color(3)*256;

set(gca,'XtickLabel',[],'YtickLabel',[]);     %Remove axis labels
set(handles.figAP,'XTickLabel',[],'YTickLabel',[]);
xlim([0 fieldSize(2)]);
ylim([0 fieldSize(1)]);
axes(hObject);                                % This makes it plot in the right figure
imwrite(pix,'stim out.png','PNG');     %Save to file, updated every time it runs
img = imread('blank.png');                %Show initial blank screen
image(img);
%hold on
axis('fill');
axis('xy');
axis('equal');
axis('off');
guidata(handles.figure1,handles);
end

function map = gray_map(mid)
%Create a nonlinear gray colormap centering on on a given middlepoint.
%This is designed to make the background (128,128,128) instead of calculated.
%mid = 0:1, or the mode of pix/nSteps(256), e.g. background
%mode(img(:))/256;
nSteps = 256;
map1 = linspace(0,0.5,mid*nSteps+1);
map2 = linspace(0.5,1,(1-mid)*nSteps);
map = [map1,map2]';
map = repmat(map,[1,3,1]);
end

function map = create_map(fore,back)
%Given 2 HSV values, create a map of default length 256 between them.
%There are two hues, and they can be non-linear in HSV
%Saturation increases then decreases, with the center at the background hue.
%Recommend 100.
%Value is constant for the entire length. Recommend 50.
global pix
if nargin == 0
    %Assume white to black if not specified
    fore = [360 100 50];
    back = [0 0 0];
elseif nargin == 1
    %Assume inverse is opposite 0.5. Note that this may not work right, e.g. if
    %fore = 0.5, back = 0.5, no color map
    back = abs(1 - fore);
end
map = [];
bkgd = mode(pix(:))/256;        %Most common value = background, used to find median of colormap
nSteps = 256;                   %Number of steps in color map

h = [ones(1,floor(bkgd*nSteps+1))*back(1),ones(1,floor((1-bkgd)*nSteps))*fore(1)]';
s = [linspace(back(2),0,bkgd*nSteps+1),linspace(0,fore(2),(1-bkgd)*nSteps)]';
v = [ones(1,floor(bkgd*nSteps+1))*back(3),ones(1,floor((1-bkgd)*nSteps))*fore(3)]';

for i = 1:size(s,1)
    [r,g,b] = HSV_to_RGB([h(i),s(i),v(i)]);
    map = [map;r,g,b];
end
end

function [img, rgb] = make_ColorOpponent(hObject,fore,back)
%Create opponent cell similar to on-center, but with opponent colors.
%Response is no longer contingent on absolute intensity of cell values, but
%provides response only if stimulus shown is correct.
%Inputs: 1) parent object (btnStart), 2) center color, 3) surround color
%
global fieldSize pix
handles = guidata(hObject);
gSize = [25, 50];
centroid = rand(1,2);
ran = 0;
while (ran - gSize(2)/fieldSize(1) < 0) || (ran + gSize(2)/fieldSize(1) >= 1)
    %y/rows
    ran = rand(1);
end
centroid(1) = ran;  %When ran is sufficient value, break loop and set center.
%E.g. gSsize(2)=50,fieldSize=[600 800]: ran must be in range of:
%50/600 to 1-(50/600) and 50/800 to 1-(50/800) or 0.083 to 0.917
%and 0.0625 to 0.9375
ran = 0;
while (ran - gSize(2)/fieldSize(2) < 0) || (ran + gSize(2)/fieldSize(2) >= 1)
    %x/columns
    ran = rand(1);
end
centroid(2) = ran;
%Make the Gaussians
g1 = gaussian2d('sd',gSize(1),'xpos',centroid(2),'ypos',centroid(1),'amplitude',1);    %40, 77
g2 = gaussian2d('sd',gSize(2),'xpos',centroid(2),'ypos',centroid(1),'amplitude',0.5);
pix=g1-g2;          %DIFFERENCE of Gaussians
pix = ((256-1).*(pix - min(pix(:)))/(max(pix(:)) - min(pix(:)))) + 1;     %Scale to range 0<>1
axes(handles.f);                                % This makes it plot in the right figure\

%Create colormap
rgb = create_map(fore,back);

imwrite(pix,rgb,'stim out.png','png')
img = imread('blank.png');                %Show initial blank screen

set(handles.f,'XTickLabel',[],'YTickLabel',[],'XTick',[],'YTick',[]);
axis('fill');
axis('xy');
axis('equal');
axis('off');
axis([0 fieldSize(2) 0 fieldSize(1)]);
guidata(handles.figure1,handles);
end


function [x, y, F] = gabor(varargin)
%Create 2D Gabor stimulus for simple cells. This is created by a
%Gaussian window x a sine wave. Inputs are given paired with strings in first
%section. If unspecified, default values are provided. Parts of function
%are combined in one line rather than calling gaussian2D() function.

p = inputParser;
%These are OPTIONAL. Leaving them out uses default values
addParamValue(p,'theta',2*pi*rand,@isnumeric);      %Angle n radians; if deg are known, = gabor('theta',deg*pi/180)
addParamValue(p,'lambda',20,@isnumeric);            %Wavelength spacing, pixels per cycle, higher = lower frequency
addParamValue(p,'Sigma',10,@isnumeric);             %SD of window
addParamValue(p,'width',256,@isnumeric);            %Width of image generated (including background)
addParamValue(p,'height',256,@isnumeric);           %Height of image generated (including background)
addParamValue(p,'px',rand*0.8 + 0.1,@isnumeric);    %0<>1 location of Gabor center in x (0.5 = center) ranges from 10%-90%
addParamValue(p,'py',rand*0.8 + 0.1,@isnumeric);    %0<>1 location of Gabor center in y (0.5 = middle) ranges from 10%-90%
p.KeepUnmatched = true;                                 %Controls for errors if bad input is given
parse(p,varargin{:});

[x, y] = meshgrid(1:p.Results.width, 1:p.Results.height);
angleR = p.Results.theta;           %Outputs angle in radians

%Place Gabor based on scaling
cx = p.Results.px*p.Results.width;
cy = p.Results.py*p.Results.height;

% Orientation
x_theta = (x-cx)*cos(p.Results.theta)+(y-cy)*sin(p.Results.theta);
y_theta = -(x-cx)*sin(p.Results.theta)+(y-cy)*cos(p.Results.theta);

% Gabor function
F = exp(-0.5*(x_theta.^2/p.Results.Sigma^2+y_theta.^2/p.Results.Sigma^2)).*cos(2*pi/p.Results.lambda*x_theta);

%e.g. [x, y, F] = gabor('width',640,'height',480,'px',0.5,'py',0.5,'theta',pi,'sigma',15,'lambda',40);
end

function gauss = gaussian2d(varargin)
%Creates a 2-dimensional Gaussian with specified amplitude, position on
%screen, and standard deviation.
p = inputParser;
addParamValue(p,'amplitude',1,@isnumeric);          %Range: 0<>1
addParamValue(p,'sd',20,@isnumeric);                %Standard deviation of Gaussian
addParamValue(p,'fwhm',0,@isnumeric);               %Full width at half maximum, only if specified then it changes sd / 2.3548
addParamValue(p,'width',800,@isnumeric);            %Width of image generated (including background)
addParamValue(p,'height',600,@isnumeric);           %Height of image generated (including background)

%Range: 0<>1. location of Gaussian center in x,y (0.5 = center/middle)
addParamValue(p,'xpos',rand*0.8 + 0.1,@isnumeric);
addParamValue(p,'ypos',rand*0.8 + 0.1,@isnumeric);
p.KeepUnmatched = true;
parse(p,varargin{:});

if p.Results.fwhm ~= 0
    p.Results.sd = p.Results.fwhm / (2*sqrt(2*log(2)));
end

[x, y] = meshgrid(1:p.Results.width, 1:p.Results.height);
% Center of gaussian window, based on normalized position in variable field
centerx = p.Results.xpos*p.Results.width;
centery = p.Results.ypos*p.Results.height;
gauss = p.Results.amplitude * exp(-(  ( ((x-centerx).^2)  /  (2*p.Results.sd.^2)) + ...
    ( ((y - centery).^2 / (2*p.Results.sd.^2) )) ));
end

function [S, win, trans] = makeSine(varargin)
%Create a 2D sinewave stimulus. Multiple arguments, default used if not
%specified. Importantly: 'sineoutput' specifies what type of sine to use.
%Default is 2, which creates a sine behind a circular aperture window.
%Intended to be called so that theta and total size are adjustable with
%keypress.
%This is based off of the Fine & Boynton eBook code with a few modifications.
global fieldSize;
p = inputParser;
%These are OPTIONAL. Leaving them out uses default values
addParamValue(p,'theta',2*pi*rand,@isnumeric);      %Angle of Sine, user controlled by default
addParamValue(p,'sf',6,@isnumeric);                 %Spatial frequency, pixels per cycle, higher = lower frequency.
addParamValue(p,'sd',20,@isnumeric);                %Standard deviation of Gaussian window
addParamValue(p,'width',100,@isnumeric);            %Width of spot, height implied
%addParamValue(p,'height',100,@isnumeric);           %Height of spot
addParamValue(p,'contrast',1,@isnumeric);         	%Contrast of sine
addParamValue(p,'sineoutput',2,@isnumeric);         %By default outputs gaussian cropped, tilted sine. Use other numbers to specify earlier stages.
addParamValue(p,'radius',1.7,@isnumeric);           %Radius of circular aperture
addParamValue(p,'amplitude',1,@isnumeric);          %Amplitude of Gaussian
addParamValue(p,'xpos',rand*0.8 + 0.1,@isnumeric);             %X position 0<>1
addParamValue(p,'ypos',rand*0.8 + 0.1,@isnumeric);             %Y position 0<>1
p.KeepUnmatched = true;                             %Controls for errors if bad input is given
parse(p,varargin{:});

%Draw 2D unwindowed sine and scaled version
width = p.Results.width;
sf = p.Results.sf;
x=linspace(-pi,pi,width);
sinewave = sin(x*sf);
onematrix = ones(size(sinewave));
sinewave2D = (onematrix'*sinewave);     %Transpose makes it 2D
scaled = ((sinewave2D+1)*127.5)+1;      %colormap(gray) won't work: need colormap(gray(256))

%Draw sine and scaled at requested contrast
contrast = p.Results.contrast;
contrastdim = contrast*sinewave2D;
scaled_contrast = contrast*scaled;  %(((contrast.*sinewave2D)+1)*127.5)+1;

%Create sf at an angle
[x1, y1] = meshgrid(linspace(-pi,pi,width));
angle = p.Results.theta;
ramp = cos(angle*pi/180)*x1 - sin(angle*pi/180)*y1;
phase = pi/2;
tilted = contrast*sin(sf*ramp-phase);     %contrast*sin(p.Results.sf*ramp-phase);
scaled_tilted = ((256-1).*(tilted - min(tilted(:)))/(max(tilted(:)) - min(tilted(:)))) + 1;

%Create sine and scaled with circular aperture
rad = p.Results.radius;
circular = sinewave2D;
tilt_circ = tilted;
for r = 1:length(x)
    for c = 1:length(x)
        if x(r)^2+x(c)^2 > rad^2
            circular(r,c) = 0;
            tilt_circ(r,c) = 0;
        end
    end
end
%fprintf('x = %s y? = %s',x(1),x(1));
scaled_circular = ((circular+1)*127.5)+1;
scaled_tilted_circular = ((tilt_circ+1)*127.5)+1;

%Buttons:
%SF -
%Size -
%Contrast -



%%%%%%%%%%%%%%  OR  %%%%%%%%%%%%%%

%Gaussian
[x y] = meshgrid(1:width);
m = mean(x(:));
sd = p.Results.sd;
Gaussian = p.Results.amplitude * exp(-((((x - m).^2)/(2*sd.^2)) + ((y - m).^2 / (2*sd.^2))));  %width/2
% image((255*Gaussian)+1);
% colormap(gray(256));
% axis equal
% axis off


% imagesc(tiltedSine)
% colormap(gray(256));
% axis equal
% axis off

%scaled_gauss_img = ((225*Gaussian)+1) .* scaled;
gauss_img = scaled.*Gaussian;
tilted_gauss = scaled_tilted.*Gaussian;
win = ones(fieldSize(1),fieldSize(2));
win = win*129;
switch p.Results.sineoutput
    case 1  %Output angled, Gaussian sine
        S = tilted_gauss;
    case 2  %Circular window tilted
        S = scaled_tilted_circular;
        %Put 100x100 into full field
        xstart = round(p.Results.xpos * fieldSize(2) - width/2);   %e.g. xpos = 0.5, xstart = 0.5*800-(100/2)=350 to 450
        ystart = round(p.Results.ypos * fieldSize(1) - width/2);
        width = round(width);
        win(ystart:ystart+width-1,xstart:xstart+width-1) = S;
        win = uint8(round(win));              %Output starts out as 'double'. MATLAB interprets that as 0<>1 when displaying image
        
        trans = win~=129;              %Keep all but gray background
        
    case 3  %Circular untilted
        S = scaled_circular;
    case 4  %Unwindowed
        S = scaled;
end
end

function [x y w h] = find_stimulus(img,bkgd)
%Finds a stimulus (sine) in a larger window. This is done by finding the
%coordinates of extreme pixels.
%x = leftmost pixel, irrespective of row
%y = topmost(?) pixel, irrespective of column
%w = width (rightmost - leftmost)
%h = height (bottommost - topmost)

%Image was previously flipped by flipud, or else coordinates wrong!
%Other option would be no flip and fieldSize - loc
width = 100;                %Default, this and next hardcoded for now
object = img ~= bkgd;       %Logical of non-129 elements
[r,c] = find(object);       %Get rows and columns for nonzero (nonfalse) elements
y = min(r(:));              %Edgemost pixelsof the circular window, but smaller than the generated sine
x = min(c(:));
w = max(c) - min(c) + 1;    %Get range of column indices  = 54
h = max(r) - min(r) + 1;    %Get range of row indices
x = x + w/2;            %Not sure if that's 100% right
y = y + h/2 - 2;

xcent = w/2 + x;
ycent = h/2 + y;
xedge = xcent - width/2;         %50 = half of 100
yedge = ycent - width/2;
end
%% Misc also

% function onClick(hObject,eventdata,hFigure)
% %Marking
% global fieldSize
% handles = guidata(gcbf);
% if strcmp(get(handles.btnStart,'Visible'),'off')        %Don't mark if program not started
%     axes(handles.overlay)
%     marks = getappdata(0,'appMarks');
%     pos = get(gca,'CurrentPoint');    %normal = left; alt = right - lowercase sensitive
%     key = get(gcbf,'SelectionType');
%     if (pos(1,1) > 0 && pos(1,1) < fieldSize(2)) && (pos(1,2) > 0 && pos(1,2) < fieldSize(1))       %If in bounds of figure
%         %if pos(2,3) ~= 0     %If in bounds of figure, not sure what 3rd column means?
%         %(pos(1) > 1 && pos(1) < fieldSize(2)) && (pos(2) > 1 && pos(2) < fieldSize(1))
%         if strcmp(key,'normal') == true
%             text(pos(1,1),pos(1,2),'+','color','red','fontsize',16, ...
%                 'HorizontalAlignment','center','VerticalAlignment','middle');
%             marks = [marks; {'excitatory', pos(1,1),pos(1,2)}];
%         elseif strcmp(key,'alt') == true
%             text(pos(1,1),pos(1,2),'-','color','red','fontsize',24, ...
%                 'HorizontalAlignment','center','VerticalAlignment','middle');
%             % Minus is smaller than plus so make it bigger text
%             marks = [marks; {'inhibitory', pos(1,1),pos(1,2)}];
%         end
%         %end
%         setappdata(0, 'appMarks', marks);   %Put the in-function marks into appMarks
%     end
% end
% end

function startDemo(hObject, eventdata, handles)
%Show cell/stimulus based on user input.
handles = guidata(hObject);
global fieldSize stimSize angle map complexAngle gbr
if (get(handles.popCellType,'Value') == 1) || (get(handles.popStimulus,'Value') == 1)
    return      %One of the boxes not selected (2 strcmps above)
else
    borders = get(handles.f,'Position');                                    %Make overlay the same size as main area
    axes(handles.overlay)
    set(handles.overlay,'Visible','on','Color','none','Position',borders, ...
        'XTick',[],'YTick',[]);   %Use axes() to put on top, below
    axis('fill')
    axis('xy')
    axis('equal')
    axis('off')
    axes(handles.f)
    set(handles.f,'XTickLabel',[],'YTickLabel',[],'XTick',[],'YTick',[]);
    axis('fill');
    axis('xy');
    axis('equal');
    axis('off');
    %HSV values to set opponent cells' fields
    %br = (bright red) red-on, dg = (dark green) green-off etc.
    br = [360,1,0.5];
    dr = [360,0.3,0.5];
    bg = [120,1,0.5];
    dg = [120,0.3,0.5];
    bb = [240,1,0.5];
    dy = [60,1,0.5];        %Higher saturation as 0.3 is ugly
    dr = br;        %Don't worry about asymmetric ones now!
    dg = bg;
    set(handles.popDemo,'Visible','off');
    celltype = get(handles.popCellType,'String');
    switch char(celltype(get(handles.popCellType,'Value')))
        case '[Cell Type]'
            %Title; Do nothing
            disp('First option is invalid!');
            return             %Quit and invalidate start press until option chosen
        case {'On-center cell','Off-center cell'}
            %'On-center cell')
            axes(handles.f)
            make_onoff(handles.f)
            
        case 'Simple cell'
            %'Simple cell'
            axes(handles.f)
            th = 15*(floor(rand() * 24));       %0 to 23, then * 15 = 0 to 345 err 15
            s = rand() * 10 + 10;               %20 to 40       default 20
            wl = s * 2;                         %Default 40
            demo = get(handles.popDemo,'String');
            if strcmp(demo(get(handles.popDemo,'Value')),'[Test Mode]')
                [x, y, gbr] = gabor('width',fieldSize(2),'height',fieldSize(1),'sigma',s,'lambda',wl,'theta',th); %,'px',0.9,'py',0.9); %,'px',0.5,'py',0.5);
            elseif strcmp(demo(get(handles.popDemo,'Value')),'3')
                %Create centered, smaller Gabor
                [x, y, gbr] = gabor('px',0.5,'py',0.5,'width',fieldSize(2),'height',fieldSize(1), ...
                    'sigma',15,'lambda',30,'theta',0);
            elseif strcmp(demo(get(handles.popDemo,'Value')),'4')
                %Create corner, larger Gabor
                [x, y, gbr] = gabor('px',0.8,'py',0.8,'width',fieldSize(2),'height',fieldSize(1), ...
                    'sigma',30,'lambda',60,'theta',45);
            end
            
            gbr = gbr-min(gbr(:));                %Scale so that the minimum is now 0 (if min != 0)
            gbr = gbr / max(gbr(:));            %Scale so tagt the maximum is now 1 (if necessary)
            
            map = gray_map(mode(gbr(:)));
            set(gca,'XTickLabel',[],'YTickLabel',[],'XTick',[],'YTick',[]);
            axis('fill');
            axis('xy');
            axis('equal');
            axis('off');
            axis([0 fieldSize(2) 0 fieldSize(1)]);
            imwrite(gbr,'stim out.png','PNG')       %putting map here doesn't work because it's not indexed?
            
            set(handles.f,'BusyAction','cancel')
            set(handles.figAP,'BusyAction','cancel','Interruptible','off')
            axes(handles.overlay);
            
        case 'Complex cell'
%             %150x80 cell at random orientation
%             w = 80;
%             h = 150;
%             th = 45*(floor(rand() * 8)) + 45;        %0 to 7, then * 45 + 15 = 45 to 360 err 45
%             th = 135;
%             complexAngle = th;
%             
%             randx = round(w + (rand * (fieldSize(2) - 2*w)));  %e.g. if 800x600, 150 to 650
%             randy = round(h + (rand * (fieldSize(1) - 2*h)));  %e.g. 100 to 500
%             x = [randx randx randx+w randx+w];
%             y = [randy randy+h randy+h randy];
%             axes(handles.overlay);  %\@
%             complex = patch(x,y,[0 1 1]);
%             handles.complex = complex;
%             set(gca,'XTickLabel',[],'YTickLabel',[],'XTick',[],'YTick',[]);
%             axis('fill');
%             axis('xy');
%             axis('equal');
%             axis('off');
%             axis([0 fieldSize(2) 0 fieldSize(1)]);
%             xdata = get(handles.complex,'XData');         %Get mean of 4 X points
%             ydata = get(handles.c-omplex,'YData');         %Get mean of 4 Y points
%             rotate(handles.complex,[0 0 1],-th,[mean(xdata) mean(ydata) 0]);
%             xdatarot = get(handles.complex,'XData');
%             ydatarot = get(handles.complex,'YData');
%             
%             
%             %Plot arrow
%             r = w/2;  %Length of arrow, total length w/2 and starts at w/4
%             
%             switch th
%                 case {360, 0}
%                     opposite = 180;
%                 case 45
%                     opposite = 135;
%                 case 90
%                     opposite = 90;
%                 case 135
%                     opposite = 45;
%                 case 180
%                     opposite = 0;
%                 case 225
%                     opposite = 315;
%                 case 270
%                     opposite = 270;
%                 case 315
%                     opposite = 225;
%             end
%             center = [((max(xdatarot) + min(xdatarot))/2),((max(ydatarot) + min(ydatarot))/2)];
%             shift = w/4;    %1/4 down box
%             if opposite == 90 || th == 270
%                 startx = center(1) - (shift * cos(th*pi/180));   %Convert to Cartesian
%                 starty = center(2) - (shift * sin(th*pi/180));
%             elseif th == 360 || th == 180 || th == 0
%                 startx = center(1) + (shift * cos(th*pi/180));   %Convert to Cartesian
%                 starty = center(2) + (shift * sin(th*pi/180));
%             else
%                 %Non-right angles
%                 startx = center(1) + (shift * cos(th*pi/180));   %Convert to Cartesian
%                 starty = center(2) - (shift * sin(th*pi/180));
%             end
%             
%             u1 = r * cos(opposite*pi/180);   %Convert to Cartesian
%             v1 = r * sin(opposite*pi/180);
%             hold on
%             arrow = quiver(startx,starty,u1,v1,'LineWidth',2,'MaxHeadSize',20,'Color','black');
%             %Get contents of figure and save to file
%             img = getframe(handles.f);
%             imwrite(img.cdata,'stim out.png','PNG');
%             axes(handles.overlay);
            
        case 'Hypercomplex cell'
            
        case {'+L-M'}
            [img, map] = make_ColorOpponent(hObject,br,dg);
        case {'-L+M'}
            [img, map] = make_ColorOpponent(hObject,dr,bg);
            
        case {'+M-L'}
            [img, map] = make_ColorOpponent(hObject,bg,dr);
        case {'-M+L'}
            [img, map] = make_ColorOpponent(hObject,dg,br);
        case {'+S-LM'}
            [img, map] = make_ColorOpponent(hObject,bb,dy);
            
        case 'L cone'
            make_point(handles.f,[1 0 0]);
        case 'M cone'
            make_point(handles.f,[0 1 0]);
        case 'S cone'
            make_point(handles.f,[0 0 1]);
        case 'Rod'
            make_point(handles.f,[1 1 1]);
        otherwise
            %Something
    end
    
    %Show image
    axes(handles.f)
    img=imread('blank.png');
    imagesc(img);
    set(handles.f,'XTickLabel',[],'YTickLabel',[],'XTick',[],'YTick',[]);
    axis('fill');
    axis('xy');
    axis('equal');
    axis('off');
    axis([0 fieldSize(2) 0 fieldSize(1)]);
    hold on
    axes(handles.overlay)  %\@
    
    %Pick stimulus type
    txtwidth = get(handles.f,'Position');
    xInstr = fieldSize(2)+25;
    yInstr = txtwidth(2) + 25; % + fieldSize(1)-170;
    set(handles.lblInstructions,'Visible','on');
    linebreak = sprintf('\n');     %Looks necessary because \n straight in doesn't work
    
    stim = get(handles.popStimulus,'String');        %Get array of stimuli
    
    switch char(stim(get(handles.popStimulus,'Value'))); %Find item in current index, convert to string
        case {'[Stimulus Type]'}
            beep
            disp('Please choose a stimulus type')
            return
        case {'Field'}
        case {'Point'}
            regular_cursor()
            instr = {'Click then  push -/_ or +/= to mark excitatory/inhibitory areas'};
            set(handles.lblInstructions,'Position',[xInstr,yInstr,500,250],'String',instr);
        case {'~570 (L cone)'}
        case {'~542 (M cone)'}
        case {'~448 (S cone)'}
        case {'~498 (Rod)'}
        case {'Bar'}
            %Bar stimulus
            instr = {'Q = Rotate Left',linebreak,'E = Rotate Right',linebreak,'PageUp/PageDown to zoom stimulus (3 sizes)',linebreak,...
                'Click then  push -/_ or +/= to mark excitatory/inhibitory areas'};
            set(handles.lblInstructions,'Position',[xInstr,yInstr,500,250],'String',instr);
            
            x = [10 10 111 111];
            y = [10 31 31 10];
            axes(handles.overlay);
            rec = patch(x,y,'r');
            xdata = get(rec,'XData');
            ydata = get(rec,'YData');
            set(rec,'XData',xdata+100,'YData',ydata+100);  %Move bar away from corner
            axis([0 fieldSize(2) 0 fieldSize(1)])
            set(gca,'XTick',[]);set(gca,'YTick',[]);
            DragObject(rec)
            handles.rec = rec;
            set(handles.rec,'FaceAlpha',0.25);      %Make bar transparent
            guidata(handles.figure1,handles);
        case {'Sine'}
            %2D Sine wave
            instr = {'Q = Rotate Left',linebreak,'E = Rotate Right',linebreak,'Click and push + or - to mark excitatory/inhibitory areas'};
            set(handles.lblInstructions,'Position',[xInstr,yInstr,400,150],'String',instr);
            axes(handles.overlay)
            [small, large, imagealpha] = makeSine('width',stimSize(1),'sineoutput',2,'theta',angle,'xpos',0.7,'ypos',0.5);
            sinestim = image(large,'AlphaData',imagealpha);%,'AlphaDataMapping','none');
            axis([0 fieldSize(2) 0 fieldSize(1)])
            set(handles.overlay,'XTick',[],'YTick',[],'XTickLabel',[],'YTickLabel',[]);
            handles.large = large; %\@
            handles.sinestim = sinestim;
            guidata(handles.figure1,handles);
            DragObject(handles.sinestim);
        case 'Spot'
            %Create circular stimulus
            instr = {'PageUp/PageDown to zoom stimulus (2 sizes)',linebreak,...
                'Click then  push -/_ or +/= to mark excitatory/inhibitory areas'};
            set(handles.lblInstructions,'Position',[xInstr,yInstr,400,150],'String',instr);
            th = linspace(0,2*pi,100);
            [x,y] = pol2cart(th,20);
            spot = patch(x,y,'r');
            xdata = get(spot,'XData');
            ydata = get(spot,'YData');
            set(spot,'XData',xdata+100,'YData',ydata+100);  %Move spot away from corner
            axis([0 fieldSize(2) 0 fieldSize(1)])
            set(spot,'FaceAlpha',0.25);
            DragObject(spot)
            handles.spot = spot;
            guidata(handles.figure1,handles);
        case {'Movement'}
            %Bar representing stimulus moving in one direction
            instr = {'Q = Rotate Left',linebreak,'E = Rotate Right',linebreak,'Click and push + or - to mark excitatory/inhibitory areas'};
            set(handles.lblInstructions,'Position',[xInstr,yInstr,400,150],'String',instr);
            arrow_cursor(0);
            axes(handles.overlay)
    end
    
    %Hide all superfluous items, show AP
    set(handles.figAP,'Visible','on');
    global fAP
    x1 = [0 50 100];
    x1 = repmat(x1,100,1);      %100r x 3c
    y1 = zeros(100,3);
    fAP = plot(handles.figAP,x1',y1','k');
    set(handles.btnStart,'Visible','off');
    axes(handles.overlay)
    guidata(hObject,handles);
    %Start timer at end to prevent errors
    %Have to redo handles as object was removed
    handles = guidata(hObject);
    if strcmp(get(handles.timer, 'Running'), 'off')
        start(handles.timer);       %\@ bugged!
    end
    guidata(hObject,handles);
end
end

function startExperiment(hObject, eventdata, handles)
%Show one of 10 experimental/test stimuli.
global map fieldSize %lms
handles = guidata(hObject);
borders = get(handles.f,'Position');                                    %Make overlay the same size as main area
axes(handles.overlay)
set(handles.overlay,'Visible','on','Color','none','Position',borders, ...
    'XTick',[],'YTick',[]);   %Use axes() to put on top, below
axis('fill')
axis('xy')
axis('equal')
axis('off')
axes(handles.f)
set(handles.f,'XTickLabel',[],'YTickLabel',[],'XTick',[],'YTick',[]);
axis('fill');
axis('xy');
axis('equal');
axis('off');

demo = get(handles.popDemo,'String');
demoval = cell2mat(demo(get(handles.popDemo,'Value')));
header = {'[Stimulus Type]'};

switch demoval       %Number's value is String + 1
    case {'[Test Mode]'}
        disp('Error: Experiment not loaded properly.')
        return
    case {'1'}
        set(handles.popStimulus,'String',{'[Set Stimulus]','Point','Spot','Bar'});
        set(handles.popStimulus,'Value',2);
        regular_cursor()
    case {'2'}
        set(handles.popStimulus,'String',{'[Set Stimulus]','Point','Spot','Bar'});
        set(handles.popStimulus,'Value',2);
        regular_cursor()
    case {'3'}
        regular_cursor()
        set(handles.popStimulus,'String',{'[Stimulus]','Point','Bar','Spot'});
        set(handles.popStimulus,'Value',2);
    case {'4'}
        regular_cursor()
        set(handles.popStimulus,'String',{'[Stimulus]','Point','Bar','Spot'});
        set(handles.popStimulus,'Value',2);
    case {'5'}        %Shown on-center
        set(handles.popCellType,'Value',2);
        axes(handles.f)
        make_onoff(handles.f)
        regular_cursor()
        set(handles.popStimulus,'String',{'[Stimulus]','Point','Bar','Spot'});
        set(handles.popStimulus,'Value',2);
        set(handles.togShow,'Value',1);              %Show field
        togShow_Callback(handles.togShow,[],handles);
        set(handles.togShow,'Visible','off')
    case {'6'}      %Shown simple
        set(handles.popCellType,'Value',4);
        set(handles.popStimulus,'String',{'[Stimulus]','Point','Bar','Spot'});
        set(handles.popStimulus,'Value',3);
        axes(handles.f)
        [x, y, gbr] = gabor('px',0.5,'py',0.5,'width',fieldSize(2),'height',fieldSize(1), ...
            'sigma',30,'lambda',60,'theta',0);
        gbr = gbr-min(gbr(:));                %Scale so that the minimum is now 0 (if min != 0)
        gbr = gbr / max(gbr(:));            %Scale so tagt the maximum is now 1 (if necessary)
        imwrite(gbr,'stim out.png','PNG')       %putting map here doesn't work because it's not indexed?
        set(handles.togShow,'Visible','off')
        img = imread('stim out.png');  %Break imaging and making image into two steps = fix colormap
        image(img)
        map = gray_map(mode(gbr(:)));
        colormap(map)
        set(gca,'XTickLabel',[],'YTickLabel',[],'XTick',[],'YTick',[]);
        axis('fill');
        axis('xy');
        axis('equal');
        axis('off');
        axis([0 fieldSize(2) 0 fieldSize(1)]);
        set(handles.f,'BusyAction','cancel')
        set(handles.figAP,'BusyAction','cancel','Interruptible','off')
        hold on
        borders = get(handles.f,'Position');                                    %Make overlay the same size as main area
        axes(handles.overlay)
        set(handles.overlay,'Visible','on','Color','none','Position',borders, ...
            'XTick',[],'YTick',[]);   %Use axes() to put on top, below
        axis('fill')
        axis('xy')
        axis('equal')
        axis('off')
        stim = get(handles.popStimulus,'String');
        switch char(stim(get(handles.popStimulus,'Value')))
            case 'Bar'
                txtwidth = get(handles.f,'Position');
                xInstr = fieldSize(2)+25;
                yInstr = txtwidth(2) + 25; % + fieldSize(1)-170;
                set(handles.lblInstructions,'Visible','on');
                linebreak = sprintf('\n');     %Looks necessary because \n straight in doesn't work
                instr = {'Q = Rotate Left',linebreak,'E = Rotate Right',linebreak,'PageUp/PageDown to zoom stimulus (3 sizes)',linebreak,...
                    'Click then  push -/_ or +/= to mark excitatory/inhibitory areas'};
                set(handles.lblInstructions,'Position',[xInstr,yInstr,500,250],'String',instr);
                x = [10 10 111 111];
                y = [10 31 31 10];
                axes(handles.overlay);
                set(handles.overlay,'Visible','on','Color','none')
                rec = patch(x,y,'r');
                axis([0 fieldSize(2) 0 fieldSize(1)])
                %set(gca,'XTick',[]);set(gca,'YTick',[]);
                DragObject(rec)
                handles.rec = rec;
                set(handles.rec,'FaceAlpha',0.25);      %Make bar transparent
                guidata(handles.figure1,handles);
                %moveit2(handles.rec);
                
            case 'Spot'
                instr = {'-/+ on keypad to zoom stimulus (2 sizes)',linebreak,...
                    'Click then  push -/_ or +/= to mark excitatory/inhibitory areas'};
                set(handles.lblInstructions,'Position',[xInstr,yInstr,400,150],'String',instr);
                th = linspace(0,2*pi,100);
                [x,y] = pol2cart(th,20);
                spot = patch(x,y,'r');
                xdata = get(spot,'XData');
                ydata = get(spot,'YData');
                set(spot,'XData',xdata+100,'YData',ydata+100);  %Move spot away from corner
                axis([0 fieldSize(2) 0 fieldSize(1)])
                set(spot,'FaceAlpha',0.25);
                DragObject(spot)
                handles.spot = spot;
                guidata(handles.figure1,handles);
        end
        set(handles.togShow,'Value',1);              %Show field
        togShow_Callback(handles.togShow,[],handles);
        set(handles.togShow,'Visible','off')
    case {'7'}      %L cone
        set(handles.popCellType,'Value',10);
        make_point(handles.f,[1 0 0]);
        set(handles.popStimulus,'Value',2);
        set(handles.togShow,'Value',1);              %Show field
        togShow_Callback(handles.togShow,[],handles);
        set(handles.togShow,'Visible','off')
    case {'8'}      %M cone
        set(handles.popCellType,'Value',11);
        make_point(handles.f,[0 1 0]);
        set(handles.togShow,'Value',1);              %Show field
        togShow_Callback(handles.togShow,[],handles);
        set(handles.togShow,'Visible','off')
    case {'9'}      %+L-M
        %See above if statement
        br = [360,1,0.5];
        dg = [120,0.3,0.5];
        [img, map] = make_ColorOpponent(hObject,br,dg);
        set(handles.popStimulus,'Value',2);
        set(handles.togShow,'Value',1);              %Show field
        togShow_Callback(handles.togShow,[],handles);
        set(handles.togShow,'Visible','off')
    case {'10'}     %+M+L
        bg = [120,1,0.5];
        dr = [360,0.3,0.5];
        [img, map] = make_ColorOpponent(hObject,bg,dr);
        set(handles.popStimulus,'Value',2);
        set(handles.togShow,'Value',1);              %Show field
        togShow_Callback(handles.togShow,[],handles);
        set(handles.togShow,'Visible','off')
end

%Hide all superfluous items, show AP
set(handles.figAP,'Visible','on');
global fAP
x1 = [0 50 100];
x1 = repmat(x1,100,1);      %100r x 3c
y1 = zeros(100,3);
fAP = plot(handles.figAP,x1',y1','k');
set(handles.btnStart,'Visible','off');
set(handles.popCellType,'Visible','off');
set(handles.popDemo,'Visible','off');
axes(handles.overlay)
guidata(hObject,handles);
%Start timer at end to prevent errors
%Have to redo handles as object was removed
handles = guidata(hObject);
if strcmp(get(handles.timer, 'Running'), 'off')
    start(handles.timer);       %\@ bugged!
end
guidata(hObject,handles);
end

function button_press(hObject, event)
%Occurs when a key is pressed, marks points etc.
%global marks;
global angle;
global fieldSize stimSize barSize spotSize;
handles = guidata(hObject);
if strcmp(get(handles.btnStart,'Visible'),'off')
    set(handles.popCellType,'Visible','on');
    marks = getappdata(0,'appMarks');
    pos = get(gca,'CurrentPoint');
    if strcmp(event.Key,'z')
        %Necessarily to manually change state, clicking does this for you.
        st = get(handles.togShow,'Value');
        if st == 0
            set(handles.togShow,'Value',1);
        else
            set(handles.togShow,'Value',0);
        end
        togShow_Callback(handles.togShow,[],handles);
    elseif strcmp(event.Key,'delete')
        %Delete the last mark placed from matrix 'handles.marks'
        if isempty(marks)
            return
        end
        if strcmp(marks(end,1,:),'excitatory')    %(end,:) = last line(click), first cell(type), entire string
            marks(end,:,:) = [];    %marks(1:end-1,:,:);
        elseif strcmp(marks(end,1,:),'inhibitory')
            marks(end,:,:) = [];    %marks(1:end-1,:,:);
        else
            %Do nothing, marks is empty or wrong data
            return
        end
        
        %Redisplay background based on current toggle state
        if get(handles.togShow,'Value') == 0
            %Show blank
            image(imread('blank.png'));
        elseif get(handles.togShow,'Value') == 1
            %Show revealed cell
            image(imread('stim out.png'));
        end
        
        %Redraw remaining marks
        positions = cell2mat(marks(:,2:3));       %Convert cell array to matrix size(1,2) of numbers/doubles
        for i = 1:size(marks,1)
            if strcmp(marks(i,1,:),'excitatory')
                text(positions(i,1),positions(i,2), '+','color','red','fontsize',16, ...
                    'HorizontalAlignment','center','VerticalAlignment','middle');
            elseif strcmp(marks(i,1,:),'inhibitory')
                text(positions(i,1),positions(i,2), '-','color','red','fontsize',24, ...
                    'HorizontalAlignment','center','VerticalAlignment','middle');
            else
                disp('Can''t find marker to delete!')           %Double single quote to make single quote in string
            end
        end
        set(handles.overlay,'YDir','normal');
        axis('image')
        axis('off')
    elseif strcmp(event.Key,'equal') %strcmp(event.Key,'add') ||
        text(pos(1,1),pos(1,2),'+','color','red','fontsize',16, ...
            'HorizontalAlignment','center','VerticalAlignment','middle');
        marks = [marks; {'excitatory', pos(1,1),pos(1,2)}];
    elseif strcmp(event.Key,'hyphen') %strcmp(event.Key,'subtract') ||
        text(pos(1,1),pos(1,2),'-','color','red','fontsize',24, ...
            'HorizontalAlignment','center','VerticalAlignment','middle');
        % Minus is smaller than plus so make it bigger text
        marks = [marks; {'inhibitory', pos(1,1),pos(1,2)}];
    elseif strcmp(event.Key,'n') || strcmp(event.Key,'pagedown')
        %Zoom out
        stim = get(handles.popStimulus,'String');        %Get array of stimuli
        if  strcmp(char(stim(get(handles.popStimulus,'Value'))),'Bar'); %Find item in current index, convert to string
            if barSize == [10 50]
                barSize = [10 50];
            elseif barSize == [15 75]
                barSize = [10 50];
            elseif barSize == [20 100]
                barSize = [15 75];
            end
            x = get(handles.rec,'XData'); %[1 1 101 101];
            y = get(handles.rec,'YData'); %[1 21 21 1];
            axes(handles.overlay);
            delete(handles.rec)
            meanx = mean(x);
            meany = mean(y);
            newx = [meanx - barSize(2)/2, meanx - barSize(2)/2, meanx + barSize(2)/2, meanx + barSize(2)/2];
            newy = [meany - barSize(1)/2, meany + barSize(1)/2, meany + barSize(1)/2, meany - barSize(1)/2];
            rec = patch(newx,newy,'r');
            axis([0 fieldSize(2) 0 fieldSize(1)])
            set(gca,'XTick',[]);set(gca,'YTick',[]);
            %Get rotation
            DragObject(rec);
            handles.rec = rec;
            rotate(handles.rec,[0 0 1],angle,[mean(x) mean(y) 0]);
            set(handles.rec,'FaceAlpha',0.25);
            guidata(handles.figure1,handles);
            
            
        elseif strcmp(char(stim(get(handles.popStimulus,'Value'))),'Sine')
            axes(handles.overlay)
            [x y w h] = find_stimulus(flipud(handles.large),129);       %Have to flip b/c retard Matlab image command flips
            axes(handles.overlay);
            if stimSize(1) == 120
                stimSize = [120 120];
            elseif stimSize(1) == 185
                stimSize = [120 120];
            elseif stimSize(1) == 285
                stimSize = [185 185];
            end
            [small, large, imagealpha] = makeSine('xpos',x/fieldSize(2),'ypos',y/fieldSize(1),'width',stimSize(1),'sineoutput',2,'theta',angle);        %MEMORY LEAK??
            sinestim = image(large,'AlphaData',imagealpha);
            axis([0 fieldSize(2) 0 fieldSize(1)])
            set(gca,'XDir','normal','YDir','normal');
            axis('image')
            axis('off')
            set(handles.overlay,'XTick',[],'YTick',[],'XTickLabel',[],'YTickLabel',[]);
            DragObject(sinestim);
            handles.large = large;
        elseif strcmp(char(stim(get(handles.popStimulus,'Value'))),'Spot')
            axes(handles.overlay)
            if spotSize == 20
                spotSize = 20;
            elseif spotSize == 35
                spotSize = 20;
            elseif spotSize == 85
                spotSize = 35;
            end
            th = linspace(0,2*pi,100);
            [x,y] = pol2cart(th,spotSize);
            xdata = get(handles.spot,'XData');
            ydata = get(handles.spot,'YData');
            x = x + min(xdata(:))+spotSize;
            y = y + min(ydata(:))+spotSize;
            delete(handles.spot);
            spot = patch(x,y,'r');
            %set(spot,'XData',xdata,'YData',ydata);  %Move spot away from corner
            axis([0 fieldSize(2) 0 fieldSize(1)])
            %set(handles.overlay,'XTick',[],'YTick',[],'XTickLabel',[],'YTickLabel',[]);
            set(gca,'XTick',[]);set(gca,'YTick',[]);
            DragObject(spot);
            handles.spot = spot;
            set(spot,'FaceAlpha',0.25);
            guidata(handles.figure1,handles);
        end
    elseif strcmp(event.Key,'m') || strcmp(event.Key,'pageup')
        %Zoom in
        stim = get(handles.popStimulus,'String');        %Get array of stimuli
        if  strcmp(char(stim(get(handles.popStimulus,'Value'))),'Bar') %Find item in current index, convert to string
            if barSize == [10 50]
                barSize = [15 75];
            elseif barSize == [15 75]
                barSize = [20 100];
            elseif barSize == [20 100]
                barSize = [20 100];
            end
            x = get(handles.rec,'XData'); %[1 1 101 101];
            y = get(handles.rec,'YData'); %[1 21 21 1];
            axes(handles.overlay);
            delete(handles.rec)
            meanx = mean(x);
            meany = mean(y);
            newx = [meanx - barSize(2)/2, meanx - barSize(2)/2, meanx + barSize(2)/2, meanx + barSize(2)/2];
            newy = [meany - barSize(1)/2, meany + barSize(1)/2, meany + barSize(1)/2, meany - barSize(1)/2];
            %51-25 51+25 = [26 26 76 76]
            %11-5 11+5 = [6 16 16 6]
            rec = patch(newx,newy,'r');
            axis([0 fieldSize(2) 0 fieldSize(1)])
            set(gca,'XTick',[]);set(gca,'YTick',[]);
            
            DragObject(rec);
            handles.rec = rec;
            rotate(handles.rec,[0 0 1],angle,[mean(x) mean(y) 0]);
            
            set(handles.rec,'FaceAlpha',0.25);
            guidata(handles.figure1,handles);
        elseif strcmp(char(stim(get(handles.popStimulus,'Value'))),'Sine')
            axes(handles.overlay)
            [x y w h] = find_stimulus(flipud(handles.large),129);       %Have to flip b/c retard Matlab image command flips
            fprintf('findx = %d findy = %d xratio = %0.5d yratio = %0.5d\n',x,y,x/fieldSize(2),y/fieldSize(1));
            axes(handles.overlay);
            if stimSize(1) == 120
                stimSize = [185 185];
            elseif stimSize(1) == 185
                stimSize = [285 285];
            elseif stimSize(1) == 250
                stimSize = [285 285];
            end
            [small, large, imagealpha] = makeSine('xpos',x/fieldSize(2),'ypos',y/fieldSize(1),'width',stimSize(1),'sineoutput',2,'theta',angle);        %MEMORY LEAK??
            sinestim = image(large,'AlphaData',imagealpha);
            axis([0 fieldSize(2) 0 fieldSize(1)])
            axis('image')
            axis('off')
            set(handles.overlay,'XTick',[],'YTick',[],'XTickLabel',[],'YTickLabel',[]);
            DragObject(sinestim);
            handles.large = large;
        elseif strcmp(char(stim(get(handles.popStimulus,'Value'))),'Spot')
            axes(handles.overlay)
            if spotSize == 20
                spotSize = 35;
            elseif spotSize == 35
                spotSize = 85;
            elseif spotSize == 85
                spotSize = 85;
            end
            th = linspace(0,2*pi,100);
            [x,y] = pol2cart(th,spotSize);
            xdata = get(handles.spot,'XData');
            ydata = get(handles.spot,'YData');
            x = x + min(xdata(:))+spotSize;
            y = y + min(ydata(:))+spotSize;
            delete(handles.spot);
            spot = patch(x,y,'r');
            axis([0 fieldSize(2) 0 fieldSize(1)])
            set(gca,'XTick',[]);set(gca,'YTick',[]);
            DragObject(spot);
            handles.spot = spot;
            set(spot,'FaceAlpha',0.25);
            guidata(handles.figure1,handles);
        end
    elseif strcmp(event.Key,'e')
        pause(0.2)
        stim = get(handles.popStimulus,'String');        %Get array of stimuli
        if strcmp(char(stim(get(handles.popStimulus,'Value'))),'Bar'); %Find item in current index, convert to string
            xdata = get(handles.rec,'XData');         %Get mean of 4 X points
            ydata = get(handles.rec,'YData');         %Get mean of 4 Y points
            angle = angle - 15;
            if angle <= 0; angle = 360; end;
            rotate(handles.rec,[0 0 1],-15,[mean(xdata) mean(ydata) 0]);%[0 0 1] = rotate around Z, -15 = angle, [xmean ymean 0] rotate relative to patch, not axes
        elseif strcmp(char(stim(get(handles.popStimulus,'Value'))),'Sine')
            axes(handles.overlay)
            angle = angle - 15;         %Not a typo/error: apparent rotation in opposite direction
            if angle <= 0
                angle = 360;
            end
            [x y w h] = find_stimulus(flipud(handles.large),129);       %Have to flip b/c retard Matlab image command flips
            axes(handles.overlay);
            [small, large, imagealpha] = makeSine('xpos',x/fieldSize(2),'ypos',y/fieldSize(1),'width',stimSize(1),'sineoutput',2,'theta',angle);        %MEMORY LEAK??
            sinestim = image(large,'AlphaData',imagealpha);
            axis([0 fieldSize(2) 0 fieldSize(1)])
            axis('image')
            axis('off')
            set(handles.overlay,'XTick',[],'YTick',[],'XTickLabel',[],'YTickLabel',[]);
            DragObject(sinestim);
            handles.large = large;
        elseif strcmp(char(stim(get(handles.popStimulus,'Value'))),'Movement')
            angle = angle - 45;
            if angle <= 0; angle = 360; end;
            arrow_cursor(angle);
        end
    elseif strcmp(event.Key,'q')
        pause(0.2)
        stim = get(handles.popStimulus,'String');        %Get array of stimuli
        if  strcmp(char(stim(get(handles.popStimulus,'Value'))),'Bar'); %Find item in current index, convert to string
            xdata = get(handles.rec,'XData');         %Get mean of 4 X points
            ydata = get(handles.rec,'YData');         %Get mean of 4 Y points
            angle = angle + 15;
            if angle >= 360; angle = 0; end;
            rotate(handles.rec,[0 0 1],15,[mean(xdata) mean(ydata) 0]);
        elseif strcmp(char(stim(get(handles.popStimulus,'Value'))),'Sine')
            axes(handles.overlay)
            angle = angle + 15;
            if angle >= 360
                angle = 0;
            end
            [x y w h] = find_stimulus(flipud(handles.large),129);       %Have to flip b/c retard Matlab image command flips
            axes(handles.overlay);
            [small, large, imagealpha] = makeSine('xpos',x/fieldSize(2),'ypos',y/fieldSize(1),'width',stimSize(1),'sineoutput',2,'theta',angle);        %MEMORY LEAK??
            sinestim = image(large,'AlphaData',imagealpha);
            axis([0 fieldSize(2) 0 fieldSize(1)])
            axis('image')
            axis('off')
            set(handles.overlay,'XTick',[],'YTick',[],'XTickLabel',[],'YTickLabel',[]);
            DragObject(sinestim);
            handles.large = large;
            
        elseif strcmp(char(stim(get(handles.popStimulus,'Value'))),'Movement')
            angle = angle + 45;
            if angle >= 360; angle = 0; end;
            arrow_cursor(angle);
        end
    elseif strcmp(event.Key,'backquote')
        %`/~ key
        %Take screenshot shortcut
        btnScreenshot_Callback(handles.btnScreenshot,[],handles);
    elseif strcmp(event.Key,'alt') || strcmp(event.Key,'ctrl')
        %To avoid beeping when trying to close etc.
    else
        beep()
        %disp('Wrong key')
    end
    axes(handles.overlay)           %Keep the bar figure on top so it doesn't disappear
    setappdata(0, 'appMarks', marks);
end
end

function update_display(hObject,eventdata,hfigure)    %(hObject,eventdata,hfigure)
% Timer timer1 callback, called each time timer iterates. For displaying
% changes in stimulus response.
global fieldSize %fireRest fireExcite fireInhib;
global fireRate fireRest fireExcite fireInhib
global fAP lms rodout
global pix map gbr
handles = guidata(hfigure);
set(handles.figAP,'Interruptible','on','BusyAction','cancel')   %\@
set(handles.figAP,'XTick',[],'YTick',[],'XLim',[0 100],'YLim',[-1 1]);      %Remove axes but leave lines

ips = 0;
exstate = 'Baseline';
excolor = [0 0 0];
x1=[]; y1=[];
set(handles.figAP,'Color','white');
% % % hold on             %Add new spikes on top of horizontal

pos = get(handles.f,'CurrentPoint');
x = round(pos(1,1));
y = round(pos(1,2));
rgb=[0 0 0];

celltype = get(handles.popCellType,'String');
switch char(celltype(get(handles.popCellType,'Value')))
    case {'On-center cell','Off-center cell'}
        if (x > 0 && x < fieldSize(2)) && (y > 0 && y < fieldSize(1))
            rgb = [(pix(y,x,1)),(pix(y,x,1)),(pix(y,x,1))];
        end      
        %Ignore peripheral gray area as non-response, not slightly excitatory
        ips = fireRate * 100; % To scale to range ~25-75
        if strcmp(char(celltype(get(handles.popCellType,'Value'))),'On-center cell')
            m = max(pix(:));
            fireRate =  (fireExcite - fireInhib) * rgb(1)/256 + fireInhib/2; %Inhib = 0.1 excit = 0.4
        elseif strcmp(char(celltype(get(handles.popCellType,'Value'))),'Off-center cell')
            rgb = rgb - 114.0911;
            m = min(pix(:));
            fireRate =  (fireExcite - fireInhib) * rgb(1)/256 + fireExcite/2; %Inhib = 0.1 excit = 0.4
        end
        a = find(pix==m);
        [r c] = ind2sub(size(pix),a);
        xpos = x; ypos = y; %fieldSize(1) - y;
        if (xpos > (c - 100) && xpos < (c + 100)) && ...
                (ypos > (r - 100) && ypos < (r + 100))
            inRange = true;
        else
            inRange = false;
        end
        
        if fireRate > 0.2 && inRange
            exstate = 'Excited';
            excolor = [0 1 0];
        elseif fireRate <= 0.15 && inRange
            exstate = 'Inhibited';
            excolor = [1 0 0];
        else
            ips = 25;
            fireRate = 0.25;
            exstate = 'Baseline';
            excolor = [0 0 0];
        end
    case {'Simple cell'}  %and Complex???
        stim = get(handles.popStimulus,'String');
        switch char(stim(get(handles.popStimulus,'Value')))
            case 'Point'
                if (x > 0 && x < fieldSize(2)) && (y > 0 && y < fieldSize(1))
                    rgb = [(gbr(y,x,1)),(gbr(y,x,1)),(gbr(y,x,1))];
                end
                fireRate =  (fireExcite - fireInhib) * rgb(1) + fireInhib/2; %Inhib = 0.1 excit = 0.4
                
                if fireRate > 0.29 && fireRate < 0.31; fireRate = 0.25; end;
                ips = fireRate * 100; % To scale to range ~25-75
                if fireRate >= 0.4
                    exstate = 'Excited';
                    excolor = [0 1 0];
                elseif fireRate < 0.25
                    exstate = 'Inhibited';
                    excolor = [1 0 0];
                else        %if fireRate < 0.25 && fireRate >= 0.1
                    exstate = 'Baseline';
                    excolor = [0 0 0];
                end
                %Ignore peripheral gray area as non-response, not slightly excitatory
                
                str = sprintf('(%0.2f, %0.2f, %0.2f)',rgb(1),rgb(2),rgb(3)); %0.2 = decimal floating point, to hundredths place e.g 1.2563 = 1.26
                set(handles.lblPos,'String',str);
            case 'Bar'
                fEx = 1.5;
                fIn = 0.05;
                [resp,respf] = mean_response(handles.f,'Bar');
                ips = (resp - 53) * 0.75; % To scale to range ~25-75
                if ips < 0; ips = 2; end;
                if ips > 75; ips = 75; end;
                if resp == 0 || isnan(resp); ips = 25; fireRate = fireRest; end;   %If background
                fireRate = ips / 100;
                
                if fireRate >= 0.4
                    exstate = 'Excited';
                    excolor = [0 1 0];
                    
                elseif fireRate < 0.25
                    exstate = 'Inhibited';
                    excolor = [1 0 0];
                    
                else        %if fireRate < 0.25 && fireRate >= 0.1
                    exstate = 'Baseline';
                    excolor = [0 0 0];
                    
                end
            case 'Spot'
                fEx = 1.5;
                fIn = 0.05;
                [resp,respf] = mean_response(handles.f,'Spot');
                ips = (resp - 53) * 0.75; % To scale to range ~25-75
                if ips < 0; ips = 2; end;
                if ips > 75; ips = 75; end;
                if resp == 0 || isnan(resp); ips = 25; fireRate = fireRest; end;   %If background
                fireRate = ips / 100;               
                if fireRate >= 0.4
                    exstate = 'Excited';
                    excolor = [0 1 0];
                elseif fireRate < 0.25
                    exstate = 'Inhibited';
                    excolor = [1 0 0];
                else        %if fireRate < 0.25 && fireRate >= 0.1
                    exstate = 'Baseline';
                    excolor = [0 0 0];
                end
            case 'Sine'
                %
        end
    case {'+L-M','-L+M','+M-L','-M+L','+S-LM'}
        stim = get(handles.popStimulus,'String');
        str = char(stim(get(handles.popStimulus,'Value')));
        reg = str(1:3);
        [lms] = lookup_Cone(str2double(reg));
        if (x > 0 && x < fieldSize(2)) && (y > 0 && y < fieldSize(1))
            pt = round(pix(y,x));       %Pixel level of indexed image = row in map
            col = map(pt,:);
            [h,s,v] = RGB_to_HSV(col);
            m = max(pix(:));
            a = find(pix==m);   %Find center
            [r c] = ind2sub(size(pix),a);
            xpos = fieldSize(2) - x; ypos = fieldSize(1) - y;
            if xpos > c - 130 && xpos < c + 130
                inRange = true;
            elseif ypos > (r - 130) && ypos < (r + 130)
                inRange = true;
            else
                inRange = false;
            end
            
            if strcmp(char(celltype(get(handles.popCellType,'Value'))),'+L-M') || ...
                    strcmp(char(celltype(get(handles.popCellType,'Value'))),'-M+L')
                ips = round((lms(1) / lms(2)) * 25);
                
            elseif strcmp(char(celltype(get(handles.popCellType,'Value'))),'+M-L') || ...
                    strcmp(char(celltype(get(handles.popCellType,'Value'))),'-L+M')
                ips = round((lms(2) / lms(1)) * 25);
            elseif strcmp(char(celltype(get(handles.popCellType,'Value'))),'+S-LM')
                ips = round((lms(3) / (lms(1) + lms(2)))/2*25);
                
            else
                disp('Check to make sure proper color center cell was chosen');
            end
            
            if ips > 75; ips = 75; end;
            fireRate = ips / 100;
            if fireRate > 0.3
                exstate = 'Excited';
                excolor = [0 1 0];
            elseif fireRate < 0.1
                exstate = 'Inhibited';
                excolor = [1 0 0];
            else
                exstate = 'Baseline';
                excolor = [0 0 0];
            end
        end
    case 'L cone'
        stim = get(handles.popStimulus,'String');
        str = char(stim(get(handles.popStimulus,'Value')));
        reg = str(1:3);
        [lms] = lookup_Cone(str2double(reg));
        ips = lms(1) * 75;
        fireRate = lms(1) * 0.75;
    case 'M cone'
        stim = get(handles.popStimulus,'String');
        str = char(stim(get(handles.popStimulus,'Value')));
        reg = str(1:3);
        [lms] = lookup_Cone(str2double(reg));
        ips = lms(2) * 75;
        fireRate = lms(2) * 0.75;
    case 'S cone'
        stim = get(handles.popStimulus,'String');
        str = char(stim(get(handles.popStimulus,'Value')));
        reg = str(1:3);
        [lms] = lookup_Cone(str2double(reg));
        ips = lms(3) * 75;
        fireRate = lms(3) * 0.75;
    case 'Rod'
        stim = get(handles.popStimulus,'String');
        str = char(stim(get(handles.popStimulus,'Value')));
        reg = str(1:3);
        [~,rodout] = lookup_Cone(str2double(reg));
        ips = rodout * 75;
        fireRate = rodout * 0.75;
        %     case 'Complex cell'
        %         resp = movement_response(handles.f);
        %         str = sprintf('(%0.2f, %0.2f, %0.2f)',activation(1),activation(2),activation(3));
        %         set(handles.lblPos,'String',str);
        %         maxFire = max([activation(1),activation(2),activation(3)]);
        %         fireRate =  (fireExcite - fireInhib) * maxFire/256 + fireInhib; %Inhib = 0.1 excit = 0.4
end    %switch

for i=2:2:98            %Leave spaces between spikes
    r = rand;
    if r < fireRate
        %E.g., fireRate = 0.20, 20% chance of line appearing at each position
        x1 = [i i i];
        y1 = [-1 0 +1];
        set(fAP(i,:),'XData',x1,'YData',y1);
        %^ Replotting is slow and can bog down/errors. It stays plotted and
        %the data just changes. Much more efficient!
        set(handles.txtExcitation,'String',sprintf('%0.0f spikes/s, %s',ips,exstate),'ForegroundColor',excolor);
    else
        %Draw over horizontal if no spike
        set(fAP(i,:),'XData',[0 50 100],'YData',[0 0 0]);
    end
end

%Annoying, won't bother
%http://stackoverflow.com/questions/1452455/how-do-you-generate-dual-tone-frequencies-in-matlab
%http://www.mathworks.com/matlabcentral/fileexchange/46192-discrete-sound-pulse-generator/content/Soundsteps.m

% if strcmp(exstate,'Excited')
%     t = 0:0.01:11; %0.5s
%     freq = 2200;
% elseif strcmp(exstate,'Baseline')
%     t = 0:0.01:10; %1001 = ~0.5s
%     freq = 2000;
% elseif strcmp(exstate,'Inhibited')
%     t = 0:0.1:100;
%     freq = 1000;
% end
% saw = sawtooth(2*pi*t);
% sound(saw,freq);

guidata(handles.figure1,handles);
end

%%%%%%%%%%%%%%%%%%%% KEEP THIS: For generating AP video in update_display%%%%%%%%%%%%%%%%%%%%
% cla                     %Clear axis, or else it will add 49 more lines w/o clearing
% line([0 100],[0 0]);    %Draw horizontal line (0,0) to (100,0), e.g. ([x1 x2],[y1 y2])
% hold on
% for i=2:2:98            %Leave spaces between spikes
%     r = rand;
%     if r < fireRate
%         line([i i i],[-1 0 +1])
%     end
% end
%%%%%%%%%%%%%%%%%%%%
% handles.mov(fra) = getframe(handles.figAP);
% guidata(hfigure,handles);
% fra = fra + 1;
% fra
% if fra == 100
%     vidObj = VideoWriter('p0.05 fr5 s19.avi');
%     vidObj.FrameRate = 5;
%     open(vidObj)
%     writeVideo(vidObj,handles.mov);
%     close(vidObj);
%     close all
% end

% fireRest = 0.25;
% fireExcite = 0.5;
% fireInhib = 0.10;

% function lineicon(theta)
% %Change icon to reflect stimulus, no use without complex
% cursor = zeros(16); %2 white 1 black
% cursor(:,:) = NaN;  %Invisible
% rads = theta*pi/180;
% angle2 = theta - 180;
% if angle2 < 0
%     angle2 = angle2 + 360;            %Fixes ~45 to 135 range
% end
% rads2 = angle2*pi/180;
% x1 = cos(rads);
% y1 = sin(rads);
% x2 = cos(rads2);
% y2 = sin(rads2);
% if (theta > 0 && theta < 90) || (theta > 180 && theta < 270)
%     %Quadrants I and III
%     x_delta = x1 - x2;
%     y_delta = y1 - y2;
% elseif (theta > 90 && theta < 180) || (theta > 270 && theta < 360)
%     %Quadrants II and IV
%     x_delta = x2 - x1;
%     y_delta = y2 - y1;
% else
%     slope = NaN;
% end
% width = 5;
% slope = (y_delta / x_delta);
% if (slope > 1) || (slope < -1)
%     endpoint = 16 / slope;
%     plot([0 endpoint],[0 16],'k','LineWidth',width)
%     hold on
%     plot([0 -endpoint],[0 -16],'k','LineWidth',width)
% elseif (slope > 0 && slope < 1) || (slope < 0 && slope > -1)
%     endpoint = 16 * slope;
%     plot([0 16],[0 endpoint],'k','LineWidth',width)
%     hold on
%     plot([0 -16],[0 -endpoint],'k','LineWidth',width)
% else
%     disp('Invalid slope!')
% end
% xlim([-16 16])
% ylim([-16 16])
% colormap(gray)
% axis off
% frm = getframe(gcf);
% [img,map] = frame2im(frm);
% %imwrite(img,'aaa.png','PNG')
% small = imresize(img,'OutputSize',[16 16]);
% imwrite(small,'aaa.png','PNG')
% set(gcf,'Pointer','custom','PointerShapeCData',small/255,'PointerShapeHotSpot',[9 9])
% end

%% Misc

function flag=isMultipleCall()
s = dbstack();
% s(1) corresponds to isMultipleCall
if numel(s)<=2, flag=false; return; end
% compare all functions on stack to name of caller
count = sum(strcmp(s(2).name,{s(:).name}));
% is caller re-entrant?
if count>1, flag=true; else flag=false; end
end


%% Mouse moving not related to object dragging (e.g. marking)
function [x,y,rgb] = moveMouse(hObject,event_obj)
% This function runs every time the mouse moves
if isMultipleCall();  return;  end
handles = guidata(hObject);
if strcmp(get(handles.btnStart,'Visible'),'off')
    global fieldSize pix fireRate fireRest fireExcite fireInhib;
    handles = guidata(hObject);
    pos = get(gca,'CurrentPoint');
    %get(handles.lblPos,'String');
    rgb=[0 0 0];
    x = round(pos(1,1));
    y = round(pos(1,2));
    if (x > 0 && x < fieldSize(2)) && (y > 0 && y < fieldSize(1))
        %if within bounds
        celltype = get(handles.popCellType,'String');
        switch char(celltype(get(handles.popCellType,'Value')))
            case {'On-center cell','Off-center cell'}
                set(handles.f,'Interruptible','off');
                set(handles.f,'BusyAction','cancel');
                rgb = [(pix(y,x,1)),(pix(y,x,1)),(pix(y,x,1))];            %Not technically RGB yet... 0<>1, round to index
                
                if rgb(1) > 50 %(rgb(1) == 255) && (rgb(2) == 255) && (rgb(3) == 255)
                    %disp('So excited!')
                    fireRate = fireExcite;
                elseif rgb(1) < -20 %(rgb(1) == 128) && (rgb(2) == 128) && (rgb(3) == 128)
                    %disp('Inhibition!')
                    fireRate = fireInhib;
                elseif rgb(1) < 50 && rgb(1) > -20
                    %disp('Resting')
                    fireRate = fireRest;
                else
                    disp('rgb out of range to measure excitation')
                end
            case {'Simple cell'}  %and Complex???
                set(handles.f,'Interruptible','off')
                set(handles.figAP,'Interruptible','off')
                stim = get(handles.popStimulus,'String');
                switch char(stim(get(handles.popStimulus,'Value')))
                    case 'Bar'
                    case 'Sine'
                end
            case {'L cone','M cone','S cone','Rod'}
                %L, M, S, Rod
                rgb = [(pix(round(y),round(x),1)) ...
                    (pix(round(y),round(x),2)) ...
                    (pix(round(y),round(x),3))];            %Not technically RGB yet... 0<>1, round to index
                rgb = round(rgb.*255);                                  % scale so that 1 = 255, 0.5 = 128 etc., round to whole number
                
                stim = get(handles.popStimulus,'String');
                switch char(stim(get(handles.popStimulus,'Value')))
                    case 'L cone'
                        resp = [1 0 0];
                    case 'M cone'
                        resp = [0 1 0];
                    case 'S cone'
                        resp = [0 0 1];
                    case 'Rod'
                        resp = [0 0 0];
                    otherwise
                        %Nothing
                        return
                end
                set(handles.lblPos,'String',str);
        end
    end
    p = [x,y];
    handles.pos = p;
    guidata(handles.figure1,handles);
end         %End for check if program started
end

function release(hObject, eventdata)
%disp('up')
set(gcf,'WindowButtonMotionFcn',@moveMouse);
end

%% Dragging stimulus object
function DragObject(h)
%Initial landing point for starting of stimulus dragging
handles = guidata(h);
stim = get(handles.popStimulus,'String');        %Get array of stimuli
switch char(stim(get(handles.popStimulus,'Value'))) %Find item in current index, convert to string
    case {'Bar','Sine','Spot'}
        gui = get(gcf,'UserData');
        set(h,'ButtonDownFcn',@StartDrag);
        set(gcf,'UserData',gui);
    otherwise
        return
end
end

function StartDrag(src,evnt)
%Second stage startiong with initial click. Getting mouse location, handling clicks
ud = get(gcf,'UserData');
invisible_cursor()

ud.currenthandle = src;
f = gcbf();
%Callbacks
set(f,'WindowButtonMotionFcn',@DoDrag);
set(f,'WindowButtonUpFcn',@StopDrag);

%Get XY data
ud.startpoint = get(gca,'CurrentPoint');
set(ud.currenthandle,'UserData',{get(ud.currenthandle,'XData') get(ud.currenthandle,'YData')});
set(gcf,'UserData',ud);
end

function DoDrag(src,evnt)
ud = get(gcf,'UserData');

%Check initial state
pos = get(gca,'CurrentPoint') - ud.startpoint;
XYData = get(ud.currenthandle,'UserData');     %At start of moving, resets when released

%Check changed state, update display
set(ud.currenthandle,'XData',XYData{1} + pos(1,1));
set(ud.currenthandle,'YData',XYData{2} + pos(1,2));
drawnow;

set(gcf,'UserData',ud);
end

function StopDrag(src,evnt)
%On stop, restore setting for next click
f = gcbf();
gui = get(gcf,'UserData');
regular_cursor()
set(f,'WindowButtonUpFcn','');
set(f,'WindowButtonMotionFcn','');
drawnow;
set(gui.currenthandle,'UserData','');
set(gcf,'UserData',[]);
end

function [response,respfield] = mean_response(hObject, stimtype)
%Get average response based on overlap of cell receptive field and light stimulus area
%bar rec = 100 x 20
global fieldSize;
handles = guidata(hObject);
if strcmp(stimtype,'Bar')
    xdata = get(handles.rec,'XData');       %Get mean of 4 X points
    ydata = get(handles.rec,'YData');       %Get mean of 4 Y points
elseif strcmp(stimtype,'Spot')
    xdata = get(handles.spot,'XData');       %Get mean of 4 X points
    ydata = get(handles.spot,'YData');       %Get mean of 4 Y points
end

if ~isempty(find(xdata<1)) || ~isempty(find(ydata<1)) || ...
        ~isempty(find(xdata>fieldSize(2))) || ~isempty(find(ydata>fieldSize(1)))    %End if out of bounds
    responses = [];
    return
end

xminrec = round(min(xdata));               %Leftmost pixel
xmaxrec = round(max(xdata));               %Rightmost pixel
yminrec = round(min(ydata));               %Top?most pixel
ymaxrec = round(max(ydata));               %Bottom?most pixel
ymin1 = yminrec;
ymax1 = ymaxrec;
yminrec = fieldSize(1) - yminrec;
ymaxrec = fieldSize(1) - ymaxrec;
[x,y] = meshgrid(1:fieldSize(2),1:fieldSize(1));
poly = double(inpolygon(x,y,xdata',ydata'));              %Field in size of polygon shown 1 if polygon there, 0 if not. Size depends on angle (for bar)
field = imread('stim out.png');                 %Pixel values of the RF field
field = double(field);
fieldsmall = field(yminrec:ymaxrec,xminrec:xmaxrec);        %Shows pixel values in same area as polygon
bkgd = mode(field(:));     %99 Probably
[r,c] = find(field~=bkgd);        %Find all that aren't background
xminrf = round(min(c(:)));        %Get location of object
xmaxrf = round(max(c(:)));
yminrf = round(min(r(:)));
ymaxrf = round(max(r(:)));
responses = poly.*(field-bkgd);                   %E.g. what is stimulus pixel value under polygon, needs to be unsigned
response = double(mean(nonzeros(responses(:)))+bkgd);       %Need to do double?
if nargout > 1; respfield = responses; end;
guidata(hObject,handles);
end

% function response = movement_response(hObject)
% %For complex cells, decided not to implement.
% global angle complexAngle fieldSize
% handles = guidata(hObject);
% pos = round(get(gca,'CurrentPoint'));  %1,1 = x, 1,2 = y
% if (pos(1,1) >= 1 || pos (1,1) < fieldSize(2)) && (pos(1,2) >= 1 || pos (1,2) < fieldSize(1))
%     xdata = get(handles.complex,'XData');
%     ydata = get(handles.complex,'YData');
%     [x,y] = meshgrid(1:fieldSize(2),1:fieldSize(1));
%     in = inpolygon(x,y,xdata',ydata');
%     sum(in(:))
%     if in(pos(1,1),pos(1,2)) == 1
%         if angle == complexAngle
%             %Best response
%         elseif abs(angle - complexAngle) < 90
%             %Good enough
%         end
%         %Increase response
%     end
% end
% response = 0;
% guidata(hObject, handles);
% end

%% Button callbacks. Many are minimal, but preferred by MATLAB
function listColors_Callback(hObject, eventdata, handles)
%Nothing right now
end

function popCellType_Callback(hObject, eventdata, handles)
%On change of cell type
handles = guidata(hObject);
header = {'[Stimulus Type]'};
set(handles.popStimulus,'Value',1);
set(handles.popStimulus,'String',header,'ForegroundColor',[0 0 0],'BackgroundColor',[1 1 1]);
celltype = get(handles.popCellType,'String');
switch char(celltype(get(handles.popCellType,'Value')))
    case 'Cell Type'
        return
    case {'On-center cell','Off-center cell'}
        set(handles.popStimulus,'String',{char(header),'Point','Spot','Bar'}, ...
            'Value',2);
    case {'Simple cell'}
        set(handles.popStimulus,'String',{char(header),'Bar' 'Sine','Spot'}, ...
            'Value',2);
    case {'Complex cell','Hypercomplex cell'}
        set(handles.popStimulus,'String',{char(header),'Movement'},'Value',2);
    case {'+L-M','-L+M','+M-L','-M+L','+S-LM','L cone','M cone','S cone','Rod'}
        set(handles.popStimulus,'String',{char(header),'420 Violet', ...
            '448 S cone','480 Blue','498 Rod', ...
            '530 Green','542 M cone','570 L cone','580 Yellow','600 Orange','630 Red'}, ...
            'Value',2);
        switch char(celltype(get(handles.popCellType,'Value')))
            case {'L cone'}
                set(handles.popStimulus,'BackgroundColor',[1 0 0]);
                set(handles.popStimulus,'ForegroundColor',[0 0 0]);
                set(handles.popStimulus,'Value',2);
            case {'M cone'}
                set(handles.popStimulus,'BackgroundColor',[0 1 0]);
                set(handles.popStimulus,'ForegroundColor',[0 0 0]);
                set(handles.popStimulus,'Value',3);
            case {'S cone'}
                set(handles.popStimulus,'BackgroundColor',[0 0 1]);
                set(handles.popStimulus,'ForegroundColor',[0 0 0]);
                set(handles.popStimulus,'Value',4);
            case {'Rod'}
                set(handles.popStimulus,'BackgroundColor',[0 0 0]);
                set(handles.popStimulus,'ForegroundColor',[1 1 1]);
                set(handles.popStimulus,'Value',5);
        end
        
end
end

function popStimulus_Callback(hObject, eventdata, handles)
%On change of stimulus type
global fieldSize lms rodout
handles = guidata(hObject);
stim = get(handles.popStimulus,'String');
set(handles.popStimulus,'ForegroundColor',[0 0 0]); %Reset black text
str = char(stim(get(handles.popStimulus,'Value')));
switch str
    case {'Point'}
        regular_cursor
    case {'Bar'}
        if isfield(handles,'rec')
            delete(handles.rec);
        elseif isfield(handles,'sine')
            delete(handles.sine);
        elseif isfield(handles,'spot')
            delete(handles.spot);
        end
        x = [10 10 111 111];
        y = [11 31 31 11];
        borders = get(handles.f,'Position');
        set(handles.overlay,'Visible','on','Color','none','Position',borders)
        axes(handles.overlay);
        rec = patch(x,y,'r');
        xdata = get(rec,'XData');
        ydata = get(rec,'YData');
        handles.rec = rec;
        set(handles.rec,'FaceAlpha',0.25);      %Make bar transparent
        set(rec,'XData',xdata+100,'YData',ydata+100);  %Move bar away from corner
        axis([1 fieldSize(2) 1 fieldSize(1)])
        set(gca,'XTick',[]);set(gca,'YTick',[])
        DragObject(rec);
        
    case {'Sine'}
        %        set(handles.rec,'Visible','off')
        %sine_stim = makeSine()
    case {'Spot'}
        if isfield(handles,'rec')
            delete(handles.rec);
        elseif isfield(handles,'sine')
            delete(handles.sine);
        elseif isfield(handles,'spot')
            delete(handles.spot);
        end
        %Create circular stimulus
        txtwidth = get(handles.f,'Position');
        xInstr = fieldSize(2)+25;
        yInstr = txtwidth(2) + 25; % + fieldSize(1)-170;
        set(handles.lblInstructions,'Visible','on');
        linebreak = sprintf('\n');
        
        instr = {'-/+ on keypad to zoom stimulus (2 sizes)',linebreak,...
            'Click then  push -/_ or +/= to mark excitatory/inhibitory areas'};
        set(handles.lblInstructions,'Position',[xInstr,yInstr,400,150],'String',instr);
        
        th = linspace(0,2*pi,100);
        [x,y] = pol2cart(th,20);
        spot = patch(x,y,'r');
        xdata = get(spot,'XData');
        ydata = get(spot,'YData');
        set(spot,'XData',xdata+100,'YData',ydata+100);  %Move spot away from corner
        axis([0 fieldSize(2) 0 fieldSize(1)])
        set(spot,'FaceAlpha',0.25);
        DragObject(spot)
        handles.spot = spot;
        guidata(handles.figure1,handles);
    case {'570 L cone'}
        reg = regexp(str,'\d');  %Extract numbers
        [lms] = lookup_Cone(str2num(str(reg)));
        set(handles.popStimulus,'BackgroundColor',[1 0 0]);
    case {'542 M cone'}
        reg = regexp(str,'\d');  %Extract numbers
        [lms] = lookup_Cone(str2num(str(reg)));
        set(handles.popStimulus,'BackgroundColor',[0 1 0]);
    case {'448 S cone'}
        reg = regexp(str,'\d');  %Extract numbers
        [lms] = lookup_Cone(str2num(str(reg)));
        set(handles.popStimulus,'BackgroundColor',[0 0 1]);
    case {'498 Rod'}
        set(handles.popStimulus,'BackgroundColor',[0 0 0]);
        set(handles.popStimulus,'ForegroundColor',[1 1 1]);
    case '630 Red'
        %         .705 .290
        set(handles.popStimulus,'BackgroundColor',[1 0 0]);
    case '600 Orange'
        %         .625 .370
        [r,g,b] = HSV_to_RGB([30 1 1]);
        set(handles.popStimulus,'BackgroundColor',[r g b]);
    case '580 Yellow'
        %         .510 .485
        [r,g,b] = HSV_to_RGB([60 1 1]);
        set(handles.popStimulus,'BackgroundColor',[r g b]);
    case '530 Green'
        %         .555 .805
        set(handles.popStimulus,'BackgroundColor',[0 1 0]);
    case '480 Blue'
        %         .090 .130
        set(handles.popStimulus,'BackgroundColor',[0 0 1]);
    case '420 Violet'
        %         .170 .005
        [r,g,b] = HSV_to_RGB([300 1 0.5]);
        set(handles.popStimulus,'BackgroundColor',[r g b]);
end
guidata(handles.figure1,handles);
end

function popDemo_Callback(hObject, eventdata, handles)
%On change of button controlling demoing/experiment simulations
header = {'[Stimulus Type]'};
demo = get(handles.popDemo,'String');
%If doing a numbered item, hide the options
switch cell2mat(demo(get(handles.popDemo,'Value')))
    case {'1'}
        set(handles.popCellType,'Value',2);
        set(handles.popStimulus,'String',{'[Stimulus]','Point'});
        set(handles.popStimulus,'Value',2);
    case {'2'}  %1 or 2
        set(handles.popCellType,'Value',3);
        set(handles.popStimulus,'String',{'[Stimulus]','Point'});
        set(handles.popStimulus,'Value',2);
    case {'3','4'}  %3 or 4
        set(handles.popCellType,'Value',4);
        set(handles.popStimulus,'String',{char(header),'Point','Bar','Spot'});
        set(handles.popStimulus,'Value',2);
    case {'5'}      %on shown
        set(handles.popCellType,'Value',2);
        set(handles.popStimulus,'String',{char(header),'Point','Bar','Spot'});
        set(handles.popStimulus,'Value',3);
    case {'6'}      %simple shown
        set(handles.popCellType,'Value',4);
        set(handles.popStimulus,'String',{char(header),'Point','Bar','Spot'});
        set(handles.popStimulus,'Value',3);
    case {'7'}  %L, M shown
        set(handles.popCellType,'Value',10);
        set(handles.popStimulus,'String',{char(header),'420 Violet', ...
            '448 S cone','480 Blue','498 Rod', ...
            '530 Green','542 M cone','570 L cone','580 Yellow','600 Orange','630 Red'}, ...
            'Value',2,'BackgroundColor',[0.5 0 1]);
        set(handles.popStimulus,'Value',2);
    case {'8'}
        set(handles.popCellType,'Value',11);
        set(handles.popStimulus,'String',{char(header),'420 Violet', ...
            '448 S cone','480 Blue','498 Rod', ...
            '530 Green','542 M cone','570 L cone','580 Yellow','600 Orange','630 Red'}, ...
            'Value',2,'BackgroundColor',[0.5 0 1]);
        set(handles.popStimulus,'Value',2);
    case {'9'} %+L-M; -L+M shown
        set(handles.popCellType,'Value',5);
        set(handles.popStimulus,'String',{char(header),'420 Violet', ...
            '448 S cone','480 Blue','498 Rod', ...
            '530 Green','542 M cone','570 L cone','580 Yellow','600 Orange','630 Red'}, ...
            'Value',2,'BackgroundColor',[0.5 0 1]);
        set(handles.popStimulus,'Value',2);
    case {'10'}
        set(handles.popCellType,'Value',7);
        set(handles.popStimulus,'String',{char(header),'420 Violet', ...
            '448 S cone','480 Blue','498 Rod', ...
            '530 Green','542 M cone','570 L cone','580 Yellow','600 Orange','630 Red'}, ...
            'Value',2,'BackgroundColor',[0.5 0 1]);
        set(handles.popStimulus,'Value',2);
end
end

function btnScreenshot_Callback(hObject, eventdata, handles)
%Takes a screenshot, named 'Screen1.png' if 0 shots exist, or number of
%last one + 1 if at least one exists.
set(hObject,'interruptible','off');     %Keeps from skipping back on screenshots
handles = guidata(hObject);
shots = dir('Screen*.png');             %Get all screenshots
if size(shots,1) == 0                   %If 0 screens taken
    str = 'Screen01.png';
    num = 1;                            %These 2 lines just checks
    z = '0';
else
    last = shots(end).name;             %Get the last saved one (numerically)
    num = strrep(last,'Screen','');     %Remove 'Screen'
    num = strrep(num,'.png','');        %Remove '.png'
    num = str2double(num);
    num = num + 1;                      %Increment to next screenshot
    if num < 10
        z = '0';
    elseif num < 100
        z = '';
    else
        disp('99 screenshots max allowed: delete some!')
        return
    end
    str = strcat('Screen',z,num2str(num),'.png');
end
img = getframe(handles.f);              %Get screenshot
imwrite(img.cdata,str,'PNG');
if ~exist(strcat('Screenshot taken ''',z,str),'file'); disp(strcat('Screenshot taken ''',str)); end;   %Just in case, if out of order
set(hObject,'interruptible','on');
end

function togShow_Callback(hObject, eventdata, handles)
%Toggle between cell displayed/hidden
global map
marks = getappdata(0,'appMarks');
togglestate=get(hObject,'Value');
axes(handles.overlay)                     %Set axes to main figure or else it will show in AP area
set(gca,'XTickLabel',[],'YTickLabel',[],'XTick',[],'YTick',[]);
axes(handles.f)

set(gca,'XTickLabel',[],'YTickLabel',[],'XTick',[],'YTick',[]);
if togglestate == 1                %Show cell location and areas
    img = imread('stim out.png');  %Break imaging and making image into two steps = fix colormap
    image(img)
    colormap(map)
    set(handles.f,'XTickLabel',[],'YTickLabel',[],'XTick',[],'YTick',[]);
    
    axis('fill');
    axis('xy');
    axis('off')
    axis('equal')
elseif togglestate == 0           %Hide cell
    image(imread('blank.png'));
    colormap(gray(256))
    set(handles.f,'XTickLabel',[],'YTickLabel',[],'XTick',[],'YTick',[]);
    axis('fill');
    axis('xy');
    axis('off')
    axis('equal')
end
if ~isempty(marks)
    pos = cell2mat(marks(:,2:3));           %Make a (Nx2)matrix of all coordinates
    for i =1:size(marks,1)
        if strcmp(marks(i,1,:),'excitatory')
            text(pos(i,1),pos(i,2),'+','color','red','fontsize',16, ...
                'HorizontalAlignment','center','VerticalAlignment','middle');
        elseif strcmp(marks(i,1,:),'inhibitory')
            text(pos(i,1),pos(i,2),'-','color','red','fontsize',24, ...
                'HorizontalAlignment','center','VerticalAlignment','middle');
        end
    end
    %Move image loading part out of isempty?
end
set(handles.overlay,'Visible','on','Color','none')
axes(handles.overlay)
guidata(hObject, handles);
end

function btnStart_Callback(hObject, eventdata, handles)
%On start experiment button press, load state of other buttons
%and display cell
axes(handles.f)
axis('fill')
axis('xy')
axis('equal')
axis('off')
switch get(handles.popDemo,'Value');
    case {1,2,3,4,5}    %Non-experiment or hidden conditions 1-4
        startDemo(hObject, eventdata, handles);
    otherwise
        startExperiment(hObject, eventdata, handles);
end
end

%% Create callbacks, 
%Created by GUIDE, probably no use in current MATLAB but left for any
%compatibility issues

function listColors_CreateFcn(hObject, eventdata, handles)
%Autofunction, load color stimuli
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function popDemo_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function popCellType_CreateFcn(hObject, eventdata, handles)
%On cell type box creation
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function txtExcitation_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function popStimulus_CreateFcn(hObject, eventdata, handles)
%On stimulus box creation
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end