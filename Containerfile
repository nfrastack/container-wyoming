# SPDX-FileCopyrightText: © 2025 Nfrastack <code@nfrastack.com>
#
# SPDX-License-Identifier: MIT

ARG \
    BASE_IMAGE

FROM ${BASE_IMAGE}

LABEL \
        org.opencontainers.image.title="Wyoming" \
        org.opencontainers.image.description="SST and TTS tools" \
        org.opencontainers.image.url="https://hub.docker.com/r/nfrastack/wyoming" \
        org.opencontainers.image.documentation="https://github.com/nfrastack/container-wyoming/blob/main/README.md" \
        org.opencontainers.image.source="https://github.com/nfrastack/container-wyoming.git" \
        org.opencontainers.image.authors="Nfrastack <code@nfrastack.com>" \
        org.opencontainers.image.vendor="Nfrastack <https://www.nfrastack.com>" \
        org.opencontainers.image.licenses="MIT"

ARG \
    OPENWAKEWORD_GROUP \
    OPENWAKEWORD_REPO_URL="https://github.com/rhasspy/wyoming-openwakeword" \
    OPENWAKEWORD_USER \
    OPENWAKEWORD_VERSION="d8e9780ef68459f81a45486d0ea7a3201ba16990" \
    PIPER_GROUP \
    PIPER_USER \
    PIPER_REPO_URL="https://github.com/OHF-Voice/piper1-gpl" \
    PIPER_VERSION="v1.3.0" \
    WHISPER_GROUP \
    WHISPER_REPO_URL="https://github.com/rhasspy/wyoming-faster-whisper" \
    WHISPER_USER \
    WHISPER_VERSION="v2.5.0" \
    WYOMING_PIPER_REPO_URL="https://github.com/rhasspy/wyoming-piper" \
    WYOMING_PIPER_VERSION="v1.6.3"

COPY CHANGELOG.md /usr/src/container/CHANGELOG.md
COPY LICENSE /usr/src/container/LICENSE
COPY README.md /usr/src/container/README.md

ENV \
    OPENWAKEWORD_USER=${OPENWAKEWORD_USER:-"openwakeword"} \
    OPENWAKEWORD_GROUP=${OPENWAKEWORD_GROUP:-"wyoming"} \
    PIPER_USER=${PIPER_USER:-"piper"} \
    PIPER_GROUP=${PIPER_GROUP:-"wyoming"} \
    WHISPER_USER=${WHISPER_USER:-"whisper"} \
    WHISPER_GROUP=${WHISPER_GROUP:-"wyoming"} \
    CONTAINER_ENABLE_SCHEDULING=TRUE \
    IMAGE_NAME="nfrastack/wyoming" \
    IMAGE_REPO_URL="https://github.com/nfrastack/container-wyoming/"

