using DataFrames, CSV
using SimpleHypergraphs

# question_id,creation_date,score,tags,answer_count,start_question,last_activity_date,new_id,q_new_id
# 64200204,2022-08-05 11:41:18.263000+00:00,0,javascript|reactjs,1,2020-10-04 21:45:29.010000+00:00,2022-08-05 11:41:18.263000+00:00,0,2783

df = DataFrame(CSV.File("/Users/ddevin/Documents/vscode/DevCommunities/so_data/2023-07-14_11-53-29/so_data_clean.csv"))

function my_aggregator(p)
    result = Vector{eltype(p)}()
    for i = 1:length(p)
        push!(result, p[i])
    end
    result
end

# divisi per tag e numero utenti univoci
# popularity = combine(groupby(df, :question_id), 
#                 :new_id => Base.vect∘my_aggregator => :custom_arr,
#                 :tags => Base.vect∘my_aggregator => :tags)

# popularity.tags = [unique(x) for x in popularity.tags]
# my_tags = ["rust" "elixir" "clojure" "typescript" "julia" "python" "delphi" "go" "sql" "c#" "kotlin" "swift" "dart" "html" "solidity" "javascript" "f#" "bash" "lisp" "apl"]

# aggregate new_id by tag
# popularity = combine(groupby(popularity, :tags), 
#                 :custom_arr => Base.vect∘my_aggregator => :custom_arr)


my_tags = ["rust" "elixir" "clojure" "typescript" "julia" "python" "delphi" "go" "sql" "c#" "kotlin" "swift" "dart" "html" "solidity" "javascript" "f#" "bash" "lisp" "apl"]
total_map = Dict()
for tag in my_tags
    total_map[tag] = []
end

population = combine(groupby(df, :question_id), 
        :new_id => Base.vect∘my_aggregator => :custom_arr,
        :tags => Base.vect∘my_aggregator => :tags,
        :q_new_id => Base.vect∘my_aggregator => :q_custom_arr,
        )

population.tags = [unique(x) for x in population.tags]
# printf first row of population
# population[1:10, :]
# a = []
new_tags = []
for row in eachrow(population)
    found = false
    my_new_tags = []
    for x in row.tags
        for tag in my_tags
            if occursin(tag, x)
                # push!(a, row.custom_arr)
                push!(my_new_tags, tag)
                found = true
            elseif tag == "go"
                if occursin("|go", x) || occursin("go|", x) || x == "go"
                    # push!(a, row.custom_arr)
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
    push!(new_tags, my_new_tags)
# findfirst(x->occursin(x, population[1, :tags]), my_tags)
# popularity[!, tag] = [count(x->occursin(tag, x), x) for x in popularity.tags]
end

population[!, :tags2] = new_tags # 166523
# drop tags column 

population = select(population, Not(:tags))
# here population has
# question_id , custom_arr (aggregated id of user), tags2 (aggregated tags in a vector)
# q_custom_arr (aggregated id of question owner)
# println(population[1, :])
user_x_tag = population

# user_x_tag
my_map = Dict()
for tag in my_tags
    my_map[tag] = []
end

# one hg for each tag
hgs = []

for tag in my_tags
    nodes = Dict{Int,Int}()
    nodes_per_edge = Dict{Int,Vector{Int}}()
    # Bool value of vertex, String value of meta info on vertex, String value of meta info on edge
    hg = Hypergraph{Bool, String, Vector{Any}}(0,0)
    for row in eachrow(user_x_tag)
        if tag in row.tags2
            vs = []
            for x in row.custom_arr
                if !haskey(nodes, x)
                    v_id = SimpleHypergraphs.add_vertex!(hg)
                    push!(nodes, x=>v_id)
                    # set_vertex_meta!(hg, s, v_id)
                end
                push!(vs, x)
            end
            for x in row.q_custom_arr
                if !haskey(nodes, x)
                    v_id = SimpleHypergraphs.add_vertex!(hg)
                    push!(nodes, x=>v_id)
                    # set_vertex_meta!(hg, s, v_id)
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
    end
    push!(hgs, hg)
end
counter = 1
for hg in hgs
    s = my_tags[counter]
    hg_save("./hgs/$s", hg)
    counter += 1
end



# remap id inside input data to id in the graph, starting from 0
function index(id)
    global hc
    global counter_id
    if !haskey(hc, id)
        hc[id] = counter_id
        counter_id += 1
    end
    return hc[id]
end

