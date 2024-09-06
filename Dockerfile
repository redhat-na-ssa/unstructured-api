# syntax=docker/dockerfile:experimental
FROM quay.io/unstructured-io/base-images:wolfi-base-latest

ARG PYTHON_VERSION="3.11"
ARG PIPELINE_PACKAGE=general

# Set up environment
ENV PYTHON python${PYTHON_VERSION}
ENV PIP ${PYTHON} -m pip

ENV HOME=/home/notebook-user
WORKDIR ${HOME}
ENV PYTHONPATH="${PYTHONPATH}:${HOME}"
ENV PATH="${HOME}/.local/bin:${PATH}"

COPY requirements/base.txt requirements-base.txt
RUN ${PIP} install pip
RUN ${PIP} install --no-cache -r requirements-base.txt

RUN ${PYTHON} -c "from unstructured.nlp.tokenize import download_nltk_packages; download_nltk_packages()" && \
  ${PYTHON} -c "from unstructured.partition.model_init import initialize; initialize()"

COPY CHANGELOG.md CHANGELOG.md
COPY logger_config.yaml logger_config.yaml
COPY prepline_${PIPELINE_PACKAGE}/ prepline_${PIPELINE_PACKAGE}/
COPY exploration-notebooks exploration-notebooks
COPY scripts/app-start.sh scripts/app-start.sh

USER 1000

ENTRYPOINT ["scripts/app-start.sh"]
# Expose a default port of 8000. Note: The EXPOSE instruction does not actually publish the port,
# but some tooling will inspect containers and perform work contingent on networking support declared.

EXPOSE 8000
