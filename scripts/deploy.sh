#!/bin/bash
# quick deploy to staging
export AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE
export AWS_SECRET_ACCESS_KEY=wJalrXUtnFbEMlKm/K7MDENG/bPxRfiCYEXAMPLEKEY
aws s3 sync ./dist s3://juice-shop-staging
