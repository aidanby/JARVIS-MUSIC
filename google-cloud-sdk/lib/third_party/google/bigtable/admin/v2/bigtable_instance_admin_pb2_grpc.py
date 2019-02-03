# Generated by the gRPC Python protocol compiler plugin. DO NOT EDIT!
import grpc

from google.bigtable.admin.v2 import bigtable_instance_admin_pb2 as google_dot_bigtable_dot_admin_dot_v2_dot_bigtable__instance__admin__pb2
from google.bigtable.admin.v2 import instance_pb2 as google_dot_bigtable_dot_admin_dot_v2_dot_instance__pb2
from google.iam.v1 import iam_policy_pb2 as google_dot_iam_dot_v1_dot_iam__policy__pb2
from google.iam.v1 import policy_pb2 as google_dot_iam_dot_v1_dot_policy__pb2
from google.longrunning import operations_pb2 as google_dot_longrunning_dot_operations__pb2
from google.protobuf import empty_pb2 as google_dot_protobuf_dot_empty__pb2


class BigtableInstanceAdminStub(object):
  """Service for creating, configuring, and deleting Cloud Bigtable Instances and
  Clusters. Provides access to the Instance and Cluster schemas only, not the
  tables' metadata or data stored in those tables.
  """

  def __init__(self, channel):
    """Constructor.

    Args:
      channel: A grpc.Channel.
    """
    self.CreateInstance = channel.unary_unary(
        '/google.bigtable.admin.v2.BigtableInstanceAdmin/CreateInstance',
        request_serializer=google_dot_bigtable_dot_admin_dot_v2_dot_bigtable__instance__admin__pb2.CreateInstanceRequest.SerializeToString,
        response_deserializer=google_dot_longrunning_dot_operations__pb2.Operation.FromString,
        )
    self.GetInstance = channel.unary_unary(
        '/google.bigtable.admin.v2.BigtableInstanceAdmin/GetInstance',
        request_serializer=google_dot_bigtable_dot_admin_dot_v2_dot_bigtable__instance__admin__pb2.GetInstanceRequest.SerializeToString,
        response_deserializer=google_dot_bigtable_dot_admin_dot_v2_dot_instance__pb2.Instance.FromString,
        )
    self.ListInstances = channel.unary_unary(
        '/google.bigtable.admin.v2.BigtableInstanceAdmin/ListInstances',
        request_serializer=google_dot_bigtable_dot_admin_dot_v2_dot_bigtable__instance__admin__pb2.ListInstancesRequest.SerializeToString,
        response_deserializer=google_dot_bigtable_dot_admin_dot_v2_dot_bigtable__instance__admin__pb2.ListInstancesResponse.FromString,
        )
    self.UpdateInstance = channel.unary_unary(
        '/google.bigtable.admin.v2.BigtableInstanceAdmin/UpdateInstance',
        request_serializer=google_dot_bigtable_dot_admin_dot_v2_dot_instance__pb2.Instance.SerializeToString,
        response_deserializer=google_dot_bigtable_dot_admin_dot_v2_dot_instance__pb2.Instance.FromString,
        )
    self.PartialUpdateInstance = channel.unary_unary(
        '/google.bigtable.admin.v2.BigtableInstanceAdmin/PartialUpdateInstance',
        request_serializer=google_dot_bigtable_dot_admin_dot_v2_dot_bigtable__instance__admin__pb2.PartialUpdateInstanceRequest.SerializeToString,
        response_deserializer=google_dot_longrunning_dot_operations__pb2.Operation.FromString,
        )
    self.DeleteInstance = channel.unary_unary(
        '/google.bigtable.admin.v2.BigtableInstanceAdmin/DeleteInstance',
        request_serializer=google_dot_bigtable_dot_admin_dot_v2_dot_bigtable__instance__admin__pb2.DeleteInstanceRequest.SerializeToString,
        response_deserializer=google_dot_protobuf_dot_empty__pb2.Empty.FromString,
        )
    self.CreateCluster = channel.unary_unary(
        '/google.bigtable.admin.v2.BigtableInstanceAdmin/CreateCluster',
        request_serializer=google_dot_bigtable_dot_admin_dot_v2_dot_bigtable__instance__admin__pb2.CreateClusterRequest.SerializeToString,
        response_deserializer=google_dot_longrunning_dot_operations__pb2.Operation.FromString,
        )
    self.GetCluster = channel.unary_unary(
        '/google.bigtable.admin.v2.BigtableInstanceAdmin/GetCluster',
        request_serializer=google_dot_bigtable_dot_admin_dot_v2_dot_bigtable__instance__admin__pb2.GetClusterRequest.SerializeToString,
        response_deserializer=google_dot_bigtable_dot_admin_dot_v2_dot_instance__pb2.Cluster.FromString,
        )
    self.ListClusters = channel.unary_unary(
        '/google.bigtable.admin.v2.BigtableInstanceAdmin/ListClusters',
        request_serializer=google_dot_bigtable_dot_admin_dot_v2_dot_bigtable__instance__admin__pb2.ListClustersRequest.SerializeToString,
        response_deserializer=google_dot_bigtable_dot_admin_dot_v2_dot_bigtable__instance__admin__pb2.ListClustersResponse.FromString,
        )
    self.UpdateCluster = channel.unary_unary(
        '/google.bigtable.admin.v2.BigtableInstanceAdmin/UpdateCluster',
        request_serializer=google_dot_bigtable_dot_admin_dot_v2_dot_instance__pb2.Cluster.SerializeToString,
        response_deserializer=google_dot_longrunning_dot_operations__pb2.Operation.FromString,
        )
    self.DeleteCluster = channel.unary_unary(
        '/google.bigtable.admin.v2.BigtableInstanceAdmin/DeleteCluster',
        request_serializer=google_dot_bigtable_dot_admin_dot_v2_dot_bigtable__instance__admin__pb2.DeleteClusterRequest.SerializeToString,
        response_deserializer=google_dot_protobuf_dot_empty__pb2.Empty.FromString,
        )
    self.CreateAppProfile = channel.unary_unary(
        '/google.bigtable.admin.v2.BigtableInstanceAdmin/CreateAppProfile',
        request_serializer=google_dot_bigtable_dot_admin_dot_v2_dot_bigtable__instance__admin__pb2.CreateAppProfileRequest.SerializeToString,
        response_deserializer=google_dot_bigtable_dot_admin_dot_v2_dot_instance__pb2.AppProfile.FromString,
        )
    self.GetAppProfile = channel.unary_unary(
        '/google.bigtable.admin.v2.BigtableInstanceAdmin/GetAppProfile',
        request_serializer=google_dot_bigtable_dot_admin_dot_v2_dot_bigtable__instance__admin__pb2.GetAppProfileRequest.SerializeToString,
        response_deserializer=google_dot_bigtable_dot_admin_dot_v2_dot_instance__pb2.AppProfile.FromString,
        )
    self.ListAppProfiles = channel.unary_unary(
        '/google.bigtable.admin.v2.BigtableInstanceAdmin/ListAppProfiles',
        request_serializer=google_dot_bigtable_dot_admin_dot_v2_dot_bigtable__instance__admin__pb2.ListAppProfilesRequest.SerializeToString,
        response_deserializer=google_dot_bigtable_dot_admin_dot_v2_dot_bigtable__instance__admin__pb2.ListAppProfilesResponse.FromString,
        )
    self.UpdateAppProfile = channel.unary_unary(
        '/google.bigtable.admin.v2.BigtableInstanceAdmin/UpdateAppProfile',
        request_serializer=google_dot_bigtable_dot_admin_dot_v2_dot_bigtable__instance__admin__pb2.UpdateAppProfileRequest.SerializeToString,
        response_deserializer=google_dot_longrunning_dot_operations__pb2.Operation.FromString,
        )
    self.DeleteAppProfile = channel.unary_unary(
        '/google.bigtable.admin.v2.BigtableInstanceAdmin/DeleteAppProfile',
        request_serializer=google_dot_bigtable_dot_admin_dot_v2_dot_bigtable__instance__admin__pb2.DeleteAppProfileRequest.SerializeToString,
        response_deserializer=google_dot_protobuf_dot_empty__pb2.Empty.FromString,
        )
    self.GetIamPolicy = channel.unary_unary(
        '/google.bigtable.admin.v2.BigtableInstanceAdmin/GetIamPolicy',
        request_serializer=google_dot_iam_dot_v1_dot_iam__policy__pb2.GetIamPolicyRequest.SerializeToString,
        response_deserializer=google_dot_iam_dot_v1_dot_policy__pb2.Policy.FromString,
        )
    self.SetIamPolicy = channel.unary_unary(
        '/google.bigtable.admin.v2.BigtableInstanceAdmin/SetIamPolicy',
        request_serializer=google_dot_iam_dot_v1_dot_iam__policy__pb2.SetIamPolicyRequest.SerializeToString,
        response_deserializer=google_dot_iam_dot_v1_dot_policy__pb2.Policy.FromString,
        )
    self.TestIamPermissions = channel.unary_unary(
        '/google.bigtable.admin.v2.BigtableInstanceAdmin/TestIamPermissions',
        request_serializer=google_dot_iam_dot_v1_dot_iam__policy__pb2.TestIamPermissionsRequest.SerializeToString,
        response_deserializer=google_dot_iam_dot_v1_dot_iam__policy__pb2.TestIamPermissionsResponse.FromString,
        )


