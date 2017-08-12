import argparse
import os
import subprocess

NEW_PROJECT_REPO = 'https://github.com/code0100fun/avr-rust-project.git'
NEW_PROJECT_BRANCH = 'project'

def execute(cmd, **kwargs):
    popen = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, universal_newlines=True, **kwargs)
    for stdout_line in iter(popen.stdout.readline, ''):
        yield stdout_line
    popen.stdout.close()
    return_code = popen.wait()
    if return_code:
        raise subprocess.CalledProcessError(return_code, cmd)

def print_it(it):
    for x in it:
        print x,

class NewAction(argparse.Action):
    def __call__(self, parser, namespace, values, option_string=None):
        _,project_name = values
        print('creating new project named  %s' % (project_name))
        project_path = '/usr/src/app/' + project_name
        print_it(execute(['git', 'clone', '-b', NEW_PROJECT_BRANCH, NEW_PROJECT_REPO, project_path]))
        print_it(execute(['rm', '-rf', project_path + '/.git']))
        print_it(execute([
            'find', '.', '-type', 'f', '-exec',
            'sed', '-i', 's/PROJECT_NAME/' + project_name + '/g', '{}', '+'
        ], cwd=project_path))
        print_it(execute(['git', 'init'], cwd=project_path))
        print_it(execute(['git', 'add', '.'], cwd=project_path))
        print_it(execute(['git', 'config', '--global', 'user.email', 'chase@code0100fun.com']))
        print_it(execute(['git', 'config', '--global', 'user.name', 'Chase McCarthy']))
        print_it(execute(['git', 'commit', '-m', 'Initial Commit'], cwd=project_path))

parser = argparse.ArgumentParser()
parser.add_argument('new', nargs='+', action=NewAction, help='create a new avr-rust project')

args = parser.parse_args()
