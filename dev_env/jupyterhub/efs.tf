resource "aws_security_group" "dev_support_efs_jupyter_sg" {
   name = "${var.resource_prefix}-${var.tenant_identifier}-efs-jupyter-sg"
   description= "Allows inbound EFS traffic from Jupyter cluster"
   vpc_id = data.aws_vpc.unity_vpc.id

   ingress {
     security_groups = [ for vc in aws_eks_cluster.jupyter_cluster.vpc_config: vc.cluster_security_group_id ]
     from_port = 2049
     to_port = 2049 
     protocol = "tcp"
   }     
        
   egress {
     security_groups = [ for vc in aws_eks_cluster.jupyter_cluster.vpc_config: vc.cluster_security_group_id ]
     from_port = 0
     to_port = 0
     protocol = "-1"
   }
}

resource "aws_efs_mount_target" "dev_support_efs_mt_1" {
   file_system_id  = data.aws_efs_file_system.dev_support_fs.id
   subnet_id       = local.az_subnet_ids[var.availability_zone_1].private[0]
   security_groups = [aws_security_group.dev_support_efs_jupyter_sg.id]
}

resource "aws_efs_mount_target" "dev_support_efs_mt_2" {
   file_system_id  = data.aws_efs_file_system.dev_support_fs.id
   subnet_id       = local.az_subnet_ids[var.availability_zone_2].private[0]
   security_groups = [aws_security_group.dev_support_efs_jupyter_sg.id]
}

# Follows setup here:
# https://aws.amazon.com/blogs/storage/persistent-storage-for-kubernetes/

resource "kubernetes_storage_class" "efs_storage_class" {
  metadata {
    name = "efs"
  }
  storage_provisioner = "efs.csi.aws.com"
  reclaim_policy      = "Retain"

  parameters = {
  }
}

resource "kubernetes_persistent_volume" "dev_support_shared_volume" {
  metadata {
    name = "${var.resource_prefix}-${var.tenant_identifier}-dev-data"
  }

  spec {
    access_modes = ["ReadWriteMany"]
    storage_class_name = "efs"

    capacity = {
      storage = "100Gi"
    }

    persistent_volume_reclaim_policy = "Retain"

    persistent_volume_source {
      csi {
        driver = "efs.csi.aws.com"
        volume_handle = "${data.aws_efs_file_system.dev_support_fs.id}"
      }
    }

  }

  # Prevents a cycle with eks_cluster.jupyter_hub
  depends_on = [ 
    kubernetes_storage_class.efs_storage_class,
    aws_efs_mount_target.dev_support_efs_mt_1,
    aws_efs_mount_target.dev_support_efs_mt_2
  ]
}

resource "kubernetes_persistent_volume_claim" "dev_support_shared_volume_claim" {
  metadata {
    name = "${var.resource_prefix}-${var.tenant_identifier}-dev-data"
    namespace = helm_release.jupyter_helm.namespace
  }

  spec {
    access_modes = ["ReadWriteMany"]

    storage_class_name = "efs"

    resources {
      requests = {
        storage = "100Gi"
      }
    }

    volume_name = "${kubernetes_persistent_volume.dev_support_shared_volume.metadata.0.name}"
  }

  # Prevents a cycle with eks_cluster.jupyter_hub
  depends_on = [ 
    kubernetes_persistent_volume.dev_support_shared_volume
  ]
}