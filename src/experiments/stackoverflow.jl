using DevCommunities


############################################

##
## build of all structures 
##

hgs_stackoverflow = build_all_hgs("stackoverflow")
dfs_raw_stackoverflow = build_raw_dfs("stackoverflow")
dfs_processed_stackoverflow = build_all_dfs("stackoverflow")
hgs_stackoverflow_labelled = build_all_hgs_labeled_stackoverflow(dfs_processed_stackoverflow, dfs_raw_stackoverflow)

############################################

##
## community detection
##

cds_stackoverflow = community_detection(hgs_stackoverflow_labelled)


# test communities
# comms = sort(cds_stackoverflow[1].np, by=length, rev=true)
# for elem in comms[1]
#     println(get_vertex_meta(hgs_stackoverflow_labelled[1], elem))
# end

############################################
