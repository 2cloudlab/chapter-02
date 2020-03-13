# IAM policy module

This module will create 4 groups of policies, as shown below:

1. AWS managed policy
2. Custom managed policy
3. Trust policy for role
4. Assume policy for group

This module only provide policies in json format, so it will only pull policy resources from AWS Web Service.

All polices that attach to IAM Group can config with 