#!/bin/bash

service ssh start

mkdir ~/.ssh/
cp ~/ssh-keys/id_rsa* ~/.ssh/
chmod -R 600 ~/.ssh/*
cat ~/.ssh/id_rsa.pub > ~/.ssh/authorized_keys

/bin/bash -c -- "while true; do sleep 600; done;"
