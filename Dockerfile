FROM java:8

MAINTAINER isaac@armory.io

COPY . workdir/

WORKDIR workdir

RUN GRADLE_USER_HOME=cache ./gradlew packDeb -x test

RUN dpkg -i ./build/distributions/*.deb

CMD ["java -jar /opt/hello-karyon-rxnetty/hello-karyon-rxnetty*.jar"]