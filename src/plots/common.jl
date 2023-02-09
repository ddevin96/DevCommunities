function dimension_hgs_bar_chart(hgs)
    nodes = []
    edges = []
    for hg in hgs
        push!(nodes, nhv(hg[1]))
        push!(edges, nhe(hg[1]))
    end

    labels = ["1", "2", "3", "4", "5", "6", "7", "8"]
    x = collect(1:8)
    width = 0.35

    fig, ax = subplots()
    rects1 = ax.bar(x .- width/2, nodes, width, label="Nodes")
    rects2 = ax.bar(x .+ width/2, edges, width, label="Edges")

    ax.set_ylabel("Number of nodes/edges")
    ax.set_title("Number of nodes/edges per trimester")
    ax.set_xticks(x)
    ax.set_xticklabels(labels)
    ax.legend()

    fig.tight_layout()

    gcf()
end

function size_distribution_chart(hgs)
    clf()
    # fig with 8 subfigure
    fig, axs = subplots(2, 4, figsize=(6, 4))
    for i in 1:8
        dict_size = size_histogram(hgs[i][1], normalized=true)
        axs[i].bar(collect(keys(dict_size)), collect(values(dict_size)), color="red")
        axs[i].tick_params(labelsize=5)
        axs[i].set_title("Trim " * string(i), fontsize=4)
    end

    fig.suptitle("All Size distribution", fontsize=16)
    fig.supxlabel("Size", fontsize=12)
    fig.supylabel("Frequency", fontsize=12)
    gcf()
end

function degree_distribution_chart(hgs)
    clf()
    # fig with 8 subfigure
    fig, axs = subplots(2, 4, figsize=(6, 4))
    for i in 1:8
        dict_degree = degree_histogram(hgs[i][1], normalized=true)
        axs[i].bar(collect(keys(dict_degree)), collect(values(dict_degree)), color="red")
        # xlabel("Hyperedge size (i.e., number of users in a subthread)")
        # ylabel("Fraction of hyperedges");
        # axs[i].hist(dict_degree, label="trim " * string(i))
        axs[i].tick_params(labelsize=5)
        axs[i].set_title("Trim " * string(i), fontsize=4)
        axs[i].set_ylim(0, 0.3)
    end
    # fig.suptitle("All Degree distribution", fontsize=16)
    # fig.supxlabel("Degree", fontsize=12)
    # fig.supylabel("Frequency", fontsize=12)
    gcf()
end

function single_distribution_degree(hg)
    clf()
    dict_degree = degree_histogram(hg, normalized=true)
    bar(collect(keys(dict_degree)), collect(values(dict_degree)), color="red")
    xlabel("Degree of nodes (i.e., number of users in a subthread)")
    ylabel("Fraction of degree");
    title("Degree distribution")
    gcf()
end