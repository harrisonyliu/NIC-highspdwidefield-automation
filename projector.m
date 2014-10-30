import ij.plugin.frame.RoiManager;
import ij.gui.Roi;
ROImgr = RoiManager.getInstance();
%run projector plugin
pp = org.micromanager.projector.ProjectorControlForm.showSingleton(mmc, gui)

%get imageplus from snap live window
ROImgr.addRoi(Roi(1200,1200,200,200));
ROImgr.addRoi(Roi(1000,1000,300,300));


%send and run ROIs
pp.sendCurrentImageWindowRois()
pp.updateROISettings()
pp.runRois()

ROImgr.runCommand('Delete')