classdef acquisitionDescriptor
    %This class describes the microscope settings to acquire an image stack
    %through micromanager.
    %   Detailed explanation goes here
    
    properties
        TimePoints; %number of time points to acquire for time lapse
        Group; %group from which acquisition settings come
        ROI; %ROI coordinates [x y h w];
    end
    
    properties (SetAccess = protected)        
        Channel; % 1 x nChannels cell array of channel names to acquire
        Exposure; %1 x nChannels array of exposure times in msec
    end
    
    properties (Dependent = true, SetAccess = protected)
        NumChannels; %number of channels to acquire        
        UseROI; %true to use the ROI; false to use the full camera frame
    end
    
    
    methods
        %constructor
        function aD = acquisitionDescriptor()
            aD.TimePoints = 1; %default
        end

        
        function obj = set.ROI(obj, array)
            if numel(array) ~= 4
                error('Must supply four coordinates (top left corner X & Y, width and height) to set ROI');
            end
            obj.ROI = array;            
        end
        
        function obj = addChannel(obj, newchan, exp)
            nchan = obj.NumChannels;
            if numel(obj.Channel) == 0
                obj.Channel = {newchan};
            else
                obj.Channel{nchan + 1} = newchan;
            end
            obj.Exposure(nchan + 1) =  exp;
        end
        
        %Dependent properties
        function nchan = get.NumChannels(obj)
            nchan = numel(obj.Channel);
        end
        
        function useROI = get.UseROI(obj)
            useROI = ~isempty(obj.ROI);
        end
        
    end
    
    
    
end

