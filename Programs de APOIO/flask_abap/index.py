# microserviçops
# design pater IDE classes 

import os
import flask
import flask_restful
# import sys
# import requests
# import json


# from OpenSSL import SSL
# context = SSL.Context(SSL.)
# context.use_privatekey_file('ca.key')
# context.use_certificate_file('ca.pem')

# import importlib
# from Modulos.Instanciadora import instanciadora

# ficha = instanciadora()

api = flask.Flask(__name__)
port = int(os.environ.get('PORT', 5723))

postApi = flask_restful.Api(api)
@api.route('/')
def root(): 
    return('Olá mundo')


if __name__ == '__main__':
    api.run(host='0.0.0.0', port=port)