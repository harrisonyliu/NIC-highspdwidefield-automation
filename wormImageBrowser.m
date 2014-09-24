function varargout = wormImageBrowser(varargin)
% WORMIMAGEBROWSER MATLAB code for wormImageBrowser.fig
%      WORMIMAGEBROWSER, by itself, creates a new WORMIMAGEBROWSER or raises the existing
%      singleton*.
%
%      H = WORMIMAGEBROWSER returns the handle to a new WORMIMAGEBROWSER or the handle to
%      the existing singleton*.
%
%      WORMIMAGEBROWSER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in WORMIMAGEBROWSER.M with the given input arguments.
%
%      WORMIMAGEBROWSER('Property','Value',...) creates a new WORMIMAGEBROWSER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before wormImageBrowser_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to wormImageBrowser_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help wormImageBrowser

% Last Modified by GUIDE v2.5 23-Sep-2014 16:22:59

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @wormImageBrowser_OpeningFcn, ...
                   'gui_OutputFcn',  @wormImageBrowser_OutputFcn, ...
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

% --- Executes just before wormImageBrowser is made visible.
function wormImageBrowser_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to wormImageBrowser (see VARARGIN)
handles.current_data = varargin{1};
maxNum = numel(handles.current_data);
imagesc(handles.current_data{1});colormap gray;axis off;axis image;
title(['Worm 1 of ' num2str(maxNum)]);

set(handles.slider1,'Max',maxNum);
set(handles.slider1,'Min',1);
set(handles.slider1,'Value',1);
set(handles.slider1,'SliderStep',[1/maxNum , 10/maxNum]);

% Choose default command line output for wormImageBrowser
handles.output = hObject;

%This array keeps track of all the bad images we do not wish to keep in our
%final, curated image set
handles.badImages = [];

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes wormImageBrowser wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = wormImageBrowser_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

imNum = round(get(hObject,'Value'));
imagesc(handles.current_data{imNum});colormap gray;axis off;axis image;
title(['Worm ' num2str(imNum) ' of ' num2str(numel(handles.current_data))]);

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function changeImage(hObject, eventdata, handles, moveAmt)
imNum = round(get(handles.slider1,'Value')) + moveAmt;

%Two possibilities: a.) The image is out of bounds or b.) The image is on
%the "bad image" list and thus should not be displayed. First check to see
%if the image is within the acceptable range. If not then don't allow the
%image to change

if imNum < 0
    imNum = 1;
elseif imNum > numel(handles.current_data)
    imNum = numel(handles.current_data);
    %Now let's check to make sure that the image we want to look at is not
    %on the list of banned images. If it is, keep moving!
elseif numel(find(handles.badImages == imNum)) > 0
    changeImage(hObject, eventdata, handles, moveAmt + sign(moveAmt));
else
    set(handles.slider1,'Value',imNum);
    imagesc(handles.current_data{imNum});colormap gray;axis off;axis image;
    title(['Worm ' num2str(imNum) ' of ' num2str(numel(handles.current_data))]);
end

% --- Executes on key press with focus on figure1 and none of its controls.
function figure1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
if strcmp(eventdata.Key,'rightarrow') == 1
    changeImage(hObject, eventdata, handles, 1)
end

if strcmp(eventdata.Key,'leftarrow') == 1
    changeImage(hObject, eventdata, handles, -1)
end

if strcmp(eventdata.Key,'uparrow') == 1
    changeImage(hObject, eventdata, handles, 10)
end

if strcmp(eventdata.Key,'downarrow') == 1
    changeImage(hObject, eventdata, handles, -10)
end

if strcmp(eventdata.Key,'1') == 1
    imNum = round(get(handles.slider1,'Value'));
    handles.badImages = [handles.badImages imNum];
    changeImage(hObject, eventdata, handles, -1)
    guidata(hObject,handles); %REMEMBER TO UPDATE THE HANDLES STRUCTURE!!!
end


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% save(handles.current_data);
fname = [get(handles.edit1,'String') '.mat'];
truncated_Images = handles.current_data;
badImages = unique(handles.badImages(find(handles.badImages > 0)));
numel(truncated_Images);
numel(handles.badImages);
truncated_Images(badImages) = [];
numel(truncated_Images);
save(fname,'truncated_Images');


function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
