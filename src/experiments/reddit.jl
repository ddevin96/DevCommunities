# load src folder into path for HGS module
# push!(LOAD_PATH, pwd() * "/src")
using DevCommunities


############################################

##
## build of all structures 
##

hgs_reddit = build_all_hgs("reddit")
dfs_raw_reddit = build_raw_dfs("reddit")
dfs_processed_reddit = build_all_dfs("reddit")
hgs_reddit_labelled = build_all_hgs_labeled_reddit(dfs_processed_reddit, dfs_raw_reddit)

############################################

##
## community detection
##

cds_reddit = community_detection(hgs_reddit_labelled)

# test communities
# comms = sort(cds_stackoverflow[1].np, by=length, rev=true)
# for elem in comms[1]
#     println(get_vertex_meta(hgs_stackoverflow_labelled[1], elem))
# end

############################################
