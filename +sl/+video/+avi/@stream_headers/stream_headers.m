classdef stream_headers < handle
    %
    %   Class:
    %   sl.video.avi.stream_headers
    %
    %   http://msdn.microsoft.com/en-us/library/ms779638.aspx
    %
    %   Yikes, see also:
    %   http://msdn.microsoft.com/en-us/library/windows/desktop/dd756832(v=vs.85).aspx
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
        fcc_type %Value must be strh
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
        priority  %Specifies priority of a stream type. For example, in a
        %file with multiple audio streams, the one with the highest priority
        %might be the default stream.
        language
        initial_frames %Specifies how far audio data is skewed ahead of the
        %video frames in interleaved files. Typically, this is about 0.75
        %seconds. If you are creating interleaved files, specify the number
        %of frames in the file prior to the initial frame of the AVI
        %sequence in this member. For more information, see the remarks for
        %the dwInitialFrames member of the AVIMAINHEADER structure.
        time_scale %aka dwScale
        %Used with dwRate to specify the time scale that this stream will
        %use. Dividing dwRate by dwScale gives the number of samples per
        %second. For video streams, this is the frame rate. For audio
        %streams, this rate corresponds to the time needed to play
        %nBlockAlign bytes of audio, which for PCM audio is the just the
        %sample rate.
        rate %aka dwRate - Frame rate of the video per 'time_scale'
        samples_per_second %Computed from 'rate' and 'time_scale'
        start_time
        duration %aka dwLength 
        %I think this is actually # of frames :/
        %
        suggested_buffer_size %aka dwSuggestedBufferSize
        %Specifies how large a buffer should be used to read this stream.
        %Typically, this contains a value corresponding to the largest chunk
        %present in the stream. Using the correct buffer size makes playback
        %more efficient. Use zero if you do not know the correct buffer
        %size.
        quality %aka dwQuality
        %Specifies an indicator of the quality of the data in the stream.
        %Quality is represented as a number between 0 and 10,000. For
        %compressed data, this typically represents the value of the quality
        %parameter passed to the compression software. If set to –1, drivers
        %use the default quality value.
        sample_size %aka dwSampleSize
        %Specifies the size of a single sample of data. This is set to zero
        %if the samples can vary in size. If this number is nonzero, then
        %multiple samples of data can be grouped into a single chunk within
        %the file. If it is zero, each sample of data (such as a video
        %frame) must be in a separate chunk. For video streams, this number
        %is typically zero, although it can be nonzero if all video frames
        %are the same size. For audio streams, this number should be the
        %same as the nBlockAlign member of the WAVEFORMATEX structure
        %describing the audio.
        %
        %    JAH NOTE: This is really important for reading the video
        %
        rc_frame %struct
        %	.left
        %	.top
        %	.right
        %	.bottom
        %Specifies the destination rectangle for a text or video stream
        %within the movie rectangle specified by the dwWidth and dwHeight
        %members of the AVI main header structure. The rcFrame member is
        %typically used in support of multiple video streams. Set this
        %rectangle to the coordinates corresponding to the movie rectangle
        %to update the whole movie rectangle. Units for this member are
        %pixels. The upper-left corner of the destination rectangle is
        %relative to the upper-left corner of the movie rectangle.
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
            
            data_as_double = double(data);
            
            obj.fcc_type         = data(1);
            obj.handler_or_codec = char(typecast(data(2),'uint8'));
            
            temp         = typecast(data(4),'uint16');
            obj.priority = temp(1);
            obj.language = temp(2);
            
            obj.initial_frames = data_as_double(5);
            obj.time_scale     = data_as_double(6);
            obj.rate           = data_as_double(7);
            
            obj.samples_per_second    = obj.rate/obj.time_scale;
            
            obj.start_time            = data_as_double(8);
            obj.duration              = data_as_double(9);
            obj.suggested_buffer_size = data_as_double(10);
            obj.quality               = data_as_double(11);
            obj.sample_size           = data_as_double(12);
            
            frame_data = typecast(data(13:14),'int16');
            obj.rc_frame = struct(...
                'left',  frame_data(1),...
                'top',   frame_data(2),...
                'right', frame_data(3),...
                'bottom',frame_data(4));
        end
    end
    
end

%{
%================================
%This is what I am coding against
%================================


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
