classdef (Hidden) index < handle
    %
    %   Class:
    %   sl.video.avi.index
    %
    %   Status:
    %   Completed but some of the code should probably be moved elsewhere.
    %   Also, there is a possibility that some flag bits are not being
    %   parsed.
    
    %   relevant header:
    %   http://doxygen.reactos.org/d2/d52/aviriff_8h_source.html
    
    properties
       is_uncompressed_video
       is_compressed_video
       is_palatte_change
       is_audio_data      %[1 x n]
        
       stream_number
       byte_offsets %As implemented, this points to the first byte
       %of relevant data in the chunk. The size is skipped (but is given
       %by chunk_lengths)
       %
       %  ??? How do people distinguish the two?
       %
       %    A low byte offset for the first index would normally
       %    be expected, typically 4 (which I correct to 0) or
       %    maybe 8, 12 ???? vs relative to start of file which might
       %    be something like 252
       chunk_lengths %Length of relevant data. This does not include size
       %or the chunk type (like '00dc')
       %
       %End of data = byte_offsets(#)+chunk_lengths(#)-1
       
       %Flags ...
       is_key_frame %Not sure how this is actually used ...
       is_rec_list
       does_not_affect_timing
       
    end
    
    methods
        function obj = index(data)
           %
           %     = sl.video.avi.index(data)
           
           %AVIOLDINDEX
           %http://msdn.microsoft.com/en-us/library/ms779634.aspx
           
           data = typecast(data,'uint32');
           
           if mod(length(data),4) ~= 0
               error('Code assumes the index data has 4 elements per entry')
           end
           
           %TODO: Should be method ...
           %Processsing of ChunkID
           %---------------------------------------------------------------
           %'xxyy'
           %xx - stream number
           %yy - 2 character code
           %
           %    db - uncompressed
           %    dc - compressed video frame
           %    pc - palatte change
           %    wb - audio data
           %TODO: Make this a static function somewhere ...
           temp      = typecast(data(1:4:end),'uint16');
           
           chunk_id_type = temp(2:2:end);
           
           obj.is_uncompressed_video = chunk_id_type == uint16(25188); %db
           obj.is_compressed_video   = chunk_id_type == uint16(25444); %dc
           obj.is_palatte_change     = chunk_id_type == uint16(25456); %pc
           obj.is_audio_data         = chunk_id_type == uint16(25207); %wb

           %Stream numbers
           %
           %    Numbers are characters :/
           %
           %    i.e. '00' or [48 48] u8
           stream_numbers_temp = double(typecast(temp(1:2:end),'uint8') - '0');
           obj.stream_number = stream_numbers_temp(1:2:end)*10 + stream_numbers_temp(2:2:end);
           %---------------------------------------------------------------
           
           flags_raw = data(2:4:end);
           %TODO ...
           %
           %    key_frame
           %    list
           %    no_time
           %
           %00127 /* flags for dwFlags member of _avioldindex_entry */
%             00128 #define AVIIF_LIST       0x00000001 - 1
%             00129 #define AVIIF_KEYFRAME   0x00000010 - 5
%             00130 #define AVIIF_NO_TIME    0x00000100 - 9
%
%             %Not yet handled ...
%             00131 #define AVIIF_COMPRESSOR 0x0FFF0000 ?????
           %
           
           obj.is_key_frame           = logical(bitget(flags_raw,1));
           obj.is_rec_list            = logical(bitget(flags_raw,5));
           obj.does_not_affect_timing = logical(bitget(flags_raw,9));
           
           obj.byte_offsets  = double(data(3:4:end)) + 4;
           %-4, would point to '00dc'
           %0 , would point to size, but the length would be missing
           %    4 bytes
           %+4, points to first valid data and covers entire data
           
           obj.chunk_lengths = double(data(4:4:end));
           
        end
    end
    
end

% An optional index ('idx1') chunk can follow the 'movi' list. The index
% contains a list of the data chunks and their location in the file. It
% consists of an AVIOLDINDEX structure with entries for each data chunk,
% including 'rec ' chunks.



% typedef struct _avioldindex {
%    FOURCC  fcc;
%    DWORD   cb;
%    struct _avioldindex_entry {
%       DWORD   dwChunkId;
%       DWORD   dwFlags;
%       DWORD   dwOffset;
%       DWORD   dwSize;
%   } aIndex[];
% } AVIOLDINDEX;