# DevCommunities detection
data available on [Zenodo](https://zenodo.org/record/7685062)
WIP - providing a notebook 

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
