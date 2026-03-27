FROM docker.io/library/alpine:3.23

ARG TARGETARCH
ARG TARGETPLATFORM
ARG BUILDPLATFORM
RUN echo "Building on ${BUILDPLATFORM} for ${TARGETPLATFORM} & ${TARGETARCH}"

RUN apk update && apk add --no-cache ca-certificates tzdata && update-ca-certificates
RUN apk update && apk add --no-cache sudo git openssh-client bash curl wget rsync vim


# Install zyedidia/eget (bootstrap)
# Asset names follow the pattern: eget_<version>_linux_amd64.tar.gz
ENV EGET_BIN=/usr/local/bin
ARG EGET_VERSION=1.3.4
RUN wget -qO- \
    "https://github.com/zyedidia/eget/releases/download/v${EGET_VERSION}/eget-${EGET_VERSION}-linux_${TARGETARCH}.tar.gz" \
    | tar -xz --strip-components=1 -C /usr/local/bin \
    "eget-${EGET_VERSION}-linux_${TARGETARCH}/eget" \
    && chmod 755 /usr/local/bin/eget \
    && eget github.com/zyedidia/eget

# Use eget to install tools
RUN eget --asset ^gnu github.com/lsd-rs/lsd && \
    eget --asset ^gnu --asset tar.gz github.com/sharkdp/bat && \
    eget --asset ^gnu --asset tar.gz github.com/sharkdp/fd && \
    eget --asset ^gnu github.com/gokcehan/lf && \
    eget --asset ^gnu github.com/dandavison/delta && \
    eget --asset ^web github.com/mr-karan/doggo && \
    eget github.com/burntsushi/ripgrep && \
    eget github.com/sharkdp/hexyl && \
    eget github.com/byron/dua-cli && \
    eget github.com/antonmedv/fx

ARG USER=gdx
RUN addgroup -g 1000 $USER \
    && adduser -u 1000 -G $USER -h /home -s /bin/bash -D $USER \
    && mkdir -p /etc/sudoers.d \
    && echo "$USER ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/$USER \
    && chmod 0440 /etc/sudoers.d/$USER
USER $USER

RUN echo "source $HOME/.bash_aliases" > $HOME/.bashrc
RUN curl -o $HOME/.bash_aliases https://raw.githubusercontent.com/gesquive/dotfiles/refs/heads/main/.config/shell_aliases

CMD ["/bin/bash"]
