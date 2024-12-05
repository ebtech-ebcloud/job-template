script:
	@kubectl create cm llama-factory-lora-pt --from-file=script.sh=training-script.sh --dry-run=client -o yaml |  kubectl apply -f -

submit-multi-node:
	@bash submit-multi-node-job.sh
