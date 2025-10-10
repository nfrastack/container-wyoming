# nfrastack/container-wyoming

## About

This will build a Docker Image for [Wyoming](https:///), A series of utilities to support voice processing, either speech to text (STT) or text to speech (TTS)

## Maintainer

- [Nfrastack](https://www.nfrastack.com)

## Table of Contents

- [About](#about)
- [Maintainer](#maintainer)
- [Table of Contents](#table-of-contents)
- [Installation](#installation)
  - [Prebuilt Images](#prebuilt-images)
  - [Quick Start](#quick-start)
  - [Persistent Storage](#persistent-storage)
- [Environment Variables](#environment-variables)
  - [Base Images used](#base-images-used)
  - [Core Configuration](#core-configuration)
- [Users and Groups](#users-and-groups)
  - [Networking](#networking)
- [Maintenance](#maintenance)
  - [Shell Access](#shell-access)
- [Support & Maintenance](#support--maintenance)
- [License](#license)

## Installation

### Prebuilt Images
Feature limited builds of the image are available on the [Github Container Registry](https://github.com/nfrastack/container-wyoming/pkgs/container/container-wyoming) and [Docker Hub](https://hub.docker.com/r/nfrastack/wyoming).

To unlock advanced features, one must provide a code to be able to change specific environment variables from defaults. Support the development to gain access to a code.

To get access to the image use your container orchestrator to pull from the following locations:

```
ghcr.io/nfrastack/container-wyoming:(image_tag)
docker.io/nfrastack/wyoming:(image_tag)
```

Image tag syntax is:

`<image>:<optional tag>

Example:

`ghcr.io/nfrastack/container-wyoming:latest` or

`ghcr.io/nfrastack/container-wyoming:1.0`


* `latest` will be the most recent commit
* An optional `tag` may exist that matches the [CHANGELOG](CHANGELOG.md) - These are the safest
* If it is built for multiple distributions there may exist a value of `alpine` or `debian`
* If there are multiple distribution variations it may include a version - see the registry for availability

Have a look at the container registries and see what tags are available.

#### Multi-Architecture Support

Images are built for `amd64` by default, with optional support for `arm64` and other architectures.

### Quick Start

* The quickest way to get started is using [docker-compose](https://docs.docker.com/compose/). See the examples folder for a working [compose.yml](examples/compose.yml) that can be modified for your use.

* Map [persistent storage](#persistent-storage) for access to configuration and data files for backup.
* Set various [environment variables](#environment-variables) to understand the capabilities of this image.

### Persistent Storage

The following directories are used for configuration and can be mapped for persistent storage.

| Directory | Description |
| --------- | ----------- |
| `/data`   | Data        |
| `/logs`   | Logs        |

### Environment Variables

#### Base Images used

This image relies on a customized base image in order to work.
Be sure to view the following repositories to understand all the customizable options:

| Image                                                   | Description |
| ------------------------------------------------------- | ----------- |
| [OS Base](https://github.com/nfrastack/container-base/) | Base Image  |

Below is the complete list of available options that can be used to customize your installation.

- Variables showing an 'x' under the `Advanced` column can only be set if the containers advanced functionality is enabled.

#### Core Configuration

| Parameter   | Description                            | Default  | Advanced |
| ----------- | -------------------------------------- | -------- | -------- |
| `MODE`      | `OPENWAKEWORD` `PIPER` `WHISPER` `ALL` | `ALL`    |          |
| `DATA_PATH` | Data Path                              | `/data`  |          |
| `LOG_PATH`  | Log Path                               | `/logs/` |          |


#### OpenWakeWord Options

| Variable                     | Description | Default                             | `_FILE` |
| ---------------------------- | ----------- | ----------------------------------- | ------- |
| `OPENWAKEWORD_DATA_PATH`     |             | `${DATA_PATH}/openwakeword/`        |         |
| `OPENWAKEWORD_LISTEN_IP`     |             | `0.0.0.0`                           |         |
| `OPENWAKEWORD_LISTEN_PORT`   |             | `10400`                             |         |
| `OPENWAKEWORD_LISTEN_TYPE`   |             | `TCP`                               |         |
| `OPENWAKEWORD_LOG_FILE`      |             | `openwakeword.log`                  |         |
| `OPENWAKEWORD_LOG_FORMAT`    |             | `YYYY-MM-DDTHH:mm:ss`               |         |
| `OPENWAKEWORD_LOG_LEVEL`     |             | `info`                              |         |
| `OPENWAKEWORD_LOG_PATH`      |             | `${LOG_PATH}/openwakeword/`         |         |
| `OPENWAKEWORD_LOG_TYPE`      |             | `both`                              |         |
| `OPENWAKEWORD_MODEL`         |             | `hey_jarvis`                        |         |
| `OPENWAKEWORD_MODEL_PATH`    |             | `${OPENWAKEWORD_DATA_PATH}/models/` |         |
| `OPENWAKEWORD_OUTPUT_PATH`   |             | `${OPENWAKEWORD_DATA_PATH}/output/` |         |
| `OPENWAKEWORD_THRESHOLD`     |             | `0.5`                               |         |
| `OPENWAKEWORD_TRIGGER_LEVEL` |             | `1`                                 |         |

#### Piper Options

| Variable              | Description | Default               | `_FILE` |
| --------------------- | ----------- | --------------------- | ------- |
| `PIPER_DATA_PATH`     |             | `${DATA_PATH}/piper/` |         |
| `PIPER_LISTEN_IP`     |             | `0.0.0.0`             |         |
| `PIPER_LISTEN_PORT`   |             | `10200`               |         |
| `PIPER_LISTEN_TYPE`   |             | `TCP`                 |         |
| `PIPER_LOG_FILE`      |             | `piper.log`           |         |
| `PIPER_LOG_FORMAT`    |             | `YYYY-MM-DDTHH:mm:ss` |         |
| `PIPER_LOG_LEVEL`     |             | `INFO`                |         |
| `PIPER_LOG_PATH`      |             | `${LOG_PATH}/piper/`  |         |
| `PIPER_LOG_TYPE`      |             | `both`                |         |
| `PIPER_VOICE`         |             | `en_US-lessac-medium` |         |
| `PIPER_SPEAKER`       |             | `0`                   |         |
| `PIPER_LENGTH_SCALE`  |             | `1.0`                 |         |
| `PIPER_NOISE_SCALE`   |             | `0.667`               |         |
| `PIPER_NOISE_WEIGHT`  |             | `0.333`               |         |
| `PIPER_PROCESS_LIMIT` |             | `1`                   |         |
| `PIPER_UPDATE_VOICES` |             | `TRUE`                |         |

#### Whisper Options

| Variable                 | Description | Default                          | `_FILE` |
| ------------------------ | ----------- | -------------------------------- | ------- |
| `WHISPER_DATA_PATH`      |             | `${DATA_PATH}/whisper/`          |         |
| `WHISPER_LISTEN_IP`      |             | `0.0.0.0`                        |         |
| `WHISPER_LISTEN_PORT`    |             | `10300`                          |         |
| `WHISPER_LISTEN_TYPE`    |             | `TCP`                            |         |
| `WHISPER_LOG_FILE`       |             | `whisper.log`                    |         |
| `WHISPER_LOG_FORMAT`     |             | `YYYY-MM-DDTHH:mm:ss`            |         |
| `WHISPER_LOG_LEVEL`      |             | `INFO`                           |         |
| `WHISPER_LOG_PATH`       |             | `${LOG_PATH}/whisper/`           |         |
| `WHISPER_LOG_TYPE`       |             | `both`                           |         |
| `WHISPER_LANGUAGE`       |             | `en`                             |         |
| `WHISPER_INITIAL_PROMPT` |             | ` `                              |         |
| `WHISPER_DOWNLOAD_PATH`  |             | `${WHISPER_DATA_PATH}/download/` |         |
| `WHISPER_BEAM_SIZE`      |             | `1`                              |         |
| `WHISPER_MODEL`          |             | `tiny-int8`                      |         |
| `WHISPER_DEVICE`         |             | `CPU`                            |         |


### Networking

| Port    | Protocol | Description  |
| ------- | -------- | ------------ |
| `10200` | `tcp`    | Piper        |
| `10300` | `tcp`    | Whisper      |
| `10400` | `tcp`    | OpenWakeWord |


## Users and Groups

| Type  | Name           | ID   |
| ----- | -------------- | ---- |
| User  | `openwakeword` | 9673 |
| User  | `piper`        | 7477 |
| User  | `whisper`      | 9777 |
| Group | `wyoming`      | 9966 |


* * *

## Maintenance

### Shell Access

For debugging and maintenance, `bash` and `sh` are available in the container.

## Support & Maintenance

- For community help, tips, and community discussions, visit the [Discussions board](/discussions).
- For personalized support or a support agreement, see [Nfrastack Support](https://nfrastack.com/).
- To report bugs, submit a [Bug Report](issues/new). Usage questions will be closed as not-a-bug.
- Feature requests are welcome, but not guaranteed. For prioritized development, consider a support agreement.
- Updates are best-effort, with priority given to active production use and support agreements.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
