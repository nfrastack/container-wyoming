ARG DISTRO=debian
ARG DISTRO_VARIANT=bookworm

FROM docker.io/tiredofit/${DISTRO}:${DISTRO_VARIANT}
LABEL maintainer="Dave Conroy (github.com/tiredofit)"

ARG OPENWAKEWORD_VERSION
ARG PIPER_VERSION
ARG WHISPER_VERSION

ENV OPENWAKEWORD_VERSION=${OPENWAKEWORD_VERSION:-"c40fe924ffa12e9ddf24a3e5fcdeb4fd58ab07eb"} \
    PIPER_VERSION=${PIPER_VERSION:-"2023.11.14-2"} \
    WYOMING_PIPER_VERSION=${WYOMING_PIPER_VERSION:-"v1.5.0"} \
    WHISPER_VERSION=${WHISPER_VERSION:-"v2.1.0"} \
    OPENWAKEWORD_REPO_URL=${OPENWAKEWORD_REPO_URL:-"https://github.com/rhasspy/wyoming-openwakeword"} \
    PIPER_REPO_URL=${PIPER_REPO_URL:-"https://github.com/rhasspy/piper"} \
    WYOMING_PIPER_REPO_URL=${WYOMING_PIPER_REPO_URL:-"https://github.com/rhasspy/wyoming-piper"} \
    WHISPER_REPO_URL=${WHISPER_REPO_URL:-"https://github.com/rhasspy/wyoming-faster-whisper"} \
    OPENWAKEWORD_USER=${OPENWAKEWORD_USER:-"openwakeword"} \
    OPENWAKEWORD_GROUP=${OPENWAKEWORD_GROUP:-"wyoming"} \
    PIPER_USER=${PIPER_USER:-"piper"} \
    PIPER_GROUP=${PIPER_GROUP:-"wyoming"} \
    WHISPER_USER=${WHISPER_USER:-"whisper"} \
    WHISPER_GROUP=${WHISPER_GROUP:-"wyoming"} \
    CONTAINER_PROCESS_RUNAWAY_PROTECTOR=FALSE \
    IMAGE_NAME="tiredofit/wyoming" \
    IMAGE_REPO_URL="https://github.com/tiredofit/docker-wyoming/"

RUN source assets/functions/00-container && \
    set -x && \
    addgroup --gid 9966 wyoming && \
    adduser \
        --shell /sbin/nologin \
        --home /opt/"${OPENWAKEWORD_USER}" \
        --gecos "OpenWakeWord" \
        --uid 9673 \
        --gid 9966 \
        --disabled-login \
        --disabled-password \
        "${OPENWAKEWORD_USER}" \
    && \
    adduser \
        --shell /sbin/nologin \
        --home /opt/"${PIPER_USER}" \
        --gecos "Piper" \
        --uid 7477 \
        --gid 9966 \
        --disabled-login \
        --disabled-password \
        "${PIPER_USER}" \
    && \
    adduser \
        --shell /sbin/nologin \
        --home /opt/"${WHISPER_USER}" \
        --gecos "Whisper" \
        --uid 9777 \
        --gid 9966 \
        --disabled-login \
        --disabled-password \
        "${WHISPER_USER}" \
    && \
    \
    package update && \
    package upgrade && \
    CONTAINER_BUILD_DEPS=" \
                            git \
                            python3-dev \
                            python3-pip \
                            python3-venv \
                         " \
                         && \
    CONTAINER_RUN_DEPS=" \
                            python3-venv \
                        " \
                         && \
    OPENWAKEWORD_BUILD_DEPS=" \
                                build-essential \
                                cmake \
                            " \
                            && \
    OPENWAKEWORD_RUN_DEPS=" \
                            " \
                            && \
    PIPER_BUILD_DEPS=" \
                            " \
                            && \
    PIPER_RUN_DEPS=" \
                            " \
                            && \
    WHISPER_BUILD_DEPS=" \
                            " \
                            && \
    WHISPER_RUN_DEPS=" \
                            " \
                            && \
    package install ${OPENWAKEWORD_BUILD_DEPS} && \
    package install ${PIPER_BUILD_DEPS} && \
    package install ${WHISPER_BUILD_DEPS} && \
    package install ${CONTAINER_BUILD_DEPS} && \
    \
    python3 -m venv /opt/openwakeword && \
    clone_git_repo "${OPENWAKEWORD_REPO_URL}" "${OPENWAKEWORD_VERSION}" /usr/src/openwakeword && \
    chown -R "${OPENWAKEWORD_USER}":"${OPENWAKEWORD_GROUP}" /opt/openwakeword && \
    source /opt/openwakeword/bin/activate && \
    cd /usr/src/openwakeword && \
    sudo -u "${OPENWAKEWORD_USER}" /opt/openwakeword/bin/pip \
                install \
                -r requirements.txt \
                && \
    /opt/openwakeword/bin/python \
                                ./setup.py \
                                    install \
                                && \
    clone_git_repo https://github.com/fwartner/home-assistant-wakewords-collection && \
    find /usr/src/home_assistant_wakewords_collection/ -type f -name *.tflite -print0 | xargs -0 cp -t /opt/openwakeword/lib/python"$(python3 --version | awk '{print $2}' | cut -d . -f 1-2)"/site-packages/wyoming_openwakeword-*-py"$(python3 --version| awk '{print $2}' | cut -d . -f 1-2)".egg/wyoming_openwakeword/models/ && \
    \
    #
    deactivate && \
    python3 -m venv /opt/piper && \
    clone_git_repo "${PIPER_REPO_URL}" "${PIPER_VERSION}" /usr/src/piper && \
    clone_git_repo "${WYOMING_PIPER_REPO_URL}" "${WYOMING_PIPER_VERSION}" /usr/src/wyoming_piper && \
    source /opt/piper/bin/activate && \
    chown -R "${PIPER_USER}":"${PIPER_GROUP}" /opt/piper && \
    cd /usr/src/piper && \
    cmake \
            -Bbuild \
            -DCMAKE_INSTALL_PREFIX=/opt/piper && \
    cmake \
            --build build \
            --config Release \
            -j$(nproc) \
            && \
    cmake \
            --install build \
            && \
    \
    cd /usr/src/wyoming_piper && \
    sudo -u "${PIPER_USER}" /opt/piper/bin/pip install \
                                                        -r requirements.txt \
                                                        && \
    /opt/piper/bin/python \
                            ./setup.py \
                                install \
                                && \
    deactivate && \
    #
    python3 -m venv /opt/whisper && \
    clone_git_repo "${WHISPER_REPO_URL}" "${WHISPER_VERSION}" /usr/src/whisper && \
    cd /usr/src/whisper && \
    chown -R "${WHISPER_USER}":"${WHISPER_GROUP}" /opt/whisper && \
    source /opt/whisper/bin/activate && \
    sudo -u "${WHISPER_USER}" /opt/whisper/bin/pip install \
                -r requirements.txt \
                && \
    python \
            ./setup.py \
                install \
            && \
    deactivate && \
    \
    package remove \
                    ${OPENWAKEWORD_BUILD_DEPS} \
                    ${PIPER_BUILD_DEPS} \
                    ${WHISPER_BUILD_DEPS} \
                    && \
    package install \
                    ${CONTAINER_RUN_DEPS} \
                    ${OPENWAKEWORD_RUN_DEPS} \
                    ${PIPER_RUN_DEPS} \
                    ${WHISPER_RUN_DEPS} \
                    && \
    package cleanup && \
    \
    rm -rf /usr/src/*

COPY install /

