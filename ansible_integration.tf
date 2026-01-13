### not requiring anymore. This doesnt work because i am running terraform from cloud.check "

/*
resource "local_file" "ansible_rds_vars" {
  filename = "${path.root}/Ansible/group_vars/all/rds_vars_${var.environment}.yml"

  content = <<-EOT
    aws_region: "${var.aws_region}"
    rds_endpoint: "${aws_db_instance.a_rds_instance.endpoint}"
    rds_secret_name: "${aws_secretsmanager_secret.a_rds_password_secret.name}"
    rds_db_name: "${aws_db_instance.a_rds_instance.db_name}"
    rds_username: "${aws_db_instance.a_rds_instance.username}"
  EOT
}
*/