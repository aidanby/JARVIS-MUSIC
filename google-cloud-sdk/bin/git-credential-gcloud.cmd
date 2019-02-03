@echo off
rem Copyright 2013 Google Inc. All Rights Reserved.
rem This is script no longer needed as of release 133.0.0
rem It is here so that git repositories set before this version continue to work.

SETLOCAL

SET CLOUDSDK_COMPONENT_MANAGER_DISABLE_UPDATE_CHECK=1

call gcloud.cmd auth git-helper --ignore-unknown "%*"

%COMSPEC% /C exit %ERRORLEVEL%
