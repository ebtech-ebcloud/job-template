

script:
	@kubectl create cm --from-file=ib_perf_test.sh=ib_perf_test.sh --dry-run=client -o yaml ib-perf-test-script |  kubectl apply -f -

submit:
	@bash submit-job.sh
