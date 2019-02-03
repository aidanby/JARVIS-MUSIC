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
"""Create node template command."""

from __future__ import absolute_import
from __future__ import division
from __future__ import unicode_literals

from googlecloudsdk.api_lib.compute import base_classes
from googlecloudsdk.api_lib.util import apis
from googlecloudsdk.calliope import base
from googlecloudsdk.command_lib.compute import flags as compute_flags
from googlecloudsdk.command_lib.compute.sole_tenancy.node_templates import flags
from googlecloudsdk.command_lib.compute.sole_tenancy.node_templates import util


def _CommonArgs(parser):
  """Common arguments for each release track."""
  flags.MakeNodeTemplateArg().AddArgument(parser)
  flags.AddCreateArgsToParser(parser)


def _Run(args, track, enable_server_binding=False):
  """Creates a node template."""
  holder = base_classes.ComputeApiHolder(track)
  client = holder.client

  node_template_ref = flags.MakeNodeTemplateArg().ResolveAsResource(
      args, holder.resources,
      scope_lister=compute_flags.GetDefaultScopeLister(holder.client))

  messages = holder.client.messages
  node_template = util.CreateNodeTemplate(node_template_ref, args, messages,
                                          enable_server_binding)
  request = messages.ComputeNodeTemplatesInsertRequest(
      nodeTemplate=node_template,
      project=node_template_ref.project,
      region=node_template_ref.region)

  service = holder.client.apitools_client.nodeTemplates
  return client.MakeRequests([(service, 'Insert', request)])[0]


@base.ReleaseTracks(base.ReleaseTrack.GA, base.ReleaseTrack.BETA)
class Create(base.CreateCommand):
  """Creates a Google Compute Engine node template."""

  @staticmethod
  def Args(parser):
    _CommonArgs(parser)

  def Run(self, args):
    return _Run(args, self.ReleaseTrack())


@base.ReleaseTracks(base.ReleaseTrack.ALPHA)
class CreateAlpha(Create):
  """Creates a Google Compute Engine node template."""

  @staticmethod
  def Args(parser):
    _CommonArgs(parser)
    messages = apis.GetMessagesModule('compute', 'alpha')
    flags.GetServerBindingMapperFlag(messages).choice_arg.AddToParser(parser)

  def Run(self, args):
    return _Run(args, self.ReleaseTrack(), enable_server_binding=True)
