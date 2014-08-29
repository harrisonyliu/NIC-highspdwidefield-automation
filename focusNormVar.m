function normVar = focusNormVar(im)
start = cputime;
normVar = zeros(1,size(im,3));

for i = 1:size(im,3);
    temp = reshape(im(:,:,i),1,numel(im(:,:,i)));
    normVar(i) = var(temp) / mean(temp);
end

figure();plot(normVar,'--b');title('Normalized Variance Focus Curve'); grid on;
['Best focused at frame: ' num2str(find(normVar == max(normVar)))]
endTime = cputime;
endTime-start