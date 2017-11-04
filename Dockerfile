FROM hkjn/alpine

ARG docker_arch
ARG docker_version
ENV DOCKER_CHANNEL=stable \
    DOCKER_VERSION=${docker_version} \
    DOCKER_ARCH=${docker_arch}
RUN echo "fetching from version $DOCKER_VERSION and arch $DOCKER_ARCH"
# TODO ENV DOCKER_SHA256
# https://github.com/docker/docker-ce/blob/5b073ee2cf564edee5adca05eee574142f7627bb/components/packaging/static/hash_files !!
RUN apk add --no-cache ca-certificates && \
    apk add --no-cache --virtual .fetch-deps curl tar && \
    curl -fsL -o docker.tgz "https://download.docker.com/linux/static/${DOCKER_CHANNEL}/${DOCKER_ARCH}/docker-${DOCKER_VERSION}.tgz" && \
    tar --extract --file docker.tgz --strip-components 1 --directory /usr/local/bin/ && \
    rm docker.tgz && \
    apk del .fetch-deps && \
    dockerd -v && \
    docker -v

COPY docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["sh"]

