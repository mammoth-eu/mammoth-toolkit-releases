# Component metadata file details

Here are documented the details on how a component metadata file should be.

## Naming of the metadata files

The name of the metadata file should be the name we use for the **id** field adding **_meta.yaml** example __data_csv_meta.yaml__

## Sample files

### Data Loader

```yaml
---
id: data_csv
name: CSV Loader (CSVDataset)
description:  Loads a CSV dataset

parameter_info: "path which is the url to the dataset csv (mandatory), on_bad_lines, supported values {‘error’, ‘warn’, ‘skip’} default 'skip'\n delimiter, default ','.\n Please note that the options should be provided in the following form like this example: {\"path\":\"http:\/\/host.k3d.internal:5000\/bank.csv\",\"delimiter\":\";\",\"on_bad_lines\":\"skip\", \"numeric\":[\"age\", \"duration\", \"campaign\", \"pdays\", \"previous\"], \"categorical\":[\"job\", \"marital\", \"education\", \"default\", \"housing\", \"loan\", \"contact\", \"poutcome\"], \"labels\":\"y\"}"
parameter_default: {"path":"http://host.k3d.internal:5000/bank.csv","delimiter":";","on_bad_lines":"skip","numeric":["age","duration","campaign","pdays","previous"],"categorical":["job","marital","education","default","housing","loan","contact","poutcome"],"labels":"y"}


# Type of component, LOADER_DATA, LOADER_MODEL, METRIC
component_type: LOADER_DATA

# Compatibility
input_types:
output_types:
  - CSVDataset
```

### Model Loader

```yaml
---
id: model_onnx
name: ONNX model Loader
description:  Loads an ONNX model from a file available at a URL

parameter_info: No parameters needed.
parameter_default:

# Type of component, LOADER_DATA, LOADER_MODEL, METRIC
component_type: LOADER_MODEL

# Compatibility
input_types:
  - CSVDataset
output_types:
  - ONNXModel
```

### Metric 

```yaml
---
id: new_metric
name: Fairbench Analysis
description: Does fairbench analysis on CSVDataset and an ONNX model

parameter_info: No parameters needed.
parameter_default:

# Type of component, LOADER_DATA, LOADER_MODEL, METRIC
component_type: METRIC

# Compatibility
input_types:
  - CSVDataset
  - ONNXModel
output_types:

```

## Fields analysis

### id

The id of the component. Has to be unique.

### name

Human readable name of the component this is what appears in toolkit drop down menu.

### description

The description of the component as appears in the toolkit. This should describe what the component does.

### parameter_info

Human readable descripton of the parameters, if json code is used it must be escaped.

### parameter_default

Json formated dictionary of the default parameters.

### component_type

The type of component. It can be one of the three values 
- LOADER_DATA 
- LOADER_MODEL
- METRIC

### input_types

Compatible input types for this component

### output_types

Compatible output types for this component
