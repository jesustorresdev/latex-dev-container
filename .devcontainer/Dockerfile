ARG VARIANT="bullseye"
FROM mcr.microsoft.com/devcontainers/base:${VARIANT}

ARG SCHEME=scheme-basic
ARG DOCFILES=0
ARG SRCFILES=0
ARG TEXLIVE_MIRROR="https://mirror.ctan.org/systems/texlive/tlnet"
ARG USERNAME=vscode

ENV TEXDIR="/opt/texlive"
ENV TEXUSERDIR="/opt/texlive-user"

# Install base packages that users may need later
RUN <<EOF
set -e
# ttf-mscorefonts-installer package is in 'contrib'
sed -i'.bak' 's/$/ contrib/' /etc/apt/sources.list
apt update -y
apt install -y --no-install-recommends \
    fontconfig python3-pygments ttf-mscorefonts-installer
apt clean autoclean
apt autoremove -y
rm -rf /var/lib/apt/lists/*
EOF

WORKDIR /tmp/texlive

# Contents of `profile.txt` for TexLive non-interactive installation
# See: https://tug.org/texlive/doc/install-tl.html#PROFILES
COPY <<EOF /tmp/texlive/profile.txt
selected_scheme ${SCHEME}
instopt_letter 0    # Set default page size to a4
instopt_adjustpath 0
tlpdbopt_autobackup 0
tlpdbopt_desktop_integration 0
tlpdbopt_file_assocs 0
tlpdbopt_install_docfiles ${DOCFILES}
tlpdbopt_install_srcfiles ${SRCFILES}
EOF

# TexLive installation
RUN <<EOF
set -e
wget -qO- ${TEXLIVE_MIRROR}/install-tl-unx.tar.gz | tar -xz --strip-components=1
export TEXLIVE_INSTALL_NO_CONTEXT_CACHE=1
export TEXLIVE_INSTALL_NO_WELCOME=1
./install-tl -profile /tmp/texlive/profile.txt -no-interaction \
    -texdir ${TEXDIR} -texuserdir ${TEXUSERDIR} --location ${TEXLIVE_MIRROR}
rm -rf /tmp/texlive/profile.txt ${TEXDIR}/*.log
EOF

ENV PATH ${PATH}:${TEXDIR}/bin/x86_64-linux:${TEXDIR}/bin/aarch64-linux

# Latexindent dependencies
RUN <<EOF
set -e
apt-get update -y
apt-get install -y --no-install-recommends cpanminus
cpanm -n -q Log::Log4perl
cpanm -n -q XString
cpanm -n -q Log::Dispatch::File
cpanm -n -q YAML::Tiny
cpanm -n -q File::HomeDir
cpanm -n -q Unicode::GCString
apt-get remove -y cpanminus
apt-get clean autoclean
apt-get autoremove -y
rm -rf /var/lib/apt/lists/*
EOF

# Update the TexLive package manager and minimal packages
RUN <<EOF
set -e
tlmgr update --self --all
tlmgr install latexmk latexindent chktex
tlmgr update --all
texhash
rm -rf ${TEXDIR}/texmf-var/web2c/*.log
EOF

# Fix permissions for user 'vscode'
RUN chown -R ${USERNAME}:${USERNAME} ${TEXDIR}

# Verify binaries work and have the right permissions
USER ${USERNAME}
RUN <<EOF
set -e
tlmgr version
latexmk -version
texhash --version
chktex --version
EOF

WORKDIR /workspaces