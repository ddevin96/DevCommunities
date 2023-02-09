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
check_hgs_labelled(hgs_stackoverflow_labelled)
############################################

##
## community detection
##
my_tags = ["rust" "elixir" "clojure" "typescript" "julia" "python" "delphi" "go" "sql" "c#" "kotlin" "swift" "dart" "html" "solidity" "javascript" "f#" "bash" "lisp" "apl"]

cds_stackoverflow = community_detection(hgs_stackoverflow_labelled)
qs = quantiles(cds_stackoverflow, "stackoverflow")

temporal_comms, percentages = temporal_communities(cds_stackoverflow, 0.05)
all_communities_aggregated, all_tags = t_communities_aggregation_stackoverflow(temporal_comms, percentages, my_tags, dfs_processed_stackoverflow)

for trim in 1:8
    for (k, v) in all_communities_aggregated[trim]
        println("Trim: ", trim, " - Community: ", k, " - Size: ", length(v))
    end
end

for trim in 1:8
    for (k, v) in all_tags[trim]
        println("Trim: ", trim, " - Community: ", k, " - Size: ", length(v))
    end
end
############################################

##
## stats on hgs and dfs
## 

# operations on hgs
# dimension_hgs_bar_chart(hgs_stackoverflow)
# size_distribution_chart(hgs_stackoverflow)
# degree_distribution_chart(hgs_stackoverflow)

# # operations on dfs processed
# popularity_stackoverflow(dfs_processed_stackoverflow)
# total_user_x_tag_stackoverflow(dfs_processed_stackoverflow)
# user_x_tag_over_time_stackoverflow(dfs_processed_stackoverflow)
# span_hours_stackoverflow(dfs_processed_stackoverflow)
# mean_total_comments_stackoverflow(dfs_processed_stackoverflow)

############################################