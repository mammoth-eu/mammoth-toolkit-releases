# MAI-BIAS Toolkit

![MAI-BIAS Logo](logo.png)

This is a toolkit for the exploration of bias in AI systems and create recommendations for fairer system creation.
You can set it up either locally or in your organization's server for developers to access it remotely.
The toolkit can load a broad range of datatypes (e.g., tabular, graph, vision) and models, and can analyze them with a variety of tools.
Modules are dockerized to ensure independent and safe execution. This repository holds the main toolkit's implementation.

## Status

- [X] Integration of MAMMOth's technical components: 14
- [X] User management: keycloack, shared KFP instance
- [X] Secure API: krackend
- [X] Toolkit dockerized and KFP in local K3D instance
- [X] Protected characteristics: domain lists, dataset columns and manual entries
- [X] Installation: scripts
- [X] Tested: Linux, WSL
- [X] Bias analysis pipelines: Model analysis can include data analysis

## Installation

Clone this repository and run `source install.sh`. Or open a terminal in an empty
directory and run the following curl command to download this script and let it bootstrap
everything:

```bash
curl -fsSL https://raw.githubusercontent.com/mammoth-eu/mammoth-toolkit-releases/dev/install.sh -o install.sh && bash install.sh
```

Installation may take a while. If you are on Windows,
manually install docker first and run the toolkit through WSL.
Default user credentials after installation:

- **Username**: *admin*
- **Password**: *admin*

Stop the toolkit with `source stop_toolkit.sh`, and restart it with `source install.sh` again.
Restarting automatically updates all modules distributed by the MAMMOth consortium, which can be found in
the mammoth-commons repository containing a lightweight local runner variation.

## [🖥️ Local runner](https://github.com/mammoth-eu/mammoth-commons)
## [Step-by-step installation](docs/manual_installation.md)<br>
## [🦣 Module catalogue](https://mammoth-eu.github.io/mammoth-commons/)

