# common parameter
base_name                  = "mirror-dev"
ec2_ami_id                 = "ami-055b91c377120f669" #2022/08/17 ap-northeast-1
vpc_id                     = "vpc-00000bf9999e11111"
ec2_instance_type          = "t2.large"
ec2_subnet_id              = "subnet-000f6d84y2e7t6de1"
ec2_root_block_volume_size = 50
ec2_key_name               = "YOURKEY"
sg_allow_access_cidrs = [
  "192.0.2.0/24",
]
sg_allow_vpc_cidr          = "192.168.0.0/16"
cloudwatch_enable_schedule = false
cloudwatch_start_schedule  = "cron(30 23 ? * 1-5 *)"
cloudwatch_stop_schedule   = "cron(0 13 ? * 2-6 *)"
