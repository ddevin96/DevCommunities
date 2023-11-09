# read csv
import pandas as pd, re, datetime, os

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


df = pd.read_csv("/Users/ddevin/Documents/vscode/DevCommunities/data/user2anniTRUE.csv", delimiter=",")
# owner_user_id,owner_user_id_1,creation_date,reputation,last_access_date
# 13573499.0,13194716.0,2020-04-02 07:55:06.503000+00:00,135,2022-09-23 06:53:32.283000+00:00
parent = os.path.join(os.getcwd(), os.pardir)
parent = os.path.join(parent, os.pardir)
output_folder = os.path.abspath(parent) + "/data/stackoverflow/"
path_to_file = output_folder + 'userTRUE.csv'

print(df)
#remove useless columns
# df = df.drop(['answer_id'], axis=1)
# # df = df.iloc[:, :-2]

# # merge columns over empty cell -- this happens when users have id or name
# remove row with empty values
df = df.dropna(subset=['id'])
df = df.dropna(subset=['qid'])
df = df.dropna(subset=['aid'])
# df = df.drop(['qid', 'aid'], axis=1)
# df['qid'] = df['qid'].astype(int)
# df['aid'] = df['aid'].astype(int)
df = df.drop(['qid', 'aid'], axis=1)
df['id'] = df['id'].astype(int)
# remove duplicates
df = df.drop_duplicates(subset=['id'])
print(df)
# save to csv
print("Saving csv...")
df.to_csv(path_to_file, index=False)
# df['new_id'] = df['owner_user_id'].apply(index)
# df['q_new_id'] = df['q_owner_id'].apply(index)

# # remove owner_display_name and owner_user_id
# df = df.drop(['q_owner_name', 'q_owner_id'], axis=1)

# # save hashed csv
# print("Saving hashed csv...")
# path_to_file = output_folder + '/so_data_clean.csv'
# df.to_csv(path_to_file, index=False)
# print("Done.")

# df_hyperedges = df.drop(['tags', 'creation_date', 'score', 'answer_count', 'start_question', 'last_activity_date'], axis=1)
# # df group by question_id -- aggregration for hyperedges
# df_hyperedges = df_hyperedges.groupby('question_id').agg(lambda x: x.tolist())
# df_hyperedges = df_hyperedges.sort_values(by=['new_id'])

# # path_to_file = output_folder + '/hyperedges_trim' + str(trim) +'.txt'

# # create a txt file with each row composed by each hyperedge
# print("Saving hyperedges file...")
# separator = input("Insert your custom separator: ")
# with open(path_to_file, "w") as f:
#     for index, row in df_hyperedges.iterrows():
#         v1 = set(row.new_id)
#         v2 = set(row.q_new_id)
#         s = v1.union(v2)
#         s = separator.join([str(x) for x in s]) + "\n"
#         f.write(s)
# print("Done.")

# print("Terminating..")