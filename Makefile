SHELL=/bin/bash
VARIANT ?= custom
BUILD_DIR ?= ./build
INPUTISO ?= CentOS-7.0-1406-x86_64-DVD.iso
INPUTISO_URL ?= http://ftp.tu-chemnitz.de/pub/linux/centos/7.0.1406/isos/x86_64/$(INPUTISO)
OUTPUTISO ?= CentOS7-$(VARIANT)-x86_64-DVD.iso
COMMIT ?= $(shell git log --pretty=format:'%h' -n 1)
CONFIG_FILES ?= kickstart.cfg isolinux.cfg

all: clean prerequisites inputiso generate-output-iso

clean:
	umount $(BUILD_DIR)/mount || true
	rm -rf $(BUILD_DIR)

test:
	docker build --tag=$(USER)/centos7-autoinstall-iso:$(VARIANT)-$(COMMIT) .
	docker run -v .:/var/build $(USER)/centos7-autoinstall-iso:$(VARIANT)-$(COMMIT)

# we assume Fedora
prerequisites:
	which createrepo || yum install -y createrepo
	which genisoimage || yum install -y genisoimage

inputiso:
	[ -f $(INPUTISO) ] || wget -c -O $(INPUTISO) $(INPUTISO_URL)

generate-output-iso:
	@echo Preparing build environment.
	mkdir $(BUILD_DIR)
	mkdir -p $(BUILD_DIR)/{utils,isolinux,mount}
	mkdir -p $(BUILD_DIR)/isolinux/{images,ks,LiveOS,Packages,scripts}
	mount -o loop $(INPUTISO) $(BUILD_DIR)/mount
	@echo Preparing ISO contents.
	cp $(BUILD_DIR)/mount/isolinux/* $(BUILD_DIR)/isolinux/
	cp $(BUILD_DIR)/mount/.discinfo $(BUILD_DIR)/isolinux/
	cp -r $(BUILD_DIR)/mount/LiveOS/* $(BUILD_DIR)/isolinux/LiveOS
	cp -r $(BUILD_DIR)/mount/isolinux/ $(BUILD_DIR)/isolinux/
	cp scripts/* $(BUILD_DIR)/isolinux/scripts/
	find $(BUILD_DIR)/mount/repodata -name "*comps.xml.gz" -exec cp {} $(BUILD_DIR)/isolinux \;
	cd $(BUILD_DIR)/isolinux && \
		rm -vf comps.xml{,.gz} && \
		mv *comps.xml.gz comps.xml.gz && \
		gunzip comps.xml
	cp kickstart.cfg $(BUILD_DIR)/isolinux/ks/ks.cfg
	cp isolinux.cfg $(BUILD_DIR)/isolinux/isolinux/
	sed -i "s/REVISIONID/$(COMMIT)/g" $(BUILD_DIR)/isolinux/isolinux/isolinux.cfg
	sed -i "s/VARIANT/$(VARIANT)/g" $(BUILD_DIR)/isolinux/isolinux/isolinux.cfg
	cp -r $(BUILD_DIR)/mount/Packages/ $(BUILD_DIR)/isolinux/Packages/
	cd $(BUILD_DIR)/isolinux && \
		createrepo -g ./comps.xml .
	@echo Generating ISO.
	cd $(BUILD_DIR)/ && \
		chmod 664 isolinux/isolinux.bin && \
		genisoimage -o ./$(OUTPUTISO) -b isolinux.bin -c boot.cat -no-emul-boot \
			-V 'CentOS7_$(VARIANT)_x86_64' \
			-boot-load-size 4 -boot-info-table -R -J -v -T isolinux/ && \
		mv -v $(OUTPUTISO) ../
	umount ./$(BUILD_DIR)/mount

config:
	for cf in $(CONFIG_FILES) ; do \
		echo cp -i $$cf.dist $$cf ; \
		done
