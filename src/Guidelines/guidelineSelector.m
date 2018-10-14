function varargout = guidelineSelector(varargin)
% GUIDELINESELECTOR MATLAB code for guidelineSelector.fig
%      GUIDELINESELECTOR, by itself, creates a new GUIDELINESELECTOR or raises the existing
%      singleton*.
%
%      H = GUIDELINESELECTOR returns the handle to a new GUIDELINESELECTOR or the handle to
%      the existing singleton*.
%
%      GUIDELINESELECTOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUIDELINESELECTOR.M with the given input arguments.
%
%      GUIDELINESELECTOR('Property','Value',...) creates a new GUIDELINESELECTOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before guidelineSelector_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to guidelineSelector_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help guidelineSelector

% Last Modified by GUIDE v2.5 02-Oct-2018 16:40:16

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @guidelineSelector_OpeningFcn, ...
                   'gui_OutputFcn',  @guidelineSelector_OutputFcn, ...
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


% --- Executes just before guidelineSelector is made visible.
function guidelineSelector_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to guidelineSelector (see VARARGIN)

% Choose default command line output for guidelineSelector
handles.output = '';

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes guidelineSelector wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = guidelineSelector_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Set the output values, depending on which button was pressed
if strcmp(handles.output, 'OK')
   g0001 = get(handles.checkbox0001, 'Value');
   g0002 = get(handles.checkbox0002, 'Value');
   g0003 = get(handles.checkbox0003, 'Value');
   g0004 = get(handles.checkbox0004, 'Value');

   varargout{1} = [g0001, g0002, g0003, g0004];
else
   varargout{1} = [0 0 0 0];
end

% The figure can be deleted now
delete(handles.figure1);


% --- Executes on button press in buttonOK.
function buttonOK_Callback(hObject, eventdata, handles)
% hObject    handle to buttonOK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Update which button was pressed
handles.output = get(hObject, 'String');

% Update handles structure
guidata(hObject, handles);

% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
uiresume(handles.figure1);


% --- Executes on button press in checkbox0001.
function checkbox0001_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox0001 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox0001


% --- Executes on button press in checkbox0002.
function checkbox0002_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox0002 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox0002


% --- Executes on button press in checkbox0003.
function checkbox0003_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox0003 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox0003


% --- Executes on button press in checkbox0004.
function checkbox0004_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox0004 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox0004


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isequal(get(hObject, 'waitstatus'), 'waiting')
    % The GUI is still in UIWAIT, use UIRESUME
    uiresume(hObject);
else
    % The GUI is no longer waiting, just close it
    delete(hObject);
end
