FROM alpine:3.15
ENV ANSIBLE_HOST_KEY_CHECKING false
ENV ANSIBLE_VAULT_PASSWORD_FILE /ansible/vault
ENV USER=ubuntu
ENV UID=1000
ENV GID=1000

RUN apk --update add --no-cache ansible shadow && rm -rf /usr/lib/python3.9/site-packages/ansible_collections
RUN addgroup -g $GID $USER

RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "/home/ubuntu" \
    --ingroup "$USER" \
#    --no-create-home \
    --uid "$UID" \
    "$USER"
RUN apk del shadow
USER ubuntu
WORKDIR /ansible
ENTRYPOINT ["ansible-vault"]
CMD ["--version"]
