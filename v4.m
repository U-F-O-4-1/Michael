clear all;
clear parrotObj;
clear camObj;

parrotObj = parrot('Mambo');        % Create a parrot object.
% nnet = googlenet;                 % Create a GoogLeNet neural network object.         % für nnet
takeoff(parrotObj);                 % Start the drone flight
%land(parrotObj);                   % reset um besser mit cam verbinden zu können
camObj = camera(parrotObj, 'FPV');  % Create a connection to the drone's FPV camera
%takeoff(parrotObj);                % Start the drone flight

tOuter= tic;
i=0;

while(toc(tOuter)<=30 && parrotObj.BatteryLevel>10)
    tInner = tic;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Startbedingungen jeder tik
    
    ausrichten=true;
    
    while ausrichten==true          % ausrichten codeschnipsel
        SP_x=1000;                  % anfangsbedingung X_wert
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %   mache foto & Speichere zur Weiterverarbeitung
        rohpicture = snapshot(camObj);     % Capture image from drone's FPV camera
        figure, imshow(rohpicture);        % Zeige Bild von Drohne (für uns, Kontrolle)
        % dynamische Speicherung der Bilder von FPV Cam
        l1 = sprintf('%06d',i);
        % Dieser Pfad muss immer angepasst werden! Der Code erstellt keine neuen Ordner
        picture = imresize(rohpicture, [360, 640]); % anpassen bild auf verarbeitungsgröße
        imwrite(picture, "C:\Constanze\Master SPS\U.F.O 4.1\resources\project\Fotos\picture_"+l1+"_FPV_drone.png") % speichert bild ab (nummerinerung in Dateiname inkludiert
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Bildverarbeitung (Rot) codeschnipsel
        
        % Dieser Code generiert ein BW Bild auf Basis vom Farbgrenzwerten kalibiriert mit der App Color Thresholder
        % auf eine orange Trinkflasche um einen Test am 08.02.2020 laufen zu lassen. Das Bild wurde mit der Drohne aufgenommen.
        % Dieser Pfad muss immer angepasst werden! Der code erstellt keine neuen Ordner
        pic_FPV_rot = imread("C:\Constanze\Master SPS\U.F.O 4.1\resources\project\Fotos\picture_"+l1+"_FPV_drone.png"); %Lese das bild in Pic_FPV_rot ein;
        imshow(pic_FPV_rot);            %Öffnen und ansehen des Bildes
        % Grenzwerte für ersten (R) Farbchannel einstellen (kommt aus App: Color
        % Thresholder)
        channel1Min = 120.000;
        channel1Max = 133.000;
        
        % Grenzwerte für zweiten (G) Farbchannel einstellen (kommt aus App: Color
        % Thresholder)
        channel2Min = 40.000;
        channel2Max = 57.000;
        
        % Grenzwerte für zweiten (B) Farbchannel einstellen (kommt aus App: Color
        % Thresholder)
        channel3Min = 38.000;
        channel3Max = 58.000;
        
        % Erstellen einer Maske aufgrund der festgelegten Grenzwerte (sind
        % insgesamt 4 Zeilen)
        sliderBW = (pic_FPV_rot(:,:,1) >= channel1Min ) & (pic_FPV_rot(:,:,1) <= channel1Max) & ...
            (pic_FPV_rot(:,:,2) >= channel2Min ) & (pic_FPV_rot(:,:,2) <= channel2Max) & ...
            (pic_FPV_rot(:,:,3) >= channel3Min ) & (pic_FPV_rot(:,:,3) <= channel3Max);
        BW = sliderBW;
        %Bis hierher das Erstellen der Maske
        imshow(pic_FPV_rot);%nur zum Anzeigen des Bildes (im Code entfernen)
        imshow(BW);%%nur zum Anzeigen des Bildes (im Code entfernen)
        Eigenschaften = regionprops(BW, {'Area','Eccentricity', 'MajorAxisLength', 'MinorAxisLength', 'Centroid', 'BoundingBox'});
        % Regionprops ist der zentrale Befehl aus der image Processing toolbox. Das
        % liefert uns in unserem Fall den Centroid = Schwerpunkt mit x und y Wert, Area = Größe des
        % Objekts in Pixel,und weitere mögliche Aspekte des Bildes - für uns sind
        % aber die wichtigtsten Centroid und Area
        Position_bottle = [0 0];
        Position_bottle = [Eigenschaften.Centroid]; %   360x640 massenschwerpunkt, größe übergeben
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %   Bildverarbeitung
        %   erkenne boundaries
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %   Turning- Codeschnipsel
        Grenze_x =100;      %grenze zum start des ausrichtens
        if isempty(Position_bottle) ==0
            SP_x =  int8(Position_bottle(:,1));
            
            
            %  gesamtgröße bild 360x640 massenschwerpunkt, größe übergeben
            if  abs(320-SP_x) > Grenze_x  && abs(320-SP_x)<1000 % solange Schwerpunkt außerhalb bereich ist
                xturn = -1*double(45/320*(320-SP_x));              % berechnen der Winkelabweichung des roten Objektes aus Schwerpunkt
                turn(parrotObj,deg2rad(xturn));         % Drehen der Drohne in Richtung Rot
                
            else
                ausrichten=false;
                return
            end
        else
            ausrichten=false;
        end
    end
    %turn(parrotObj,deg2rad(90));   % Turn the drone by pi/2 radians
    %turn(parrotObj,deg2rad(-90));   % Turn the drone by -pi/2 radians
    %moveforward(parrotObj,1); % Fliege Vorwärts
    
end
land(parrotObj); % Land the drone.
