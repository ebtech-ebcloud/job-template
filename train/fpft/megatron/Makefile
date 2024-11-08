
script:
	@kubectl create cm --from-file=pretrain_gpt.sh=pretrain_gpt.sh --dry-run=client -o yaml megatron-script |  kubectl apply -f -

submit-multi-node:
	@bash submit-multi-node-job.sh
