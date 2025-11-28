#!/bin/bash
env >/tmp/opsdev.log
pwd >>/tmp/opsdev.log
cat .env >>/tmp/opsdev.log
ops ide login
ops ide devel