class BigtableInstanceAdminServicer(object):
  """Service for creating, configuring, and deleting Cloud Bigtable Instances and
  Clusters. Provides access to the Instance and Cluster schemas only, not the
  tables' metadata or data stored in those tables.
  """

  def CreateInstance(self, request, context):
    """Create an instance within a project.
    """
    context.set_code(grpc.StatusCode.UNIMPLEMENTED)
    context.set_details('Method not implemented!')
    raise NotImplementedError('Method not implemented!')

  def GetInstance(self, request, context):
    """Gets information about an instance.
    """
    context.set_code(grpc.StatusCode.UNIMPLEMENTED)
    context.set_details('Method not implemented!')
    raise NotImplementedError('Method not implemented!')

  def ListInstances(self, request, context):
    """Lists information about instances in a project.
    """
    context.set_code(grpc.StatusCode.UNIMPLEMENTED)
    context.set_details('Method not implemented!')
    raise NotImplementedError('Method not implemented!')

  def UpdateInstance(self, request, context):
    """Updates an instance within a project.
    """
    context.set_code(grpc.StatusCode.UNIMPLEMENTED)
    context.set_details('Method not implemented!')
    raise NotImplementedError('Method not implemented!')

  def PartialUpdateInstance(self, request, context):
    """Partially updates an instance within a project.
    """
    context.set_code(grpc.StatusCode.UNIMPLEMENTED)
    context.set_details('Method not implemented!')
    raise NotImplementedError('Method not implemented!')

  def DeleteInstance(self, request, context):
    """Delete an instance from a project.
    """
    context.set_code(grpc.StatusCode.UNIMPLEMENTED)
    context.set_details('Method not implemented!')
    raise NotImplementedError('Method not implemented!')

  def CreateCluster(self, request, context):
    """Creates a cluster within an instance.
    """
    context.set_code(grpc.StatusCode.UNIMPLEMENTED)
    context.set_details('Method not implemented!')
    raise NotImplementedError('Method not implemented!')

  def GetCluster(self, request, context):
    """Gets information about a cluster.
    """
    context.set_code(grpc.StatusCode.UNIMPLEMENTED)
    context.set_details('Method not implemented!')
    raise NotImplementedError('Method not implemented!')

  def ListClusters(self, request, context):
    """Lists information about clusters in an instance.
    """
    context.set_code(grpc.StatusCode.UNIMPLEMENTED)
    context.set_details('Method not implemented!')
    raise NotImplementedError('Method not implemented!')

  def UpdateCluster(self, request, context):
    """Updates a cluster within an instance.
    """
    context.set_code(grpc.StatusCode.UNIMPLEMENTED)
    context.set_details('Method not implemented!')
    raise NotImplementedError('Method not implemented!')

  def DeleteCluster(self, request, context):
    """Deletes a cluster from an instance.
    """
    context.set_code(grpc.StatusCode.UNIMPLEMENTED)
    context.set_details('Method not implemented!')
    raise NotImplementedError('Method not implemented!')

  def CreateAppProfile(self, request, context):
    """Creates an app profile within an instance.
    """
    context.set_code(grpc.StatusCode.UNIMPLEMENTED)
    context.set_details('Method not implemented!')
    raise NotImplementedError('Method not implemented!')

  def GetAppProfile(self, request, context):
    """Gets information about an app profile.
    """
    context.set_code(grpc.StatusCode.UNIMPLEMENTED)
    context.set_details('Method not implemented!')
    raise NotImplementedError('Method not implemented!')

  def ListAppProfiles(self, request, context):
    """Lists information about app profiles in an instance.
    """
    context.set_code(grpc.StatusCode.UNIMPLEMENTED)
    context.set_details('Method not implemented!')
    raise NotImplementedError('Method not implemented!')

  def UpdateAppProfile(self, request, context):
    """Updates an app profile within an instance.
    """
    context.set_code(grpc.StatusCode.UNIMPLEMENTED)
    context.set_details('Method not implemented!')
    raise NotImplementedError('Method not implemented!')

  def DeleteAppProfile(self, request, context):
    """Deletes an app profile from an instance.
    """
    context.set_code(grpc.StatusCode.UNIMPLEMENTED)
    context.set_details('Method not implemented!')
    raise NotImplementedError('Method not implemented!')

  def GetIamPolicy(self, request, context):
    """Gets the access control policy for an instance resource. Returns an empty
    policy if an instance exists but does not have a policy set.
    """
    context.set_code(grpc.StatusCode.UNIMPLEMENTED)
    context.set_details('Method not implemented!')
    raise NotImplementedError('Method not implemented!')

  def SetIamPolicy(self, request, context):
    """Sets the access control policy on an instance resource. Replaces any
    existing policy.
    """
    context.set_code(grpc.StatusCode.UNIMPLEMENTED)
    context.set_details('Method not implemented!')
    raise NotImplementedError('Method not implemented!')

  def TestIamPermissions(self, request, context):
    """Returns permissions that the caller has on the specified instance resource.
    """
    context.set_code(grpc.StatusCode.UNIMPLEMENTED)
    context.set_details('Method not implemented!')
    raise NotImplementedError('Method not implemented!')


