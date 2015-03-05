#!/bin/bash

cd ~/.m2/repository/
find ./ -name *.lastUpdated -type f -print |xargs rm -f
