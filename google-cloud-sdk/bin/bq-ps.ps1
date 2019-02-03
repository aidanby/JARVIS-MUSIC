# Copyright 2013 Google Inc. All Rights Reserved.

${CLOUDSDK_PS1_PREAMBLE}

# Powershell properly escapes arguments passed by array.
$run_args_array = @() # empty array
if ($cloudsdk_python_args) {
  $run_args_array += $cloudsdk_python_args.split(' ')
}
$run_args_array += (Join-Path $cloudsdk_root_dir 'bin\bootstrapping\bq.py')
$run_args_array += $args

if ($MyInvocation.ExpectingInput) {
  $input | & "$cloudsdk_python" $run_args_array
} else {
  & "$cloudsdk_python" $run_args_array
}

Restore-Environment $origEnv

exit $LastExitCode
