beadAcq = acquisitionDescriptor;
beadAcq.Group = 'Channel';

beadAcq = beadAcq.addChannel('BF',10);
beadAcq = beadAcq.addChannel('Ex292-Em482',5000);
beadAcq = beadAcq.addChannel('Ex292-Em510',5000);
beadAcq = beadAcq.addChannel('Ex292-Em543',5000);
beadAcq = beadAcq.addChannel('Ex292-Em572',5000);
beadAcq = beadAcq.addChannel('Ex292-Em615',1000);
beadAcq = beadAcq.addChannel('Ex292-Em630',1000);