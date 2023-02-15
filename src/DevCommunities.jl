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
export degree_histogram
export my_aggregator, my_trick, string_aggregator
export myfindcommunities, community_detection
export check_hgs_labelled
export temporal_communities, communities_between_trimesters
export t_communities_aggregation_reddit, t_communities_aggregation_stackoverflow
export quantiles
export sankey

include("utils.jl")
include("lp.jl")

############################################
## plotting functions
############################################

export dimension_hgs_bar_chart, size_distribution_chart, degree_distribution_chart, single_distribution_degree
export popularity_reddit, span_hours_reddit, total_user_x_subreddit, user_x_tag_over_time_reddit, mean_total_comment_reddit
export popularity_stackoverflow, span_hours_stackoverflow, total_user_x_tag_stackoverflow, user_x_tag_over_time_stackoverflow, mean_total_comments_stackoverflow
include("plots/plots_reddit.jl")
include("plots/plots_stackoverflow.jl")
include("plots/common.jl")

end
