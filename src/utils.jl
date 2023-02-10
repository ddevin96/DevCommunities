function build_hg(path)

    nodes = Dict{Int,Int}()
    nodes_per_edge = Dict{Int,Vector{Int}}()

    hg = Hypergraph(0,0)

    for line in eachline(path)
        # split elemnts of the line by comma
        d = split(line, ",")
        vs = map(x -> parse(Int,(strip(replace(x, r"\[|\]" => "")))), d)
        for v in vs
            if !haskey(nodes, v)
                v_id = SimpleHypergraphs.add_vertex!(hg)
                push!(nodes, v=>v_id)
            end
        end
        # add he 
        vertices = Dict{Int, Bool}(nodes[v] => true for v in vs)
        he_id = SimpleHypergraphs.add_hyperedge!(hg; vertices = vertices)
        push!(nodes_per_edge, he_id => vs)  
    end

    return hg, nodes, nodes_per_edge
end

# name of the folder containing the dataset
# follow the readme for the structure of the folder 
function build_all_hgs(name_dataset)
    hgs = []
    for i in 1:8
        # path = "../../data/" * name_dataset * "/processed/trimestre" * string(i) * "/hyperedges.txt"
        path = "data/" * name_dataset * "/processed/trimestre" * string(i) * "/hyperedges.txt"
        hg = build_hg(path)
        push!(hgs, hg)
    end
    return hgs
end

function build_df(path)
    df = DataFrame(CSV.File(path))
    return df
end

function build_all_dfs(name_dataset)
    dfs = []
    for i in 1:8
        path = "data/" * name_dataset * "/processed/trimestre" * string(i) * "/processed.csv"
        df = DataFrame(CSV.File(path))
        if name_dataset == "reddit"
            df = df[.!startswith.(df.subreddit, "u_"), :]
        end
        push!(dfs, df)
    end
    return dfs
end

function build_raw_dfs(name_dataset)
    dfs = []
    for i in 1:8
        println("$i")
        path = "data/" * name_dataset * "/raw_data/trimestre" * string(i) * ".csv"
        df = DataFrame(CSV.File(path))
        if name_dataset == "reddit"
            df = df[.!startswith.(df.subreddit, "u_"), :]
        end
        push!(dfs, df)
    end
    return dfs
end

# return a dict with key = length of hyperedges and value = number of hyperedges with that length
# normalized = true if you want the values to be normalized
function degree_histogram(hg; normalized=false) 
    hist = Dict{Int,Union{Int,Float64}}()
    
    for v in 1:nhv(hg)      
        deg = length(gethyperedges(hg, v))
        hist[deg] = get(hist, deg, 0) + 1
    end

    if normalized
        for (deg, count) in hist
            hist[deg] = count / nhv(hg)
        end

        return hist
    end

    return hist
end

# return a dict with key = degree of vertices and value = number of vertices with that length
# normalized = true if you want the values to be normalized
function size_histogram(hg; normalized=false) 
    hist = Dict{Int,Union{Int,Float64}}()

    for he in 1:nhe(hg)      
        s = length(getvertices(hg, he))
        hist[s] = get(hist, s, 0) + 1
    end

    if normalized
        for (s, count) in hist
            hist[s] = count / nhe(hg)
        end

        return hist
    end

    return hist
end

## check error on hg labelled 
function check_hgs_labelled(hgs)
    for i in 1:8
        for j in 1:nhv(hgs[i])
            # print error if meta info is missing
            if get_vertex_meta(hgs[i], j) == ""
                println("Error: missing meta info on vertex $j")
            end
        end
        for j in 1:nhe(hgs[i])
            # print error if meta info is missing
            if get_hyperedge_meta(hgs[i], j) == ""
                println("Error: missing meta info on edge $j")
            end
        end
    end
end

# custom aggregator for a generic type inside the DataFrame
function my_aggregator(p)
    result = Vector{eltype(p)}()
    for i = 1:length(p)
        push!(result, p[i])
    end
    result
end

function my_trick(p)
    return p[1]
end

function string_aggregator(p)
    result = String[]
    for i = 1:length(p)
        push!(result, p[i])
    end
    result
