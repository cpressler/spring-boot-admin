FROM centos:7

ARG buildversion
ARG ARTIFACT_ID=spring-boot-admin

RUN echo "Oh dang look at that $buildversion"

ARG sourceJar=./target/spring-boot-admin-${buildversion}-boot.jar
#RUN echo $sourceJar

EXPOSE 8180


RUN yum update -y -q && \
yum install -y -q java-1.8.0-openjdk && \
rm -rf /var/cache/yum && \
mkdir /opt/services && \
mkdir /opt/services/spring-boot-admin


COPY ./${ARTIFACT_ID}.service /usr/lib/systemd/system/${ARTIFACT_ID}.service
COPY ./spring-boot-admin.sysconfig /etc/sysconfig/spring-boot-admin
COPY $sourceJar /opt/services/spring-boot-admin/spring-boot-admin-boot.jar
RUN chmod 666 /usr/lib/systemd/system/spring-boot-admin.service && \
ln -s /usr/lib/systemd/system/spring-boot-admin.service /etc/systemd/system/multi-user.target.wants/spring-boot-admin.service

ADD ./docker/server/docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]

