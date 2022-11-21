function flag = is_apple_silicon()
%
%   flag = sl.os.is_apple_silicon()

persistent is_m1_mac

if isempty(is_m1_mac)
    if ismac()
        [~,result] = system('uname -v');
        is_m1_mac = any(strfind(result,'ARM64'));
    else
        is_m1_mac = false;
    end
end

flag = is_m1_mac;

end