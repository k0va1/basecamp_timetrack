#! /bin/bash

eval $(cat .env | tr '\n' ' ') ./bin/run
