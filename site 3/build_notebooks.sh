#!/usr/bin/env bash
# Copie les notebooks de la racine vers docs/notebooks avec des noms sans espaces
# (le dossier généré est ignoré par git).
set -e
rm -rf docs/notebooks && mkdir -p docs/notebooks
for f in *.ipynb; do
  cp "$f" "docs/notebooks/$(echo "$f" | tr ' A-Z' '_a-z')"
done
ls docs/notebooks
