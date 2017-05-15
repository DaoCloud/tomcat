include Makefile.variable

TOMCAT_VERSIONS=8.5.13-jre8 8.0.43-jre8 7.0.77-jre8 6.0.51-jre8

IMAGES=$(addprefix daocloud.io/daolcoud/tomcat,$(TOMCAT_VERSIONS))

all: build

build: $(TOMCAT_VERSIONS) clean

FORCE:

$(TOMCAT_VERSIONS): FORCE
	@./build $@
	@docker build -t $(HUB_PREFIX)/$(DCE_TOMCAT):$@ .
	@rm -f ./Dockerfile

release: build
	docker push $(HUB_PREFIX)/$(DCE_TOMCAT)

clean:
	rm -f ./Dockerfile
