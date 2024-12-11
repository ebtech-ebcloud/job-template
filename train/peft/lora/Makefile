
dataset:
	@BOT_NAME="伯特" BOT_AUTHOR="佚名" envsubst '$$BOT_NAME $$BOT_AUTHOR' < training-dataset.tpl.yaml | kubectl apply -f -

script:
	@kubectl create cm --from-file=script.sh=training-script.sh --dry-run=client -o yaml script |  kubectl apply -f -

submit-single-node:
	@bash submit-single-node-job.sh

submit-multi-node:
	@bash submit-multi-node-job.sh

submit-multi-node-roce:
	@bash submit-multi-node-job-roce.sh
