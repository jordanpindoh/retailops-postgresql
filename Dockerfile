FROM postgres:17.11-alpine AS builder

RUN apk add --no-cache build-base git openssl-dev krb5-dev

RUN git clone --depth 1 --branch REL_17_STABLE \
    https://github.com/pgaudit/pgaudit.git /tmp/pgaudit

WORKDIR /tmp/pgaudit

RUN make USE_PGXS=1 with_llvm=no \
    && make install USE_PGXS=1 with_llvm=no

FROM postgres:17.11-alpine

COPY --from=builder /usr/local/lib/postgresql/pgaudit.so /usr/local/lib/postgresql/
COPY --from=builder /usr/local/share/postgresql/extension/pgaudit* /usr/local/share/postgresql/extension/
