FROM centos:centos7
RUN yum -y install make deltarpm
ADD . /var/build
WORKDIR /var/build
RUN make prerequisites
ENTRYPOINT ["make"]
