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

for trim in 1:8
    println("Trim ", trim)
    for (k, v) in all_communities_aggregated[trim]
        println(" ", k, " ", length(v))
    end
end

# confront the tags of each community between consecutive trimester
for trim in 1:7
    open("results/redditsankeytrim"*string(trim)*"trim"*string(trim+1)*".txt", "w") do io
        write(io, "intersection\n")
        for (k, v) in all_communities_aggregated[trim]
            if haskey(all_communities_aggregated[trim+1], k)
                intersezione = intersect(all_communities_aggregated[trim][k], all_communities_aggregated[trim+1][k])
                # println("Tag ", k, " ", length(all_communities_aggregated[trim][k]), " - ", length(all_communities_aggregated[trim+1][k]), " Intersezione ", length(intersezione))
                write(io, k)
                write(io, ",")
                write(io, string(length(all_communities_aggregated[trim][k])))
                write(io, ",")
                write(io, string(length(all_communities_aggregated[trim+1][k])))
                write(io, ",")
                write(io, string(length(intersezione)))
                write(io, "\n")
            end
        end
        write(io, "-------\n\n")
        write(io, "Migration \n")
        # find how many user move from each community to another
        for (k, v) in all_communities_aggregated[trim]
            if haskey(all_communities_aggregated[trim+1], k)
                possible_moved = setdiff(all_communities_aggregated[trim][k], all_communities_aggregated[trim+1][k])
                for (k2, v2) in all_communities_aggregated[trim+1]
                    intersezione = intersect(possible_moved, all_communities_aggregated[trim+1][k2])
                    if length(intersezione) > 0
                        # println("MOving from ", k, " ", length(possible_moved), " to ", k2, " ", length(all_communities_aggregated[trim+1][k2]), " Intersezione ", length(intersezione))
                        write(io, k)
                        write(io, ",")
                        write(io, string(length(possible_moved)))
                        write(io, ",")
                        write(io, k2)
                        write(io, ",")
                        write(io, string(length(all_communities_aggregated[trim+1][k2])))
                        write(io, ",")
                        write(io, string(length(intersezione)))
                        write(io, "\n")
                    end
                end
            end
            write(io, "*****\n")
        end

        # user that disappeared from the community
        possible_ghost = Set()
        set_user1 = Set()
        set_user2 = Set()
        for (k, v) in all_communities_aggregated[trim]
            set_user1 = union(set_user1, all_communities_aggregated[trim][k])
        end
        for (k2, v2) in all_communities_aggregated[trim+1]
            set_user2 = union(set_user2, all_communities_aggregated[trim+1][k2])  
        end
        possible_ghost = setdiff(set_user1, set_user2)
        # if length(possible_ghost) > 0
            # println("User disappeared ", length(possible_ghost))
            write(io, "User disappeared ")
            write(io, string(length(possible_ghost)))
            write(io, "\n")
        # end

        new_users = setdiff(set_user2, set_user1)
        # if length(new_users) > 0
            # println("New users ", length(new_users))
            write(io, "New users ")
            write(io, string(length(new_users)))
            write(io, "\n")
        # end
    end
end

############################################