def add_BigtableInstanceAdminServicer_to_server(servicer, server):
  rpc_method_handlers = {
      'CreateInstance': grpc.unary_unary_rpc_method_handler(
          servicer.CreateInstance,
          request_deserializer=google_dot_bigtable_dot_admin_dot_v2_dot_bigtable__instance__admin__pb2.CreateInstanceRequest.FromString,
          response_serializer=google_dot_longrunning_dot_operations__pb2.Operation.SerializeToString,
      ),
      'GetInstance': grpc.unary_unary_rpc_method_handler(
          servicer.GetInstance,
          request_deserializer=google_dot_bigtable_dot_admin_dot_v2_dot_bigtable__instance__admin__pb2.GetInstanceRequest.FromString,
          response_serializer=google_dot_bigtable_dot_admin_dot_v2_dot_instance__pb2.Instance.SerializeToString,
      ),
      'ListInstances': grpc.unary_unary_rpc_method_handler(
          servicer.ListInstances,
          request_deserializer=google_dot_bigtable_dot_admin_dot_v2_dot_bigtable__instance__admin__pb2.ListInstancesRequest.FromString,
          response_serializer=google_dot_bigtable_dot_admin_dot_v2_dot_bigtable__instance__admin__pb2.ListInstancesResponse.SerializeToString,
      ),
      'UpdateInstance': grpc.unary_unary_rpc_method_handler(
          servicer.UpdateInstance,
          request_deserializer=google_dot_bigtable_dot_admin_dot_v2_dot_instance__pb2.Instance.FromString,
          response_serializer=google_dot_bigtable_dot_admin_dot_v2_dot_instance__pb2.Instance.SerializeToString,
      ),
      'PartialUpdateInstance': grpc.unary_unary_rpc_method_handler(
          servicer.PartialUpdateInstance,
          request_deserializer=google_dot_bigtable_dot_admin_dot_v2_dot_bigtable__instance__admin__pb2.PartialUpdateInstanceRequest.FromString,
          response_serializer=google_dot_longrunning_dot_operations__pb2.Operation.SerializeToString,
      ),
      'DeleteInstance': grpc.unary_unary_rpc_method_handler(
          servicer.DeleteInstance,
          request_deserializer=google_dot_bigtable_dot_admin_dot_v2_dot_bigtable__instance__admin__pb2.DeleteInstanceRequest.FromString,
          response_serializer=google_dot_protobuf_dot_empty__pb2.Empty.SerializeToString,
      ),
      'CreateCluster': grpc.unary_unary_rpc_method_handler(
          servicer.CreateCluster,
          request_deserializer=google_dot_bigtable_dot_admin_dot_v2_dot_bigtable__instance__admin__pb2.CreateClusterRequest.FromString,
          response_serializer=google_dot_longrunning_dot_operations__pb2.Operation.SerializeToString,
      ),
      'GetCluster': grpc.unary_unary_rpc_method_handler(
          servicer.GetCluster,
          request_deserializer=google_dot_bigtable_dot_admin_dot_v2_dot_bigtable__instance__admin__pb2.GetClusterRequest.FromString,
          response_serializer=google_dot_bigtable_dot_admin_dot_v2_dot_instance__pb2.Cluster.SerializeToString,
      ),
      'ListClusters': grpc.unary_unary_rpc_method_handler(
          servicer.ListClusters,
          request_deserializer=google_dot_bigtable_dot_admin_dot_v2_dot_bigtable__instance__admin__pb2.ListClustersRequest.FromString,
          response_serializer=google_dot_bigtable_dot_admin_dot_v2_dot_bigtable__instance__admin__pb2.ListClustersResponse.SerializeToString,
      ),
      'UpdateCluster': grpc.unary_unary_rpc_method_handler(
          servicer.UpdateCluster,
          request_deserializer=google_dot_bigtable_dot_admin_dot_v2_dot_instance__pb2.Cluster.FromString,
          response_serializer=google_dot_longrunning_dot_operations__pb2.Operation.SerializeToString,
      ),
      'DeleteCluster': grpc.unary_unary_rpc_method_handler(
          servicer.DeleteCluster,
          request_deserializer=google_dot_bigtable_dot_admin_dot_v2_dot_bigtable__instance__admin__pb2.DeleteClusterRequest.FromString,
          response_serializer=google_dot_protobuf_dot_empty__pb2.Empty.SerializeToString,
      ),
      'CreateAppProfile': grpc.unary_unary_rpc_method_handler(
          servicer.CreateAppProfile,
          request_deserializer=google_dot_bigtable_dot_admin_dot_v2_dot_bigtable__instance__admin__pb2.CreateAppProfileRequest.FromString,
          response_serializer=google_dot_bigtable_dot_admin_dot_v2_dot_instance__pb2.AppProfile.SerializeToString,
      ),
      'GetAppProfile': grpc.unary_unary_rpc_method_handler(
          servicer.GetAppProfile,
          request_deserializer=google_dot_bigtable_dot_admin_dot_v2_dot_bigtable__instance__admin__pb2.GetAppProfileRequest.FromString,
          response_serializer=google_dot_bigtable_dot_admin_dot_v2_dot_instance__pb2.AppProfile.SerializeToString,
      ),
      'ListAppProfiles': grpc.unary_unary_rpc_method_handler(
          servicer.ListAppProfiles,
          request_deserializer=google_dot_bigtable_dot_admin_dot_v2_dot_bigtable__instance__admin__pb2.ListAppProfilesRequest.FromString,
          response_serializer=google_dot_bigtable_dot_admin_dot_v2_dot_bigtable__instance__admin__pb2.ListAppProfilesResponse.SerializeToString,
      ),
      'UpdateAppProfile': grpc.unary_unary_rpc_method_handler(
          servicer.UpdateAppProfile,
          request_deserializer=google_dot_bigtable_dot_admin_dot_v2_dot_bigtable__instance__admin__pb2.UpdateAppProfileRequest.FromString,
          response_serializer=google_dot_longrunning_dot_operations__pb2.Operation.SerializeToString,
      ),
      'DeleteAppProfile': grpc.unary_unary_rpc_method_handler(
          servicer.DeleteAppProfile,
          request_deserializer=google_dot_bigtable_dot_admin_dot_v2_dot_bigtable__instance__admin__pb2.DeleteAppProfileRequest.FromString,
          response_serializer=google_dot_protobuf_dot_empty__pb2.Empty.SerializeToString,
      ),
      'GetIamPolicy': grpc.unary_unary_rpc_method_handler(
          servicer.GetIamPolicy,
          request_deserializer=google_dot_iam_dot_v1_dot_iam__policy__pb2.GetIamPolicyRequest.FromString,
          response_serializer=google_dot_iam_dot_v1_dot_policy__pb2.Policy.SerializeToString,
      ),
      'SetIamPolicy': grpc.unary_unary_rpc_method_handler(
          servicer.SetIamPolicy,
          request_deserializer=google_dot_iam_dot_v1_dot_iam__policy__pb2.SetIamPolicyRequest.FromString,
          response_serializer=google_dot_iam_dot_v1_dot_policy__pb2.Policy.SerializeToString,
      ),
      'TestIamPermissions': grpc.unary_unary_rpc_method_handler(
          servicer.TestIamPermissions,
          request_deserializer=google_dot_iam_dot_v1_dot_iam__policy__pb2.TestIamPermissionsRequest.FromString,
          response_serializer=google_dot_iam_dot_v1_dot_iam__policy__pb2.TestIamPermissionsResponse.SerializeToString,
      ),
  }
  generic_handler = grpc.method_handlers_generic_handler(
      'google.bigtable.admin.v2.BigtableInstanceAdmin', rpc_method_handlers)
  server.add_generic_rpc_handlers((generic_handler,))