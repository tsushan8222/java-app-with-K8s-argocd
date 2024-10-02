FROM 1243244532423.dkr.ecr.us-east-1.amazonaws.com/example-base-openjdk-jre-shared:openjdk-jre-17
LABEL COMPANY="example"
LABEL MAINTAINER="example"
LABEL APPLICATION="Java Simple App"
RUN apt-get update; apt-get install -y curl
RUN curl -O https://download.newrelic.com/newrelic/java-agent/newrelic-agent/NR_AGENT_VERSION/newrelic-agent-NR_AGENT_VERSION.jar
RUN mkdir -p /agent
RUN mv newrelic-agent-NR_AGENT_VERSION.jar /agent/newrelic-agent.jar
ARG JAR_FILE=build/libs/*.jar
EXPOSE 8080
COPY agent/newrelic.yml /agent/newrelic.yml
COPY build/libs/b2b-product-exp-*-SNAPSHOT.jar b2b-product-exp-1.0.jar
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar /b2b-product-exp-1.0.jar"]
