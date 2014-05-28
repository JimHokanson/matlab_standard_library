classdef video_stream_formats < handle
    %
    %   Class:
    %   sl.video.avi.stream_formats
    
    %
    %   http://msdn.microsoft.com/en-us/library/ms779712.aspx
    
    properties
        width
        height
        %For uncompressed RGB bitmaps, if biHeight is positive, the bitmap
        %is a bottom-up DIB with the origin at the lower left corner. If
        %biHeight is negative, the bitmap is a top-down DIB with the origin
        %at the upper left corner.
        %
        %For YUV bitmaps, the bitmap is always top-down, regardless of the
        %sign of biHeight. Decoders should offer YUV formats with postive
        %biHeight, but for backward compatibility they should accept YUV
        %formats with either positive or negative biHeight.
        %
        %For compressed formats, biHeight must be positive, regardless of
        %image orientation.
        planes %Might remove this, must be set to 1
        bit_count
        compression
        size_image_bytes
        x_ppm
        y_ppm
        n_color_indices
        n_colors_important
        c_struct %Structure that is specific to the compression type
    end
    
    methods
        function obj = video_stream_formats(chunk_info,all_data)
            I = find(strcmp(chunk_info.full_names,'AVI.hdrl.strl.strf'));
            if length(I) ~= 1
                if length(I) > 1
                    error('Only a single stream is currently supported')
                else
                    error('Unable to find stream format')
                end
            end
            
            data = typecast(all_data(chunk_info.data_start_I(I):chunk_info.data_end_I(I)),'uint32');
            
            %data_d = double(data);
            
            n_bytes_for_this_object = data(1);
            obj.width  = typecast(data(2),'int32');
            obj.height = typecast(data(3),'int32');
            
            temp = typecast(data(4),'uint16');
            obj.planes      = temp(1);
            obj.bit_count   = temp(2);
            
            obj.compression = char(typecast(data(5),'uint8'));
            obj.size_image_bytes = data(6);
            obj.x_ppm = typecast(data(7),'int32');
            obj.y_ppm = typecast(data(8),'int32');
            obj.n_color_indices    = data(9);
            obj.n_colors_important = data(10);
            
            
            %NOTE: At this point there is some remaining data
            %which needs to be tranlsated, based on the codec
            %
            %remaining_data = n_bytes_for_this_object - 40 (10*4)
            %
            %   TODO: Handle this
            
            switch obj.compression
                case 'mjpg'
                    %TODO Add properties
                case char(zeros(1,4))
                    %Raw ...
                otherwise
                    error('Unhandled data')
                %IV50
                %-http://www.free-codecs.com/download/Indeo_Codec.htm ????
            end
            
        end
    end
    
end

%{

typedef struct tagBITMAPINFOHEADER {
    DWORD  biSize;
    LONG   biWidth;
    LONG   biHeight;
    WORD   biPlanes;
    WORD   biBitCount;
    DWORD  biCompression;
    DWORD  biSizeImage;
    LONG   biXPelsPerMeter;
    LONG   biYPelsPerMeter;
    DWORD  biClrUsed;
    DWORD  biClrImportant;
} BITMAPINFOHEADER;

%For mjpg
%-------------------------------------------------------

typedef struct tagJPEGINFOHEADER {
     /* compress-specific fields */
     DWORD  JPEGSize;
     DWORD  JPEGProcess;
 
     /* Process specific fields */
     DWORD  JPEGColorSpaceID;
     DWORD  JPEGBitsPerSample;
 
     DWORD  JPEGHSubSampling;
     DWORD  JPEGVSubSampling;
} JPEGINFOHEADER




%}