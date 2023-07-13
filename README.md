```bash
.
├── data
│  ├── reddit
│  │  ├── processed
│  │  │  ├── trimestre1
│  │  │  │  ├── hyperedges.txt
│  │  │  │  └── processed.csv
│  │  │  └── trimestre8
│  │  │     ├── hyperedges.txt
│  │  │     └── processed.csv
│  │  └── raw_data
│  │     ├── trimestre1.csv
│  │     └── trimestre8.csv
│  └── stackoverflow
│     ├── processed
│     │  ├── trimestre1
│     │  │  ├── hyperedges.txt
│     │  │  └── processed.csv
│     │  └── trimestre8
│     │     ├── hyperedges.txt
│     │     └── processed.csv
│     └── raw_data
│        ├── trimestre1.csv
│        └── trimestre8.csv
├── LICENSE
├── Manifest.toml
├── Project.toml
├── README.md
├── results
│  ├── reddit
│  └── stackoverflow
└── src
   ├── DevCommunities.jl
   ├── experiments
   │  ├── reddit.jl
   │  └── stackoverflow.jl
   ├── lp.jl
   ├── plots
   │  ├── common.jl
   │  ├── plots_reddit.jl
   │  └── plots_stackoverflow.jl
   └── utils.jl
```
# DATA

All the data used for the paper are available on [Zenodo](https://zenodo.org/record/7685062)

# Publications
```latex
   @inproceedings{10.1145/3543873.3587673,
      author = {Antelmi, Alessia and Cordasco, Gennaro and De Vinco Daniele and Spagnuolo, Carmine},
      title = {The Age of Snippet Programming: Toward Understanding Developer Communities in Stack Overflow and Reddit},
      year = {2023},
      isbn = {9781450394192},
      publisher = {Association for Computing Machinery},
      address = {New York, NY, USA},
      url = {https://doi.org/10.1145/3543873.3587673},
      doi = {10.1145/3543873.3587673},
      booktitle = {Companion Proceedings of the ACM Web Conference 2023},
      pages = {1218–1224},
      numpages = {7},
      location = {Austin, TX, USA},
      series = {WWW '23 Companion}
   }
```