end

function build_all_hgs_labeled_reddit(dfs_processed_reddit, dfs_raw_reddit)
    hgs_labeled = []
    for i in 1:8

        population = combine(groupby(dfs_processed_reddit[i], :submission_id), 
            :new_id => Base.vect∘my_aggregator => :custom_arr,
            :subreddit => my_trick => :subreddit,
            :comment_id => Base.vect∘string_aggregator => :comments,
            )

        df_to_build = population
        raw_df = dfs_raw_reddit[i]
        df_to_build.subreddit = string.(df_to_build.subreddit) # cast subreddit to string
        println("Building hypergraph $i")
        nodes = Dict{Int,Int}()
        nodes_per_edge = Dict{Int,Vector{Int}}()
        # Bool value of vertex, String value of meta info on vertex, String value of meta info on edge
        hg = Hypergraph{Bool, String, String}(0,0)
        for row in eachrow(df_to_build)
            vs = [] #Array{Int, 1}()
            position = 1
            for x in row.custom_arr
                if !haskey(nodes, x)
                    v_id = SimpleHypergraphs.add_vertex!(hg)
                    temp_df = raw_df[raw_df.comment_id .== row.comments[position], :author]
                    s = ""
                    author = string(temp_df[1])
                    s = s * author
                    push!(nodes, x=>v_id)
                    set_vertex_meta!(hg, s, v_id)
                end
                push!(vs, x)
                position += 1
            end
            vs = unique(vs)
            vertices = Dict{Int, Bool}(nodes[v] => true for v in vs)
            he_id = SimpleHypergraphs.add_hyperedge!(hg; vertices = vertices)
            r = "" * row.subreddit
            SimpleHypergraphs.set_hyperedge_meta!(hg, r, he_id)
            push!(nodes_per_edge, he_id => vs)  
        end
        push!(hgs_labeled, hg)
    end
    return hgs_labeled
end

function build_all_hgs_labeled_stackoverflow(dfs_processed_stackoverflow, dfs_raw_stackoverflow)
    hgs_labeled = []
    for i in 1:8
        println("Building hypergraph $i")
        population = combine(groupby(dfs_processed_stackoverflow[i], :question_id), 
            :new_id => Base.vect∘my_aggregator => :custom_arr,
            :tags => Base.vect∘my_aggregator => :tags,
            :q_new_id => Base.vect∘my_aggregator => :q_custom_arr,
            :answer_id => Base.vect∘my_aggregator => :answers,
            )

        raw_df = dfs_raw_stackoverflow[i]
        # cast owner_user_id to int
        my_tags = ["rust" "elixir" "clojure" "typescript" "julia" "python" "delphi" "go" "sql" "c#" "kotlin" "swift" "dart" "html" "solidity" "javascript" "f#" "bash" "lisp" "apl"]

        new_tags = []
        for row in eachrow(population)
            found = false
            my_new_tags = []
            for x in row.tags
                for tag in my_tags
                    if occursin(tag, x)
                        push!(my_new_tags, tag)
                        found = true
                    elseif tag == "go"
                        if occursin("|go", x) || occursin("go|", x) || x == "go"
                            push!(my_new_tags, tag)
                            found = true
                        end
                    end
                end
                if !found
                    # # push!(a, row.custom_arr)
                    push!(my_new_tags, "other")
                    # found = true
                end
            end
            push!(new_tags, unique(my_new_tags))
        end

        population[!, :tags2] = new_tags # 166523
        population = select(population, Not(:tags))
        df_to_build = population # 166523×4 DataFrame

        # build hg with label
        nodes = Dict{Int,Int}()
        nodes_per_edge = Dict{Int,Vector{Int}}()
        # Bool value of vertex, String value of meta info on vertex, String value of meta info on edge
        hg = Hypergraph{Bool, String, Vector{Any}}(0,0)

        for row in eachrow(df_to_build)
            vs = [] #Array{Int, 1}()
            # answers
            for x in row.custom_arr
                position = 1
                if !haskey(nodes, x)
                    v_id = SimpleHypergraphs.add_vertex!(hg)
                    temp_df = raw_df[raw_df.answer_id .== row.answers[position], :]
                    s = ""
                    my_row = first(temp_df)
                    if ismissing(my_row.owner_display_name)
                        s = s * string(my_row.owner_user_id)
                    else
                        s = s * string(my_row.owner_display_name)
                    end
                    push!(nodes, x=>v_id)
                    set_vertex_meta!(hg, s, v_id)
                    #
                    # set_vertex_meta!(hg, "other", v_id)
                end
                push!(vs, x)
                position += 1
            end
            # question owner
            for x in row.q_custom_arr
                if !haskey(nodes, x)
                    v_id = SimpleHypergraphs.add_vertex!(hg)
                    push!(nodes, x=>v_id)
                    temp_df = raw_df[raw_df.question_id .== row.question_id, :]
                    s = ""
                    my_row = first(temp_df)
                    if ismissing(my_row.q_owner_name)
                        s = s * string(my_row.q_owner_id)
                    else
                        s = s * string(my_row.q_owner_name)
                    end
                    push!(nodes, x=>v_id)
                    set_vertex_meta!(hg, s, v_id)
                end
                push!(vs, x)
            end
            vs = unique(vs)
            # add he
            vertices = Dict{Int, Bool}(nodes[v] => true for v in vs)
            he_id = SimpleHypergraphs.add_hyperedge!(hg; vertices = vertices)
            SimpleHypergraphs.set_hyperedge_meta!(hg, row.tags2, he_id)
            push!(nodes_per_edge, he_id => vs)  
        end
        push!(hgs_labeled, hg)
    end
    return hgs_labeled
