# ssh orb "
# cd /Users/ddevin/Documents/MoCHy
# bash run_exact_par.sh /Users/ddevin/Documents/vscode/DevCommunities/randoms/randomPIPE.hg"

PATH_TO_HG=$1
ssh orb "
cd /Users/ddevin/Documents/MoCHy
bash run_approx_ver2_par.sh $PATH_TO_HG"