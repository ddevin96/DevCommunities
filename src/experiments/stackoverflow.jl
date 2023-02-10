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
my_tags_so = ["rust" "elixir" "clojure" "typescript" "julia" "python" "delphi" "go" "sql" "c#" "kotlin" "swift" "dart" "html" "solidity" "javascript" "f#" "bash" "lisp" "apl"]

cds_stackoverflow = community_detection(hgs_stackoverflow_labelled)
qs = quantiles(cds_stackoverflow, "stackoverflow")

temporal_comms_s, percentages_s = temporal_communities(cds_stackoverflow, 0.05)
all_communities_aggregated_s, all_tags = t_communities_aggregation_stackoverflow(temporal_comms_s, percentages_s, my_tags_so, dfs_processed_stackoverflow)

communities_between_trimesters(all_communities_aggregated_s, hgs_stackoverflow_labelled, "stackoverflow")
sankey(all_communities_aggregated_s, hgs_stackoverflow_labelled, "stackoverflow")

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

## random stuff for debugging
# using SimpleHypergraphs
# using DataFrames
# population = combine(groupby(dfs_processed_stackoverflow[1], :new_id), 
#                 :tags => Base.vect∘my_aggregator => :tags,
#                 :q_new_id => Base.vect∘my_aggregator => :q_custom_arr,
#                 )
        
# population.tags = [unique(x) for x in population.tags]
# # printf first row of population
# population
# # a = []
# new_tags = []
# for row in eachrow(population)
#     found = false
#     my_new_tags = []
#     for x in row.tags
#         for tag in my_tags
#             # println("tag: ", tag, " - x: ", x)
#             if occursin(tag, x)
#                 # push!(a, row.custom_arr)
#                 push!(my_new_tags, tag)
#                 found = true
#             elseif tag == "go"
#                 if occursin("|go", x) || occursin("go|", x) || x == "go"
#                     # push!(a, row.custom_arr)
#                     push!(my_new_tags, tag)
#                     found = true
#                 end
#             end
#         end
#         break
#         if !found
#             # # push!(a, row.custom_arr)
#             push!(my_new_tags, "other")
#             # found = true
#         end
#     break
#     end
#     push!(new_tags, my_new_tags)
# # findfirst(x->occursin(x, population[1, :tags]), my_tags)
# # popularity[!, tag] = [count(x->occursin(tag, x), x) for x in popularity.tags]
# end

# population[!, :tags2] = new_tags # 166523
# # drop tags column 

# population = select(population, Not(:tags))
# population

open("results/stackoverflow/tags_x_communities.txt", "w") do io
    for tag in my_tags_so
        write(io, tag * ",")
        for trim in 1:8
            if haskey(all_communities_aggregated_s[trim], tag)
                write(io, string(length(all_communities_aggregated_s[trim][tag]))*",")
            else
                write(io, "0,")
            end
        end
        write(io, "\n")
    end
end

for trim in 1:8
    print(length(cds_stackoverflow[trim].np))
    print(",")
end