end

function community_detection(hgs)
    communities = []
    for i in 1:8
        println("Building communities of hg $i")
        b = SimpleHypergraphs.BipartiteView(hgs[i])
        cc = connected_components(b)
        comm_sizes = [length(comm) for comm in cc]
        isolated_components = []
        # sort cc by length
        cc = sort(cc, by=length, rev=true)

        for comp in cc[2:length(cc)]
            append!(isolated_components, comp)
        end

        hg_no_isolated = deepcopy(hgs[i])

        for v in Iterators.reverse(isolated_components)
            v > nhv(hgs[i]) && continue
            remove_vertex!(hg_no_isolated, Int(v))
        end

        hyperedges = [e for e in 1:nhe(hg_no_isolated) if length(getvertices(hg_no_isolated, e)) == 0]

        # remove empty hyperedges
        for he in Iterators.reverse(hyperedges)
            remove_hyperedge!(hg_no_isolated, he)
        end

        for he in Iterators.reverse(1:nhe(hg_no_isolated))
            for v in Iterators.reverse(collect(keys(getvertices(hg_no_isolated, he))))
                if v > nhv(hg_no_isolated)
                    remove_hyperedge!(hg_no_isolated, he)
                    break
                end
            end
        end

        # prune because i lose some vertices # rip heroes
        prune_hypergraph!(hg_no_isolated)
        cflp = CFLabelPropagationFinder(100, 1234)
        c = myfindcommunities(hg_no_isolated, cflp)
        push!(communities, c)
    end
    return communities
end

function quantiles(cds, name_dataset)
    open("results/" * name_dataset * "/quantiles.txt", "w") do io
        write(io, "quantiles 0.25 0.5 0.75 0.9\n")
        for i in 1:8
            size_communities = length.(cds[i].np)
            v = quantile(size_communities, [0.25, 0.5, 0.75, 0.9])
            write(io, "trim$i\t")
            for j in 1:4
                write(io, string(v[j]) * " ")
            end
            write(io, "\n")
        end
    end
end

# temporal_communities(cds, 0.05) # 5% of top communities
function temporal_communities(communities, perc)
    temporal_comms = []
    percentages = []
    for i in 1:8
        sorted_communities_by_size = sort(communities[i].np, by=length, rev=true)
        # pick the top perc of communities
        percentage = length(communities[i].np) * perc
        percentage = trunc(Int, percentage)
        push!(percentages, percentage)
        top_comms = sorted_communities_by_size[1:percentage]
        push!(temporal_comms, top_comms)
    end
    return temporal_comms, percentages
