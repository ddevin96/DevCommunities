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
# check if the hgs don't have empty label for each vertex or hyperedge
check_hgs_labelled(hgs_reddit_labelled)
############################################

##
## community detection
##

my_tags_r = ["rust" "elixir" "Clojure" "typescript" "Julia" "Python" "delphi" "golang" "SQL" "csharp" "Kotlin" "swift" "dartlang" "HTML" "solidity" "javascript" "fsharp" "bash" "lisp" "apljk"]

cds_reddit = community_detection(hgs_reddit_labelled)
qs = quantiles(cds_reddit, "reddit")

temporal_comms_r, percentages_r = temporal_communities(cds_reddit, 0.05)
all_communities_aggregated_r = t_communities_aggregation_reddit(temporal_comms_r, percentages_r, my_tags_r, dfs_processed_reddit)

# confront the tags of each community between consecutive trimester
communities_between_trimesters(all_communities_aggregated_r, hgs_reddit_labelled, "reddit")
sankey(all_communities_aggregated_r, hgs_reddit_labelled, "reddit")

############################################

##
## stats on hgs and dfs
## 

# operations on hgs
dimension_hgs_bar_chart(hgs_reddit)
size_distribution_chart(hgs_reddit)
degree_distribution_chart(hgs_reddit)

# operations on dfs processed
popularity_reddit(dfs_processed_reddit)
total_user_x_subreddit(dfs_processed_reddit)
user_x_tag_over_time_reddit(dfs_processed_reddit)
span_hours_reddit(dfs_processed_reddit)
mean_total_comment_reddit(dfs_processed_reddit)

############################################