resource "aws_s3_bucket" "lep_demo" {
   bucket = "lep-demo-s3-bucket-1234"
   acl    = "private"

   versioning {
     enabled = true
   }
}
