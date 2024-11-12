function varargout = AKHIRNYA(varargin)
% AKHIRNYA MATLAB code for AKHIRNYA.fig
%      AKHIRNYA, by itself, creates a new AKHIRNYA or raises the existing
%      singleton*.
%
%      H = AKHIRNYA returns the handle to a new AKHIRNYA or the handle to
%      the existing singleton*.
%
%      AKHIRNYA('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in AKHIRNYA.M with the given input arguments.
%
%      AKHIRNYA('Property','Value',...) creates a new AKHIRNYA or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before AKHIRNYA_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to AKHIRNYA_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help AKHIRNYA

% Last Modified by GUIDE v2.5 10-Nov-2024 22:55:52

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @AKHIRNYA_OpeningFcn, ...
                   'gui_OutputFcn',  @AKHIRNYA_OutputFcn, ...
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


% --- Executes just before AKHIRNYA is made visible.
function AKHIRNYA_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to AKHIRNYA (see VARARGIN)

% Choose default command line output for AKHIRNYA
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);


% UIWAIT makes AKHIRNYA wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = AKHIRNYA_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% --- Executes on button press in Buka_Citra.
function Buka_Citra_Callback(hObject, eventdata, handles)
% hObject    - Handle to Buka_Citra (see GCBO)
% eventdata  - Reserved, to be defined in a future version of MATLAB
% handles    - Structure with handles and user data (see GUIDATA)

% Membuka dialog untuk memilih file gambar
[name_file1, name_path1] = uigetfile( ...
    {'*.png;*.jpg;*.tif','Files of type (*.bmp,*.jpg,*.tif)'; ...
     '*.png','File png (*.png)'; ...
     '*.jpg','File jpg (*.jpg)'; ...
     '*.tif','File tif (*.tif)'; ...
     '*.*','All Files (*.*)'}, ...
    'Open Image');

% Periksa apakah pengguna telah memilih file (bukan membatalkan)
if ~isequal(name_file1, 0)
    % Bersihkan gambar lama di axes dan data terkait di handles
    cla(handles.axes1, 'reset');       % Hapus gambar lama dari axes
    set(handles.uitable1, 'Data', {}); % Kosongkan data pada uitable
    set(handles.Wajah, 'Value', 0);    % Reset tombol Wajah
    set(handles.Mata, 'Value', 0);     % Reset tombol Mata
    set(handles.Hidung, 'Value', 0);   % Reset tombol Hidung
    set(handles.Mulut, 'Value', 0);    % Reset tombol Mulut

    % Jika ada data gambar lama, hapus dari handles
    if isfield(handles, 'data1')
        handles = rmfield(handles, 'data1'); % Hapus data gambar lama
    end

    % Membaca dan menyimpan gambar baru ke handles
    handles.data1 = imread(fullfile(name_path1, name_file1));
    guidata(hObject, handles); % Simpan perubahan pada handles

    % Menampilkan gambar baru di axes
    axes(handles.axes1);
    imshow(handles.data1);

    % Menampilkan nama file gambar di Edit Text
    set(handles.edit1, 'String', name_file1); % Update Edit Text dengan nama file
else
    % Jika pengguna membatalkan pemilihan file, keluar dari fungsi
    return;
end


% --- Executes on button press in Deteksi.
function Deteksi_Callback(hObject, eventdata, handles)
% hObject    handle to Deteksi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Callback untuk tombol "Deteksi" fitur wajah, mata, hidung, atau mulut

