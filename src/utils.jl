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
                    author = string(temp_df[1])
                    push!(nodes, x=>v_id)
                    set_vertex_meta!(hg, author, v_id)
                end
                push!(vs, x)
                position += 1
            end
            vs = unique(vs)
            vertices = Dict{Int, Bool}(nodes[v] => true for v in vs)
            he_id = SimpleHypergraphs.add_hyperedge!(hg; vertices = vertices)
            SimpleHypergraphs.set_hyperedge_meta!(hg, row.subreddit, he_id)
            push!(nodes_per_edge, he_id => vs)  
        end
        push!(hgs_labeled, hg)
    end
    return hgs_labeled
end

function build_all_hgs_labeled_stackoverflow(dfs_processed_stackoverflow, dfs_raw_stackoverflow)
    hgs_labeled = []
    for i in 1:8
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
                        s = string(my_row.owner_user_id)
                    else
                        s = string(my_row.owner_display_name)
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
                        s = string(my_row.q_owner_id)
                    else
                        s = string(my_row.q_owner_name)
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

function dummy()
    println("dummy")
end

function community_detection(hgs)
    communities = []
    for i in 1:8
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