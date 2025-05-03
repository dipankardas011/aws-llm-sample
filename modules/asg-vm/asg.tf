resource "aws_autoscaling_group" "bar" {
  desired_capacity = 1
  max_size         = var.sg_max_instances
  min_size         = 1
  name             = local.asg_name

  warm_pool {
    min_size                    = 1
    max_group_prepared_capacity = 1
  }

  vpc_zone_identifier = var.subnet_ids

  mixed_instances_policy {
    instances_distribution {
      on_demand_base_capacity                  = 0
      on_demand_percentage_above_base_capacity = 25
      spot_allocation_strategy                 = "lowest-price"
    }

    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.launch_templ.id
        version            = "$Latest"
      }
    }
  }
}

output "asg_details" {
  value = {
    id   = aws_autoscaling_group.bar.id
    name = aws_autoscaling_group.bar.name
  }
}