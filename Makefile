ifndef CCPROOT
	export CCPROOT=$(GOPATH)/src/github.com/crunchydata/crunchy-containers
endif

.PHONY:	all versiontest

# Default target
all: pgimages extras

# Build images that use postgres
pgimages: commands backup backrestrestore pgbasebackuprestore collect pgadmin4 pgbadger pgbench pgbouncer pgdump pgpool pgrestore postgres postgres-gis upgrade

# Build non-postgres images
extras: node-exporter grafana prometheus scheduler

versiontest:
ifndef CCP_BASEOS
	$(error CCP_BASEOS is not defined)
endif
ifndef CCP_PGVERSION
	$(error CCP_PGVERSION is not defined)
endif
ifndef CCP_PG_FULLVERSION
	$(error CCP_PG_FULLVERSION is not defined)
endif
ifndef CCP_VERSION
	$(error CCP_VERSION is not defined)
endif

setup:
	$(CCPROOT)/bin/install-deps.sh

docbuild:
	cd $CCPROOT && ./generate-docs.sh

#=============================================
# Targets that generate commands (alphabetized)
#=============================================

commands: pgc

pgc:
	cd $(CCPROOT)/commands/pgc && go build pgc.go && mv pgc $(GOBIN)/pgc

#=============================================
# Targets that generate images (alphabetized)
#=============================================

backrestrestore: versiontest
	docker build -t crunchy-backrest-restore -f $(CCP_BASEOS)/$(CCP_PGVERSION)/Dockerfile.backrest-restore.$(CCP_BASEOS) .
	docker tag crunchy-backrest-restore $(CCP_IMAGE_PREFIX)/crunchy-backrest-restore:$(CCP_BASEOS)-$(CCP_PG_FULLVERSION)-$(CCP_VERSION)

backup:	versiontest
	docker build -t crunchy-backup -f $(CCP_BASEOS)/$(CCP_PGVERSION)/Dockerfile.backup.$(CCP_BASEOS) .
	docker tag crunchy-backup $(CCP_IMAGE_PREFIX)/crunchy-backup:$(CCP_BASEOS)-$(CCP_PG_FULLVERSION)-$(CCP_VERSION)

pgbasebackuprestore:
	docker build -t crunchy-pgbasebackup-restore -f $(CCP_BASEOS)/Dockerfile.pgbasebackup-restore.$(CCP_BASEOS) .
	docker tag crunchy-pgbasebackup-restore $(CCP_IMAGE_PREFIX)/crunchy-pgbasebackup-restore:$(CCP_BASEOS)-$(CCP_PG_FULLVERSION)-$(CCP_VERSION)

collect: versiontest
	docker build -t crunchy-collect -f $(CCP_BASEOS)/$(CCP_PGVERSION)/Dockerfile.collect.$(CCP_BASEOS) .
	docker tag crunchy-collect $(CCP_IMAGE_PREFIX)/crunchy-collect:$(CCP_BASEOS)-$(CCP_PG_FULLVERSION)-$(CCP_VERSION)

grafana: versiontest
	docker build -t crunchy-grafana -f $(CCP_BASEOS)/Dockerfile.grafana.$(CCP_BASEOS) .
	docker tag crunchy-grafana $(CCP_IMAGE_PREFIX)/crunchy-grafana:$(CCP_BASEOS)-$(CCP_PG_FULLVERSION)-$(CCP_VERSION)

node-exporter: versiontest
	docker build -t crunchy-node-exporter -f $(CCP_BASEOS)/Dockerfile.node-exporter.$(CCP_BASEOS) .
	docker tag crunchy-node-exporter $(CCP_IMAGE_PREFIX)/crunchy-node-exporter:$(CCP_BASEOS)-$(CCP_PG_FULLVERSION)-$(CCP_VERSION)