end

function t_communities_aggregation_reddit(temporal_comms, percentages, my_tags, dfs_processed_reddit)
    all_tags = []
    for trim in 1:8
        tags = Dict()
        for i in 1:percentages[trim]
            temporal_community = temporal_comms[trim][i]
            tag_d = Dict()
            for user in temporal_community
                # retrieve all the tags of the user
                mydf = dfs_processed_reddit[trim]
                temp_df = mydf[mydf.new_id .== user, :]
                # retrieve all the tags of the user
                for tag in my_tags
                    if tag in temp_df.subreddit
                        if !haskey(tag_d, tag)
                            tag_d[tag] = 0
                        end
                        tag_d[tag] += 1
                    end
                end
            end
            max_tag = ""
            max_tag_count = 0
            for (k, v) in tag_d
                if v > max_tag_count
                    max_tag = k
                    max_tag_count = v
                end
            end
            if max_tag == ""
                continue
            end
            if !haskey(tags, max_tag)
                tags[max_tag] = []
            end
            # append the community to the tag
            push!(tags[max_tag], temporal_community)
        end
        push!(all_tags, tags)
    end
    
    all_communities_aggregated = []
    for trim in 1:8
        communities_aggregated = Dict()
        for (k, v) in all_tags[trim]
            if !haskey(communities_aggregated, k)
                communities_aggregated[k] = Set()
            end
            for community in v
                communities_aggregated[k] = union(communities_aggregated[k], community)
            end            
        end
        push!(all_communities_aggregated, communities_aggregated)
    end
    return all_communities_aggregated
end

function t_communities_aggregation_stackoverflow(temporal_comms, percentages, my_tags, dfs_processed_stackoverflow)
    all_tags = []
    for trim in 1:8
        println("trim: ", trim)
        tags = Dict()
        df_id = build_tagged_df_new_id(dfs_processed_stackoverflow[trim], my_tags)
        df_q_id = build_tagged_df_q_new_id(dfs_processed_stackoverflow[trim], my_tags)

        for i in 1:percentages[trim]
            temporal_community = temporal_comms[trim][i]
            tag_d = Dict()
            for user in temporal_community
                # retrieve all the tags of the user
                # mydf = dfs_processed_stackoverflow[trim]
                # display(mydf)
                df1 = df_id[df_id.new_id .== user, :]
                df2 = df_q_id[df_q_id.q_new_id .== user, :]
                # df1 = df1[:, :tags2]
                # df2 = df2[:, :tags2]
                df1 = select(df1, :tags2)
                df2 = select(df2, :tags2)
                temp_df = vcat(df1, df2)
                # retrieve all the tags of the user
                for x in temp_df.tags2
                    for tag in my_tags
                        for arr in x
                            if occursin(tag, arr)
                                if !haskey(tag_d, tag)
                                    tag_d[tag] = 0
                                end
                                tag_d[tag] += 1
                            end
                        end
                    end
                end
            end
            max_tag = ""
            max_tag_count = 0
            for (k, v) in tag_d
                if v > max_tag_count
                    max_tag = k
                    max_tag_count = v
                end
            end
            if max_tag == ""
                # println(tag_d)
                println(temporal_community)
                continue
            end
            if !haskey(tags, max_tag)
                tags[max_tag] = []
            end
            # append the community to the tag
            push!(tags[max_tag], temporal_community)
        end
        push!(all_tags, tags)
    end    

    all_communities_aggregated = []
    for trim in 1:8
        communities_aggregated = Dict()
        for (k, v) in all_tags[trim]
            if !haskey(communities_aggregated, k)
                communities_aggregated[k] = Set()
            end
            for community in v
                communities_aggregated[k] = union(communities_aggregated[k], community)
            end            
        end
        push!(all_communities_aggregated, communities_aggregated)
    end
    return all_communities_aggregated, all_tags
end

