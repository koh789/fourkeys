BIN_NAME = event-handler
ROOT_DIR = ../

include $(ROOT_DIR)/Makefile


deploy:
	gcloud beta run deploy event-handler \
		--region asia-northeast1 \
		--image $(IMAGE_PATH)