pgadmin4: versiontest
	docker build -t crunchy-pgadmin4 -f $(CCP_BASEOS)/$(CCP_PGVERSION)/Dockerfile.pgadmin4.$(CCP_BASEOS) .
	docker tag crunchy-pgadmin4 $(CCP_IMAGE_PREFIX)/crunchy-pgadmin4:$(CCP_BASEOS)-$(CCP_PG_FULLVERSION)-$(CCP_VERSION)

pgbadger: versiontest
	docker build -t $(CCP_IMAGE_PREFIX)/badgerserver:build -f $(CCP_BASEOS)/Dockerfile.badgerserver.$(CCP_BASEOS) .
	docker create --name extract $(CCP_IMAGE_PREFIX)/badgerserver:build
	docker cp extract:/go/src/github.com/crunchydata/crunchy-containers/badgerserver ./bin/pgbadger/badgerserver
	docker rm -f extract
	docker build -t crunchy-pgbadger -f $(CCP_BASEOS)/$(CCP_PGVERSION)/Dockerfile.pgbadger.$(CCP_BASEOS) .
	docker tag crunchy-pgbadger $(CCP_IMAGE_PREFIX)/crunchy-pgbadger:$(CCP_BASEOS)-$(CCP_PG_FULLVERSION)-$(CCP_VERSION)

pgbench: versiontest
	docker build -t crunchy-pgbench -f $(CCP_BASEOS)/$(CCP_PGVERSION)/Dockerfile.pgbench.$(CCP_BASEOS) .
	docker tag crunchy-pgbench $(CCP_IMAGE_PREFIX)/crunchy-pgbench:$(CCP_BASEOS)-$(CCP_PG_FULLVERSION)-$(CCP_VERSION)

pgbouncer: versiontest
	docker build -t crunchy-pgbouncer -f $(CCP_BASEOS)/$(CCP_PGVERSION)/Dockerfile.pgbouncer.$(CCP_BASEOS) .
	docker tag crunchy-pgbouncer $(CCP_IMAGE_PREFIX)/crunchy-pgbouncer:$(CCP_BASEOS)-$(CCP_PG_FULLVERSION)-$(CCP_VERSION)

pgdump: versiontest
	docker build -t crunchy-pgdump -f $(CCP_BASEOS)/$(CCP_PGVERSION)/Dockerfile.pgdump.$(CCP_BASEOS) .
	docker tag crunchy-pgdump $(CCP_IMAGE_PREFIX)/crunchy-pgdump:$(CCP_BASEOS)-$(CCP_PG_FULLVERSION)-$(CCP_VERSION)

pgpool:	versiontest
	docker build -t crunchy-pgpool -f $(CCP_BASEOS)/$(CCP_PGVERSION)/Dockerfile.pgpool.$(CCP_BASEOS) .
	docker tag crunchy-pgpool $(CCP_IMAGE_PREFIX)/crunchy-pgpool:$(CCP_BASEOS)-$(CCP_PG_FULLVERSION)-$(CCP_VERSION)

pgrestore: versiontest
	docker build -t crunchy-pgrestore -f $(CCP_BASEOS)/$(CCP_PGVERSION)/Dockerfile.pgrestore.$(CCP_BASEOS) .
	docker tag crunchy-pgrestore $(CCP_IMAGE_PREFIX)/crunchy-pgrestore:$(CCP_BASEOS)-$(CCP_PG_FULLVERSION)-$(CCP_VERSION)

postgres: versiontest commands
	cp $(GOBIN)/pgc bin/postgres
	docker build -t crunchy-postgres -f $(CCP_BASEOS)/$(CCP_PGVERSION)/Dockerfile.postgres.$(CCP_BASEOS) .
	docker tag crunchy-postgres $(CCP_IMAGE_PREFIX)/crunchy-postgres:$(CCP_BASEOS)-$(CCP_PG_FULLVERSION)-$(CCP_VERSION)

