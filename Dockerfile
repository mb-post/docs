FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=UTC

# TeX Live + pandoc + SVG converter + Japanese fonts
RUN apt-get update && apt-get install -y --no-install-recommends \
    pandoc \
    texlive-luatex \
    texlive-lang-japanese \
    texlive-latex-extra \
    texlive-fonts-recommended \
    texlive-plain-generic \
    librsvg2-bin \
    python3 \
    fonts-noto-cjk \
    git \
    make \
    && rm -rf /var/lib/apt/lists/*

# Build the luaotfload font database so fontspec can resolve fonts
# installed via TeX Live (e.g. TeX Gyre Heros) by name.
RUN luaotfload-tool --update --force

WORKDIR /work
