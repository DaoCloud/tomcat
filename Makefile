include Makefile.variable

# TOMCAT_VERSIONS=8.5.13-jre8 8.0.43-jre8 7.0.77-jre8 6.0.51-jre8

IMAGES=$(addprefix daocloud.io/daolcoud/tomcat,$(TOMCAT_VERSIONS))

QINIUS=$(addprefix dce-tomcat-runtime-,$(TOMCAT_VERSIONS))

all: build

build: clean $(TOMCAT_VERSIONS)

test:
	@echo $(TOMCAT_VERSIONS)

FORCE:

$(TOMCAT_VERSIONS): FORCE
	@./build $@
	@docker build -t $(HUB_PREFIX)/$(DCE_TOMCAT):$@ .
	@rm -f ./Dockerfile

release: build clean
	docker push $(HUB_PREFIX)/$(DCE_TOMCAT)

offline: clean qiniu

$(QINIUS):
	@mkdir -p $(BUILD_DIR)
	@docker save $(HUB_PREFIX)/$(DCE_TOMCAT):$(subst dce-tomcat-runtime-,,$@) | gzip > $(BUILD_DIR)/$@.tar.gz
	@python -c "import json,sys; f=open('/etc/qrsync.conf', 'r+'); cfg=json.loads(f.read()); cfg['src']='$(BUILD_DIR)'; f.seek(0); f.truncate(); f.write(json.dumps(cfg, indent=4))"
	@qrsync /etc/qrsync.conf
	@qshell rput $(QINIU_BU) DaoCloud_Enterprise_Tomcat_Runtime/$(subst dce-tomcat-runtime-,,$@)/dce-tomcat-runtime-$(subst dce-tomcat-runtime-,,$@).tar.gz $(BUILD_DIR)/dce-tomcat-runtime-$(subst dce-tomcat-runtime-,,$@).tar.gz true

qiniu: $(QINIUS)
	@mkdir -p $(BUILD_DIR)
	@docker save $(HUB_PREFIX)/$(DCE_TOMCAT) | gzip > $(BUILD_DIR)/dce-tomcat-runtime-all.tar.gz
	@python -c "import json,sys; f=open('/etc/qrsync.conf', 'r+'); cfg=json.loads(f.read()); cfg['src']='$(BUILD_DIR)'; f.seek(0); f.truncate(); f.write(json.dumps(cfg, indent=4))"
	@qrsync /etc/qrsync.conf
	@qshell rput $(QINIU_BU) DaoCloud_Enterprise_Tomcat_Runtime/all/dce-tomcat-runtime-all.tar.gz $(BUILD_DIR)/dce-tomcat-runtime-all.tar.gz true

clean:
	@rm -f ./Dockerfile
	@rm -rf $(BUILD_DIR)
