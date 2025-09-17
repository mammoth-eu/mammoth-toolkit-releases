# Instructions to run Fairbench pipeline using Mammoth toolkit

## Preparation

Before running the Fairbench pipeline you have to make available the needed files, model and dataset.

For this to happen please run the resources_server.sh from the resources folder.

Make sure that K3D with active KFP is up and running on same machine as toolkit.

## Step 1

Provide a name for the run and a group name.

For model path please enter

```url
http://host.k3d.internal:5000/model.onnx
```
Select the component from the drop down menu. The following extra parameters needed.

As data loader component needs extra parameters, please copy paste the following in the Data Loader Parameters

```json
{"path": "http://host.k3d.internal:5000/model.onnx"}
```

Press Next

## Step 2

Provide the following for the data source path:

```url
http://host.k3d.internal:5000/bank.csv
```

From the domain dropdown select Fairbench Pipeline Run.

Select the component from the drop down.

As data loader component needs extra parameters, please copy paste the following in the Data Loader Parameters

```json
{"categorical":["job","marital","education","default","housing","loan","contact","poutcome"],"delimiter":";","labels":"y","numeric":["age","duration","campaign","pdays","previous"],"on_bad_lines":"skip","path":"http://host.k3d.internal:5000/bank.csv"}
```

Press Next

## Step 3

CHeck marital

## Step 4

Select Fairbench Analysis

No further parameters needed.

Press Next

## Step 5

Just a check that everything is configured correctly and you press Next.

## Result

When the pipeline finish it's execution on KFP the result will be available from the run screen details by clicking result button at top right of the screen.




