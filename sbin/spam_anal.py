#!/usr/bin/python

import email
import re
from   mailbox import UnixMailbox
import sys


class Counts(dict):

    def __lshift__(self, key):
        self[key] = self.get(key, 0) + 1



mailbox_filename = sys.argv[1]
mailbox = UnixMailbox(file(mailbox_filename, "rb"),
                      email.message_from_file)

addr_regex = re.compile(r".*<(.*)>")
received_regex = re.compile(r"from .*by .*\.indetermi\.net.*for <(.*)>")

def clean_up_addr(addr):
    addr = addr.strip().lower()
    match = addr_regex.match(addr)
    if match is not None:
        return match.group(1)
    else:
        return addr


recp_stats = Counts()
cnt = 0
for message in mailbox:
    cnt += 1

    received = message["Received"]
    if received is not None:
        received = received.replace("\n", " ")
        received = received.replace("\t", " ")
        match = received_regex.match(received)
    else:
        match = None
        
    if match is not None:
        recp_stats << clean_up_addr(match.group(1))
    else:
        to = message["To"]
        if to is not None:
            tos = map(clean_up_addr, message["To"].split(","))
            recp_stats << tos[0]

for name, count in sorted(recp_stats.iteritems()):
    print "%-32s %d" % (name, count, )
