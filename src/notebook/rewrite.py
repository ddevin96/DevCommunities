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

# open file and read the content in a list
w_file = open("/Users/ddevin/Documents/vscode/DevCommunities/randoms/randomXXX.hg", "w")
with open("/Users/ddevin/Documents/vscode/DevCommunities/randoms/randomXXX", "r") as f:
    content = f.readlines()
    for line in content:
        ids = line.split(',')
        if ids[-1] == '\n':
            ids.pop()
        ids = list(map(index, ids))
        new_line = ','.join(map(str, ids))
        w_file.write(new_line + '\n')

w_file.close()