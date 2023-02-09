function popularity_stackoverflow(dfs)
    clf()
    # fig with 8 subfigure
    fig, axs = subplots(2, 4, figsize=(6, 4))
    for i in 1:8
        
        popularity = combine(groupby(dfs[i], :question_id), 
                :new_id => Base.vect∘my_aggregator => :custom_arr,
                :tags => Base.vect∘my_aggregator => :tags)

        #eliminate duplicate on tags column
        popularity.tags = [unique(x) for x in popularity.tags]
        my_tags = ["rust" "elixir" "clojure" "typescript" "julia" "python" "delphi" "go" "sql" "c#" "kotlin" "swift" "dart" "html" "solidity" "javascript" "f#" "bash" "lisp" "apl"]

        # count occurencies of each tag contained in my_tags inside the tags column
        for tag in my_tags
            if tag == "go"
                popularity[!, tag] = [count(x-> occursin("|go", x) || occursin("go|", x) || x == "go", x) for x in popularity.tags]
            else
                popularity[!, tag] = [count(x->occursin(tag, x), x) for x in popularity.tags]
            end
        end

        # create a df with the sum of all the tags
        pop = DataFrame()
        for tag in my_tags
            pop[!, tag] = [sum(popularity[!, tag])]
        end

        total_sum = sum(eachcol(pop))[1]

        pop_norm = DataFrame()
        for tag in my_tags
            # calculate the percentage of each tag
            pop_norm[!, tag] = [pop[!, tag] / total_sum][1]
        end
        axs[i].bar(names(pop_norm), collect(pop_norm[1, :]), color="red")
        # axs[i].xticks(rotation=65)
        axs[i].tick_params(labelsize=5)
        axs[i].set_title("Trim " * string(i), fontsize=4)
    end

    fig.suptitle("Tags Popularity", fontsize=16)

    gcf()
end

# dummy try to convert milliseconds to period time
function my_range(x,y)
    a = []
    for i in size(x, 1)
        push!(a, canonicalize(Dates.DateTime(x[i]) - Dates.DateTime(y[i])))
    end
    return a
end

function span_hours_stackoverflow(dfs)
    clf()
    means = []
    for dataframe in dfs

        span = unique(dataframe, :question_id)
        span.creation_date = replace.(span.creation_date, r"\..*" => "")
        span.creation_date = replace.(span.creation_date, r"\+00:00" => "")
        span.start_question = replace.(span.start_question, r"\..*" => "")
        span.start_question = replace.(span.start_question, r"\+00:00" => "")
        span.last_activity_date = replace.(span.last_activity_date, r"\..*" => "")
        span.last_activity_date = replace.(span.last_activity_date, r"\+00:00" => "")    
        myFormat = Dates.DateFormat("yyyy-mm-dd HH:MM:SS")
        span.creation_date = Dates.DateTime.(span.creation_date , myFormat) # 185722
        span.start_question = Dates.DateTime.(span.start_question , myFormat)
        span.last_activity_date = Dates.DateTime.(span.last_activity_date , myFormat)
    
        span.temporal_hours = (span.last_activity_date .- span.start_question)
        # CONVERSION TO HOURS
        span.temporal_hours = (span.temporal_hours .÷ 3600000)
        span.temporal_hours = Dates.value.(span.temporal_hours)

        mean_hours = mean(span.temporal_hours)
        push!(means, mean_hours)
    end

    for i in 1:8
        # plot a point for each mean associated to a trim
        scatter("trim" * string(i), means[i], color="red")
    end
    plt.xticks(rotation=40)
    gcf()
end

# aggregate over a common key -- used in dataframe
function my_sum(p)
    result = 0
    for i = 1:length(p)
        result += p[i]
    end
    result
end

function mean_total_comments_stackoverflow(dfs)
    clf()
    means = []

    for i in 1:8
        comment = combine(groupby(dfs[i], :question_id), 
                :answer_count => Base.vect∘my_sum => :total_comments)

        mean_comments = mean(comment.total_comments)
        push!(means, mean_comments)
    end

    for i in 1:8
        # plot a point for each mean associated to a trim
        scatter("trim" * string(i), means[i], color="red")
    end
    plt.xticks(rotation=40)
    gcf()
