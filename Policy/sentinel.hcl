# Defines WHICH policies exist and HOW to enforce them
policy "restrict-ec2-instance-type" {
    source            = "./restrict-ec2-instance-type.sentinel"
    enforcement_level = "advisory"
}
