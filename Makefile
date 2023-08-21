.PHONY: setup

setup:
	poetry shell && \
	poetry lock && \
	poetry install && \
	pre-commit install