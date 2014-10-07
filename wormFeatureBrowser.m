function varargout = wormFeatureBrowser(varargin)
% WORMFEATUREBROWSER MATLAB code for wormFeatureBrowser.fig
%      WORMFEATUREBROWSER, by itself, creates a new WORMFEATUREBROWSER or raises the existing
%      singleton*.
%
%      H = WORMFEATUREBROWSER returns the handle to a new WORMFEATUREBROWSER or the handle to
%      the existing singleton*.
%
%      WORMFEATUREBROWSER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in WORMFEATUREBROWSER.M with the given input arguments.
%
%      WORMFEATUREBROWSER('Property','Value',...) creates a new WORMFEATUREBROWSER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before wormFeatureBrowser_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to wormFeatureBrowser_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help wormFeatureBrowser

% Last Modified by GUIDE v2.5 06-Oct-2014 20:02:17

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @wormFeatureBrowser_OpeningFcn, ...
                   'gui_OutputFcn',  @wormFeatureBrowser_OutputFcn, ...
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


% --- Executes just before wormFeatureBrowser is made visible.
function wormFeatureBrowser_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to wormFeatureBrowser (see VARARGIN)
handles.lgg1 = varargin{1};
handles.lgg1Feat = varargin{2};
handles.lipl4 = varargin{3};
handles.lipl4Feat = varargin{4};
handles.x = 1;
handles.y = 1;
handles.misclass_lipl4 = [];
handles.misclass_lgg1 = [];
handles.misclass_lipl4_Im = [];
handles.misclass_lgg1_Im = [];

% Choose default command line output for wormFeatureBrowser
handles.output = hObject;
handles.misclass_lipl4 = [];
handles.misclass_lgg1 = [];

featList = cell(1,size(handles.lgg1Feat,2));
for i=1:size(handles.lgg1Feat,2)
    featList{i} = num2str(i);
end

set(handles.popupmenu1,'String',featList)
set(handles.popupmenu2,'String',featList)


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes wormFeatureBrowser wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = wormFeatureBrowser_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
contents = cellstr(get(hObject,'String'));
handles.x = str2num(contents{get(hObject,'Value')});
guidata(hObject, handles);
% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
contents = cellstr(get(hObject,'String'));
handles.y = str2num(contents{get(hObject,'Value')});
guidata(hObject, handles);
% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2


% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(handles.misclass_lipl4) == 1
    disp('No misclassifications or nothing selected!');
else
    num = numel(handles.misclass_lipl4);
    temp = cell(1,num);
    for i = 1:num
        temp{i} = handles.lgg1{handles.misclass_lipl4(i)};
    end
    wormImageBrowser(temp);
    handles.misclass_lipl4_Im = temp;
    guidata(hObject, handles);
end


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(handles.misclass_lgg1) == 1
    disp('No misclassifications or nothing selected!');
else
    num = numel(handles.misclass_lgg1);
    temp = cell(1,num);
    for i = 1:num
        temp{i} = handles.lgg1{handles.misclass_lgg1(i)};
    end
    wormImageBrowser(temp);
    handles.misclass_lgg1_Im = temp;
    guidata(hObject, handles);
end


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
temp_lipl4 = zeros(size(handles.lipl4Feat,1),1);
temp_lgg1 = ones(size(handles.lgg1Feat,1),1);
trainingClass = [temp_lipl4; temp_lgg1];
trainingData = [handles.lipl4Feat(:,[handles.x handles.y]); ...
    handles.lgg1Feat(:,[handles.x handles.y])];
svmModel = svmtrain(trainingData, trainingClass, ...
    'Autoscale',true, 'Showplot',true, 'Method','QP', ...
    'BoxConstraint',2e-1, 'Kernel_Function','rbf', 'RBF_Sigma',1);

% plot(handles.lgg1Feat(:,handles.x),handles.lgg1Feat(:,handles.y),'b.',...
%     handles.lipl4Feat(:,handles.x),handles.lipl4Feat(:,handles.y),'r*');
title(['Feature ' num2str(handles.x) ' versus feature ' num2str(handles.y)]);
xlabel(['Feature ' num2str(handles.x)]);ylabel(['Feature ' num2str(handles.y)]);
legend('lipl4','lgg1');


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp('yay')

% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
plot([1:size(handles.lgg1Feat,1)],handles.lgg1Feat(:,handles.x),'b.',...
    [1:size(handles.lipl4Feat,1)],handles.lipl4Feat(:,handles.x),'r*');
title(['Feature ' num2str(handles.x)]);
xlabel('Observation');ylabel(['Feature ' num2str(handles.y)]);
legend('lgg1','lipl4');


% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
temp_lipl4 = zeros(size(handles.lipl4Feat,1),1);
temp_lgg1 = ones(size(handles.lgg1Feat,1),1);
trainingClass = [temp_lipl4; temp_lgg1];
trainingData = [handles.lipl4Feat; handles.lgg1Feat];
svmModel = svmtrain(trainingData, trainingClass, ...
    'Autoscale',true, 'Showplot',false, 'Method','QP', ...
    'BoxConstraint',2e-1, 'Kernel_Function','rbf', 'RBF_Sigma',1);
class_lipl4 = svmclassify(svmModel,trainingData(1:numel(temp_lipl4),:));
class_lgg1 = svmclassify(svmModel,trainingData(numel(temp_lipl4)+1:end,:));
handles.misclass_lipl4 = find(class_lipl4 == 1);
handles.misclass_lgg1 = find(class_lgg1 == 0);
guidata(hObject, handles);


% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