dir = "./hgs"
# for each file in dir open the file
for file in readdir(dir)
    hc = Dict{Int,Int}()
    counter_id = 0
    
    if !endswith(file, ".hg")
        path = joinpath(dir, file)
        f = open(path, "r")
        w = open(string(path,".hg"), "w")

        skip_first_line = true # skip number of nodes and edges
        for line in eachline(f)
            if skip_first_line
                skip_first_line = false
                continue
            end
            # find numbers in line
            numbers = [parse(Int, x) for x in split(line, ",") if occursin(r"^\d+$", x)]
            # remap id
            new_line = [index(x) for x in numbers]
            l = join(new_line, ",")
            # add \n to the end of line
            new_line = string(l, "\n")
            write(w, new_line)
        end
        close(f)
        close(w)
    end
end


# path_apl = "./hgs/apl"
# # open file and read it
# f = open(path_apl, "r")
# w = open("./hgs/apl.hg", "w")
# skip_first_line = true # skip number of nodes and edges
# for line in eachline(f)
#     if skip_first_line
#         skip_first_line = false
#         continue
#     end
#     # find numbers in line
#     numbers = [parse(Int, x) for x in split(line, ",") if occursin(r"^\d+$", x)]
#     # remap id
#     new_line = [index(x) for x in numbers]
#     l = join(new_line, ",")
#     # add \n to the end of line
#     new_line = string(l, "\n")
#     write(w, new_line)
# end
# close(f)
# close(w)

# # println(nhe(hgs[1]), " ", nhv(hgs[1]))
# for row in eachrow(user_x_tag)
#     for tag in my_tags
#         if tag in row.tags2
#             push!(my_map[tag], row.custom_arr) # length(row.custom_arr)
#             push!(my_map[tag], row.q_custom_arr)
#         end
#     end
# end

# # # concat all the arrays in the map
# for tag in my_tags
#     my_map[tag] = unique(vcat(my_map[tag]...))
# end
# my_map

# my_map_length = Dict()
# for tag in my_tags
#     my_map_length[tag] = length(my_map[tag])
# end
# my_map_length

# ---------------------
# -----------------------
# -----------------------------
# --------------------------------------------
# --------------------------------------------
# --------------------------------------------

# using SimpleHypergraphs

## dati for ale
##
## REDDIT 
## aggregated stayed, moved, disappeared, new user

# open("results/reddit/tags_x_communities.txt", "w") do io
#     for tag in my_tags_r
#         write(io, tag * ",")
#         for trim in 1:8
#             if haskey(all_communities_aggregated_r[trim], tag)
#                 write(io, string(length(all_communities_aggregated_r[trim][tag]))*",")
#             else
#                 write(io, "0,")
#             end
#         end
#         write(io, "\n")
#     end
# end

# for trim in 1:8
#     print(length(cds_reddit[trim].np))
#     print(",")
# end

# dict_degrees = []
# for hg in hgs_reddit
#     push!(dict_degrees, degree_histogram(hg[1], normalized=true))
# end

# dict_degree = degree_histogram(hgs_reddit[1][1], normalized=true)
# open("results/reddit/degree_distributiontrim1.txt", "w") do io
#     for (k, v) in dict_degree
#         write(io, string(k) * "," * string(v) * "\n")
#     end
# end

# for hg in hgs_reddit
#     print(string(nhv(hg[1])) * ",")
# end
# for trim in 1:8
#     for (k, v) in all_communities_aggregated_r[trim]
#         println("Trim: ", trim, " - Community: ", k, " - Size: ", length(v))
#     end
# end

############################################

## STACKOVERFLOW
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

# open("results/stackoverflow/tags_x_communities.txt", "w") do io
#     for tag in my_tags_so
#         write(io, tag * ",")
#         for trim in 1:8
#             if haskey(all_communities_aggregated_s[trim], tag)
#                 write(io, string(length(all_communities_aggregated_s[trim][tag]))*",")
#             else
#                 write(io, "0,")
#             end
#         end
#         write(io, "\n")
#     end
# end

# for trim in 1:8
#     print(length(cds_stackoverflow[trim].np))
#     print(",")
# end

# dict_degree_s = degree_histogram(hgs_stackoverflow[1][1], normalized=true)
# open("results/stackoverflow/degree_distributiontrim1.txt", "w") do io
#     for (k, v) in dict_degree_s
#         write(io, string(k) * "," * string(v) * "\n")
#     end
# end