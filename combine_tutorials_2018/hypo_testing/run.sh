# this exercise is taken from https://twiki.cern.ch/twiki/bin/viewauth/CMS/SWGuideCMSDataAnalysisSchool2014HiggsCombPropertiesExercise#Higgs_JCP with some bug fixes

# In this datacard you will note that besides the usual SM signal contributions (ggH, qqH, ZH, and WH) there are two new processes (qqbarH_ALT and ggH_ALT) corresponding to the production of 2+m via quark-antiquark annihilation and gluon-fusion. 
head jcp_hwwof_0j_8TeV.txt

#Let's look at the shape of the templates: 
python plotShapes.py -l -q -b

#You will notice multiple peaks. These correspond to an unrolled 2D histogram encoding the information of mT and mll as explained in https://twiki.cern.ch/twiki/bin/view/CMSPublic/Hig12042TWiki Basically, inside each peak mll is increasing, while different peaks correspond to larger mT values.  You can see that the signal shapes are also different, with different hypotheses having more or less signal in the different "peaks" (which correspond to different mT values).

# The hypothesis test is performed by constructing a nested model which has two relevant parameters:
#  *  fqq, the fraction qqbarH_ALT / (qqbarH_ALT + ggH_ALT)
#  *  x, the fraction 0+ / (0+ + 2+m) 

#This means that signal model is defined as S(x,fqq) = r * [ x * S(0+) + (1-x) * S(2+m) ], with S(2+m) =  fqq * S(qq->2+m) + (1-fqq)*S(gg->qq2+m). The parameter r is the usual overall signal strength which is profiled so as to not use yield information in the hypotheses test. 

#You can immediately see that this general (nested) signal model encodes several interesting limiting cases: 
#Hypothesis                 r    x  fqq
#--------------------------------------
#SMH                        1    0  -
#0+                         free 0  -
#gg->2+m                    free 1  0
#qq->2+m                    free 1  1
#production indpendent 2+m  free 1  free

# Let's create the binary workspace encoding the physics model.  The PhysicsModel that encodes the signal model above is the twoHypothesisHiggs (https://github.com/cms-analysis/HiggsAnalysis-CombinedLimit/blob/master/python/HiggsJPC.py).  We would like each of the processes to be differentiated via fqq. This is done using a "Physics Option" called "fqqIncluded". The parameter fqq is fixed to 0 by default and does not float. 

text2workspace.py jcp_hwwof_0j_8TeV.txt -P HiggsAnalysis.CombinedLimit.HiggsJPC:twoHypothesisHiggs -m 125.7 --PO verbose --PO fqqIncluded -o jcp_hww.root


# Let's now generate toys datasets to determine the test statistic distributions under different assumptions. The way the TEV test statistic works is that the POI is set to 0 and 1. In the Physics Model the POI is set to x so the two hypothesis are x=0 (SMH) and x=1 (gg->2+m, remember fqq is fixed to 0).

# First we do pre-fit expected:
combine -M HybridNew -m 125.7 jcp_hww.root --testStat=TEV --singlePoint 1 --saveHybridResult -T 5000 --fork 8 --clsAcc 0 --fullBToys --generateExt=1 --generateNuis=0 --expectedFromGrid 0.5 -n jcp_hww_pre-fit_exp

# Second we do post-fit expected:
combine -M HybridNew -m 125.7 jcp_hww.root --testStat=TEV --singlePoint 1 --saveHybridResult -T 5000 --fork 8 --clsAcc 0 --fullBToys --frequentist --expectedFromGrid 0.5 -n jcp_hww_post-fit_exp

# Finally we do postfit observed:
combine -M HybridNew -m 125.7 jcp_hww.root --testStat=TEV --singlePoint 1 --saveHybridResult -T 5000 --fork 8 --clsAcc 0 --fullBToys --frequentist -n jcp_hww_post-fit_obs

# First you will notice that the pre-fit expected and post fit expected cls values are different.  The difference between the post-fit expected and the pre-fit expected is related to fact that the data does not accommodate a large signal. We can check this also by performing fits for the signal strength for the two hypotheses: we create a workspace that has the signal strength as an additional parameter of interest, and then run fits for the signal strength r at a fixed value of the mixing x corresponding to the two hypotheses :

combine jcp_hww.root -M MultiDimFit -m 125.7 --redefineSignalPOIs r -P r --floatOtherPOI=0 --setParameters x=0 --freezeParameters x -n MU_SCALAR

combine jcp_hww.root -M MultiDimFit -m 125.7 --redefineSignalPOIs r -P r --floatOtherPOI=0 --setParameters x=1 --freezeParameters x -n MU_SPIN2

# This implies that our post-fit expectation for the signal yield is less than the SM Higgs prediction, especially for the spin 0 case, and consequently also our post-fit expectation for the separation between the two hypotheses is worse (with less events, it's harder to separate them).

# Lets look at the output of the post fit observed file. First convert the results to a tree:
root -l -q -b higgsCombinejcp_hww_post-fit_obs.HybridNew.mH125.7.root ${CMSSW_BASE}/src/HiggsAnalysis/CombinedLimit/test/plotting/hypoTestResultTree.cxx\(\"jcp_hww_post-fit_obs.qvals.root\",125.7,1,\"x\"\)

#root -l jcp_hww_post-fit_obs.qvals.root
#q->Print()

#The type encodes which hypothesis the value of q corresponds to (observation has type zero, null is type -1 and alt is type 1). Now lets make a plot of the test statistic distributions in the observed case:

python plotQ.py -l -q -b

# Take a look at the plot that is produced and try to understand it



