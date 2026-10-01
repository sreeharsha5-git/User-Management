# ---------- Stage 1: Build WAR ----------
FROM maven:3.9-eclipse-temurin-17 AS build

WORKDIR /build

COPY pom.xml .

RUN mvn -B dependency:go-offline

COPY src ./src

RUN mvn -B clean package -DskipTests


# ---------- Stage 2: Tomcat 11 ----------
FROM tomcat:11.0-jdk17-temurin-jammy

RUN rm -rf /usr/local/tomcat/webapps/*

COPY --from=build /build/target/user-management.war \
    /usr/local/tomcat/webapps/ROOT.war

EXPOSE 10000

CMD ["sh", "-c", "sed -i \"s/port=\\\"8080\\\"/port=\\\"${PORT:-10000}\\\"/\" /usr/local/tomcat/conf/server.xml && catalina.sh run"]