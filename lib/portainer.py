#!/usr/bin/env python3
"""britto-wizard · helper do Portainer (mesmo fluxo do SetupOrion, em Python para não depender de jq).

Uso:
  portainer.py init   <host> <usuario> <senha>          cria o admin (primeira vez) e grava /root/dados_vps/dados_portainer
  portainer.py wait   <host>                            espera o Portainer responder (até 10 min)
  portainer.py deploy <nome> <arquivo.yaml> <env-file>  renderiza ${VAR} com o .env e cria/atualiza a stack (editável no Portainer)
  portainer.py exists <nome>                            sai 0 se a stack existe
  portainer.py ping                                     login + endpoint + Swarm visíveis

Credenciais lidas de /root/dados_vps/dados_portainer (formato do SetupOrion, compatível com ele).
"""
import json
import os
import re
import ssl
import sys
import time
import urllib.error
import urllib.request

DADOS = '/root/dados_vps/dados_portainer'
CTX = ssl.create_default_context()
CTX.check_hostname = False
CTX.verify_mode = ssl.CERT_NONE  # certificado do Let's Encrypt pode ainda não ter saído na 1ª execução


def req(base, method, path, body=None, token=None, timeout=120, headers=None):
    data = json.dumps(body).encode() if body is not None else None
    r = urllib.request.Request(base + path, method=method, data=data)
    r.add_header('Content-Type', 'application/json')
    for k, v in (headers or {}).items():
        r.add_header(k, v)
    if token:
        r.add_header('Authorization', 'Bearer ' + token)
    with urllib.request.urlopen(r, timeout=timeout, context=CTX) as resp:
        raw = resp.read()
        return json.loads(raw) if raw else None


def dados():
    d = {}
    for line in open(DADOS, encoding='utf-8'):
        if ': ' in line:
            k, v = line.rstrip('\n').split(': ', 1)
            d[k] = v
    return 'https://' + d['Dominio do portainer'].replace('https://', ''), d['Usuario'], d['Senha']


def login():
    base, user, pw = dados()
    token = req(base, 'POST', '/api/auth', {'username': user, 'password': pw})['jwt']
    endpoints = req(base, 'GET', '/api/endpoints', token=token)
    ep = next((e for e in endpoints if e.get('Name') == 'primary'), endpoints[0] if endpoints else None)
    if not ep:
        sys.exit('Portainer sem endpoint (o agente ainda não subiu?)')
    swarm = req(base, 'GET', f"/api/endpoints/{ep['Id']}/docker/swarm", token=token)['ID']
    return base, token, ep['Id'], swarm


def render(path, env_file):
    env = {}
    for line in open(env_file, encoding='utf-8'):
        line = line.rstrip('\n')
        if line and not line.startswith('#') and '=' in line:
            k, v = line.split('=', 1)
            env[k.strip()] = v
    text = open(path, encoding='utf-8').read()
    missing = set()

    def sub(m):
        k = m.group(1)
        if k in env:
            return env[k]
        missing.add(k)
        return m.group(0)

    out = re.sub(r'(?<!\$)\$\{([A-Z0-9_]+)\}', sub, text)
    if missing:
        sys.exit('Variáveis sem valor no .env: ' + ', '.join(sorted(missing)))
    return out


def cmd_init(host, user, pw):
    # Portainer 2.3x+ exige o setup token impresso no log da 1ª subida (X-Setup-Token);
    # o wizard lê o token do log e passa em PORTAINER_SETUP_TOKEN. Versões antigas ignoram o cabeçalho.
    base = 'https://' + host
    headers = {'X-Setup-Token': os.environ['PORTAINER_SETUP_TOKEN']} if os.environ.get('PORTAINER_SETUP_TOKEN') else {}
    for tentativa in range(6):
        try:
            req(base, 'POST', '/api/users/admin/init', {'Username': user, 'Password': pw}, headers=headers)
            print('admin do Portainer criado')
            break
        except urllib.error.HTTPError as e:
            if e.code == 409:
                print('admin do Portainer já existia')
                break
            if tentativa == 5:
                raise
            time.sleep(10)
    os.makedirs('/root/dados_vps', mode=0o700, exist_ok=True)
    fd = os.open(DADOS, os.O_WRONLY | os.O_CREAT | os.O_TRUNC, 0o600)
    os.write(fd, f'[ PORTAINER ]\nDominio do portainer: {host}\n\nUsuario: {user}\n\nSenha: {pw}\n'.encode())
    os.close(fd)


def cmd_wait(host):
    base = 'https://' + host
    for _ in range(120):
        try:
            req(base, 'GET', '/api/system/status', timeout=10)
            print('Portainer respondendo')
            return
        except Exception:  # noqa: BLE001 (DNS, TLS ou Traefik ainda subindo)
            time.sleep(5)
    sys.exit(f'Portainer não respondeu em https://{host} (confira DNS e portas 80/443)')


def find_stack(base, token, name):
    return next((s for s in req(base, 'GET', '/api/stacks', token=token) if s['Name'] == name), None)


def cmd_deploy(name, path, env_file):
    content = render(path, env_file)
    base, token, ep, swarm = login()
    stack = find_stack(base, token, name)
    if stack:
        req(base, 'PUT', f"/api/stacks/{stack['Id']}?endpointId={ep}",
            {'StackFileContent': content, 'Env': stack.get('Env') or [], 'Prune': False, 'PullImage': True}, token=token, timeout=600)
        print(f'stack {name} atualizada')
    else:
        req(base, 'POST', f'/api/stacks/create/swarm/string?endpointId={ep}',
            {'Name': name, 'SwarmID': swarm, 'StackFileContent': content, 'Env': []}, token=token, timeout=600)
        print(f'stack {name} criada')


def cmd_exists(name):
    base, token, _, _ = login()
    sys.exit(0 if find_stack(base, token, name) else 1)


if __name__ == '__main__':
    a = sys.argv[1:]
    try:
        if a[:1] == ['init'] and len(a) == 4:
            cmd_init(*a[1:])
        elif a[:1] == ['wait'] and len(a) == 2:
            cmd_wait(a[1])
        elif a[:1] == ['deploy'] and len(a) == 4:
            cmd_deploy(*a[1:])
        elif a[:1] == ['ping']:
            login()
            print('Portainer: login, endpoint e Swarm ok')
        elif a[:1] == ['exists'] and len(a) == 2:
            cmd_exists(a[1])
        elif a[:1] == ['render'] and len(a) == 3:
            sys.stdout.write(render(a[1], a[2]))
        else:
            sys.exit(__doc__)
    except urllib.error.HTTPError as e:
        sys.exit(f'Portainer HTTP {e.code}: {e.read().decode(errors="replace")[:300]}')
