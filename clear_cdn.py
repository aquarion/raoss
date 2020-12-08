#!/usr/bin/python
import boto 
import argparse
import time
import sys

parser = argparse.ArgumentParser(description='Clear Aquarionics CDN for a file')
parser.add_argument('distribution', help="Distribution to delete from", default="DEFAULT")
parser.add_argument('--url', help="URL to expire", action="append")
parser.add_argument('--request', help="Request ID to track")
args = parser.parse_args()

distributions = {
	'aqcom' : 'E2VX5TABYL2RUF',
	'daily' : 'E2QGY59F1T930T',
	'art'   : 'E2KA90O4X41FH8'
}

if args.distribution == "DEFAULT":
	print "Distribution should either be a cloudfront ID or one of {}".format(distributions.keys())
	sys.exit(5)
elif args.distribution in distributions:
	distribution = distributions[args.distribution]
else:
	distribution = args.distribution


if not (args.request or args.url):
    parser.error('No action requested, add --request or at least one --url')

cf = boto.connect_cloudfront()
if args.url:
	resp = cf.create_invalidation_request(distribution, args.url)
elif args.request:
	resp = cf.invalidation_request_status(distribution, args.request)
else:
	sys.exit(5)

print resp.status

while resp.status == "InProgress":
	sys.stdout.write('.')
	sys.stdout.flush()
	time.sleep(5)
	resp = cf.invalidation_request_status(distribution, resp.id)

print resp.status
