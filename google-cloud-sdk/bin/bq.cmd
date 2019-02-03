@echo off
rem Copyright 2013 Google Inc. All Rights Reserved.

SETLOCAL

rem <cloud-sdk-cmd-preamble>
rem
rem  CLOUDSDK_ROOT_DIR            (a)  installation root dir
rem  CLOUDSDK_PYTHON              (u)  python interpreter path
rem  CLOUDSDK_PYTHON_ARGS         (u)  python interpreter arguments
rem  CLOUDSDK_PYTHON_SITEPACKAGES (u)  use python site packages
rem
rem (a) always defined by the preamble
rem (u) user definition overrides preamble

rem This command lives in google-cloud-sdk\bin so its parent directory is the
rem root. Don't enable DelayedExpansion yet or we destroy PATHs that have
rem exclamation marks. Quotes needed to support ampersands.
SET "CLOUDSDK_ROOT_DIR=%~dp0.."
SET "PATH=%CLOUDSDK_ROOT_DIR%\bin\sdk;%PATH%"


rem %PYTHONHOME% can interfere with gcloud. Users should use
rem CLOUDSDK_PYTHON to configure which python gcloud uses.
SET PYTHONHOME=


SETLOCAL EnableDelayedExpansion

IF "%CLOUDSDK_PYTHON%"=="" (
  SET BUNDLED_PYTHON=!CLOUDSDK_ROOT_DIR!\platform\bundledpython\python.exe
  IF EXIST !BUNDLED_PYTHON! (
    SET CLOUDSDK_PYTHON=!BUNDLED_PYTHON!
  ) ELSE (
    SET CLOUDSDK_PYTHON=python.exe
  )
)

IF "%CLOUDSDK_PYTHON_SITEPACKAGES%" == "" (
  IF "!VIRTUAL_ENV!" == "" (
    SET CLOUDSDK_PYTHON_SITEPACKAGES=
  ) ELSE (
    SET CLOUDSDK_PYTHON_SITEPACKAGES=1
  )
)
SET CLOUDSDK_PYTHON_ARGS_NO_S=!CLOUDSDK_PYTHON_ARGS:-S=!
IF "%CLOUDSDK_PYTHON_SITEPACKAGES%" == "" (
  IF "!CLOUDSDK_PYTHON_ARGS!" == "" (
    SET CLOUDSDK_PYTHON_ARGS=-S
  ) ELSE (
    SET CLOUDSDK_PYTHON_ARGS=!CLOUDSDK_PYTHON_ARGS_NO_S! -S
  )
) ELSE IF "!CLOUDSDK_PYTHON_ARGS!" == "" (
  SET CLOUDSDK_PYTHON_ARGS=
) ELSE (
  SET CLOUDSDK_PYTHON_ARGS=!CLOUDSDK_PYTHON_ARGS_NO_S!
)

SETLOCAL DisableDelayedExpansion

rem </cloud-sdk-cmd-preamble>

"%COMSPEC%" /C ""%CLOUDSDK_PYTHON%" %CLOUDSDK_PYTHON_ARGS% "%CLOUDSDK_ROOT_DIR%\bin\bootstrapping\bq.py" %*"

"%COMSPEC%" /C exit %ERRORLEVEL%
