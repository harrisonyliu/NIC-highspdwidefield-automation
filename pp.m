import org.micromanager.projector.ProjectorControlForm
%display projector window
pp = ProjectorControlForm.showSingleton(mmc, gui);
%commands
pp.sendCurrentImageWindowRois(); %sends current imageJ ROIs to device