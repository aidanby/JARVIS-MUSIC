# -*- coding: utf-8 -*- #
# Copyright 2018 Google Inc. All Rights Reserved.
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
"""Command for asset operations describe."""

from __future__ import absolute_import
from __future__ import division
from __future__ import unicode_literals

from googlecloudsdk.api_lib.asset import client_util
from googlecloudsdk.calliope import base
from googlecloudsdk.command_lib.asset import flags


class Describe(base.DescribeCommand):
  """Describe a cloud asset operation."""

  @staticmethod
  def Args(parser):
    flags.AddOperationArgs(parser)

  def Run(self, args):
    client = client_util.GetClient()
    message_module = client_util.GetMessages()
    operation_name = args.id
    if operation_name.startswith('projects'):
      service = client.projects_operations
      message = message_module.CloudassetProjectsOperationsGetRequest
    else:
      service = client.organizations_operations
      message = message_module.CloudassetOrganizationsOperationsGetRequest
    return service.Get(message(name=args.id))