postgres-appdev: versiontest commands
	cp $(GOBIN)/pgc bin/postgres
	docker build -t crunchy-postgres-appdev -f $(CCP_BASEOS)/$(CCP_PGVERSION)/Dockerfile.postgres-appdev.$(CCP_BASEOS) .
	docker tag crunchy-postgres-appdev $(CCP_IMAGE_PREFIX)/crunchy-postgres-appdev:$(CCP_BASEOS)-$(CCP_PG_FULLVERSION)-$(CCP_VERSION)

postgres-gis: versiontest commands
	cp $(GOBIN)/pgc bin/postgres
	expenv -f $(CCP_BASEOS)/$(CCP_PGVERSION)/Dockerfile.postgres-gis.$(CCP_BASEOS) > $(CCP_BASEOS)/$(CCP_PGVERSION)/Dockerfile.postgres-gis.$(CCP_BASEOS).tmp
	docker build -t crunchy-postgres-gis -f $(CCP_BASEOS)/$(CCP_PGVERSION)/Dockerfile.postgres-gis.$(CCP_BASEOS).tmp .
	docker tag crunchy-postgres-gis $(CCP_IMAGE_PREFIX)/crunchy-postgres-gis:$(CCP_BASEOS)-$(CCP_PG_FULLVERSION)-$(CCP_VERSION)
	rm -f $(CCP_BASEOS)/$(CCP_PGVERSION)/Dockerfile.postgres-gis.$(CCP_BASEOS).tmp

prometheus: versiontest
	docker build -t crunchy-prometheus -f $(CCP_BASEOS)/Dockerfile.prometheus.$(CCP_BASEOS) .
	docker tag crunchy-prometheus $(CCP_IMAGE_PREFIX)/crunchy-prometheus:$(CCP_BASEOS)-$(CCP_PG_FULLVERSION)-$(CCP_VERSION)

sample-app: versiontest
	docker build -t $(CCP_IMAGE_PREFIX)/sample-app-build:build -f $(CCP_BASEOS)/Dockerfile.sample-app-build.$(CCP_BASEOS) .
	docker create --name extract $(CCP_IMAGE_PREFIX)/sample-app-build:build
	docker cp extract:/go/src/github.com/crunchydata/sample-app/sample-app ./bin/sample-app
	docker rm -f extract
	docker build -t crunchy-sample-app -f $(CCP_BASEOS)/Dockerfile.sample-app.$(CCP_BASEOS) .
	docker tag crunchy-sample-app $(CCP_IMAGE_PREFIX)/crunchy-sample-app:$(CCP_BASEOS)-$(CCP_PG_FULLVERSION)-$(CCP_VERSION)

scheduler: versiontest
	docker build -t $(CCP_IMAGE_PREFIX)/scheduler-build:build -f $(CCP_BASEOS)/Dockerfile.scheduler-build.$(CCP_BASEOS) .
	docker create --name extract $(CCP_IMAGE_PREFIX)/scheduler-build:build
	docker cp extract:/go/src/github.com/crunchydata/crunchy-containers/scheduler ./bin/scheduler
	docker rm -f extract
	docker build -t crunchy-scheduler -f $(CCP_BASEOS)/Dockerfile.scheduler.$(CCP_BASEOS) .
	docker tag crunchy-scheduler $(CCP_IMAGE_PREFIX)/crunchy-scheduler:$(CCP_BASEOS)-$(CCP_PG_FULLVERSION)-$(CCP_VERSION)

upgrade: versiontest
	if [[ '$(CCP_PGVERSION)' != '9.5' ]]; then \
		docker build -t crunchy-upgrade -f $(CCP_BASEOS)/$(CCP_PGVERSION)/Dockerfile.upgrade.$(CCP_BASEOS) . ;\
		docker tag crunchy-upgrade $(CCP_IMAGE_PREFIX)/crunchy-upgrade:$(CCP_BASEOS)-$(CCP_PG_FULLVERSION)-$(CCP_VERSION) ;\
	fi

#=================
# Utility targets
#=================
push:
	./bin/push-to-dockerhub.sh

-include Makefile.build