% Periksa apakah gambar telah dimuat
if isfield(handles, 'data1')
    % Tentukan detektor dan anotasi berdasarkan pilihan
    if get(handles.Wajah, 'Value') == 1
        detectorType = 'Face';
        detector = vision.CascadeObjectDetector(); % Detektor untuk wajah
    elseif get(handles.Mata, 'Value') == 1
        detectorType = 'Eyes';
        detector = vision.CascadeObjectDetector('EyePairBig');
        detector.MergeThreshold = 40; % Ambang batas untuk mengurangi noise
    elseif get(handles.Hidung, 'Value') == 1
        detectorType = 'Nose';
        detector = vision.CascadeObjectDetector('Nose');
        detector.MergeThreshold = 80;
    elseif get(handles.Mulut, 'Value') == 1
        detectorType = 'Mouth';
        detector = vision.CascadeObjectDetector('Mouth');
        detector.MergeThreshold = 150;
    else
        % Tampilkan pesan jika tidak ada opsi yang dipilih
        msgbox('Pilih opsi terlebih dahulu.', 'Error', 'error');
        return;
    end

    % Skala gambar sesuai ukuran layar untuk mencegah tampilan terlalu besar
    screenSize = get(0, 'ScreenSize');
    scaleFactor = min(screenSize(3)/size(handles.data1, 2), ...
                      screenSize(4)/size(handles.data1, 1));
    if scaleFactor < 1
        I = imresize(handles.data1, scaleFactor);
    else
        I = handles.data1;
    end

    % Deteksi objek sesuai pilihan
    bboxes = step(detector, I);

    % Tandai objek yang terdeteksi dengan anotasi
    annotatedImage = insertObjectAnnotation(I, 'rectangle', bboxes, detectorType);

    % Kosongkan axes sebelum menampilkan hasil deteksi baru
    cla(handles.axes1, 'reset');
    axes(handles.axes1);
    imshow(annotatedImage);
    title(['Detected ' detectorType]);

else
    % Pesan kesalahan jika gambar belum dipilih
    msgbox('Buka gambar terlebih dahulu.', 'Error', 'error');
end


% --- Executes on button press in Reset.
function Reset_Callback(hObject, eventdata, handles)
% hObject    handle to Reset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Callback untuk tombol "Reset" untuk menghapus gambar dan data terkait dari GUI

% Hapus gambar dari axes dan bersihkan komponen lainnya
cla(handles.axes1, 'reset');            % Hapus gambar dari axes1
set(handles.edit1, 'String', '');       % Kosongkan teks di edit1
set(handles.uitable1, 'Data', {});      % Kosongkan data pada uitable1

% Setel semua tombol pilihan (Wajah, Mata, Hidung, Mulut) ke nonaktif (0)
set(handles.Wajah, 'Value', 0);
set(handles.Mata, 'Value', 0);
set(handles.Hidung, 'Value', 0);
set(handles.Mulut, 'Value', 0);

% Hapus title pada axes
title(handles.axes1, '');               % Kosongkan title pada axes1

% Bersihkan variabel data gambar di handles jika ada
if isfield(handles, 'data1')
    handles = rmfield(handles, 'data1'); % Hapus data gambar lama dari handles
end

% Perbarui handles untuk menyimpan perubahan
guidata(hObject, handles);

