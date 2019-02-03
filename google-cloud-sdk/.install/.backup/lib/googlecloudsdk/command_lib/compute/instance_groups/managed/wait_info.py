# -*- coding: utf-8 -*- #
# Copyright 2016 Google Inc. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
"""Wait messages for the compute instance groups managed commands."""


from __future__ import absolute_import
from __future__ import division
from __future__ import unicode_literals


_CURRENT_ACTION_TYPES = ['abandoning', 'creating', 'creatingWithoutRetries',
                         'deleting', 'recreating', 'refreshing', 'restarting',
                         'verifying']


_PENDING_ACTION_TYPES = ['creating', 'deleting', 'restarting', 'recreating']


def IsGroupStable(igm_ref):
  """Checks if IGM is stable.

  Args:
    igm_ref: reference to the Instance Group Manager.
  Returns:
    True if IGM is stable, false otherwise.
  """

  # TODO(b/110828064): don't check for status existence once status API is v1
  status = getattr(igm_ref, 'status', None)
  if status is not None:
    return status.isStable

  has_current_actions = any(
      getattr(igm_ref.currentActions, action, 0)
      for action in _CURRENT_ACTION_TYPES)
  if has_current_actions:
    return False

  # Pending actions are populated in alpha and beta only, so we need to check
  # for their existence.
  pending_actions = getattr(igm_ref, 'pendingActions', None)
  if pending_actions is not None:
    has_pending_actions = any(
        getattr(pending_actions, action, 0) for action in _PENDING_ACTION_TYPES)
    if has_pending_actions:
      return False

  return True


def CreateWaitText(igm_ref):
  """Creates text presented at each wait operation.

  Args:
    igm_ref: reference to the Instance Group Manager.
  Returns:
    A message with current operations count for IGM.
  """
  text = 'Waiting for group to become stable'
  current_actions_text = _CreateActionsText(
      ', current operations: ',
      igm_ref.currentActions,
      _CURRENT_ACTION_TYPES)

  # Pending actions are populated in alpha and beta only, so we need to check
  # for their existence.
  pending_actions_text = ''
  pending_actions = getattr(igm_ref, 'pendingActions', None)
  if pending_actions is not None:
    pending_actions_text = _CreateActionsText(
        ', pending operations: ', pending_actions, _PENDING_ACTION_TYPES)
  return text + current_actions_text + pending_actions_text


def _CreateActionsText(text, igm_field, action_types):
  """Creates text presented at each wait operation for given IGM field.

  Args:
    text: the text associated with the field.
    igm_field: reference to a field in the Instance Group Manager.
    action_types: array with field values to be counted.
  Returns:
    A message with given field and action types count for IGM.
  """
  actions = []
  for action in action_types:
    action_count = getattr(igm_field, action, None) or 0
    if action_count > 0:
      actions.append('{0}: {1}'.format(action, action_count))
  return text + ', '.join(actions) if actions else ''
