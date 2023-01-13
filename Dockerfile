FROM hexpm/elixir:1.14.2-erlang-25.0.4-alpine-3.17.0 as builder

ENV MIX_ENV=prod

ARG BRANCH=stable

RUN apk update \
    && apk add git gcc g++ musl-dev make cmake file-dev

WORKDIR /akkoma

RUN git clone -b "${BRANCH}" --depth=1 https://akkoma.dev/AkkomaGang/akkoma.git

COPY ./prod.secret.exs config/prod.secret.exs

RUN mix local.hex --force &&\
    mix local.rebar --force &&\
    mix deps.get --only ${MIX_ENV} &&\
    mkdir release &&\
    mix release --path release &&\
    mix pleroma.config migrate_to_db

FROM alpine:3.17.0 as final

ENV UID=911 GID=911

ARG HOME=/opt/akkoma
ARG DATA=/var/lib/akkoma

RUN adduser --system --shell /bin/false --home ${HOME} -D -G akkoma -u ${UID} akkoma

RUN apk update &&\
    apk add exiftool ffmpeg imagemagick libmagic ncurses postgresql-client su-exec shadow &&\
    mkdir -p ${DATA}/uploads &&\
    mkdir -p ${DATA}/static &&\
    chown -R akkoma:akkoma ${DATA} &&\
    mkdir -p /etc/akkoma &&\
    chown -R akkoma:akkoma /etc/akkoma

USER akkoma

COPY --from=builder --chown=akkoma /akkoma/config/docker.exs /etc/akkoma/config.exs
COPY --from=builder --chown=akkoma /akkoma/release ${HOME}
COPY --from=builder --chown=akkoma /akkoma/docker-entrypoint.sh ${HOME}/docker-entrypoint.sh


EXPOSE 4000

ENTRYPOINT ["/opt/akkoma/docker-entrypoint.sh"]

