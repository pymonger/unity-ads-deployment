resource "aws_cloudformation_stack" "dev" {
  name = "awsDevDockstoreStack"

  parameters = {
    ResourcePrefix = "${var.resource_prefix}"
    VpcId = data.aws_vpc.unity_vpc.id
    SubnetId1 = tolist(data.aws_subnets.unity_public_subnets.ids)[0]
    SubnetId2 = tolist(data.aws_subnets.unity_public_subnets.ids)[1]
  }


  template_body = file("./load_balancer-dev.yml")

}



