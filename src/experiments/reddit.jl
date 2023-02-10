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
# sankey stuff || write to results/reddit/redditsankeytrim1trim2.txt
communities_between_trimesters(all_communities_aggregated_r, hgs_reddit_labelled, "reddit")
sankey(all_communities_aggregated_r, hgs_reddit_labelled, "reddit")

# for trim in 1:8
#     for (k, v) in all_communities_aggregated_r[trim]
#         println("Trim: ", trim, " - Community: ", k, " - Size: ", length(v))
#     end
# end


############################################

##
## stats on hgs and dfs
## 

# operations on hgs
# dimension_hgs_bar_chart(hgs_reddit)
# size_distribution_chart(hgs_reddit)
# degree_distribution_chart(hgs_reddit)

# operations on dfs processed
# popularity_reddit(dfs_processed_reddit)
# total_user_x_subreddit(dfs_processed_reddit)
# user_x_tag_over_time_reddit(dfs_processed_reddit)
# span_hours_reddit(dfs_processed_reddit)
# mean_total_comment_reddit(dfs_processed_reddit)

############################################

## dati for ale
##
## tabelline
## how to sankey -- plotlyù
## aggregated stayed, moved, disappeared, new user

open("results/reddit/tags_x_communities.txt", "w") do io
    for tag in my_tags_r
        write(io, tag * ",")
        for trim in 1:8
            if haskey(all_communities_aggregated_r[trim], tag)
                write(io, string(length(all_communities_aggregated_r[trim][tag]))*",")
            else
                write(io, "0,")
            end
        end
        write(io, "\n")
    end
end

for trim in 1:8
    print(length(cds_reddit[trim].np))
    print(",")
end