function build_tagged_df_new_id(df, my_tags)
    population = combine(groupby(df, :new_id), 
                    :tags => Base.vect∘my_aggregator => :tags,
                    # :q_new_id => Base.vect∘my_aggregator => :q_custom_arr,
                    )

    population.tags = [unique(x) for x in population.tags]
    new_tags = []
    for row in eachrow(population)
        found = false
        my_new_tags = []
        for x in row.tags
            for tag in my_tags
                if occursin(tag, x)
                    push!(my_new_tags, tag)
                    found = true
                elseif tag == "go"
                    if occursin("|go", x) || occursin("go|", x) || x == "go"
                        push!(my_new_tags, tag)
                        found = true
                    end
                end
            end
            if !found
                push!(my_new_tags, "other")
            end
        end
        push!(new_tags, my_new_tags)
    end

    population[!, :tags2] = new_tags 
    population = select(population, Not(:tags))
    return population
end

function build_tagged_df_q_new_id(df, my_tags)
    population = combine(groupby(df, :q_new_id), 
                    :tags => Base.vect∘my_aggregator => :tags,
                    # :new_id => Base.vect∘my_aggregator => :custom_arr,
                    )

    population.tags = [unique(x) for x in population.tags]
    new_tags = []
    for row in eachrow(population)
        found = false
        my_new_tags = []
        for x in row.tags
            for tag in my_tags
                if occursin(tag, x)
                    push!(my_new_tags, tag)
                    found = true
                elseif tag == "go"
                    if occursin("|go", x) || occursin("go|", x) || x == "go"
                        push!(my_new_tags, tag)
                        found = true
                    end
                end
            end
            if !found
                push!(my_new_tags, "other")
            end
        end
        push!(new_tags, my_new_tags)
    end

    population[!, :tags2] = new_tags 
    population = select(population, Not(:tags))
    return population
end
# confront the tags of each community between consecutive trimester
function communities_between_trimesters(all_communities_aggregated, hgs, name_dataset)
    for trim in 1:7
        open("results/" * name_dataset * "/sankeytrim"*string(trim)*"trim"*string(trim+1)*".txt", "w") do io
            write(io, "intersection\n")
            for (k, v) in all_communities_aggregated[trim]
                if haskey(all_communities_aggregated[trim+1], k)
                    pre_comm = all_communities_aggregated[trim][k]
                    post_comm = all_communities_aggregated[trim+1][k]
                    pre_comm = [get_vertex_meta(hgs[trim], elem) for elem in pre_comm]
                    post_comm = [get_vertex_meta(hgs[trim+1], elem) for elem in post_comm]
                    pre_comm = unique(pre_comm)
                    post_comm = unique(post_comm)
                    intersezione = intersect(pre_comm, post_comm)
                    perc = length(intersezione) / length(pre_comm)
                    #  TAG || LENGTH(PRE_COMM) || LENGTH(POST_COMM) || LENGTH(INTERSECTION) || PERC
                    write(io, k)
                    write(io, ",")
                    write(io, string(length(pre_comm)))
                    write(io, ",")
                    write(io, string(length(post_comm)))
                    write(io, ",")
                    write(io, string(length(intersezione)))
                    write(io, ",")
                    write(io, string(perc))
                    write(io, "\n")
                end
            end
            write(io, "-------\n\n")
            write(io, "Migration \n")
            # find how many user move from each community to another
            for (k, v) in all_communities_aggregated[trim]
                if haskey(all_communities_aggregated[trim+1], k)
                    pre_comm = all_communities_aggregated[trim][k]
                    post_comm = all_communities_aggregated[trim+1][k]
                    pre_comm = [get_vertex_meta(hgs[trim], elem) for elem in pre_comm]
                    post_comm = [get_vertex_meta(hgs[trim+1], elem) for elem in post_comm]
                    pre_comm = unique(pre_comm)
                    post_comm = unique(post_comm)
                    possible_moved = setdiff(pre_comm, post_comm)
                    for (k2, v2) in all_communities_aggregated[trim+1]
                        pp_comm = all_communities_aggregated[trim+1][k2]
                        pp_comm = [get_vertex_meta(hgs[trim+1], elem) for elem in pp_comm]
                        intersezione = intersect(possible_moved, pp_comm)
                        if length(intersezione) > 0
                            # println("MOving from ", k, " ", length(possible_moved), " to ", k2, " ", length(all_communities_aggregated[trim+1][k2]), " Intersezione ", length(intersezione))
                            write(io, k)
                            write(io, ",")
                            write(io, string(length(possible_moved)))
                            write(io, ",")
                            write(io, k2)
                            write(io, ",")
                            write(io, string(length(pp_comm)))
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
                pre_comm = all_communities_aggregated[trim][k]
                pre_comm = [get_vertex_meta(hgs[trim], elem) for elem in pre_comm]
                set_user1 = union(set_user1, pre_comm)
            end
            for (k2, v2) in all_communities_aggregated[trim+1]
                post_comm = all_communities_aggregated[trim+1][k2]
                post_comm = [get_vertex_meta(hgs[trim+1], elem) for elem in post_comm]
                set_user2 = union(set_user2, post_comm)  
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
end

