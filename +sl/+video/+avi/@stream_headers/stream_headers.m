classdef stream_headers < handle
    %
    %   Class:
    %   sl.video.avi.stream_headers
    %   
    %   http://msdn.microsoft.com/en-us/library/ms779638.aspx
    %
    %   Improvements:
    %   ----------------------------------------
    %   1) Support multiple stream headers
    %   2) Build in support for additional header data and name
    %       - strd
    %       - strn
    %
    %
    %   Status:
    %   Very poorly implemented, just enough to get by
    
    properties
       fcc_type 
    end
    
    
    properties (Dependent)
       is_audio_stream
       is_midi_stream %???? - what would the format contain?
       is_text_stream %???? - what would the format contain?
       is_video_stream 
    end
    
    
    methods
        function value = get.is_audio_stream(obj)
           value = obj.fcc_type == typecast(uint8('auds'),'uint32');
        end
        function value = get.is_midi_stream(obj)
           value = obj.fcc_type == typecast(uint8('mids'),'uint32'); 
        end
        function value = get.is_text_stream(obj)
           value = obj.fcc_type == typecast(uint8('txts'),'uint32');
        end
        function value = get.is_video_stream(obj)
           value = obj.fcc_type == typecast(uint8('vids'),'uint32'); 
        end
    end
    
    %NOTE: Eventually these would be arrays
    %As of now I only support a single stream
    properties  
       handler_or_codec
       priority
       language
       initial_frames
       time_scale
       rate
       samples_per_second
       start_time
       duration
       suggested_buffer_size
       quality %# between 1 and 10000. Is this signed???
       %   - if -1, drivers use the default quality value
       sample_size
       %   - 0, if samples can vary in size
       %   - if non-zero, multiple samples of data can be grouped into
       %   a single chunk within the file ...
       rc_frame
    end
    
    methods
        function obj = stream_headers(chunk_info,all_data)
           
           I = find(strcmp(chunk_info.full_names,'AVI.hdrl.strl.strh'));
           if length(I) ~= 1
               if length(I) > 1
                   error('Only a single stream is currently supported')
               else
                   error('Unable to find stream header')
               end
           end
           
           data = typecast(all_data(chunk_info.data_start_I(I):chunk_info.data_end_I(I)),'uint32');
           
           data_d = double(data);
           
           obj.fcc_type         = data(1);
           obj.handler_or_codec = char(typecast(data(2),'uint8'));
%            temp_flags = data(3);
           %
           
           temp = typecast(data(4),'uint16');
           obj.priority = temp(1);
           obj.language = temp(2);
           
           obj.initial_frames = data_d(5);
           obj.time_scale = data_d(6);
           obj.rate  = data_d(7);
           
           obj.samples_per_second = obj.rate/obj.time_scale;
           
           obj.start_time = data_d(8);
           obj.duration = data_d(9);
           obj.suggested_buffer_size = data_d(10);
           obj.quality = data_d(11);
           obj.sample_size = data_d(12);
           
           temp = data(13:14);
           if any(temp ~= 0)
               error('rcFrame not yet implemented')
           end
           %strh
           %
        end
    end
    
end

%{

typedef struct _avistreamheader {
     FOURCC fcc;
     DWORD  cb;
     FOURCC fccType;
     FOURCC fccHandler;
     DWORD  dwFlags;
     WORD   wPriority; 2 bytes
     WORD   wLanguage;
     DWORD  dwInitialFrames;
     DWORD  dwScale;
     DWORD  dwRate;
     DWORD  dwStart;
     DWORD  dwLength;
     DWORD  dwSuggestedBufferSize;
     DWORD  dwQuality;
     DWORD  dwSampleSize;
     struct {
         short int left;
         short int top;
         short int right;
         short int bottom;
     }  rcFrame;
} AVISTREAMHEADER;

      LIST ('hdrl'
            'avih'(<Main AVI Header>)
            LIST ('strl'
                  'strh'(<Stream header>)
                  'strf'(<Stream format>)
                  [ 'strd'(<Additional header data>) ]
                  [ 'strn'(<Stream name>) ]
                  ...
                 )



One or more 'strl' lists follow the main header. A 'strl' list is required
for each data stream. Each 'strl' list contains information about one
stream in the file, and must contain a stream header chunk ('strh') and a
stream format chunk ('strf'). In addition, a 'strl' list might contain a
stream-header data chunk ('strd') and a stream name chunk ('strn').

The stream header chunk ('strh') consists of an AVISTREAMHEADER structure.

A stream format chunk ('strf') must follow the stream header chunk. The
stream format chunk describes the format of the data in the stream. The
data contained in this chunk depends on the stream type. For video streams,
the information is a BITMAPINFO structure, including palette information if
appropriate. For audio streams, the information is a WAVEFORMATEX
structure.

If the stream-header data ('strd') chunk is present, it follows the stream
format chunk. The format and content of this chunk are defined by the codec
driver. Typically, drivers use this information for configuration.
Applications that read and write AVI files do not need to interpret this
information; they simple transfer it to and from the driver as a memory
block.

The optional 'strn' chunk contains a null-terminated text string describing
the stream.

The stream headers in the 'hdrl' list are associated with the stream data
in the 'movi' list according to the order of the 'strl' chunks. The first
'strl' chunk applies to stream 0, the second applies to stream 1, and so
forth.



%}
