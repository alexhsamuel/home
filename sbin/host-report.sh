#!/bin/bash

echo "Uptime:"
uptime
echo

echo "Disk usage:"
df -h / 
echo

echo "Bandwidth:"
echo $(/sbin/ifconfig venet0 | grep bytes)
echo

echo "New spam:"
sa-learn --spam --mbox $HOME/mail/Junk
echo

echo "SpamAssassin statistics:"
sa-learn --dump magic | egrep 'nham|nspam'
echo

echo "Mail queue:"
mailq
echo

yesterday=$(python -c '
from datetime import date
t = date.today()
y = date.fromordinal(t.toordinal() - 1)
print y.strftime("%b %d").replace(" 0", "  ")
')

echo "Mail statistics:"
num_send=$(grep -e "^$yesterday .* postfix/smtp.* relay=" /var/log/mail.log | wc -l)
num_recv=$(grep -e "^$yesterday .* postfix/qmgr.* nrcpt=" /var/log/mail.log | wc -l)
echo "email sent $num_send received $num_recv yesterday"
echo
