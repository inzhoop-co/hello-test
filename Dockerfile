FROM eris/decerver:latest
MAINTAINER inzHoop <support@inzhoop.com>

USER root

COPY . $ERIS/dapps/hellohugo/
RUN chown $USER -R $ERIS/dapps/hellohugo/

USER $USER

CMD $ERIS/dapps/hellohugo/start.sh
