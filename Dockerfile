# syntax=docker/dockerfile:1
#
# Image Hermes dérivée pour Resilia.
# Base = image officielle épinglée par digest. Ajout = client Python Hindsight,
# installé dans un répertoire séparé puis ajouté à la fin de sys.path via un
# fichier .pth : les paquets de l'image gardent la priorité, seuls les modules
# absents sont pris ici. Aucune installation au démarrage, aucun accès réseau
# au runtime.

ARG PYTHON_VERSION=3.14
ARG BASE_IMAGE

FROM python:${PYTHON_VERSION}-slim AS deps
ARG CLIENT_SPEC=hindsight-client==0.10.1
ARG EMBED_SPEC=hindsight-embed==0.10.1
RUN pip install --no-cache-dir --target /deps "${CLIENT_SPEC}" "${EMBED_SPEC}"

FROM ${BASE_IMAGE}

COPY --from=deps /deps /opt/resilia/hindsight-deps

RUN set -eu; \
    purelib="$(/opt/hermes/.venv/bin/python -c 'import sysconfig; print(sysconfig.get_paths()["purelib"])')"; \
    printf '%s\n' /opt/resilia/hindsight-deps > "${purelib}/resilia-hindsight-deps.pth"; \
    /opt/hermes/.venv/bin/python -c 'import hindsight_client, hindsight_embed; print("HINDSIGHT_DEPS_OK")'
