# Release notes

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

