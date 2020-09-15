# AWS CloudFront Deployment

This module creates an AWS CloudFront deployment by creating an S3 Bucket and CloudFront distribution. The S3 Bucket created is used as the CloudFront origin.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | ~> 0.12.29 |
| aws | ~> 2.53 |
| template | ~> 2.1 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 2.53 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| acm\_certificate\_arn | ARN of the corresponding ACM SSL to use with this deployment. | `string` | n/a | yes |
| dns\_names | DNS names to associate with this deployment | `list(string)` | n/a | yes |
| dns\_zone | Name of the DNS zone to use with this deployment. | `string` | n/a | yes |
| environment\_name | Name of environment. | `string` | n/a | yes |
| name | Name of this deployment. | `string` | n/a | yes |
| namespace | Determines naming convention of assets. Generally follows DNS naming convention. | `string` | n/a | yes |
| s3\_bucket | S3 Bucket name that will be created for this deployment. | `string` | n/a | yes |
| tags | A mapping of tags to assign to the AWS resources. | `map(string)` | n/a | yes |
| cors\_rule | CORS rule to apply to s3 bucket | <pre>list(object({<br>    allowed_headers = list(string)<br>    allowed_methods = list(string)<br>    allowed_origins = list(string)<br>    expose_headers  = list(string)<br>    max_age_seconds = number<br>  }))</pre> | `[]` | no |
| is\_ipv6\_enabled | (Optional) - Whether the IPv6 is enabled for the distribution. | `bool` | `true` | no |
| private\_dns | If true, this module will create Route53 DNS records in a private zone | `bool` | `false` | no |
| use\_external\_dns | If true, this module will not create any Route53 DNS records. | `bool` | `false` | no |
| web\_acl\_id | (Optional) - If you're using AWS WAF to filter CloudFront requests, the Id of the AWS WAF web ACL that is associated with the distribution. | `string` | `null` | no |
| whitelisted\_headers | List of whitelisted headers for this CloudFront distribution. | `list(string)` | <pre>[<br>  "Origin"<br>]</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| cloudfront\_domain\_name | n/a |
| cloudfront\_id | n/a |
| s3\_bucket\_name | n/a |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->