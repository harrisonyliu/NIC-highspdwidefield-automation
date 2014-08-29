function grad = focusSobel(im)
start = cputime;
grad = zeros(1,size(im,3));

for i = 1:size(im,3);
    grad(i) = sum(sum(imgradient(im(:,:,i))));
end

% figure();plot(grad,'--b');title('Tenenbaum Gradient Focus Curve');grid on;
% ['Best focused at frame: ' num2str(find(grad == max(grad)))]
endtime = cputime;
endtime-start