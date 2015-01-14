for i = 1:numel(truncated_Images)
    temp = truncated_Images{i};
    temp = (temp ./ max(max(temp))) * (2^16);
    temp = uint16(temp);
    imwrite(temp,'lgg1_stack.tif','WriteMode','append');
end