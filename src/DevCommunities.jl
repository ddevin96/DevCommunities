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
export myfindcommunities, community_detection
export check_hgs_labelled
export temporal_communities, communities_between_trimesters
export t_communities_aggregation_reddit #, t_communities_aggregation_stackoverflow

include("utils.jl")
include("lp.jl")

############################################
## plotting functions
############################################

export dimension_hgs_bar_chart, size_distribution_chart, degree_distribution_chart
export single_distribution_degree

include("plots/plots_reddit.jl")
include("plots/plots_stackoverflow.jl")
include("plots/common.jl")

end
