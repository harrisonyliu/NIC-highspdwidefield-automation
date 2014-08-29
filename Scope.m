classdef Scope < handle
 %Master object to control scope; wraps various MM objects to give simple
 %access to what we need.
 % Based on Roy Wollman's scope object.
    
    properties
        
        %% MM objects
        mmc % the MM core
        studio % MM studio - the main plugin      
        gui % MMC gui object
        
        %% imaging properties
        Exposure
        Channel
        Z
        X
        Y
        XY % so I can set them together in a single call
        ZstageActive=false;
        
        %% image size properties
        Width
        Height
        BitDepth
        
        %% properties needed to save images
        AcqData %an AcquisitionDescriptor
        site=0;
        basePath = 'C:\Roy\Data\';
        expPath = 'TestingScope';
        TimeStamp=[];
        
        %% plotting related variables
        lastImg=zeros(100);
        Lvl=[];
        figs=[];
    end
    
    
    %% Methods
    methods
        
        %% constructors
        function Scp = Scope
            
            % general stuff
            warning('off','Images:initSize:adjustingMag')
            warning('off','Images:imshow:magnificationMustBeFitForDockedFigure')
            % Init MM
            import mmcorej.*;
            import org.micromanager.*;
            import ij.*;
            ij.ImageJ;
            Scp.studio = MMStudioPlugin;
            Scp.studio.run('');
            uiwait(msgbox('Press when Micro-Manager finishes loading'));
            Scp.mmc = Scp.studio.getMMCoreInstance;
            Scp.gui = Scp.studio.getMMStudioMainFrameInstance;
            %grab an image, since first image is often 0
            Scp.mmc.snapImage;
            junk = Scp.mmc.getImage;
        end
        
        function quit(Scp)
            %Scp.mmc.unloadAllDevices;
            Scp.mmc.reset();
            Scp.mmc.delete();
            Scp.mmc=[];
            Scp.studio=[];
            Scp.gui=[];
        end
        
        
        %% behavior methods
        
        function dataStruct = acquire(Scp, acqDescriptor, dataStruct)
            if acqDescriptor.UseROI
                Scp.mmc.setROI(acqDescriptor.ROI(1), acqDescriptor.ROI(2), ...
                    acqDescriptor.ROI(3), acqDescriptor.ROI(4));
            end
            w=Scp.Width;
            h=Scp.Height;
            bd=Scp.BitDepth;
            if (bd>8)
                ImgType='uint16';
            else
                ImgType='uint8';
            end
            
            nChannels = acqDescriptor.NumChannels;
            nTime = acqDescriptor.TimePoints;
            configGroup = acqDescriptor.Group;
            img=zeros(h, w, nChannels, nTime, ImgType); % notice the traspose element in the loop
            for t = 1:nTime
                for c = 1:nChannels
                    Scp.mmc.setConfig(configGroup, acqDescriptor.Channel(c));
                    Scp.Exposure=acqDescriptor.Exposure(c);
                    
                    % setup finished - now acquire!
                    Scp.mmc.snapImage;
                    %Scp.TimeStamp(c)=now;
                    imgtmp=Scp.mmc.getImage;
                    img(:,:,c,t)=reshape(typecast(imgtmp,ImgType),w,h)';
                end
            end
            %probably there should be a factory method to build the right
            %dataStruct for us....
            dataStruct.RawData = img;
        end
        
        function saveLastImg(Scp)
            if ~exist(fullfile(Scp.basePath,Scp.expPath),'dir')
                mkdir(fullfile(Scp.basePath,Scp.expPath));
            end
            for i=1:size(Scp.lastImg,3)
                filename = fullfile(Scp.basePath,Scp.expPath,...
                    sprintf('Img_%03d_%010d_%s.tif',...
                    Scp.site,Scp.frameID,acqDescriptor(i).Channel));
                imwrite(uint16(Scp.lastImg(:,:,i)*2^16),filename,'Description',Scp.getMetaData(i,'asString',true));
            end
        end
                
        function moveByStageAFrame(Scp,direction)
            frmX = Scp.mmc.getPixelSizeUm*Scp.Width;
            frmY = Scp.mmc.getPixelSizeUm*Scp.Height;
            switch direction
                case 'north'
                    dxdy=[0 1];
                case 'south'
                    dxdy=[0 -1];
                case 'west'
                    dxdy=[1 0];
                case 'east'
                    dxdy=[-1 0];
                case 'northeast'
                    dxdy=[-1 1];
                case 'northwest'
                    dxdy=[1 1];
                case 'southeast'
                    dxdy=[-1 -1];
                case 'southwest'
                    dxdy=[1 -1];
                otherwise
                    dxdy=[0 0];
                    warning('Unrecognized direction - not moving'); %#ok<*WNTAG>
            end
            Scp.XY=[Scp.X+dxdy(1)*frmX Scp.Y+dxdy(2)*frmY];
        end
               
        %% get/sets
        
        %% Image properties
        function lvl=get.Lvl(Scp)
            if isempty(Scp.Lvl)
                lvl=repmat({[]},length(Scp.AcqData),1);
            elseif length(Scp.Lvl)==1
                lvl=repmat(Scp.Lvl,size(Scp.lastImg,3));
            else
                lvl=Scp.Lvl;
            end
        end
        function w=get.Width(Scp)
            w=Scp.mmc.getImageWidth;
        end
        function h=get.Height(Scp)
            h=Scp.mmc.getImageHeight;
        end
        function bd=get.BitDepth(Scp)
            bd=Scp.mmc.getImageBitDepth;
        end
                
        function exptime = get.Exposure(Scp)
            exptime = Scp.mmc.getExposure;
        end
        
        function set.Exposure(Scp,exptime)
            % check input - real and numel==1
            if ~isreal(exptime) || numel(exptime)~=1 ||exptime <0
                error('Exposure must be a double positive scalar!');
            end
            Scp.mmc.setExposure(exptime);
        end
        
        %% XY positions
        function Z = get.Z(Scp)
            Z=Scp.mmc.getPosition(Scp.mmc.getFocusDevice);
        end
        
        function set.Z(Scp,Z)
            Scp.mmc.setPosition(Scp.mmc.getFocusDevice,Z)
        end
        
        function X = get.X(Scp)
            X=Scp.mmc.getXPosition(Scp.mmc.getXYStageDevice);
        end
        
        function set.X(Scp,X)
            Scp.mmc.setXYPosition(Scp.mmc.getXYStageDevice,X,Scp.Y)
        end
        
        function Y = get.Y(Scp)
            Y=Scp.mmc.getYPosition(Scp.mmc.getXYStageDevice);
        end
        
        function set.Y(Scp,Y)
            Scp.mmc.setXYPosition(Scp.mmc.getXYStageDevice,Scp.X,Y)
        end
        
        function XY = get.XY(Scp)
            XY(1)=Scp.mmc.getXPosition(Scp.mmc.getXYStageDevice);
            XY(2)=Scp.mmc.getYPosition(Scp.mmc.getXYStageDevice);
        end
        
        function set.XY(Scp,XY)
            Scp.mmc.setXYPosition(Scp.mmc.getXYStageDevice,XY(1),XY(2))
        end
        
        function set.AcqData(Scp,AcqData)
            Scp.AcqData = AcqData;
            if isempty(Scp.figs)
                Scp.figs=1:numel(AcqData);
            end
        end
        
    end
end