classdef main_avi_header < handle
    %
    %   Class:
    %   sl.video.avi.main_avi_header
    %
    %   %http://ffmpeg.org/doxygen/0.6/avi_8h.html
    %
    %   ??? What are these????
    %   Has the main header been expanded?
    %   #define     AVIF_TRUSTCKTYPE    0x00000800   
    %   #define 	AVI_MAX_RIFF_SIZE   0x40000000LL
    %   #define 	AVI_MASTER_INDEX_SIZE   256
    %   #define 	AVIIF_INDEX   0x10
    
    properties
       frames_per_second
       max_bytes_per_second
       padding_granularity
       total_frames 
       initial_frames 
       n_streams 
       suggested_buffer_size 
       width 
       height 
       flags %struct - might make non-handle object
%          copyrighted: 0
%            has_index: 1
%       is_interleaved: 0
%       must_use_index: 0
%     was_capture_file: 0
       flag_bits
    end
    
    methods
        function obj = main_avi_header(data)
            %
            %   obj = sl.video.avi.main_header(data)
            
            %http://msdn.microsoft.com/en-us/library/ms779632.aspx    
        
           data = typecast(data,'uint32');
        
           if length(data) ~= 14
              if length(data) > 14
                  %TODO: Throw warning
              else
                 error('AVI main header has less data than expected') 
              end
           end
        
           data_d = double(data); %from u32 to double
        
           obj.frames_per_second    = 1/(data_d(1)*1e-6);
           obj.max_bytes_per_second = data_d(2);
           obj.padding_granularity  = data_d(3);
           
           flag_values = data(4);
           
           flag_bits_local = bitget(flag_values,1:32);
           obj.flags = struct(...
               'copyrighted',       flag_bits_local(18),...
               'has_index',         flag_bits_local(5),...
               'is_interleaved',    flag_bits_local(9),...
               'must_use_index',    flag_bits_local(6),...
               'was_capture_file',  flag_bits_local(17));
           obj.flag_bits = flag_bits_local;
           obj.total_frames = data_d(5);
           obj.initial_frames = data_d(6);
           obj.n_streams = data_d(7);
           obj.suggested_buffer_size = data_d(8);
           obj.width  = data_d(9);
           obj.height = data_d(10);
           %reserved - 4 bytes
           
        end
    end
    
end

