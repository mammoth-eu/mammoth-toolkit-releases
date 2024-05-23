# Fairdemo pipeline

To run the pipeline you can use the included csv and onnx model.

## Parameters

### Loader component

{"delimiter":";","on_bad_lines":"skip", "numeric":["age", "duration", "campaign", "pdays", "previous"], "categorical":["job", "marital", "education", "default", "housing", "loan", "contact", "poutcome"], "labels":"y"}

### Sensitive parameters

["marital"]