RUN echo "" && \
    WYOMING_BUILD_DEPS_DEBIAN=" \
                                   git \
                                   python3-dev \
                                   python3-pip \
                                   python3-venv \
                                " \
                                && \
    WYOMING_RUN_DEPS_DEBIAN=" \
                              python3-venv \
                            " \
                            && \
    OPENWAKEWORD_BUILD_DEPS_DEBIAN=" \
                                        build-essential \
                                        cmake \
                                   " \
                                   && \
    OPENWAKEWORD_RUN_DEPS_DEBIAN=" \
                                 " \
                                 && \
    PIPER_BUILD_DEPS_DEBIAN=" \
                            " \
                            && \
    PIPER_RUN_DEPS_DEBIAN=" \
                          " \
                          && \
    WHISPER_BUILD_DEPS_DEBIAN=" \
                              " \
                              && \
    WHISPER_RUN_DEPS_DEBIAN=" \
                            " \
                            && \
    \
    source /container/base/functions/container/build && \
    container_build_log image && \
    create_user ${OPENWAKEWORD_USER} 9673 wyoming 9966 /opt/${OPENWAKEWORD_USER} && \
    create_user ${PIPER_USER} 7477 wyoming 9966 /opt/${PIPER_USER} && \
    create_user ${WHISPER_USER} 9777 wyoming 9966 /opt/${WHISPER_USER} && \
    case $(container_info variant ) in \
        bookworm ) \
            package repo add backports ; \
            backport="/$(container_info variant)-backports" ; \
        ;; \
    esac && \
    OPENWAKEWORD_BUILD_DEPS_DEBIAN=" \
                                        build-essential \
                                        cmake${backport} \
                                   " \
                                   && \
    package update && \
    package upgrade && \
    package install \
                        OPENWAKEWORD_BUILD_DEPS \
                        OPENWAKEWORD_RUN_DEPS \
                        PIPER_BUILD_DEPS \
                        PIPER_RUN_DEPS \
                        WHISPER_BUILD_DEPS \
                        WHISPER_RUN_DEPS \
                        WYOMING_BUILD_DEPS \
                        WYOMING_RUN_DEPS \
                    && \
    \
    pip install --break-system-packages \
                uv \
                && \
    uv venv /opt/${OPENWAKEWORD_USER} && \
    clone_git_repo "${OPENWAKEWORD_REPO_URL}" "${OPENWAKEWORD_VERSION}" /usr/src/openwakeword && \
    source /opt/${OPENWAKEWORD_USER}/bin/activate && \
    cd /usr/src/openwakeword && \
    uv pip install \
                    setuptools \
                    wheel \
                    && \
    uv pip install \
                    -r requirements.txt \
                    && \
    /opt/${OPENWAKEWORD_USER}/bin/python \
                                            ./setup.py \
                                                install \
                                            && \
    \
    chown -R "${OPENWAKEWORD_USER}":"${OPENWAKEWORD_GROUP}" /opt/${OPENWAKEWORD_USER} && \
    clone_git_repo https://github.com/fwartner/home-assistant-wakewords-collection && \
    find /usr/src/home_assistant_wakewords_collection/ -type f -name *.tflite -print0 | xargs -0 cp -t /opt/${OPENWAKEWORD_USER}/lib/python"$(python3 --version | awk '{print $2}' | cut -d . -f 1-2)"/site-packages/wyoming_openwakeword/models/ && \
    deactivate && \
    container_build_log add "OpenWakeWord" "${OPENWAKEWORD_VERSION}" "${OPENWAKEWORD_REPO_URL}" && \
    \
    uv venv /opt/piper && \
    clone_git_repo "${PIPER_REPO_URL}" "${PIPER_VERSION}" /usr/src/piper && \
    source /opt/${PIPER_USER}/bin/activate && \
    cd /usr/src/piper && \
    cmake \
            -Bbuild \
            -DCMAKE_INSTALL_PREFIX=/opt/${PIPER_USER} && \
    cmake \
            --build build \
            --config Release \
            -j$(nproc) \
            && \
    cmake \
            --install build \
            && \
    \
    container_build_log add "Piper" "${PIPER_VERSION}" "${PIPER_REPO_URL}" && \
    clone_git_repo "${WYOMING_PIPER_REPO_URL}" "${WYOMING_PIPER_VERSION}" /usr/src/wyoming_piper && \
    uv pip install . && \
    chown -R "${PIPER_USER}":"${PIPER_GROUP}" /opt/${PIPER_USER} && \
    deactivate && \
    container_build_log add "Wyoming Piper" "${WYOMING_PIPER_VERSION}" "${WYOMING_PIPER_REPO_URL}" && \
    \
    uv venv /opt/${WHISPER_USER} && \
    clone_git_repo "${WHISPER_REPO_URL}" "${WHISPER_VERSION}" /usr/src/whisper && \
    cd /usr/src/whisper && \
    source /opt/${WHISPER_USER}/bin/activate && \
    uv pip install . && \
    chown -R "${WHISPER_USER}":"${WHISPER_GROUP}" /opt/${WHISPER_USER} && \
    deactivate && \
    container_build_log add "Whisper" "${WHISPER_VERSION}" "${WHISPER_REPO_URL}" && \
    package remove \
                    OPENWAKEWORD_BUILD_DEPS \
                    PIPER_BUILD_DEPS \
                    WHISPER_BUILD_DEPS \
                    WYOMING_BUILD_DEPS \
                    && \
    package cleanup && \
    \
    rm -rf \
            /opt/${WHISPER_USER}/.cache \
            /opt/${PIPER_USER}/.cache \
            /opt/${OPENWAKEWORD_USER}/.cache

COPY rootfs /
