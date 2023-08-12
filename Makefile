.PHONY: init

SHELL := /bin/bash

init:
	poetry lock && \
	poetry install && \
	pre-commit install