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

check_hgs_labelled(hgs_reddit_labelled)

##
## community detection
##

cds_reddit = community_detection(hgs_reddit_labelled)

# test communities
# for i in 1:length(cds_reddit)
#     println("Community detection for graph ", i)
#     comms = sort(cds_reddit[i].np, by=length, rev=true)
#     println("Number of communities: ", length(comms))
#     # for elem in comms[1]
#     #     println(get_vertex_meta(hgs_reddit_labelled[i], elem))
#     # end
# end

my_tags = ["rust" "elixir" "Clojure" "typescript" "Julia" "Python" "delphi" "golang" "SQL" "csharp" "Kotlin" "swift" "dartlang" "HTML" "solidity" "javascript" "fsharp" "bash" "lisp" "apljk"]

temporal_comms, percentages = temporal_communities(cds_reddit, 0.05)

all_communities_aggregated = t_communities_aggregation_reddit(temporal_comms, percentages, my_tags, dfs_processed_reddit)

# confront the tags of each community between consecutive trimester
# sankey stuff redditsankeytrim1trim2.txt
communities_between_trimesters(all_communities_aggregated, hgs_reddit_labelled)

############################################

##
## stats
## 

# size hypergraphs
# dimension_hgs_bar_chart(hgs_reddit)
# size_distribution_chart(hgs_reddit)
# degree_distribution_chart(hgs_reddit)