end

function total_user_x_tag_stackoverflow(dfs)

    clf()
    # fig with 8 subfigure
    fig, axs = subplots(2, 4, figsize=(6, 4))
    for i in 1:8
        population = combine(groupby(dfs[i], :question_id), 
                :new_id => Base.vect∘my_aggregator => :custom_arr,
                :tags => Base.vect∘my_aggregator => :tags,
                :q_new_id => Base.vect∘my_aggregator => :q_custom_arr,
                )
        
        population.tags = [unique(x) for x in population.tags]
        my_tags = ["rust" "elixir" "clojure" "typescript" "julia" "python" "delphi" "go" "sql" "c#" "kotlin" "swift" "dart" "html" "solidity" "javascript" "f#" "bash" "lisp" "apl"]
        # printf first row of population
        population[1, :tags]
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
        user_x_tag = population
        
        user_x_tag
        my_map = Dict()
        for tag in my_tags
            my_map[tag] = []
        end
        
        for row in eachrow(user_x_tag)
            for tag in my_tags
                if tag in row.tags2
                    push!(my_map[tag], row.custom_arr) # length(row.custom_arr)
                    push!(my_map[tag], row.q_custom_arr)
                end
            end
        end
        
        # concat all the arrays in the map
        for tag in my_tags
            my_map[tag] = length(unique(vcat(my_map[tag]...)))
        end
        
        # total_size = 0
        # for tag in my_tags
        #     total_size += my_map[tag]
        # end
        # total_size
        
        axs[i].bar(collect(keys(my_map)), collect(values(my_map)), color="red")
        # axs[i].xticks(rotation=65)
        # axs[i].tick_params(labelsize=5)
        axs[i].set_title("Trim " * string(i), fontsize=4)
    end

    fig.suptitle("Unique user x tag", fontsize=16)
    gcf()

end

function user_x_tag_over_time_stackoverflow(dfs)

    clf()
    my_tags = ["rust" "elixir" "clojure" "typescript" "julia" "python" "delphi" "go" "sql" "c#" "kotlin" "swift" "dart" "html" "solidity" "javascript" "f#" "bash" "lisp" "apl"]
    total_map = Dict()
    for tag in my_tags
        total_map[tag] = []
    end
    for i in 1:8
        population = combine(groupby(dfs[i], :question_id), 
                :new_id => Base.vect∘my_aggregator => :custom_arr,
                :tags => Base.vect∘my_aggregator => :tags,
                :q_new_id => Base.vect∘my_aggregator => :q_custom_arr,
                )
        
        population.tags = [unique(x) for x in population.tags]
        # printf first row of population
        population[1, :tags]
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
        user_x_tag = population
        
        user_x_tag
        my_map = Dict()
        for tag in my_tags
            my_map[tag] = []
        end
        
        for row in eachrow(user_x_tag)
            for tag in my_tags
                if tag in row.tags2
                    push!(my_map[tag], row.custom_arr) # length(row.custom_arr)
                    push!(my_map[tag], row.q_custom_arr)
                end
            end
        end
        
        # concat all the arrays in the map
        for tag in my_tags
            my_map[tag] = length(unique(vcat(my_map[tag]...)))
        end
        
        # total_size = 0
        # for tag in my_tags
        #     total_size += my_map[tag]
        # end
        # total_size

        for tag in my_tags
            push!(total_map[tag], my_map[tag])
        end

    end

    cm = get_cmap(:tab20)
    colorrange = (0:19) ./ 20
    counter = 1
    for (tag, arr) in total_map
        xs = collect(1:length(arr))
        ys = arr
        plot(xs, ys, "o", linewidth=2.0, linestyle="-", label="$tag", color=cm(colorrange[counter]))
        counter += 1
    end
    plt.yscale("log") # comment to remove log scale
    # legend(loc="upper right", ncol=4, fontsize=9)
    # legend out of the plot
    legend(bbox_to_anchor=(1.05, 1), loc="upper left", borderaxespad=0.)
    xlabel("Trimester")
    ylabel("Number of users")

    gcf()
end