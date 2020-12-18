#!/usr/bin/python
import boto3
import botocore
import argparse
import time
import sys


from pprint import pprint

parser = argparse.ArgumentParser(description='Clear cloudfront CDN for a file')
parser.add_argument(
    'distribution', help="Distribution to delete from", default="DEFAULT")
parser.add_argument('--path', help="path to expire", action="append")
parser.add_argument('--request', help="Request ID to track")
parser.add_argument('--profile', help="AWS Profile to use")

args = parser.parse_args()


if not (args.request or args.path):
    parser.error('No action requested, add --request or at least one --path')

if args.profile:
    print(("Setting session to {}".format(args.profile)))
    boto3.setup_default_session(profile_name=args.profile)


cf = boto3.client('cloudfront')

distribution = args.distribution


matched = 0


def find_distro_id(cf, distribution):
    distros = cf.list_distributions()

    for distro in distros['DistributionList']['Items']:
        if distro['Id'] == distribution:
            print((" -> Distro found by ID {}".format(distro['Id'])))
            return distro['Id']
        if distro['DomainName'] == distribution:
            print(
                (" -> Distro found by Domain {} == {} ".format(distribution, distro['Id'])))
            return distro['Id']
        if distro['Aliases']['Quantity']:
            for alias in distro['Aliases']["Items"]:
                if alias == distribution:
                    print(
                        (" -> Distro found by Alias {} == {} ".format(distribution, distro['Id'])))
                    return distro['Id']
    return False


distribution = find_distro_id(cf, distribution)

if not distribution:
    print("Couldn't find matching disto")
    sys.exit(5)

if args.path:
    InvalidationBatch = {
        'Paths': {
            'Quantity': len(args.path),
            'Items': args.path
        },
        'CallerReference': str(time.time()).replace(".", "")
    }

    try:
        resp = cf.create_invalidation(
            DistributionId=distribution, InvalidationBatch=InvalidationBatch)
    except botocore.exceptions.ClientError as error:
        print('Error creating invalidation:')
        print(("AWS Error {}: {}".format(
            error.response['Error']['Code'], error.response['Error']['Message'])))
        sys.exit(5)

elif args.request:
    try:
        resp = cf.get_invalidation(
            DistributionId=distribution, Id=args.request)
    except botocore.exceptions.ClientError as error:
        print('Error fetching response:')
        print(("AWS Error {}: {}".format(
            error.response['Error']['Code'], error.response['Error']['Message'])))
        sys.exit(5)

else:
    sys.exit(5)

print(('Invalidation {} now in progress. (you can ctrl-c out of this process and recheck with --request later) '.format(
    resp['Invalidation']['Id'])))

while resp['Invalidation']['Status'] == "InProgress":
    sys.stdout.write('.')
    sys.stdout.flush()
    time.sleep(5)
    resp = cf.get_invalidation(
        DistributionId=distribution, Id=resp['Invalidation']['Id'])
print("!")

print(('Invalidation {} {}: '.format(
    resp['Invalidation']['Id'], resp['Invalidation']['Status'])))
