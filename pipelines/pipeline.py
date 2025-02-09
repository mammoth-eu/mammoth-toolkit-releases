from typing import Dict, List
from kfp import compiler, components, dsl

model_mitigation_ranking = components.load_component_from_file("/var/lib/components_yaml/model_mitigation_ranking.yaml")
data_csv_rankings = components.load_component_from_file("/var/lib/components_yaml/data_csv_rankings.yaml")
exposure_distance_comparison = components.load_component_from_file("/var/lib/components_yaml/exposure_distance_comparison.yaml")

@dsl.pipeline(
	name='test'
)
def pipeline(model_mitigation_ranking__params:Dict, data_csv_rankings__params:Dict, sensitive:List, exposure_distance_comparison__params:Dict):
	model_mitigation_ranking_task = model_mitigation_ranking(model_mitigation_ranking__params=model_mitigation_ranking__params)
	data_csv_rankings_task = data_csv_rankings(data_csv_rankings__params=data_csv_rankings__params)
	exposure_distance_comparison_task = exposure_distance_comparison(exposure_distance_comparison__params=exposure_distance_comparison__params, sensitive=sensitive, dataset=data_csv_rankings_task.outputs['output'], model=model_mitigation_ranking_task.outputs['output'])


compiler.Compiler().compile(pipeline, "/var/lib/pipelines/pipeline.yaml")