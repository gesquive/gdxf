FROM docker.io/library/alpine:3.20

RUN apk update && apk add --no-cache ca-certificates tzdata && update-ca-certificates
RUN apk update && apk add --no-cache sudo git openssh-client bash curl rsync vim

ARG USER=xfer
RUN addgroup -g 1000 $USER \
    && adduser -u 1000 -G $USER -h /home/$USER -s /bin/bash -D $USER \
    && mkdir -p /etc/sudoers.d \
    && echo "$USER ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/$USER \
    && chmod 0440 /etc/sudoers.d/$USER
USER $USER

RUN echo "source $HOME/.bash_aliases" > $HOME/.bashrc
RUN curl -o $HOME/.bash_aliases https://raw.githubusercontent.com/gesquive/dotfiles/refs/heads/main/.config/shell_aliases
