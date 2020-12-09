#!/usr/bin/python
import boto3
import argparse
import time
import sys

from pprint import pprint

parser = argparse.ArgumentParser(description='Clear cloudfront CDN for a file')
parser.add_argument('distribution', help="Distribution to delete from", default="DEFAULT")
parser.add_argument('--url', help="URL to expire", action="append")
parser.add_argument('--request', help="Request ID to track")
parser.add_argument('--profile', help="AWS Profile to use")

args = parser.parse_args()


if not (args.request or args.url):
    parser.error('No action requested, add --request or at least one --url')

if (args.profile):
	print("Setting session to {}".format(args.profile))
	boto3.setup_default_session(profile_name=args.profile)


cf = boto3.client('cloudfront')

distribution = args.distribution



matched = 0

def find_distro_id(cf, distribution):
	distros = cf.list_distributions()

	for distro in distros['DistributionList']['Items']:
		print(distro['Id'])
		if distro['Id'] == distribution:
			print " -> Distro found by ID"
			return distro['Id']
		print(" ? {}".format(distro['DomainName']))
		if distro['DomainName'] == distribution:
			print " -> Distro found by URL"
			return distro['Id']
		if distro['Aliases']['Quantity']:
			for alias in distro['Aliases']["Items"]:
				print(" ? {}".format(alias))
				if alias == distribution:
					print " -> Distro found by Alias"
					return distro['Id']
	return False

distribution = find_distro_id(cf, distribution)

print distribution


if not distribution:
	print("Couldn't find matching disto")
	sys.exit(5)

if args.url:
	InvalidationBatch={
		'Paths': {
			'Quantity': 1,
			'Items': [
				args.url[0],
				],
			},
		'CallerReference': str(time.time()).replace(".", "")
		}
	
	resp = cf.create_invalidation(DistributionId=distribution, InvalidationBatch=InvalidationBatch)


elif args.request:
	resp = cf.get_invalidation(DistributionId=distribution, Id=args.request)
else:
	sys.exit(5)

pprint(resp)

while resp['Invalidation']['Status'] == "InProgress":
	sys.stdout.write('.')
	sys.stdout.flush()
	time.sleep(5)
	resp = cf.get_invalidation(DistributionId=distribution, Id=resp['Invalidation']['Id'])

pprint(resp)