FROM swift:5.0
USER root
LABEL "com.github.actions.name"="ExpressSwift-Actions"
LABEL "com.github.actions.description"=""
LABEL "com.github.actions.icon"="airplay"
LABEL "com.github.actions.color"="orange"
LABEL "repository"="https://github.com/diejmon/ExpressSwift.git"
LABEL "homepage"="http://github.com/actions"
LABEL "maintainer"="diejmon@gmail.com"
RUN mkdir /ExpressSwift
WORKDIR /ExpressSwift
COPY . /ExpressSwift