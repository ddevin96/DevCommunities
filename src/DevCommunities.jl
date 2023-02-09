module DevCommunities

using Revise
using CSV
using DataFrames
using SimpleHypergraphs
using PyPlot
using Dates
using Statistics
using Random
using Graphs

export build_hg, build_all_hgs
export build_df, build_all_dfs, build_raw_dfs
export build_all_hgs_labeled_reddit, build_all_hgs_labeled_stackoverflow
export my_aggregator, my_trick, string_aggregator
export myfindcommunities
export community_detection
export check_hgs_labelled
export temporal_communities
export t_communities_aggregation_reddit #, t_communities_aggregation_stackoverflow

include("utils.jl")
include("lp.jl")

end
