#!/bin/bash
echo "admin" | podman login localhost:6081 -u "admin" --password-stdin
