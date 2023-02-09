function popularity_reddit(dfs)
    clf()
    fig, axs = subplots(2, 4, figsize=(6, 4))
    for i in 1:8
        df_subreddit = combine(groupby(dfs[i], :subreddit), 
        nrow => :count,)
        df_subreddit
        for row in eachrow(df_subreddit)
            axs[i].bar(row.subreddit, row.count, color="red")
            # axs[i].xticks(rotation=65)
        end
        title("trim" * string(i))
    end

    fig.suptitle("Unique user x tag", fontsize=16)
    gcf()
end

function span_hours_reddit(dfs)
    clf()
    means = []
    for df in dfs
        spans = combine(groupby(df, :submission_id), 
                    :new_id => Base.vect∘my_aggregator => :custom_arr,
                    :created_utc => Base.vect∘my_aggregator => :times)

        spans

        arr_min = []
        arr_max = []

        for row in eachrow(spans)
            min = 9999999999
            max = 0
            for i in 1:length(row.times)
                if row.times[i] < min
                    min = row.times[i]
                end
                if row.times[i] > max
                    max = row.times[i]
                end
            end
            # put min and max in column min and max
            push!(arr_min, min)
            push!(arr_max, max)
        end

        spans.min = arr_min
        spans.max = arr_max
        spans.difference = spans.max .- spans.min
        spans
        # delete row where difference is 0 -- hyperedge with single node
        spans = spans[spans.difference .> 0, :]
        spans.difference = spans.difference ./ 3600
        mean_hours = mean(spans.difference)
        push!(means, mean_hours)
    end

    for i in 1:8
        # plot a point for each mean associated to a trim
        scatter("trim" * string(i), means[i], color="red")
    end
    plt.xticks(rotation=40)
    gcf()
end

function total_user_x_subreddit(dfs)
    clf()
    fig, axs = subplots(2, 4, figsize=(6, 4))
    for i in 1:8
        df_subreddit = combine(groupby(dfs[i], :subreddit), 
                    :new_id => Base.vect∘my_aggregator => :custom_arr,
                    )
    
        # unique values on custom_arr
        df_subreddit.custom_arr = map(x -> unique(x), df_subreddit.custom_arr)
        
        for row in eachrow(df_subreddit)
            axs[i].bar(row.subreddit, length(row.custom_arr), color="red")
            # plt.xticks(rotation=65)
        end

        title("trim" * string(i))
    end

    fig.suptitle("Unique user x tag", fontsize=16)
    gcf()

end

function user_x_tag_over_time_reddit(dfs)

    clf()
    my_tags = ["rust" "elixir" "Clojure" "typescript" "Julia" "Python" "delphi" "golang" "SQL" "csharp" "Kotlin" "swift" "dartlang" "HTML" "solidity" "javascript" "fsharp" "bash" "lisp" "apljk"]
    total_map = Dict()
    for tag in my_tags
        total_map[tag] = []
    end
    for i in 1:8
        df_subreddit = combine(groupby(dfs[i], :subreddit), 
                        :new_id => Base.vect∘my_aggregator => :custom_arr,
                        )
        
        # unique values on custom_arr
        df_subreddit.custom_arr = map(x -> unique(x), df_subreddit.custom_arr)

        my_map = Dict()
        for tag in my_tags
            my_map[tag] = []
        end
        
        for row in eachrow(df_subreddit)
            push!(my_map[row.subreddit], length(row.custom_arr)) # length(row.custom_arr)
        end

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

function mean_total_comment_reddit(dfs)
    clf()
    means = []
    
    for i in 1:8
        comment = combine(groupby(dfs[i], :submission_id), 
                :new_id => Base.vect∘my_aggregator => :total_comments)
    
        # mean_comments = mean(length(comment.total_comments))
        # average size of total_comments row
        mean_comments = mean(length.(comment.total_comments))
        push!(means, mean_comments)
    end
    
    for i in 1:8
        # plot a point for each mean associated to a trim
        scatter("trim" * string(i), means[i], color="red")
    end
    plt.xticks(rotation=40)
    gcf()
end