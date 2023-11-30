#############################
# Jupyterlab common variables
# These come from the top level variables

variable "tenant_identifier" {
  description = "String identifying the tenant for which resources are created, string inserted into generated resource names"
  type        = string
}

variable "resource_prefix" {
  description = "String used at the beginning of the names for all resources to identify them according to the UADS subsystem"
  type        = string
}

variable "load_balancer_port" {
  description = "Incoming port where load balancer will accept traffic"
  type       = number
}

variable "jupyter_proxy_port" {
  description = "Listening port for Jupyter kubernetes cluster"
  type       = number
}

###################################
# Frontend module common variables

variable "vpc_id" {
  description = "VPC id for load balancer target group"
  type        = string
}

variable "lb_subnet_ids" {
  description = "Subnet ids for the load balancer"
  type        = list
}

variable "security_group_id" {
  description = "Security group id giving access to load balancer to Jupyter EKS cluster"
  type        = string
}

variable "autoscaling_group_name" {
  description = "Name of the EKS cluster autoscaling group to connect to the front end"
  type        = string
}

###########################
# Module specific variables

# ... None yet ...
