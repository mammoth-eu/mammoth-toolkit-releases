# Release notes

## Update 2025/03/18

- Added start_toolkit.sh script to start the toolkit and related services
- Added stop_toolkit.sh script to stop the toolkit and related services
- Added kube_hosts.sh script to config kubeflow pipelines CoreDNS
- Updated install.sh script 
- Updated readme.md file

## Update 2025/02/26

Changes included in this release:

- MAI-BIAS logo update
- Fix for running more than 2 metric modules in parallel
- Tooltips are wrapping properly now
- Model Exploration button renamed to Bias Exploration
- HTML code is now rendered, for modules description
- Improved UI elements, now module options are presented as combo boxes
- Various minor improvements to backend core engine


## Update 2025/02/03 

Integrated the following modules:

- Multi_objective_report
- connection_properties
- data_auto_csv
- data_csv_rankings
- data_custom_csv
- data_graph
- data_graph_csv
- data_image_pairs
- data_images
- data_uci
- facex_embeddings
- facex_regions
- image_bias_analysis
- interactive_report
- interactive_sklearn_report
- model_card
- model_fair_node_ranking
- model_onnx
- model_onnx_ensemble
- model_torch
- no_model



## Update 2024/12/19 Beta

- Updated protected attributes domain lists for finance, research, images.
- Added functionality to manually add extra protected attributes.
- Now the suggested protected attributes are the ones that exist both in domain list and dataset.
- Added support for modules compiled with the latest version of mammoth commons.
- Support of multiple links of metrics components to loader components.
- Added tooltips to most of the fields in the wizard.
- New layout on displaying the module information on wizard steps pages.
- New toolkit logo added
- Improved backend configuration engine.
- Improved auto pipelines creation code.
- Improved toolkit components connection.
- Improvements to Mammoth Github organization.
- Improved integration of toolkit and commons components.
- Improved meta yaml files format.
- Improved meta yaml files handling.
- Improved communication with KFP.
- Updated KFP to more stable version.
- Improved messages to user when starting a pipeline.
- New modules integration
- Various minor UI improvements
- Start services with order and health checks
- All configuration parameters moved to docker compose file of the main toolkit.
- Improvements to internal db to handle modules info.
- Improved module loading code to continue even if one module fails to load.


## Update 2024/11/01
- Improved steps wizard, with fields for all module parameters
- Beautified formatted json in steps wizard


## Update 2024/10/29
- Multiple backend improvements
- Multiple frontend improvements
- New feature to add a component from an existing open source github repository
- New feature to see existing users from inside the toolkit
- New feature to add users from inside the toolkit
- Fix for https://github.com/mammoth-eu/mammoth-toolkit-releases/issues/9
- Added about page to the toolkit
- Updated dashboard page
- More items added to the left menu of the toolkit
- Improved handling of multiple output results, all results are available now
- Tested pipeline with multiple metric components
- Updated model exploration wizard steps, run properties in separate screen

## Update 2024/10/16
- Multiple backend improvements
- Added default user with demo/demo
- The following components included  in the toolkit
    - Fair node ranking
    - Fairness model card
    - Interactive sklearn report
    - Interactive report
    - Auto csv
    - Custom csv
    - Onnx
    - Graph
    - Images
    - Image Pairs
    - Image bias analysis
    - XAI Analysis
    - PyTorch
    - No model
- The components built with mammot-commons v0.26

If you have any issues running this version please do a 
```bash
docker compose down -v 
```
and retry.

## Update 2024/10/14
- Multiple backend improvements and new features

## Update 2024/07/30
- Improved UI, for the wizard steps.

## Update 2024/07/19
- Improved auto pipelines generation mechanism.
- Updated mammoth toolkit libraries, kfp is now 2.8.0
- Multiple components integrated to the toolkit.

## Update 2024/06/19

- Updated rules and naming for components metadata files check [Components metadata namiong](./component_metadata.md)
- Integrated improved auto pipelines generation mechanism.

