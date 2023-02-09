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

my_tags = ["rust" "elixir" "clojure" "typescript" "julia" "python" "delphi" "go" "sql" "c#" "kotlin" "swift" "dart" "html" "solidity" "javascript" "f#" "bash" "lisp" "apl"]

##
## stats on hgs and dfs
## 

# operations on hgs
dimension_hgs_bar_chart(hgs_stackoverflow)
size_distribution_chart(hgs_stackoverflow)
degree_distribution_chart(hgs_stackoverflow)

# operations on dfs processed
popularity_stackoverflow(dfs_processed_stackoverflow)
total_user_x_tag_stackoverflow(dfs_processed_stackoverflow)
user_x_tag_over_time_stackoverflow(dfs_processed_stackoverflow)
span_hours_stackoverflow(dfs_processed_stackoverflow)
mean_total_comments_stackoverflow(dfs_processed_stackoverflow)