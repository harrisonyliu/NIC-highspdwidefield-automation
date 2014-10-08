function manualAcq(mmc, gui)

% mmc.setFocusDevice('TIZDrive');
mmc.setFocusDevice('ZStage');
tic
for i = 1:11
    currentPos = -250 + (i-1)*50
    gui.setRelativeStagePosition(currentPos);
    snap()
end

    function snap()
        mmc.snapImage();
        w = mmc.getImageWidth();
        h = mmc.getImageHeight();
        bd = mmc.getImageBitDepth();
        if (bd>8)
            imgType='uint16';
        else
            imgType='uint8';
        end
        img = reshape(typecast(mmc.getImage() ,imgType),w,h)';
%         figure();imagesc(img);colormap gray;axis off;axis image;
    end
toc
end