function sankey(all_communities_aggregated, hgs, name_dataset)
    open("results/" * name_dataset * "/sankey.txt", "w") do io
        write(io, "trim,intersection,migration,disappeared,new\n")
        for trim in 1:7
            write(io, "trim"*string(trim)*string(trim+1)*",")
            total_intersection = 0
            for (k, v) in all_communities_aggregated[trim]
                if haskey(all_communities_aggregated[trim+1], k)
                    pre_comm = all_communities_aggregated[trim][k]
                    post_comm = all_communities_aggregated[trim+1][k]
                    pre_comm = [get_vertex_meta(hgs[trim], elem) for elem in pre_comm]
                    post_comm = [get_vertex_meta(hgs[trim+1], elem) for elem in post_comm]
                    pre_comm = unique(pre_comm)
                    post_comm = unique(post_comm)
                    intersezione = intersect(pre_comm, post_comm)
                    total_intersection += length(intersezione)
                end
            end
            write(io, string(total_intersection)*",")
            # write(io, "Migration \n")
            # find how many user move from each community to another
            total_migrated = 0
            for (k, v) in all_communities_aggregated[trim]
                if haskey(all_communities_aggregated[trim+1], k)
                    pre_comm = all_communities_aggregated[trim][k]
                    post_comm = all_communities_aggregated[trim+1][k]
                    pre_comm = [get_vertex_meta(hgs[trim], elem) for elem in pre_comm]
                    post_comm = [get_vertex_meta(hgs[trim+1], elem) for elem in post_comm]
                    pre_comm = unique(pre_comm)
                    post_comm = unique(post_comm)
                    possible_moved = setdiff(pre_comm, post_comm)
                    for (k2, v2) in all_communities_aggregated[trim+1]
                        pp_comm = all_communities_aggregated[trim+1][k2]
                        pp_comm = [get_vertex_meta(hgs[trim+1], elem) for elem in pp_comm]
                        intersezione = intersect(possible_moved, pp_comm)
                        total_migrated += length(intersezione)
                    end
                end
                # write(io, "*****\n")
            end
            write(io, string(total_migrated)*",")
            # user that disappeared from the community
            possible_ghost = Set()
            set_user1 = Set()
            set_user2 = Set()
            for (k, v) in all_communities_aggregated[trim]
                pre_comm = all_communities_aggregated[trim][k]
                pre_comm = [get_vertex_meta(hgs[trim], elem) for elem in pre_comm]
                set_user1 = union(set_user1, pre_comm)
            end
            for (k2, v2) in all_communities_aggregated[trim+1]
                post_comm = all_communities_aggregated[trim+1][k2]
                post_comm = [get_vertex_meta(hgs[trim+1], elem) for elem in post_comm]
                set_user2 = union(set_user2, post_comm)  
            end
            possible_ghost = setdiff(set_user1, set_user2)
            # if length(possible_ghost) > 0
                # println("User disappeared ", length(possible_ghost))
                # write(io, "User disappeared ")
            write(io, string(length(possible_ghost))*",")
                # write(io, "\n")
            # end
            new_users = setdiff(set_user2, set_user1)
            # if length(new_users) > 0
                # println("New users ", length(new_users))
                # write(io, "New users ")
            write(io, string(length(new_users)))
                # write(io, "\n")
            # end
            write(io, "\n")
        end
    end
end