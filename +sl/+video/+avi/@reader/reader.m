classdef reader < handle
    %
    %   Class:
    %   sl.video.avi.reader
    %
    %   AVI is a generic wrapper for audio and video. This class provides
    %   access to the container. Currently only a subset of the format is
    %   supported, although it should be pretty easy to extend.
    %
    %   Decoding the audio and video is another task. Currently only the
    %   mjpg video codec is supported.
    %
    %   ?? Can this be tied directly into ffmpeg ??
    %   ?? Use mmread instead ??
    %
    %
    %   Documenation Sources
    %   -------------------------------------------------------------------
    %   http://msdn.microsoft.com/en-us/library/ms779631.aspx
    %   http://msdn.microsoft.com/en-us/library/ms779636.aspx
    %
    %   Most AVI files also use the file format extensions developed by the
    %   Matrox OpenDML group in February 1996. These files are supported by
    %   Microsoft, and are unofficially called "AVI 2.0".
    %
    %   http://www.the-labs.com/Video/odmlff2-avidef.pdf
    
    %{
    
    base_path = '/Users/jameshokanson/Desktop/worm_data/segworm_data/video/'
    video_name = 'mec-4 (u253) off food x_2010_04_21__17_19_20__1.avi'
    video_path = fullfile(base_path,video_name);
    
    obj = sl.video.avi.reader(video_path);
    
    %}
    
    properties
        file_path
        d0 = '-----  Objects  -----'
        chunk_info
        main_avi_header
        index_data
        stream_headers
        video_stream_formats
        codec
        d1 = '-----  Dependent Props  ----'
    end
    
    properties (Dependent)
        fps
        n_frames
        duration
        height
        width
        codec_type
    end
    
    properties (Hidden)
       frame_data_start_I
       frame_data_end_I
       next_frame = 1
       data
    end
    
    methods
        function value = get.fps(obj)
           value = obj.main_avi_header.frames_per_second;
        end
        function value = get.n_frames(obj)
           value = obj.main_avi_header.total_frames; 
        end
        function value = get.duration(obj)
           value = obj.n_frames/obj.fps; 
        end
        function value = get.height(obj)
           value = obj.main_avi_header.height; 
        end
        function value = get.width(obj)
           value = obj.main_avi_header.width;
        end
        function value = get.codec_type(obj)
           value = obj.stream_headers.handler_or_codec;
        end
    end
    
    methods
        function obj = reader(file_path,varargin)
            %
            %    obj = sl.video.avi.reader(file_path)
            
            in.ignore_length_error = false;
            in = sl.in.processVarargin(in,varargin);
            
            obj.file_path = file_path;
            
            %NOTE: For large files this might eventually need to change.
            %We are reading in the data all at once.
            data_local = sl.io.fileRead(file_path,'*uint8');
            obj.data = data_local;
            
            %Get information about the video
            %-------------------------------
            chunk_info_local = sl.video.avi.chunk_info(data_local,in);
            
            obj.chunk_info = chunk_info_local;
            
            obj.main_avi_header  = sl.video.avi.main_avi_header(helper__getDataSubset(chunk_info_local,data_local,'AVI.hdrl.avih'));
            
            %main_avi_header_local = obj.main_avi_header;
            
            %TODO: Check if index exists ...
            
            obj.index_data = sl.video.avi.index(helper__getDataSubset(chunk_info_local,data_local,'AVI.idx1'));
            
            %NOTE: If the idx1 does not exist, an indx may ...
            %This is part of AVI 2
            
            
            obj.stream_headers = sl.video.avi.stream_headers(chunk_info_local,data_local);
            
            obj.video_stream_formats = sl.video.avi.video_stream_formats(chunk_info_local,data_local);
            
            
            %???? - what's the difference between this and:
            %obj.stream_headers.handler_or_codec
            compression = obj.video_stream_formats.compression;
            
            %NOTE: This could be a warning, if we just wanted to examine
            %the avi itself. Move the warning to the decoding stage?
            switch compression
                case 'mjpg'
                    obj.codec = sl.video.codec.mjpg;
                case char(zeros(1,4))
                    obj.codec = sl.video.codec.raw(obj.height,obj.width);
                otherwise
                    error('Compression type: "%s" not yet supported')
            end

            
            
            %Explicit determination of data starts and ends
            %-----------------------------------------------------
            %NOTE: This could eventually change
            
            idx = obj.index_data;
            
            I_movi = sl.str.findSingularMatch('AVI.movi',chunk_info_local.full_names);
            
            start_of_video_data = chunk_info_local.data_start_I(I_movi);
            
            obj.frame_data_start_I = start_of_video_data + idx.byte_offsets;
            obj.frame_data_end_I   = obj.frame_data_start_I + idx.chunk_lengths - 1;
            
        end
        function [data_out,frame_number] = getNextFrame(obj)
            %
            %
            %   What should I do for null frames???
            
            error('This doesn''t look implemented') 
            %:/
            
            next_frame_local = obj.next_frame;
            if next_frame_local > obj.n_frames
                data_out = [];
                frame_number = -1;
                return
            end
            
            obj.getFrame(next_frame_local);

            obj.next_frame = next_frame_local + 1;
            
        end
        function data_out = getFrame(obj,frame_number)
                       
            frame_data = obj.getRawFrameData(frame_number);
            
            if isempty(frame_data)
               data_out = [];
               return
            end
            
            data_out = obj.codec.decodeFrame(frame_data);
        end
        function raw_frame_data = getRawFrameData(obj,frame_number)
            start_I = obj.frame_data_start_I(frame_number);
            end_I   = obj.frame_data_end_I(frame_number);
            raw_frame_data = obj.data(start_I:end_I);  
        end
        function close(obj)
           %Do nothing for now
           %If we start to partially read a video from file
           %into memory and keep the file open then we will
           %want to close the file ...
        end
        %NOTE: Might want delete function as well ...
    end
    
end

function data_subset = helper__getDataSubset(chunk_info,data,name)
    I = find(strcmp(chunk_info.full_names,name));
    data_subset     = data(chunk_info.data_start_I(I):chunk_info.data_end_I(I));
end
