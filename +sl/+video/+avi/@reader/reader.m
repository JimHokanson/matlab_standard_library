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
    
    properties
        file_path
        main_avi_header
        index_data
        stream_headers
        video_stream_formats
    end
    
    methods
        function obj = reader(file_path)
            %
            %    obj = sl.video.avi.reader(file_path)
            %
            obj.file_path = file_path;
            
            data = sl.io.fileRead(file_path,'*uint8');
            
            chunk_info = sl.video.avi.chunk_info(data);
            
            obj.main_avi_header  = sl.video.avi.main_avi_header(helper__getDataSubset(chunk_info,data,'AVI.hdrl.avih'));
            
            %main_avi_header_local = obj.main_avi_header;
            
            %TODO: Check if index exists ...
            
            obj.index_data = sl.video.avi.index(helper__getDataSubset(chunk_info,data,'AVI.idx1'));
            
            %NOTE: If the idx1 does not exist, an indx may ...
            %This is part of AVI 2
            
            
            obj.stream_headers = sl.video.avi.stream_headers(chunk_info,data);
            
            obj.video_stream_formats = sl.video.avi.video_stream_formats(chunk_info,data);
            
            %keyboard
            
            I = find(strcmp(chunk_info.full_names,'AVI.movi'));
            
            movie_start = chunk_info.data_start_I(I);
            movie_end   = chunk_info.data_end_I(I);
            
            idx = obj.index_data;
            
            %Let's examine each movie index
            
            keyboard
            
            %TODO: Provide n_objs property
            n_frames = length(idx.is_uncompressed_video);
            movie_data_all = cell(1,n_frames);
            movie_data_first_600 = zeros(600,n_frames);
            keep_mask = false(1,n_frames);
            
            start_I = idx.byte_offsets + movie_start;
            end_I   = start_I + idx.chunk_lengths - 1;
            
            for iFrame = 1:n_frames
               temp = data(start_I(iFrame):end_I(iFrame));
               if ~isempty(temp)
                  movie_data_all{iFrame} = temp;
                  movie_data_first_600(:,iFrame) = temp(1:600);
                  keep_mask(iFrame) = true;
               end
            end
            
            
            img_data = data(253+8:253+9325+8);
            
            %TODO: Check out stream info to see
            %that this is defined ...
            
            
            
            
            
            %Luminance
            q1   = img_data(43:109);
            q1_m = reshape(q1(4:end),8,8);
            
            %Chrominance
            q2 = img_data(112:178);
            q2_m = reshape(q2(4:end),8,8);
            
            
            h1 = img_data(202:230); %dc luminance - first 17 are bits
            h2 = img_data(235:413); %ac luminance - first 17 are bits
            h3 = img_data(418:446); %dc chrominance?
            h4 = img_data(451:629);
            
            sof_info = img_data(179:197);
            %255  192    0   17      8       1  224       2  128       3        
            %
            %                        a        b            c            d
            %
            %
            %   1   33    0        2   17    1           3   17    1
            %   
            %   Y                 Cb                    Cr
            %    
            %
            %       2H 1 V          1H  1V              1H 1V
            %- bit depth
            %- height
            %- width
            %- # of components - 
            %For each component:
            %- ID
            %   - 1 Y
            %   - 2 Cb
            %   - 3 Cr
            %   - 4 I
            %   - 5 Q
            %-sampling factors
            %   - bits 0 - 3 vertical
            %   - bits 4 - 7 horizontal
            %- quantization table number
            %
            %   What about the Huffman tables??? How to know
            %   which to use?????
            %
            %   1 for each component?
            
            actual_image_data = img_data(447:end);
            
            %Remaining:
            %---------------------------------------------------------------
            % 'hdrl'
            %
            %  1 or more of these ...
            % 'RIFF.AVI.hdrl.strl'
            % 'RIFF.AVI.hdrl.strl.strh'
            % 'RIFF.AVI.hdrl.strl.strf'
            % [ 'strd'(<Additional header data>) ]
            % [ 'strn'(<Stream name>) ]
            %
            % 'movi'
            %    - where the data is kept
            %
            %    Another set of chunks
            %
            %
            %  'idx1'
            
            
        end
    end
    
end

function data_subset = helper__getDataSubset(chunk_info,data,name)
    I = find(strcmp(chunk_info.full_names,name));
    data_subset     = data(chunk_info.data_start_I(I):chunk_info.data_end_I(I));
end
