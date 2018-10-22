import ROOT

for index in [2]:
  
  f = ROOT.TFile('higgsCombineToys'+str(index)+'.GoodnessOfFit.mH125.123456.root')
  t = f.Get('limit')
  c = ROOT.TCanvas()
  vals = []
  for e in range(t.GetEntries()):
      t.GetEntry(e)
      vals.append(t.limit)
  
  t.Draw('limit>>hist(80,0,400)')
  hist = ROOT.gDirectory.Get('hist')
  hist.SetTitle('Test-statistic distribution')
  hist.Draw("HIST")
  
  fobs = ROOT.TFile('higgsCombineObs'+str(index)+'.GoodnessOfFit.mH125.root')
  tobs = fobs.Get('limit')
  tobs.GetEntry(0)
  obs = tobs.limit
  
  pval = sum(1.0 for i in vals if i >= obs) / float(len(vals))
  
  arr = ROOT.TArrow(obs, 0.001, obs, hist.GetMaximum()/4, 0.02, "<|")
  arr.SetLineColor(ROOT.kBlue)
  arr.SetFillColor(ROOT.kBlue)
  arr.SetFillStyle(1001)
  arr.SetLineWidth(6)
  arr.SetLineStyle(1)
  arr.SetAngle(60)
  arr.Draw("<|same")
  
  c.SaveAs("saturated_gof_"+str(index)+".pdf")
  
  print 'index=%i p-value for obs=%f is %f' % (index,obs, pval)
  
