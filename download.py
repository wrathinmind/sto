import base64
import json
import requests
import sys
import re
import os

link = sys.argv[1]
outfile = sys.argv[2]

ua = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36'
headers = {
    'User-Agent': ua
}
data = requests.get(link, headers=headers)
redirects = re.findall(r'/redirect/[0-9]+', data.text)
if not redirects:
    print("episode not found, exiting")
    exit()

redirect = redirects[0]

data = requests.get(f"https://s.to{redirect}", headers=headers, allow_redirects=True)
redirects = re.findall(r"window.location.href = '(.*?)'", data.text)
if not redirects:
    print("redirect not found, exiting")
    exit()
redirect = redirects[0]
data = requests.get(redirect, headers=headers)
encrypted_data = re.findall(r'<script type="application/json">\["(.*?)"\]</script>', data.text)
if not encrypted_data:
    print("could not find encrypted link, exiting")
    exit()

encrypted_text = encrypted_data[0]


def decode(encrypted_text):
    def dec_1(data):
        out = ''
        for c in data:
            if ord(c) >= 0x41 and ord(c) <= 0x5a:
                out += chr((ord(c) - 0x41 + 0xd) % 0x1a + 0x41)
            elif ord(c) >= 0x61 and ord(c) <= 0x7a:
                out += chr((ord(c) - 0x61 + 0xd) % 0x1a + 0x61)
            else:
                out += c
        return out 

    def dec_2(data):
        out = ''
        for c in data:
            if c in 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=':
                out += c
        return out 

    def dec_3(data, k):
        out = ''
        for c in data:
            out += chr(ord(c) -k )
        return out 


    e1 = dec_1(encrypted_text)
    e2 = dec_2(e1)
    e3 = base64.b64decode(e2.encode()).decode()
    e4 = dec_3(e3, 3)
    e5 = e4[::-1]
    e6 = base64.b64decode(e5.encode()).decode()
    return json.loads(e6)


data = decode(encrypted_text)
link = data['source']
print(f"source link: {link}")

cmd = f"ffmpeg -user_agent '{ua}' -i '{link}' -y {outfile}"
print(cmd)
os.system(cmd)













