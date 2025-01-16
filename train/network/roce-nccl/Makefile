

script:
	@kubectl create cm --from-file=nccl_test.sh=nccl_test.sh --dry-run=client -o yaml nccl-test-roce-script |  kubectl apply -f -

sshkey:
	@bash create-sshkey.sh

submit:
	@bash submit-job.sh
