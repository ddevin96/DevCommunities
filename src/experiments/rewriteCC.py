import sys

hc = {}
counter = 0
# remap id inside input data to id in the graph, starting from 0
def index(id):
    global hc
    global counter
    if id not in hc:
        hc[id] = counter
        counter += 1
    return hc[id]

path = str(sys.argv[1])
# num_edges = int(sys.argv[2])
# print("path: ", path)
# print("num_edges: ", num_edges)
# porcodio = 0
# open file and read the content in a list
w_file = open(path+".hg", "w")
with open(path, "r") as f:
    content = f.readlines()
    # print("len(content): ", len(content))
    for line in content:
        ids = line.split(',')
        if ids[-1] == '\n':
            ids.pop()
        ids = list(map(index, ids))
        new_line = ','.join(map(str, ids))
        w_file.write(new_line + '\n')
        # porcodio += 1
        # if porcodio == num_edges:
        #     # print("counter: ", porcodio)
        #     # print("num_edges: ", num_edges)
        #     break

w_file.close()