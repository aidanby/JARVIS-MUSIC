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
"""Command for removing resource policies from a disk."""

from __future__ import absolute_import
from __future__ import division
from __future__ import unicode_literals

from googlecloudsdk.api_lib.compute import base_classes
from googlecloudsdk.api_lib.compute import disks_util as api_util
from googlecloudsdk.calliope import base
from googlecloudsdk.command_lib.compute.disks import flags as disks_flags
from googlecloudsdk.command_lib.compute.resource_policies import flags
from googlecloudsdk.command_lib.compute.resource_policies import util


@base.ReleaseTracks(base.ReleaseTrack.ALPHA)
class DisksRemoveResourcePolicies(base.UpdateCommand):
  """Remove resource policies from a Google Compute Engine disk.

    *{command}* removes resource policies from a Google Compute
    Engine virtual disk.
  """

  @staticmethod
  def Args(parser):
    disks_flags.MakeDiskArgZonalOrRegional(plural=False).AddArgument(
        parser, operation_type='remove resource policies from')
    flags.AddResourcePoliciesArgs(
        parser, 'removed from', 'disk', required=True)

  def Run(self, args):
    holder = base_classes.ComputeApiHolder(self.ReleaseTrack())
    client = holder.client.apitools_client
    messages = holder.client.messages

    disk_ref = disks_flags.MakeDiskArgZonalOrRegional(
        plural=False).ResolveAsResource(args, holder.resources)
    disk_info = api_util.GetDiskInfo(disk_ref, client, messages)
    disk_region = disk_info.GetDiskRegionName()

    resource_policies = []
    for policy in args.resource_policies:
      resource_policy_ref = util.ParseResourcePolicy(
          holder.resources,
          policy,
          project=disk_ref.project,
          region=disk_region)
      resource_policies.append(resource_policy_ref.SelfLink())

    return disk_info.MakeRemoveResourcePoliciesRequest(resource_policies,
                                                       holder.client)
