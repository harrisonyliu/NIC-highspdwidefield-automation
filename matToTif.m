for i = 1:size(fish_stack.images,3)
    temp = fish_stack.images(:,:,i);
    temp = (temp ./ max(max(temp))) * (2^16);
    temp = uint16(temp);
    imwrite(temp,'fish_stack_bad.tif','WriteMode','append');
end