function photoactivate(mmc,gui,pp,ROImgr,boundingboxes)
import ij.gui.Roi;
tot_Area = 0;

for i = 1:numel(boundingboxes)
    x0 = boundingboxes(i).BoundingBox(1)*2 - 50;
    y0 = boundingboxes(i).BoundingBox(2)*2 - 50;
    dx = boundingboxes(i).BoundingBox(3)*2 + 100;
    dy = boundingboxes(i).BoundingBox(4)*2 + 100;
    tot_Area = tot_Area + dx*dy;
    ROImgr.addRoi(Roi(x0,y0,dx,dy));
end
gui.enableLiveMode(1);
pp.sendCurrentImageWindowRois();
pp.updateROISettings();
pp.runRois();
% pp.runRois();
pause_time = 3.2*numel(boundingboxes) + (2.8*10^-5)*tot_Area;
disp(['Pausing for ' num2str(pause_time) ' seconds to photoactivate ' ...
    num2str(numel(boundingboxes)) ' worms']);
pause(pause_time);
gui.enableLiveMode(0);
ROImgr.runCommand('Delete');