% --- Executes on button press in Ekstraksi_Ciri.
function Ekstraksi_Ciri_Callback(hObject, eventdata, handles)
% hObject    handle to Ekstraksi_Ciri (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    % Cek apakah gambar sudah dimuat
    if ~isfield(handles, 'data1')
        msgbox('Harap buka gambar terlebih dahulu.', 'Error', 'error');
        return;
    end
    
    I = handles.data1;
%    msgbox('Ekstraksi data dimulai');
    % Inisialisasi detektor untuk berbagai bagian wajah
    faceDetector = vision.CascadeObjectDetector();
    eyeDetector = vision.CascadeObjectDetector('EyePairBig'); % Deteksi pasangan mata
    noseDetector = vision.CascadeObjectDetector('Nose');
    mouthDetector = vision.CascadeObjectDetector('Mouth');
    
    eyeDetector.MergeThreshold = 70;
    noseDetector.MergeThreshold = 80;
    mouthDetector.MergeThreshold = 150;

    % Deteksi posisi wajah
    faceBbox = step(faceDetector, I);
    eyeBbox = step(eyeDetector, I);
    noseBbox = step(noseDetector, I);
    mouthBbox = step(mouthDetector, I);

    % Tampilkan gambar dengan bounding box menggunakan insertObjectAnnotation
    if ~isempty(faceBbox) || ~isempty(eyeBbox) || ~isempty(noseBbox) || ~isempty(mouthBbox)
%        msgbox('Ekstraksi data 2 dimulai');
        axes(handles.axes1);
         I_annotated = I; % Salin gambar asli
%         
%         % Anotasi untuk wajah, mata, hidung, dan mulut
% 
%         imshow(I_annotated); hold on;
        imshow(I); hold on;
        
        
        % Pastikan deteksi berhasil sebelum menghitung jarak
        if ~isempty(eyeBbox) && ~isempty(noseBbox) && ~isempty(mouthBbox)
%            msgbox('Ekstraksi data 3 dimulai');
            % Mengambil titik tengah dari pasangan mata
            mataTengah = [eyeBbox(1) + eyeBbox(3)/2, eyeBbox(2) + eyeBbox(4)/2]; 
            
            % Koordinat hidung dan mulut
            hidung = [noseBbox(1) + noseBbox(3)/2, noseBbox(2) + noseBbox(4)/2];
            mulut = [mouthBbox(1) + mouthBbox(3)/2, mouthBbox(2) + mouthBbox(4)/2];
            
            % Pastikan nilai koordinat tidak di luar gambar
            mataTengah(1) = max(min(mataTengah(1), size(I, 2)), 1);
            mataTengah(2) = max(min(mataTengah(2), size(I, 1)), 1);
            hidung(1) = max(min(hidung(1), size(I, 2)), 1);
            hidung(2) = max(min(hidung(2), size(I, 1)), 1);
            mulut(1) = max(min(mulut(1), size(I, 2)), 1);
            mulut(2) = max(min(mulut(2), size(I, 1)), 1);

            % Hitung jarak antar landmark
            jarakMataHidung = sqrt(sum((mataTengah - hidung).^2));
            jarakMataMulut = sqrt(sum((mataTengah - mulut).^2));
            jarakHidungMulut = sqrt(sum((hidung - mulut).^2));

            % Menyiapkan data untuk `uitable1`
            data = {
                'mata-hidung', jarakMataHidung;
                'mata-mulut', jarakMataMulut;
                'hidung-mulut', jarakHidungMulut;
            };

            % Tampilkan data di `uitable1`
            set(handles.uitable1, 'Data', data);
            
            % Plot titik landmark dan koneksi di gambar
            plot(mataTengah(1), mataTengah(2), 'yo', 'MarkerFaceColor', 'y', 'MarkerSize', 10);
            plot(hidung(1), hidung(2), 'go', 'MarkerFaceColor', 'g', 'MarkerSize', 10);
            plot(mulut(1), mulut(2), 'bo', 'MarkerFaceColor', 'b', 'MarkerSize', 10);
            
            % Plot koneksi antar landmark
            plot([mataTengah(1), hidung(1)], [mataTengah(2), hidung(2)], 'g-', 'LineWidth', 2);
            plot([mataTengah(1), mulut(1)], [mataTengah(2), mulut(2)], 'b-', 'LineWidth', 2);
            plot([hidung(1), mulut(1)], [hidung(2), mulut(2)], 'c-', 'LineWidth', 2);
        
            set(handles.Wajah, 'Value', 0); % Nonaktifkan tombol Wajah
            set(handles.Mata, 'Value', 0); % Nonaktifkan tombol Mata
            set(handles.Hidung, 'Value', 0); % Nonaktifkan tombol Hidung
            set(handles.Mulut, 'Value', 0); % Nonaktifkan tombol Mulut
        else
            msgbox('gagal ekstraksi ciri wajah');
            hold off;
        end
    else
        msgbox('Gagal mendeteksi bagian wajah.', 'Error', 'error');
    end



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


% --- Executes on button press in Wajah.
function Wajah_Callback(hObject, eventdata, handles)
% hObject    handle to Wajah (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Wajah


% --- Executes on button press in Mata_Kanan.
function Mata_Kanan_Callback(hObject, eventdata, handles)
% hObject    handle to Mata_Kanan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Mata_Kanan


% --- Executes on button press in Mata_Kiri.
function Mata_Kiri_Callback(hObject, eventdata, handles)
% hObject    handle to Mata_Kiri (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Mata_Kiri


% --- Executes on button press in Hidung.
function Hidung_Callback(hObject, eventdata, handles)
% hObject    handle to Hidung (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Hidung


% --- Executes on button press in Mulut.
function Mulut_Callback(hObject, eventdata, handles)
% hObject    handle to Mulut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Mulut


% --- Executes on button press in Open_Cam.
function Open_Cam_Callback(hObject, eventdata, handles)
% Callback untuk membuka kamera dan menampilkan video preview di axes1
% Memberikan instruksi "Press Enter button to take a snapshot" di layar

    try
        % Inisialisasi kamera
        handles.vid = videoinput('winvideo', 1); % Inisiasi kamera dengan adaptor 'winvideo' dan ID kamera 1
        
        % Dapatkan resolusi video dari kamera
        vidRes = get(handles.vid, 'VideoResolution');
        imWidth = vidRes(1); % Lebar gambar
        imHeight = vidRes(2); % Tinggi gambar
        
        % Bersihkan data sebelumnya di tabel dan reset tombol fitur deteksi
        set(handles.uitable1, 'Data', {}); % Kosongkan tabel data
        set(handles.Wajah, 'Value', 0); % Nonaktifkan tombol deteksi Wajah
        set(handles.Mata, 'Value', 0); % Nonaktifkan tombol deteksi Mata
        set(handles.Hidung, 'Value', 0); % Nonaktifkan tombol deteksi Hidung
        set(handles.Mulut, 'Value', 0); % Nonaktifkan tombol deteksi Mulut
        if isfield(handles, 'data1')
            handles = rmfield(handles, 'data1'); % Hapus data gambar lama jika ada
        end
        
        % Arahkan video ke axes1
        cla(handles.axes1); % Bersihkan axes1
        axes(handles.axes1); % Fokuskan pada axes1
        hImage = image(zeros(imHeight, imWidth, 3), 'Parent', handles.axes1); % Siapkan tampilan video
        
        % Menampilkan video di axes1
        preview(handles.vid, hImage); % Menampilkan video kamera di axes1        
        axis(handles.axes1, 'image'); % Menyesuaikan skala axes dengan ukuran gambar
        % Tambahkan teks instruksi untuk pengguna di tengah atas video
        text(imWidth/2, imHeight/16, 'Press Enter button to take a snapshot', ...
            'Color', 'k', 'FontSize', 12, 'BackgroundColor', 'w', 'HorizontalAlignment', 'center');
        
        % Simpan objek kamera ke dalam handles agar bisa diakses oleh callback lain
        guidata(hObject, handles); 
    catch
        % Tampilkan pesan error jika kamera tidak tersedia atau tidak bisa dibuka
        errordlg('Kamera tidak ditemukan atau tidak bisa dibuka.');
    end



% --- Executes on key press with focus on figure1 or any of its controls.
function figure1_WindowKeyPressFcn(hObject, eventdata, handles)
% Callback yang memproses event penekanan tombol pada figure1 atau kontrolnya.
% Jika tombol "Enter" ditekan, fungsi ini mengambil gambar snapshot dari kamera aktif,
% menampilkannya di axes1, dan menyimpannya di handles.data1.

   if strcmp(eventdata.Key, 'return')  % Periksa apakah tombol "Enter" ditekan
        try
            % Pastikan kamera telah aktif dan valid
            if isfield(handles, 'vid') && isvalid(handles.vid)
                % Ambil snapshot dari video feed kamera
                set(handles.vid,'ReturnedColorSpace','RGB')
                img = getsnapshot(handles.vid);
                
                % Hentikan preview dan hapus objek video kamera
                stoppreview(handles.vid);
                delete(handles.vid);
                handles = rmfield(handles, 'vid'); % Hapus handle kamera dari struktur handles
                
                % Bersihkan axes1 dan tampilkan snapshot
                cla(handles.axes1); % Bersihkan konten axes1
                axes(handles.axes1); % Arahkan ke axes1 untuk memastikan tampil di area yang tepat
                imshow(img, 'Parent', handles.axes1); % Tampilkan gambar di axes1
                
                % Simpan gambar di handles.data1 untuk akses lebih lanjut
                handles.data1 = img;  
                guidata(hObject, handles); % Perbarui struktur handles untuk menyimpan perubahan
                
            else
                % Tampilkan pesan error jika kamera tidak aktif
                errordlg('Kamera tidak aktif. Mohon nyalakan kamera terlebih dahulu.');
            end
        catch
            % Tampilkan pesan error jika terjadi masalah dalam pengambilan gambar
            errordlg('Terjadi kesalahan saat mengambil gambar.');
        end
   end


% --- Executes when figure1 is resized.
function figure1_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over text7.
function text7_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to text7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
