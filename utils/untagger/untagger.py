import sys, re, subprocess


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
