FROM java:7

MAINTAINER isaac@armory.io

COPY build/distributions/ workdir/

WORKDIR workdir

RUN dpkg -i *.deb

CMD ["java", "-jar", "/opt/hello-karyon-rxnetty/hello-karyon-rxnetty-all-0.1.0.jar"]