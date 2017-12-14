import sys, re, subprocess

# usage example:
# oc get istag | awk '/pdf/ { print $1}' | python untagger.py pdf:13 pdf:14 pdf:15 pdf:16 pdf:17 pdf:74 pdf:latest pdf:dev pdf:test pdf:prod
# ^^^^^^ above would remove all the imagestream tags from the `pdf` imagestream *except* those provided as the last set of arguments.

if __name__ == '__main__':
    to_untag = sys.argv[1:]
    print(to_untag)

while 1:
    line = sys.stdin.readline()
    if line == '':
        break

    tag = line.rstrip('\n')

    if tag not in to_untag:
        print("untagging '{}'   ".format(tag))
        subprocess.call('oc tag -d {}'.format(tag),shell=True)
    else:
        print("Not untagging '{}'".format(tag))
