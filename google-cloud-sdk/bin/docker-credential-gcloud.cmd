@echo off
rem Copyright 2017 Google Inc. All Rights Reserved.

SETLOCAL

SET CLOUDSDK_COMPONENT_MANAGER_DISABLE_UPDATE_CHECK=1

call gcloud.cmd auth docker-helper "%*"

%COMSPEC% /C exit %ERRORLEVEL%
